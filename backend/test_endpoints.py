"""
Quick test to check endpoints
"""
import requests

base_url = "http://localhost:8000"

try:
    # Get OpenAPI schema
    response = requests.get(f"{base_url}/openapi.json")
    if response.status_code == 200:
        paths = response.json()['paths']
        
        print("=" * 60)
        print("ALL /users/me/profile RELATED ENDPOINTS:")
        print("=" * 60)
        
        for path, methods in paths.items():
            if '/users/me/profile' in path:
                for method, details in methods.items():
                    print(f"\n{method.upper()} {path}")
                    print(f"  Summary: {details.get('summary', 'N/A')}")
                    print(f"  Tags: {details.get('tags', [])}")
        
        print("\n" + "=" * 60)
        print("ALL ENDPOINTS WITH 'users' IN PATH:")
        print("=" * 60)
        
        for path in sorted(paths.keys()):
            if 'users' in path.lower():
                methods = list(paths[path].keys())
                print(f"{', '.join([m.upper() for m in methods])} {path}")
                
except Exception as e:
    print(f"Error: {e}")
    print("\nMake sure backend is running on http://localhost:8000")
