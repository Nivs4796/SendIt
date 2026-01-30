# Business Logic & Algorithms Specification

## 1. Overview

This document details the core business logic algorithms that power the SendIt platform, including driver matching, surge pricing, cancellation policies, and rating systems.

---

## 2. Driver Matching Algorithm

### 2.1 Overview
Find and assign the best available driver for an incoming order.

### 2.2 Algorithm Steps

```
1. Receive Order Creation Request
2. Extract pickup location (lat, lng)
3. Find Available Drivers
   - online_status = true
   - No active jobs OR can accept multiple jobs
   - Vehicle type matches order requirement
   - Within search radius
4. Calculate Distance & Sort
5. Apply Filters
6. Send Job Requests
7. Handle Acceptance/Rejection
```

### 2.3 Detailed Implementation

```typescript
// services/driverMatching.service.ts

interface MatchingParams {
  pickupLat: number;
  pickupLng: number;
  vehicleType: string;
  serviceType: string;
  orderId: string;
}

export class DriverMatchingService {
  private readonly SEARCH_RADIUS_KM = 10;
  private readonly MAX_DRIVERS_TO_NOTIFY = 5;
  private readonly ACCEPTANCE_TIMEOUT_SECONDS = 30;
  
  async findAndAssignDriver(params: MatchingParams): Promise<Pilot | null> {
    // Step 1: Find eligible drivers
    const eligibleDrivers = await this.findEligibleDrivers(params);
    
    if (eligibleDrivers.length === 0) {
      throw new AppError(503, 'ORD_3003', 'No drivers available');
    }
    
    // Step 2: Sort by preference
    const sortedDrivers = this.sortByPreference(eligibleDrivers, params);
    
    // Step 3: Send sequential job requests
    for (const driver of sortedDrivers.slice(0, this.MAX_DRIVERS_TO_NOTIFY)) {
      const accepted = await this.sendJobRequest(driver, params.orderId);
      
      if (accepted) {
        return driver;
      }
    }
    
    return null; // No driver accepted
  }
  
  private async findEligibleDrivers(params: MatchingParams): Promise<Pilot[]> {
    const query = `
      SELECT p.*, 
             ST_Distance(
               p.current_location,
               ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography
             ) / 1000 as distance_km
      FROM pilots p
      INNER JOIN vehicles v ON v.pilot_id = p.id
      WHERE p.online_status = true
        AND p.verification_status = 'approved'
        AND v.is_active = true
        AND v.vehicle_type = $3
        AND ST_DWithin(
          p.current_location,
          ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography,
          $4 * 1000  -- Convert km to meters
        )
      ORDER BY distance_km ASC
    `;
    
    return await db.query(query, [
      params.pickupLng,
      params.pickupLat,
      params.vehicleType,
      this.SEARCH_RADIUS_KM
    ]);
  }
  
  private sortByPreference(drivers: Pilot[], params: MatchingParams): Pilot[] {
    return drivers.sort((a, b) => {
      // Priority 1: Distance (weight: 50%)
      const distanceScore = (b.distance_km - a.distance_km) * 0.5;
      
      // Priority 2: Rating (weight: 30%)
      const ratingScore = (a.rating - b.rating) * 0.3;
      
      // Priority 3: Completion rate (weight: 20%)
      const completionRateA = a.completed_rides / a.total_rides;
      const completionRateB = b.completed_rides / b.total_rides;
      const completionScore = (completionRateA - completionRateB) * 0.2;
      
      return (distanceScore + ratingScore + completionScore);
    });
  }
  
  private async sendJobRequest(driver: Pilot, orderId: string): Promise<boolean> {
    return new Promise((resolve) => {
      // Send via Socket.io
      io.to(driver.socket_id).emit('job:new', {
        order_id: orderId,
        // ... order details
      });
      
      // Set timeout
      const timeout = setTimeout(() => {
        resolve(false); // Auto-decline after timeout
      }, this.ACCEPTANCE_TIMEOUT_SECONDS * 1000);
      
      // Listen for response
      const responseHandler = (response: { accepted: boolean }) => {
        clearTimeout(timeout);
        resolve(response.accepted);
      };
      
      io.once(`job:response:${orderId}`, responseHandler);
    });
  }
}
```

### 2.4 Search Radius Escalation

If no drivers found within initial radius, expand search:

| Attempt | Radius (km) | Wait Time (s) |
|---------|-------------|---------------|
| 1 | 5 | 30 |
| 2 | 10 | 30 |
| 3 | 15 | 60 |
| 4 | 20 | 60 |

After 4 attempts, return "No drivers available".

---

## 3. Dynamic Pricing Algorithm

### 3.1 Base Fare Calculation

```typescript
interface PricingParams {
  vehicleType: string;
  distanceKm: number;
  durationMins: number;
  pickupLat: number;
  pickupLng: number;
  isScheduled: boolean;
}

export class PricingService {
  async calculateFare(params: PricingParams): Promise<FareBreakdown> {
    // Step 1: Get base pricing for vehicle
    const vehiclePricing = await this.getVehiclePricing(params.vehicleType);
    
    // Step 2: Calculate base fare
    const baseFare = vehiclePricing.base_fare;
    const distanceFare = params.distanceKm * vehiclePricing.per_km_rate;
    
    // Step 3: Apply surge multiplier
    const surgeMultiplier = await this.getSurgeMultiplier(
      params.pickupLat,
      params.pickupLng
    );
    
    // Step 4: Calculate subtotal
    const subtotal = (baseFare + distanceFare) * surgeMultiplier;
    
    // Step 5: Add taxes
    const cgst = subtotal * 0.09; // 9%
    const sgst = subtotal * 0.09; // 9%
    
    // Step 6: Total
    const total = subtotal + cgst + sgst;
    
    return {
      base_fare: baseFare,
      distance_fare: distanceFare,
      surge_multiplier: surgeMultiplier,
      subtotal,
      cgst,
      sgst,
      total: Math.round(total * 100) / 100 // Round to 2 decimals
    };
  }
}
```

### 3.2 Surge Pricing Logic

```typescript
async getSurgeMultiplier(lat: number, lng: number): Promise<number> {
  // Check if location is in surge zone
  const surgeZone = await db.query(`
    SELECT surge_multiplier
    FROM surge_pricing_zones
    WHERE is_active = true
      AND ST_Contains(
        boundary,
        ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography
      )
    LIMIT 1
  `, [lng, lat]);
  
  if (surgeZone.length > 0) {
    return surgeZone[0].surge_multiplier;
  }
  
  // Check demand vs supply
  const demandSupplyRatio = await this.getDemandSupplyRatio(lat, lng);
  
  if (demandSupplyRatio > 3) return 2.0;   // High demand
  if (demandSupplyRatio > 2) return 1.5;   // Medium demand
  if (demandSupplyRatio > 1.5) return 1.2; // Slightly high demand
  
  return 1.0; // Normal pricing
}

async getDemandSupplyRatio(lat: number, lng: number): Promise<number> {
  const RADIUS_KM = 5;
  
  // Count active orders in area
  const activeOrders = await db.query(`
    SELECT COUNT(*) as count
    FROM orders
    WHERE status IN ('pending', 'searching_driver')
      AND ST_DWithin(
        ST_SetSRID(ST_MakePoint(pickup_lng, pickup_lat), 4326)::geography,
        ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography,
        $3 * 1000
      )
  `, [lng, lat, RADIUS_KM]);
  
  // Count available drivers in area
  const availableDrivers = await db.query(`
    SELECT COUNT(*) as count
    FROM pilots
    WHERE online_status = true
      AND ST_DWithin(
        current_location,
        ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography,
        $3 * 1000
      )
  `, [lng, lat, RADIUS_KM]);
  
  const demand = activeOrders[0].count;
  const supply = availableDrivers[0].count;
  
  if (supply === 0) return 5; // Maximum surge
  
  return demand / supply;
}
```

### 3.3 Pricing Rules

**Distance Brackets:**
- 0-5 km: Base fare + distance * rate
- 5-10 km: Base fare + 10% discount on distance rate
- 10+ km: Base fare + 15% discount on distance rate

**Time-based Multipliers:**
- Peak hours (8-10 AM, 6-8 PM): 1.2x
- Late night (11 PM - 5 AM): 1.3x
- Weekends: 1.1x

**Minimum Fare:** ₹40 for any trip

---

## 4. Cancellation Penalty Algorithm

### 4.1 User Cancellation Policy

```typescript
export class CancellationService {
  calculateUserPenalty(order: Order): number {
    const timeSinceCreation = Date.now() - order.created_at.getTime();
    const minutesElapsed = timeSinceCreation / (1000 * 60);
    
    // No penalty if cancelled within 2 minutes
    if (minutesElapsed <= 2) {
      return 0;
    }
    
    // Driver not assigned yet
    if (!order.pilot_id) {
      return 0;
    }
    
    // Driver assigned but not picked up
    if (order.status === 'assigned') {
      const timeSinceAssignment = Date.now() - order.driver_assigned_at.getTime();
      const minutesSinceAssignment = timeSinceAssignment / (1000 * 60);
      
      if (minutesSinceAssignment <= 3) {
        return order.total_amount * 0.2; // 20% of order value
      } else {
        return order.total_amount * 0.5; // 50% of order value
      }
    }
    
    // Package picked up - full charge
    if (order.status === 'picked_up' || order.status === 'in_transit') {
      return order.total_amount;
    }
    
    return 0;
  }
}
```

### 4.2 Cancellation Penalty Table

| Order Status | Time | User Penalty | Pilot Penalty |
|--------------|------|--------------|---------------|
| Pending | Any | ₹0 | N/A |
| Driver Assigned | < 3 mins | 20% of fare | ₹50 |
| Driver Assigned | > 3 mins | 50% of fare | ₹100 |
| Picked Up | Any | 100% of fare | ₹200 + rating impact |

### 4.3 Pilot Penalties

```typescript
async applyPilotPenalty(pilot: Pilot, order: Order, reason: string) {
  let penalty = 0;
  let ratingImpact = 0;
  
  switch (order.status) {
    case 'assigned':
      penalty = 50;
      ratingImpact = -0.1;
      break;
    case 'picked_up':
      penalty = 100;
      ratingImpact = -0.3;
      break;
    case 'in_transit':
      penalty = 200;
      ratingImpact = -0.5;
      // Temporary suspension
      await this.suspendPilot(pilot.id, 24); // 24 hours
      break;
  }
  
  // Deduct from wallet
  await this.deductFromWallet(pilot.id, penalty, reason);
  
  // Adjust rating
  await this.adjustRating(pilot.id, ratingImpact);
  
  // Track cancellation count
  await this.incrementCancellationCount(pilot.id);
  
  // Check if pilot needs warning/suspension
  const cancellationRate = await this.getCancellationRate(pilot.id);
  if (cancellationRate > 0.2) { // >20% cancellation rate
    await this.sendWarning(pilot.id);
  }
  if (cancellationRate > 0.4) { // >40% cancellation rate
    await this.suspendPilot(pilot.id, 168); // 7 days
  }
}
```

---

## 5. Rating & Review System

### 5.1 Pilot Rating Algorithm

```typescript
export class RatingService {
  async updatePilotRating(pilotId: string, newRating: number) {
    const pilot = await db.pilots.findById(pilotId);
    
    // Weighted average: Recent ratings have more weight
    const totalRides = pilot.total_rides;
    const currentRating = pilot.rating;
    
    // Weight: Last 100 rides count more
    const weight = Math.min(totalRides, 100);
    
    const updatedRating = (
      (currentRating * weight) + newRating
    ) / (weight + 1);
    
    await db.pilots.update(pilotId, {
      rating: Math.round(updatedRating * 100) / 100,
      total_rides: totalRides + 1
    });
    
    // Check if rating dropped significantly
    if (updatedRating < 4.0 && currentRating >= 4.0) {
      await this. sendLowRatingAlert(pilotId);
    }
    
    // Automatic suspension if rating < 3.5
    if (updatedRating < 3.5) {
      await this.suspendPilot(pilotId, 72, 'Low rating');
    }
  }
  
  async calculateAverageRating(pilotId: string, lastNRides: number = 100): Promise<number> {
    const recentOrders = await db.query(`
      SELECT AVG(pilot_rating) as avg_rating
      FROM (
        SELECT pilot_rating
        FROM orders
        WHERE pilot_id = $1
          AND pilot_rating IS NOT NULL
        ORDER BY delivered_at DESC
        LIMIT $2
      ) recent
    `, [pilotId, lastNRides]);
    
    return recentOrders[0].avg_rating || 0;
  }
}
```

### 5.2 Rating Weights

- **Recent Performance (60%):** Last 100 rides
- **Overall Performance (40%):** All-time average

### 5.3 Pilot Incentives Based on Rating

| Rating Range | Incentive |
|--------------|-----------|
| 4.8 - 5.0 | ₹500 bonus/month + Priority job allocation |
| 4.5 - 4.79 | ₹200 bonus/month |
| 4.0 - 4.49 | Standard |
| 3.5 - 3.99 | Warning + Training recommended |
| < 3.5 | Temporary suspension |

---

## 6. Coupon Validation Logic

```typescript
export class CouponService {
  async validateCoupon(
    code: string,
    userId: string,
    orderValue: number,
    vehicleType: string
  ): Promise<CouponValidation> {
    // Fetch coupon
    const coupon = await db.coupons.findByCode(code);
    
    if (!coupon) {
      throw new AppError(400, 'PAY_4006', 'Invalid coupon code');
    }
    
    // Check if active
    if (!coupon.is_active) {
      throw new AppError(400, 'PAY_4006', 'Coupon is not active');
    }
    
    // Check expiry
    const now = new Date();
    if (now < coupon.valid_from || now > coupon.valid_until) {
      throw new AppError(400, 'PAY_4007', 'Coupon has expired');
    }
    
    // Check usage limit
    if (coupon.usage_count >= coupon.usage_limit) {
      throw new AppError(400, 'PAY_4008', 'Coupon usage limit exceeded');
    }
    
    // Check per-user limit
    const userUsageCount = await db.coupon_usage.count({
      coupon_id: coupon.id,
      user_id: userId
    });
    
    if (userUsageCount >= coupon.per_user_limit) {
      throw new AppError(400, 'PAY_4008', 'You have already used this coupon');
    }
    
    // Check minimum order value
    if (orderValue < coupon.min_order_value) {
      throw new AppError(
        400,
        'PAY_4009',
        `Minimum order value of ₹${coupon.min_order_value} required`
      );
    }
    
    // Check applicable vehicle types
    if (coupon.applicable_vehicle_types) {
      if (!coupon.applicable_vehicle_types.includes(vehicleType)) {
        throw new AppError(400, 'PAY_4006', 'Coupon not applicable for this vehicle type');
      }
    }
    
    // Calculate discount
    let discount = 0;
    if (coupon.discount_type === 'percentage') {
      discount = (orderValue * coupon.discount_value) / 100;
      if (coupon.max_discount) {
        discount = Math.min(discount, coupon.max_discount);
      }
    } else { // fixed
      discount = coupon.discount_value;
    }
    
    return {
      valid: true,
      discount: Math.round(discount * 100) / 100,
      coupon_id: coupon.id
    };
  }
}
```

---

## 7. Referral Reward Logic

### 7.1 User Referral Flow

```
1. User A shares referral code with User B
2. User B signs up with code
3. User B completes first order
4. User A gets ₹50 credit
5. User B gets ₹50 credit
```

### 7.2 Implementation

```typescript
export class ReferralService {
async processReferral(referralCode: string, newUserId: string) {
    // Find referrer
    const referrer = await db.users.findByReferralCode(referralCode);
    
    if (!referrer) {
      throw new AppError(400, 'Invalid referral code');
    }
    
    // Create referral record
    await db.referrals.create({
      referrer_id: referrer.id,
      referrer_type: 'user',
      referee_id: newUserId,
      referee_type: 'user',
      referral_code: referralCode,
      reward_amount: 50,
      status: 'pending'
    });
  }
  
  async completeReferral(userId: string, orderId: string) {
    // Check if user was referred
    const referral = await db.referrals.findOne({
      referee_id: userId,
      status: 'pending'
    });
    
    if (!referral) return;
    
    // Credit both users
    await this.creditWallet(referral.referrer_id, 50, 'Referral reward');
    await this.creditWallet(referral.referee_id, 50, 'Welcome bonus');
    
    // Update referral status
    await db.referrals.update(referral.id, {
      status: 'completed',
      completed_at: new Date()
    });
  }
}
```

### 7.3 Pilot Referral Rewards

- Referrer: 100 reward points
- Referee: 100 reward points after completing 10 deliveries

---

## 8. Wallet Calculation Logic

### 8.1 Pilot Earnings per Order

```typescript
export class EarningsService {
  calculatePilotEarnings(order: Order): number {
    const baseFare = order.base_fare;
    const distanceFare = order.distance_fare;
    const subtotal = baseFare + distanceFare;
    
    // Platform commission (20%)
    const commission = subtotal * 0.2;
    
    // Pilot gets 80%
    const pilotEarnings = subtotal - commission;
    
    // Add incentives
    let incentive = 0;
    if (order.load_assist_required) {
      incentive += 20; // Loading assistance bonus
    }
    
    return pilotEarnings + incentive;
  }
}
```

### 8.2 Commission Breakdown

| Vehicle Type | Platform Commission |
|--------------|---------------------|
| Cycle/EV Cycle | 15% |
| 2 Wheeler | 20% |
| 3 Wheeler | 20% |
| Trucks | 25% |

---

## 9. Performance Metrics Calculation

### 9.1 Pilot Performance Score

```typescript
function calculatePerformanceScore(pilot: Pilot): number {
  const rating = pilot.rating / 5; // Normalize to 0-1
  const completionRate = pilot.completed_rides / pilot.total_rides;
  const acceptanceRate = pilot.accepted_jobs / pilot.total_job_offers;
  const cancellationRate = 1 - (pilot.cancelled_rides / pilot.total_rides);
  
  // Weighted score
  const score = (
    rating * 0.4 +
    completionRate * 0.3 +
    acceptanceRate * 0.2 +
    cancellationRate * 0.1
  ) * 100;
  
  return Math.round(score);
}
```

### 9.2 Metrics Tracked

- **Acceptance Rate:** Jobs accepted / Jobs offered
- **Completion Rate:** Completed / Total accepted
- **Cancellation Rate:** Cancelled / Total accepted
- **Average Rating:** Weighted average of last 100 rides
- **On-time Rate:** Delivered on-time / Total delivered

---

**Document Version:** 1.0  
**Last Updated:** 2026-01-29  
**Status:** Production Ready
