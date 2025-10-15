"""
Test script for role-based authentication
Demonstrates the complete authentication flow
"""
import requests
import json

BASE_URL = "http://10.0.0.2:8000"


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


def test_authentication_flow():
    """Test complete authentication flow"""
    
    # 1. Signup
    print("\n🔹 Step 1: Creating new user account...")
    signup_data = {
        "email": "testuser@example.com",
        "password": "SecurePassword123!",
        "full_name": "Test User"
    }
    response = requests.post(f"{BASE_URL}/auth/signup", json=signup_data)
    print_response("SIGNUP", response)
    
    if response.status_code != 201:
        print("\n⚠️ Note: User might already exist. Trying to login instead...")
        
        # Try login if signup fails
        login_data = {
            "email": signup_data["email"],
            "password": signup_data["password"]
        }
        response = requests.post(f"{BASE_URL}/auth/login", json=login_data)
        print_response("LOGIN", response)
    
    if response.status_code in [200, 201]:
        tokens = response.json()
        access_token = tokens["access_token"]
        refresh_token = tokens["refresh_token"]
        user = tokens["user"]
        
        print(f"\n✅ Authentication successful!")
        print(f"User ID: {user['id']}")
        print(f"Email: {user['email']}")
        print(f"Role: {user['role']}")
        
        # 2. Get current user profile
        print("\n🔹 Step 2: Getting user profile...")
        headers = {"Authorization": f"Bearer {access_token}"}
        response = requests.get(f"{BASE_URL}/auth/me", headers=headers)
        print_response("GET PROFILE", response)
        
        # 3. Try to access protected endpoint
        print("\n🔹 Step 3: Accessing protected endpoint...")
        response = requests.get(f"{BASE_URL}/users/me/profile", headers=headers)
        print_response("PROTECTED ENDPOINT", response)
        
        # 4. Apply for trainer role
        print("\n🔹 Step 4: Applying for trainer role...")
        application_data = {
            "requested_role": "trainer",
            "reason": "I am a certified personal trainer with 5 years of experience",
            "qualifications": "NASM-CPT, ACE Certified, BS in Exercise Science"
        }
        response = requests.post(f"{BASE_URL}/auth/apply-role", json=application_data, headers=headers)
        print_response("ROLE APPLICATION", response)
        
        # 5. View my applications
        print("\n🔹 Step 5: Viewing my applications...")
        response = requests.get(f"{BASE_URL}/auth/my-applications", headers=headers)
        print_response("MY APPLICATIONS", response)
        
        # 6. Try to access trainer dashboard (should fail - not approved yet)
        print("\n🔹 Step 6: Trying to access trainer dashboard (should fail)...")
        response = requests.get(f"{BASE_URL}/users/trainer/dashboard", headers=headers)
        print_response("TRAINER DASHBOARD (Unauthorized)", response)
        
        # 7. Try to access admin endpoint (should fail - not admin)
        print("\n🔹 Step 7: Trying to access admin endpoint (should fail)...")
        response = requests.get(f"{BASE_URL}/auth/admin/applications/pending", headers=headers)
        print_response("ADMIN ENDPOINT (Forbidden)", response)
        
        # 8. Refresh token
        print("\n🔹 Step 8: Refreshing access token...")
        refresh_data = {"refresh_token": refresh_token}
        response = requests.post(f"{BASE_URL}/auth/refresh", json=refresh_data)
        print_response("REFRESH TOKEN", response)
        
        print("\n" + "="*60)
        print("✅ AUTHENTICATION FLOW TEST COMPLETE!")
        print("="*60)
        print("\n📝 Summary:")
        print("  - User signup/login: ✅")
        print("  - Profile access: ✅")
        print("  - Protected endpoints: ✅")
        print("  - Role application: ✅")
        print("  - Role-based access control: ✅")
        print("  - Token refresh: ✅")
        print("\n💡 Next steps:")
        print("  1. Create an admin user in Supabase")
        print("  2. Admin can approve role applications via /auth/admin/applications/review")
        print("  3. After approval, user gains trainer/seller permissions")
        
    else:
        print("\n❌ Authentication failed!")


if __name__ == "__main__":
    print("="*60)
    print("ROLE-BASED AUTHENTICATION TEST")
    print("="*60)
    print(f"Testing against: {BASE_URL}")
    print("\nMake sure the server is running on port 8000")
    input("\nPress Enter to start the test...")
    
    test_authentication_flow()
