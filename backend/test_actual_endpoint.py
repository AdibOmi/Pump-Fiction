"""
Test the actual endpoint response
"""
import requests

# Use the token from login
token = "eyJhbGciOiJIUzI1NiIsImtpZCI6ImVvSko3dU5ZTnplZE9FMUciLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL251dmpqa3Zjamxkcm14c2JraWJwLnN1cGFiYXNlLmNvL2F1dGgvdjEiLCJzdWIiOiJlYzgyN2NiNS1iZmNiLTRiODMtOWQ4ZC1kNjQzYjNhN2ZhMDQiLCJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoxNzYwODE2MzQ0LCJpYXQiOjE3NjA4MTI3NDQsImVtYWlsIjoiY2FwYWJsZW1hbm40ZHdpbkBnbWFpbC5jb20iLCJwaG9uZSI6IiIsImFwcF9tZXRhZGF0YSI6eyJwcm92aWRlciI6ImVtYWlsIiwicHJvdmlkZXJzIjpbImVtYWlsIl19LCJ1c2VyX21ldGFkYXRhIjp7ImVtYWlsIjoiY2FwYWJsZW1hbm40ZHdpbkBnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiZnVsbF9uYW1lIjoiQWhtZWQgU2hhZmluIFJ1aGFuIiwicGhvbmVfbnVtYmVyIjoiMDAwMDAwIiwicGhvbmVfdmVyaWZpZWQiOmZhbHNlLCJyb2xlIjoibm9ybWFsX3VzZXIiLCJzdWIiOiJlYzgyN2NiNS1iZmNiLTRiODMtOWQ4ZC1kNjQzYjNhN2ZhMDQifSwicm9sZSI6ImF1dGhlbnRpY2F0ZWQiLCJhYWwiOiJhYWwxIiwiYW1yIjpbeyJtZXRob2QiOiJwYXNzd29yZCIsInRpbWVzdGFtcCI6MTc2MDgxMjc0NH1dLCJzZXNzaW9uX2lkIjoiZmE3MTUzNWItMzg1ZS00YTM2LTk0OTQtMGU0OWE1YWZkODFjIiwiaXNfYW5vbnltb3VzIjpmYWxzZX0.pOAELHE9p-23wVlM6GQF5KQIGwojbdR-0kQweYPJx-4"

headers = {"Authorization": f"Bearer {token}"}

print("Testing GET /users/me/profile...")
print("=" * 60)

response = requests.get("http://localhost:8000/users/me/profile", headers=headers)
print(f"Status: {response.status_code}")
print(f"Response: {response.json()}")
print("\n" + "=" * 60)

# Check all registered routes
print("\nChecking all /users routes:")
print("=" * 60)
r = requests.get("http://localhost:8000/openapi.json")
paths = r.json()['paths']

for path in sorted(paths.keys()):
    if path.startswith('/users'):
        methods = list(paths[path].keys())
        print(f"{', '.join([m.upper() for m in methods])}: {path}")
