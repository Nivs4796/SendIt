# Supplementary Database Tables & Specifications

## Overview
This document provides additional database tables and specifications that were identified as missing from the initial backend-api-plan.md.

---

## 1. OTP Verifications Table

### Purpose
Store OTPs temporarily for phone verification during authentication.

### Schema
```sql
CREATE TABLE otp_verifications (\n  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone VARCHAR(15) NOT NULL,
  country_code VARCHAR(5) DEFAULT '+91',
  otp VARCHAR(6) NOT NULL,
  user_type VARCHAR(10), -- 'user' or 'pilot'
  is_verified BOOLEAN DEFAULT false,
  attempts INTEGER DEFAULT 0,
  max_attempts INTEGER DEFAULT 3,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_otp_phone ON otp_verifications(phone, expires_at);
CREATE INDEX idx_otp_expires ON otp_verifications(expires_at);
```

### Cleanup Strategy
- Delete verified OTPs after 24 hours
- Delete expired OTPs automatically (cron job every 5 mins)
- Rate limit: Max 3 OTPs per phone per hour

---

## 2. Admin Users Table

### Purpose
Store admin dashboard user accounts with role-based access control.

### Schema
```sql
CREATE TABLE admin_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  name VARCHAR(100) NOT NULL,
  role VARCHAR(20) DEFAULT 'viewer', -- super_admin, admin, support, viewer
  
  -- Permissions
  permissions JSONB, -- Detailed permissions JSON
  
  -- Status
  isActive BOOLEAN DEFAULT true,
  last_login TIMESTAMP,
  
  -- Security
  failed_login_attempts INTEGER DEFAULT 0,
  locked_until TIMESTAMP,
  two_factor_enabled BOOLEAN DEFAULT false,
  two_factor_secret TEXT,
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  created_by UUID REFERENCES admin_users(id)
);

CREATE INDEX idx_admin_email ON admin_users(email);
CREATE INDEX idx_admin_role ON admin_users(role);
```

### Role Permissions
```json
{
  "super_admin": ["all"],
  "admin": ["users:read", "users:write", "pilots:read", "pilots:write", "orders:read", "orders:write", "pricing:write", "analytics:read"],
  "support": ["users:read", "pilots:read", "orders:read", "orders:write", "support:write"],
  "viewer": ["users:read", "pilots:read", "orders:read", "analytics:read"]
}
```

---

## 3. Support Tickets Table

### Purpose
Manage user and pilot support requests.

### Schema
```sql
CREATE TABLE support_tickets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_number VARCHAR(20) UNIQUE NOT NULL,
  
  -- Requester
  user_id UUID REFERENCES users(id),
  pilot_id UUID REFERENCES pilots(id),
  requester_type VARCHAR(10), -- 'user' or 'pilot'
  
  -- Ticket Details
  category VARCHAR(50), -- 'account', 'order', 'payment', 'technical', 'other'
  priority VARCHAR(20) DEFAULT 'medium', -- 'low', 'medium', 'high', 'urgent'
  status VARCHAR(20) DEFAULT 'open', -- 'open', 'in_progress', 'resolved', 'closed'
  
  subject VARCHAR(200) NOT NULL,
  description TEXT NOT NULL,
  attachments JSONB, -- Array of file URLs
  
  -- Assignment
  assigned_to UUID REFERENCES admin_users(id),
  assigned_at TIMESTAMP,
  
  -- Related Entities
  order_id UUID REFERENCES orders(id),
  
  -- Resolution
  resolution TEXT,
  resolved_at TIMESTAMP,
  resolved_by UUID REFERENCES admin_users(id),
  
  -- Timestamps
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_tickets_user ON support_tickets(user_id);
CREATE INDEX idx_tickets_pilot ON support_tickets(pilot_id);
CREATE INDEX idx_tickets_status ON support_tickets(status);
CREATE INDEX idx_tickets_assigned ON support_tickets(assigned_to);
CREATE INDEX idx_tickets_created ON support_tickets(created_at DESC);
```

### Support Ticket Messages Table
```sql
CREATE TABLE ticket_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_id UUID REFERENCES support_tickets(id) ON DELETE CASCADE,
  
  sender_id UUID, -- Can be user, pilot, or admin
  sender_type VARCHAR(10), -- 'user', 'pilot', 'admin'
  
  message TEXT NOT NULL,
  attachments JSONB,
  is_internal BOOLEAN DEFAULT false, -- Internal admin notes
  
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_ticket_messages_ticket ON ticket_messages(ticket_id, created_at);
```

---

## 4. Audit Logs Table

### Purpose
Track all critical actions for security and compliance.

### Schema
```sql
CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Actor
  actor_id UUID, -- user_id, pilot_id, or admin_id
  actor_type VARCHAR(10), -- 'user', 'pilot', 'admin', 'system'
  actor_email VARCHAR(255),
  
  -- Action
  action VARCHAR(50) NOT NULL, -- 'create', 'update', 'delete', 'login', 'approve', etc.
  entity_type VARCHAR(50), -- 'user', 'order', 'pilot', 'pricing', etc.
  entity_id UUID,
  
  -- Details
  description TEXT,
  changes JSONB, -- Before/after state
  metadata JSONB, -- IP address, user agent, etc.
  
  -- Result
  success BOOLEAN DEFAULT true,
  error_message TEXT,
  
  -- Context
  ip_address INET,
  user_agent TEXT,
  
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_audit_actor ON audit_logs(actor_id, actor_type, created_at DESC);
CREATE INDEX idx_audit_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_action ON audit_logs(action, created_at DESC);
CREATE INDEX idx_audit_created ON audit_logs(created_at DESC);
```

### Example Audit Log Entries
```json
{
  "action": "pilot_approval",
  "entity_type": "pilot",
  "entity_id": "uuid",
  "changes": {
    "verification_status": {
      "before": "pending",
      "after": "approved"
    }
  },
  "metadata": {
    "ip": "192.168.1.1",
    "browser": "Chrome"
  }
}
```

---

## 5. App Versions Table

### Purpose
Track mobile app versions for force update and compatibility checks.

### Schema
```sql
CREATE TABLE app_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  app_type VARCHAR(10) NOT NULL, -- 'user' or 'pilot'
  platform VARCHAR(10) NOT NULL, -- 'ios' or 'android'
  
  version_number VARCHAR(20) NOT NULL, -- '1.2.3'
  build_number INTEGER NOT NULL,
  
  min_supported_version VARCHAR(20), -- Minimum version that can still work
  force_update BOOLEAN DEFAULT false,
  is_latest BOOLEAN DEFAULT false,
  
  release_notes TEXT,
  download_url TEXT,
  
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE UNIQUE INDEX idx_app_version_unique ON app_versions(app_type, platform, version_number);
CREATE INDEX idx_app_latest ON app_versions(app_type, platform, is_latest);
```

---

## 6. System Settings Table

### Purpose
Store configurable system-wide settings.

### Schema
```sql
CREATE TABLE system_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  setting_key VARCHAR(100) UNIQUE NOT NULL,
  setting_value JSONB NOT NULL,
  setting_type VARCHAR(20), -- 'string', 'number', 'boolean', 'json'
  
  description TEXT,
  is_public BOOLEAN DEFAULT false, -- Can be accessed by mobile apps
  
  updated_at TIMESTAMP DEFAULT NOW(),
  updated_by UUID REFERENCES admin_users(id)
);

CREATE INDEX idx_settings_key ON system_settings(setting_key);
CREATE INDEX idx_settings_public ON system_settings(is_public);
```

### Example Settings
```json
{
  "driver_search_radius_km": 10,
  "max_delivery_distance_km": 50,
  "order_timeout_mins": 30,
  "surge_pricing_enabled": true,
  "maintenance_mode": false,
  "referral_reward_amount": 50,
  "min_wallet_withdrawal": 500,
  "cgst_percentage": 9,
  "sgst_percentage": 9
}
```

---

## 7. Promotional Banners Table

### Purpose
Manage promotional banners/campaigns for mobile apps.

### Schema
```sql
CREATE TABLE promotional_banners (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  title VARCHAR(200) NOT NULL,
  description TEXT,
  image_url TEXT NOT NULL,
  
  target_app VARCHAR(10), -- 'user', 'pilot', 'both'
  target_screen VARCHAR(50), -- 'home', 'orders', 'profile', etc.
  
  action_type VARCHAR(20), -- 'none', 'deeplink', 'external_url', 'coupon'
  action_value TEXT, -- URL or coupon code
  
  priority INTEGER DEFAULT 0, -- Higher = shown first
  is_active BOOLEAN DEFAULT true,
  
  valid_from TIMESTAMP DEFAULT NOW(),
  valid_until TIMESTAMP,
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_banners_active ON promotional_banners(is_active, priority DESC);
CREATE INDEX idx_banners_target ON promotional_banners(target_app, target_screen);
```

---

## 8. Device Tokens Table

### Purpose
Store FCM device tokens for push notifications.

### Schema
```sql
CREATE TABLE device_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  user_id UUID REFERENCES users(id),
  pilot_id UUID REFERENCES pilots(id),
  user_type VARCHAR(10), -- 'user' or 'pilot'
  
  device_token TEXT NOT NULL,
  platform VARCHAR(10), -- 'ios' or 'android'
  device_info JSONB, -- Model, OS version, etc.
  
  is_active BOOLEAN DEFAULT true,
  last_used_at TIMESTAMP DEFAULT NOW(),
  
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_device_user ON device_tokens(user_id);
CREATE INDEX idx_device_pilot ON device_tokens(pilot_id);
CREATE INDEX idx_device_token ON device_tokens(device_token);
```

---

## 9. Surge Pricing Zones Table

### Purpose
Define geographic zones for surge pricing.

### Schema
```sql
CREATE TABLE surge_pricing_zones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  zone_name VARCHAR(100) NOT NULL,
  city VARCHAR(100) NOT NULL,
  
  -- Geographic boundary (polygon)
  boundary GEOGRAPHY(POLYGON) NOT NULL,
  
  -- Surge multiplier
  surge_multiplier DECIMAL(3,2) DEFAULT 1.00,
  
  -- Conditions
  is_active BOOLEAN DEFAULT true,
  applies_to_vehicle_types JSONB, -- Array of vehicle types
  
  -- Time-based surge
  active_hours JSONB, -- {"monday": ["08:00-10:00", "18:00-20:00"], ...}
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_surge_boundary ON surge_pricing_zones USING GIST(boundary);
CREATE INDEX idx_surge_active ON surge_pricing_zones(is_active);
```

---

## 10. Scheduled Jobs Table

### Purpose
Track background job executions.

### Schema
```sql
CREATE TABLE scheduled_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  job_name VARCHAR(100) NOT NULL,
  job_type VARCHAR(50), -- 'driver_matching', 'notification', 'analytics', etc.
  
  status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'processing', 'completed', 'failed'
  
  scheduled_for TIMESTAMP NOT NULL,
  started_at TIMESTAMP,
  completed_at TIMESTAMP,
  
  related_entity_id UUID, -- order_id, etc.
  related_entity_type VARCHAR(50),
  
  payload JSONB,
  result JSONB,
  error_message TEXT,
  
  retry_count INTEGER DEFAULT 0,
  max_retries INTEGER DEFAULT 3,
  
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_jobs_scheduled ON scheduled_jobs(scheduled_for, status);
CREATE INDEX idx_jobs_entity ON scheduled_jobs(related_entity_type, related_entity_id);
```

---

## API Endpoints for New Tables

### Admin Users
```
POST   /api/v1/admin/auth/login
POST   /api/v1/admin/auth/logout
GET    /api/v1/admin/users
POST   /api/v1/admin/users
PUT    /api/v1/admin/users/:id
DELETE /api/v1/admin/users/:id
```

### Support Tickets
```
GET    /api/v1/support/tickets
POST   /api/v1/support/tickets
GET    /api/v1/support/tickets/:id
PUT    /api/v1/support/tickets/:id
POST   /api/v1/support/tickets/:id/messages
GET    /api/v1/support/tickets/:id/messages
```

### Settings
```
GET    /api/v1/settings/public           # Mobile apps can access
GET    /api/v1/admin/settings             # All settings
PUT    /api/v1/admin/settings/:key
```

### Promotional Banners
```
GET    /api/v1/banners?app=user&screen=home
GET    /api/v1/admin/banners
POST   /api/v1/admin/banners
PUT    /api/v1/admin/banners/:id
DELETE /api/v1/admin/banners/:id
```

### App Versions
```
GET    /api/v1/app/version/check?app=user&platform=ios&version=1.2.3
POST   /api/v1/admin/app-versions
```

---

## Migration Strategy

### Phase 1 (MVP) - Add Now:
- [x] otp_verifications
- [x] admin_users
- [ ] device_tokens
- [ ] system_settings

### Phase 2 - Add Later:
- [ ] support_tickets
- [ ] ticket_messages
- [ ] promotional_banners
- [ ] app_versions

### Phase 3 - Advanced:
- [ ] audit_logs
- [ ] surge_pricing_zones
- [ ] scheduled_jobs

---

**Document Version:** 1.0  
**Last Updated:** 2026-01-29  
**Status:** Supplementary to backend-api-plan.md
