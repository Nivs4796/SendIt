import admin from 'firebase-admin';
import prisma from '../config/database';

// Initialize Firebase Admin (credentials loaded from env or service account)
let firebaseInitialized = false;

const initializeFirebase = () => {
  if (firebaseInitialized) return;
  
  try {
    // Check if FIREBASE_SERVICE_ACCOUNT env var exists
    const serviceAccount = process.env.FIREBASE_SERVICE_ACCOUNT;
    
    if (serviceAccount) {
      admin.initializeApp({
        credential: admin.credential.cert(JSON.parse(serviceAccount)),
      });
    } else {
      // Use application default credentials (for GCP deployment)
      admin.initializeApp({
        credential: admin.credential.applicationDefault(),
      });
    }
    
    firebaseInitialized = true;
    console.log('✅ Firebase Admin initialized');
  } catch (error) {
    console.error('❌ Firebase Admin initialization failed:', error);
  }
};

// Initialize on module load
initializeFirebase();

export const fcmService = {
  /**
   * Register FCM token for a user
   */
  async registerUserToken(userId: string, fcmToken: string) {
    return prisma.user.update({
      where: { id: userId },
      data: { fcmToken },
      select: { id: true, fcmToken: true },
    });
  },

  /**
   * Register FCM token for a pilot
   */
  async registerPilotToken(pilotId: string, fcmToken: string) {
    return prisma.pilot.update({
      where: { id: pilotId },
      data: { fcmToken },
      select: { id: true, fcmToken: true },
    });
  },

  /**
   * Clear FCM token (on logout)
   */
  async clearUserToken(userId: string) {
    return prisma.user.update({
      where: { id: userId },
      data: { fcmToken: null },
    });
  },

  async clearPilotToken(pilotId: string) {
    return prisma.pilot.update({
      where: { id: pilotId },
      data: { fcmToken: null },
    });
  },

  /**
   * Send push notification to a specific user
   */
  async sendToUser(userId: string, title: string, body: string, data?: Record<string, string>) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { fcmToken: true },
    });

    if (!user?.fcmToken) {
      console.log(`No FCM token for user ${userId}`);
      return null;
    }

    return this.sendNotification(user.fcmToken, title, body, data);
  },

  /**
   * Send push notification to a specific pilot
   */
  async sendToPilot(pilotId: string, title: string, body: string, data?: Record<string, string>) {
    const pilot = await prisma.pilot.findUnique({
      where: { id: pilotId },
      select: { fcmToken: true },
    });

    if (!pilot?.fcmToken) {
      console.log(`No FCM token for pilot ${pilotId}`);
      return null;
    }

    return this.sendNotification(pilot.fcmToken, title, body, data);
  },

  /**
   * Send notification to a specific FCM token
   */
  async sendNotification(token: string, title: string, body: string, data?: Record<string, string>) {
    if (!firebaseInitialized) {
      console.error('Firebase not initialized, skipping notification');
      return null;
    }

    try {
      const message: admin.messaging.Message = {
        token,
        notification: {
          title,
          body,
        },
        data: data || {},
        android: {
          priority: 'high',
          notification: {
            channelId: 'high_importance_channel',
            priority: 'high',
            sound: 'default',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      };

      const response = await admin.messaging().send(message);
      console.log('✅ Notification sent:', response);
      return response;
    } catch (error: any) {
      console.error('❌ Failed to send notification:', error);
      
      // Handle invalid token
      if (error.code === 'messaging/registration-token-not-registered') {
        // Token is invalid, clear it
        await prisma.user.updateMany({
          where: { fcmToken: token },
          data: { fcmToken: null },
        });
        await prisma.pilot.updateMany({
          where: { fcmToken: token },
          data: { fcmToken: null },
        });
      }
      
      return null;
    }
  },

  /**
   * Send notification to multiple tokens
   */
  async sendToMultiple(tokens: string[], title: string, body: string, data?: Record<string, string>) {
    if (!firebaseInitialized || tokens.length === 0) return null;

    try {
      const message: admin.messaging.MulticastMessage = {
        tokens,
        notification: {
          title,
          body,
        },
        data: data || {},
        android: {
          priority: 'high',
        },
      };

      const response = await admin.messaging().sendEachForMulticast(message);
      console.log(`✅ Notifications sent: ${response.successCount}/${tokens.length}`);
      return response;
    } catch (error) {
      console.error('❌ Failed to send multicast:', error);
      return null;
    }
  },

  /**
   * Send notification to a topic
   */
  async sendToTopic(topic: string, title: string, body: string, data?: Record<string, string>) {
    if (!firebaseInitialized) return null;

    try {
      const message: admin.messaging.Message = {
        topic,
        notification: {
          title,
          body,
        },
        data: data || {},
      };

      const response = await admin.messaging().send(message);
      console.log(`✅ Topic notification sent to ${topic}:`, response);
      return response;
    } catch (error) {
      console.error('❌ Failed to send to topic:', error);
      return null;
    }
  },

  /**
   * Notify user about booking status change
   */
  async notifyBookingStatus(userId: string, bookingId: string, status: string, pilotName?: string) {
    const messages: Record<string, { title: string; body: string }> = {
      ACCEPTED: {
        title: '🎉 Pilot Assigned!',
        body: `${pilotName || 'A pilot'} has accepted your delivery.`,
      },
      PICKED_UP: {
        title: '📦 Package Picked Up',
        body: 'Your package has been picked up and is on the way!',
      },
      DELIVERED: {
        title: '✅ Delivered!',
        body: 'Your package has been delivered successfully.',
      },
      CANCELLED: {
        title: '❌ Booking Cancelled',
        body: 'Your booking has been cancelled.',
      },
    };

    const msg = messages[status];
    if (!msg) return;

    return this.sendToUser(userId, msg.title, msg.body, {
      type: 'booking',
      id: bookingId,
      status,
    });
  },

  /**
   * Notify pilot about new job
   */
  async notifyNewJob(pilotId: string, bookingId: string, pickup: string, drop: string, fare: number) {
    return this.sendToPilot(
      pilotId,
      '🚀 New Delivery Request!',
      `₹${fare} | ${pickup} → ${drop}`,
      {
        type: 'job',
        id: bookingId,
      }
    );
  },
};

export default fcmService;
