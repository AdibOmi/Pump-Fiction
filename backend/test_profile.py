"""
Test script for user profile endpoint
Tests that the profile API returns email and other user data correctly
"""
import requests
import json

BASE_URL = "http://localhost:8000"  # Change to your backend URL


def print_response(title, response):
    """Pretty print API response"""
    print(f"\n{'='*60}")
    print(f"{title}")
    print(f"{'='*60}")
    print(f"Status Code: {response.status_code}")
    try:
        print(f"Response: {json.dumps(response.json(), indent=2)}")
    except:
        print(f"Response: {response.text}")


def test_profile_endpoint():
    """Test profile endpoint with authentication"""
    
    print("\n🔹 Testing Profile Endpoint")
    print("="*60)
    
    # Step 1: Login to get access token
    print("\n📝 Step 1: Logging in to get access token...")
    login_data = {
        "email": "testuser@example.com",  # Change to your test user
        "password": "SecurePassword123!"   # Change to your test password
    }
    
    response = requests.post(f"{BASE_URL}/auth/login", json=login_data)
    print_response("LOGIN", response)
    
    if response.status_code != 200:
        print("\n❌ Login failed! Please check credentials or create a test user first.")
        print("\n💡 To create a test user, run:")
        print("   python backend/test_auth.py")
        return
    
    tokens = response.json()
    access_token = tokens.get("access_token")
    
    if not access_token:
        print("\n❌ No access token received!")
        return
    
    print(f"\n✅ Access token received: {access_token[:20]}...")
    
    # Step 2: Get user profile
    print("\n📝 Step 2: Getting user profile...")
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }
    
    response = requests.get(f"{BASE_URL}/profile/me", headers=headers)
    print_response("GET PROFILE", response)
    
    if response.status_code == 200:
        profile = response.json()
        print("\n✅ Profile retrieved successfully!")
        print("\n📊 Profile Data:")
        print(f"   • Email: {profile.get('email')}")
        print(f"   • Full Name: {profile.get('full_name')}")
        print(f"   • Phone: {profile.get('phone_number')}")
        print(f"   • User ID: {profile.get('user_id')}")
        print(f"   • Profile ID: {profile.get('id')}")
        print(f"   • Gender: {profile.get('gender')}")
        print(f"   • Weight: {profile.get('weight_kg')}")
        print(f"   • Height: {profile.get('height_cm')}")
        print(f"   • Fitness Goal: {profile.get('fitness_goal')}")
        
        # Verify email is present
        if profile.get('email'):
            print("\n✅ Email is present in profile response!")
        else:
            print("\n❌ Email is MISSING from profile response!")
            
    else:
        print("\n❌ Failed to get profile!")
    
    # Step 3: Update profile (optional)
    print("\n📝 Step 3: Testing profile update...")
    update_data = {
        "full_name": "Updated Test User",
        "phone_number": "+1234567890"
    }
    
    response = requests.put(f"{BASE_URL}/profile/me", json=update_data, headers=headers)
    print_response("UPDATE PROFILE", response)
    
    if response.status_code == 200:
        updated_profile = response.json()
        print("\n✅ Profile updated successfully!")
        print(f"   • New Full Name: {updated_profile.get('full_name')}")
        print(f"   • New Phone: {updated_profile.get('phone_number')}")
        print(f"   • Email (should still be present): {updated_profile.get('email')}")
    
    print("\n" + "="*60)
    print("✅ Test completed!")
    print("="*60)


if __name__ == "__main__":
    try:
        test_profile_endpoint()
    except Exception as e:
        print(f"\n❌ Error: {e}")
        print("\n💡 Make sure:")
        print("   1. Backend is running (python -m app.main)")
        print("   2. You have a test user account")
        print("   3. The BASE_URL is correct")
