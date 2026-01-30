#!/bin/bash
# scripts/test-api.sh - SendIt API Testing Script

BASE_URL="http://localhost:5000/api/v1"
TOKEN=""

echo "🧪 SendIt API Test Suite"
echo "========================"
echo ""

# Health Check
echo "1. Health Check"
echo "---------------"
curl -s "$BASE_URL/health" | jq .
echo ""

# Get Vehicle Types (Public endpoint)
echo "2. Get Vehicle Types (Public)"
echo "-----------------------------"
curl -s "$BASE_URL/vehicles/types" | jq .
echo ""

# Send User OTP
echo "3. Send User OTP"
echo "----------------"
OTP_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/user/send-otp" \
  -H "Content-Type: application/json" \
  -d '{"phone": "+919876543210"}')
echo $OTP_RESPONSE | jq .
OTP=$(echo $OTP_RESPONSE | jq -r '.data.otp // empty')
echo ""

# Verify User OTP
if [ -n "$OTP" ]; then
  echo "4. Verify User OTP"
  echo "------------------"
  AUTH_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/user/verify-otp" \
    -H "Content-Type: application/json" \
    -d "{\"phone\": \"+919876543210\", \"otp\": \"$OTP\"}")
  echo $AUTH_RESPONSE | jq .
  TOKEN=$(echo $AUTH_RESPONSE | jq -r '.data.accessToken // empty')
  echo ""
fi

# Test Authenticated Endpoints (if token available)
if [ -n "$TOKEN" ]; then
  echo "5. Get User Profile (Authenticated)"
  echo "------------------------------------"
  curl -s "$BASE_URL/users/profile" \
    -H "Authorization: Bearer $TOKEN" | jq .
  echo ""

  echo "6. Create Address"
  echo "-----------------"
  ADDRESS_RESPONSE=$(curl -s -X POST "$BASE_URL/addresses" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
      "label": "Home",
      "address": "123 Test Street, MG Road",
      "city": "Ahmedabad",
      "state": "Gujarat",
      "pincode": "380001",
      "lat": 23.0225,
      "lng": 72.5714,
      "isDefault": true
    }')
  echo $ADDRESS_RESPONSE | jq .
  echo ""

  echo "7. Get All Addresses"
  echo "--------------------"
  curl -s "$BASE_URL/addresses" \
    -H "Authorization: Bearer $TOKEN" | jq .
  echo ""

  echo "8. Get User Bookings"
  echo "--------------------"
  curl -s "$BASE_URL/bookings/my-bookings" \
    -H "Authorization: Bearer $TOKEN" | jq .
  echo ""
fi

# Admin Login
echo "9. Admin Login"
echo "--------------"
ADMIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/admin/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@sendit.co.in", "password": "admin123"}')
echo $ADMIN_RESPONSE | jq .
ADMIN_TOKEN=$(echo $ADMIN_RESPONSE | jq -r '.data.accessToken // empty')
echo ""

# Test Admin Endpoints (if token available)
if [ -n "$ADMIN_TOKEN" ]; then
  echo "10. List Users (Admin)"
  echo "----------------------"
  curl -s "$BASE_URL/users" \
    -H "Authorization: Bearer $ADMIN_TOKEN" | jq .
  echo ""

  echo "11. List Pilots (Admin)"
  echo "-----------------------"
  curl -s "$BASE_URL/pilots" \
    -H "Authorization: Bearer $ADMIN_TOKEN" | jq .
  echo ""
fi

# Test Validation Errors
echo "12. Test Validation (Invalid Phone)"
echo "------------------------------------"
curl -s -X POST "$BASE_URL/auth/user/send-otp" \
  -H "Content-Type: application/json" \
  -d '{"phone": "invalid"}' | jq .
echo ""

echo "13. Test Validation (Missing Fields)"
echo "-------------------------------------"
curl -s -X POST "$BASE_URL/auth/admin/login" \
  -H "Content-Type: application/json" \
  -d '{}' | jq .
echo ""

echo "14. Test Unauthorized Access"
echo "----------------------------"
curl -s "$BASE_URL/users/profile" | jq .
echo ""

echo "✅ API Tests Complete"
echo ""
echo "📚 View API Documentation at: http://localhost:5000/api-docs"
