#!/bin/bash
# ============================================
# SendIt API Test Script
# ============================================
# This script tests all major API endpoints
# Usage: ./scripts/test-api.sh [base_url]
# ============================================

set -e

BASE_URL="${1:-http://localhost:5000/api/v1}"
TOKEN=""
ADMIN_TOKEN=""
USER_ID=""
ADDRESS_ID=""
BOOKING_ID=""
VEHICLE_TYPE_ID=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_test() { echo -e "\n${YELLOW}Testing: $1${NC}"; }
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }

if ! command -v jq &> /dev/null; then
    echo "jq is required. Install: brew install jq"
    exit 1
fi

# ============================================
# SYSTEM TESTS
# ============================================
print_header "SYSTEM TESTS"

print_test "Health Check"
HEALTH=$(curl -s "$BASE_URL/health")
if echo "$HEALTH" | jq -e '.success == true' > /dev/null 2>&1; then
    print_success "Health check passed"
    echo "$HEALTH" | jq .
else
    print_error "Health check failed"
fi

# ============================================
# AUTHENTICATION TESTS
# ============================================
print_header "AUTHENTICATION TESTS"

print_test "User Send OTP"
OTP_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/user/send-otp" \
  -H "Content-Type: application/json" \
  -d '{"phone": "+919876543210"}')

if echo "$OTP_RESPONSE" | jq -e '.success == true' > /dev/null 2>&1; then
    print_success "OTP sent"
    OTP=$(echo "$OTP_RESPONSE" | jq -r '.data.otp // empty')
    [ -n "$OTP" ] && echo "OTP: $OTP"
else
    print_error "Failed to send OTP"
fi

print_test "User Verify OTP"
if [ -n "$OTP" ]; then
    AUTH_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/user/verify-otp" \
      -H "Content-Type: application/json" \
      -d "{\"phone\": \"+919876543210\", \"otp\": \"$OTP\"}")

    if echo "$AUTH_RESPONSE" | jq -e '.success == true' > /dev/null 2>&1; then
        print_success "User logged in"
        TOKEN=$(echo "$AUTH_RESPONSE" | jq -r '.data.accessToken')
        USER_ID=$(echo "$AUTH_RESPONSE" | jq -r '.data.user.id')
    else
        print_error "OTP verification failed"
    fi
fi

print_test "Admin Login"
ADMIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/admin/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@sendit.co.in", "password": "admin123"}')

if echo "$ADMIN_RESPONSE" | jq -e '.success == true' > /dev/null 2>&1; then
    print_success "Admin logged in"
    ADMIN_TOKEN=$(echo "$ADMIN_RESPONSE" | jq -r '.data.accessToken')
else
    print_error "Admin login failed"
fi

# ============================================
# USER & ADDRESS TESTS
# ============================================
print_header "USER & ADDRESS TESTS"

if [ -n "$TOKEN" ]; then
    print_test "Get User Profile"
    curl -s "$BASE_URL/users/profile" -H "Authorization: Bearer $TOKEN" | jq '.data.user | {id, name, phone}'

    print_test "Create Address"
    ADDRESS=$(curl -s -X POST "$BASE_URL/addresses" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"label":"Home","address":"123 Test St","city":"Ahmedabad","state":"Gujarat","pincode":"380001","lat":23.02,"lng":72.57}')

    if echo "$ADDRESS" | jq -e '.success == true' > /dev/null 2>&1; then
        print_success "Address created"
        ADDRESS_ID=$(echo "$ADDRESS" | jq -r '.data.address.id')
    fi
fi

# ============================================
# VEHICLE & BOOKING TESTS
# ============================================
print_header "VEHICLE & BOOKING TESTS"

print_test "Get Vehicle Types"
TYPES=$(curl -s "$BASE_URL/vehicles/types")
if echo "$TYPES" | jq -e '.success == true' > /dev/null 2>&1; then
    print_success "Vehicle types retrieved"
    VEHICLE_TYPE_ID=$(echo "$TYPES" | jq -r '.data.types[0].id // empty')
    echo "$TYPES" | jq '.data.types[] | {name, basePrice}'
fi

# ============================================
# ADMIN TESTS
# ============================================
print_header "ADMIN TESTS"

if [ -n "$ADMIN_TOKEN" ]; then
    print_test "Dashboard Stats"
    curl -s "$BASE_URL/admin/dashboard" -H "Authorization: Bearer $ADMIN_TOKEN" | jq '.data | {totalUsers, totalPilots, totalBookings}'

    print_test "List Users"
    curl -s "$BASE_URL/admin/users?limit=3" -H "Authorization: Bearer $ADMIN_TOKEN" | jq '.data.users | length'

    print_test "List Pilots"
    curl -s "$BASE_URL/admin/pilots?limit=3" -H "Authorization: Bearer $ADMIN_TOKEN" | jq '.data.pilots | length'
fi

# ============================================
# WALLET & COUPON TESTS
# ============================================
print_header "WALLET & COUPON TESTS"

if [ -n "$TOKEN" ]; then
    print_test "Wallet Balance"
    curl -s "$BASE_URL/wallet/balance" -H "Authorization: Bearer $TOKEN" | jq '.data'

    print_test "Available Coupons"
    curl -s "$BASE_URL/coupons/available" -H "Authorization: Bearer $TOKEN" | jq '.data.coupons | length'
fi

# ============================================
# ERROR HANDLING TESTS
# ============================================
print_header "ERROR HANDLING TESTS"

print_test "404 Not Found"
curl -s "$BASE_URL/nonexistent" | jq '{success, code, message}'

print_test "401 Unauthorized"
curl -s "$BASE_URL/users/profile" | jq '{success, message}'

print_test "400 Validation Error"
curl -s -X POST "$BASE_URL/auth/user/send-otp" -H "Content-Type: application/json" -d '{"phone":"bad"}' | jq '{success, code, errors}'

# ============================================
# SUMMARY
# ============================================
print_header "TEST COMPLETE"
echo "Base URL: $BASE_URL"
echo "Swagger: ${BASE_URL%/api/v1}/api-docs"
