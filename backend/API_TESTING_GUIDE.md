# AI Chat API Testing Guide

## Prerequisites

You need:
1. ✅ Access token from login
2. ✅ Session ID from creating a session

---

## Complete Testing Flow

### Step 1: Login (Get Access Token) ✅

```http
POST http://localhost:8000/auth/login
Content-Type: application/json

{
  "email": "your@email.com",
  "password": "yourpassword"
}
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "user": {
    "id": "ec827cb5-bfcb-4b83-9d8d-d643b3a7fa04",
    "email": "your@email.com"
  }
}
```

**Save:** `access_token`

---

### Step 2: Create a Chat Session ✅ (You already did this!)

```http
POST http://localhost:8000/ai-chat/sessions
Authorization: Bearer YOUR_ACCESS_TOKEN
Content-Type: application/json

{
  "title": "Rumman Name Meaning"
}
```

**Response:**
```json
{
  "id": "09d203a5-e118-45b4-941b-b39da154cbb6",
  "user_id": "ec827cb5-bfcb-4b83-9d8d-d643b3a7fa04",
  "title": "Rumman Name Meaning",
  "last_message_at": "2025-10-15T12:45:00",
  "is_archived": false,
  "created_at": "2025-10-15T12:45:00",
  "updated_at": "2025-10-15T12:45:00"
}
```

**Save:** `session_id` = `"09d203a5-e118-45b4-941b-b39da154cbb6"`

---

### Step 3: Send a Message to the AI 🔥

This is where the magic happens! Send your question and get an AI response.

```http
POST http://localhost:8000/ai-chat/sessions/09d203a5-e118-45b4-941b-b39da154cbb6/messages
Authorization: Bearer YOUR_ACCESS_TOKEN
Content-Type: application/json

{
  "content": "What does the name Rumman mean?"
}
```

**Expected Response:**
```json
{
  "user_message": {
    "id": "abc123...",
    "session_id": "09d203a5-e118-45b4-941b-b39da154cbb6",
    "role": "user",
    "content": "What does the name Rumman mean?",
    "tokens_used": null,
    "model_version": null,
    "safety_flag": false,
    "disclaimer_shown": false,
    "created_at": "2025-10-15T12:46:00"
  },
  "assistant_message": {
    "id": "def456...",
    "session_id": "09d203a5-e118-45b4-941b-b39da154cbb6",
    "role": "assistant",
    "content": "Rumman is an Arabic name that means 'pomegranate'...",
    "tokens_used": 150,
    "model_version": "gemini-1.5-flash",
    "safety_flag": false,
    "disclaimer_shown": false,
    "created_at": "2025-10-15T12:46:02"
  }
}
```

**What happens:**
1. Your message is saved to the database
2. Message is sent to Google Gemini AI
3. AI generates a response
4. AI response is saved to the database
5. Both messages are returned to you

---

### Step 4: Send Another Message (Continue Conversation)

```http
POST http://localhost:8000/ai-chat/sessions/09d203a5-e118-45b4-941b-b39da154cbb6/messages
Authorization: Bearer YOUR_ACCESS_TOKEN
Content-Type: application/json

{
  "content": "Is Rumman a common name?"
}
```

**Response:** Same format as Step 3

---

### Step 5: Get Full Session History

See all messages in the conversation:

```http
GET http://localhost:8000/ai-chat/sessions/09d203a5-e118-45b4-941b-b39da154cbb6
Authorization: Bearer YOUR_ACCESS_TOKEN
```

**Expected Response:**
```json
{
  "id": "09d203a5-e118-45b4-941b-b39da154cbb6",
  "user_id": "ec827cb5-bfcb-4b83-9d8d-d643b3a7fa04",
  "title": "Rumman Name Meaning",
  "last_message_at": "2025-10-15T12:47:00",
  "is_archived": false,
  "created_at": "2025-10-15T12:45:00",
  "updated_at": "2025-10-15T12:47:00",
  "messages": [
    {
      "id": "abc123...",
      "role": "user",
      "content": "What does the name Rumman mean?",
      "created_at": "2025-10-15T12:46:00"
    },
    {
      "id": "def456...",
      "role": "assistant",
      "content": "Rumman is an Arabic name that means 'pomegranate'...",
      "created_at": "2025-10-15T12:46:02"
    },
    {
      "id": "ghi789...",
      "role": "user",
      "content": "Is Rumman a common name?",
      "created_at": "2025-10-15T12:47:00"
    },
    {
      "id": "jkl012...",
      "role": "assistant",
      "content": "Rumman is moderately common in Arabic-speaking countries...",
      "created_at": "2025-10-15T12:47:02"
    }
  ]
}
```

---

### Step 6: List All Your Sessions

```http
GET http://localhost:8000/ai-chat/sessions
Authorization: Bearer YOUR_ACCESS_TOKEN
```

**Expected Response:**
```json
[
  {
    "id": "09d203a5-e118-45b4-941b-b39da154cbb6",
    "user_id": "ec827cb5-bfcb-4b83-9d8d-d643b3a7fa04",
    "title": "Rumman Name Meaning",
    "last_message_at": "2025-10-15T12:47:00",
    "is_archived": false,
    "created_at": "2025-10-15T12:45:00",
    "updated_at": "2025-10-15T12:47:00"
  },
  {
    "id": "another-session-id...",
    "title": "Workout Tips",
    "last_message_at": "2025-10-14T10:00:00",
    ...
  }
]
```

---

### Step 7: Create Another Session (Optional)

```http
POST http://localhost:8000/ai-chat/sessions
Authorization: Bearer YOUR_ACCESS_TOKEN
Content-Type: application/json

{
  "title": "Fitness Questions"
}
```

Then send messages to this new session:

```http
POST http://localhost:8000/ai-chat/sessions/{NEW_SESSION_ID}/messages
Authorization: Bearer YOUR_ACCESS_TOKEN
Content-Type: application/json

{
  "content": "What's the best way to build muscle?"
}
```

---

### Step 8: Archive a Session

```http
POST http://localhost:8000/ai-chat/sessions/09d203a5-e118-45b4-941b-b39da154cbb6/archive
Authorization: Bearer YOUR_ACCESS_TOKEN
```

**Response:**
```json
{
  "message": "Session archived successfully"
}
```

---

### Step 9: Get Only Archived Sessions

```http
GET http://localhost:8000/ai-chat/sessions?is_archived=true
Authorization: Bearer YOUR_ACCESS_TOKEN
```

---

### Step 10: Delete a Session

```http
DELETE http://localhost:8000/ai-chat/sessions/09d203a5-e118-45b4-941b-b39da154cbb6
Authorization: Bearer YOUR_ACCESS_TOKEN
```

**Response:** 204 No Content

**Note:** This permanently deletes the session and ALL its messages!

---

## Testing Tools

### Option 1: Using cURL (Command Line)

**Replace these values:**
- `YOUR_ACCESS_TOKEN` - from Step 1
- `YOUR_SESSION_ID` - from Step 2

```bash
# Send a message
curl -X POST http://localhost:8000/ai-chat/sessions/YOUR_SESSION_ID/messages \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"content": "What does the name Rumman mean?"}'
```

---

### Option 2: Using Postman/Insomnia

1. **Set Authorization Header:**
   - Type: Bearer Token
   - Token: `YOUR_ACCESS_TOKEN`

2. **Set Content-Type Header:**
   - Key: `Content-Type`
   - Value: `application/json`

3. **Create Request:**
   - Method: `POST`
   - URL: `http://localhost:8000/ai-chat/sessions/YOUR_SESSION_ID/messages`
   - Body (JSON):
     ```json
     {
       "content": "What does the name Rumman mean?"
     }
     ```

---

### Option 3: Using Browser (Swagger UI)

1. Go to: http://localhost:8000/docs
2. Click **Authorize** button (top right)
3. Enter: `Bearer YOUR_ACCESS_TOKEN`
4. Click **Authorize**
5. Scroll to **AI Chat** section
6. Try the endpoints interactively!

---

## Quick Test Sequence

Here's a quick test you can copy-paste (replace YOUR_ACCESS_TOKEN and YOUR_SESSION_ID):

```bash
# 1. Send first message
curl -X POST http://localhost:8000/ai-chat/sessions/YOUR_SESSION_ID/messages \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"content": "What does the name Rumman mean?"}'

# 2. Send second message
curl -X POST http://localhost:8000/ai-chat/sessions/YOUR_SESSION_ID/messages \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"content": "Tell me more about its origin"}'

# 3. Get full conversation history
curl -X GET http://localhost:8000/ai-chat/sessions/YOUR_SESSION_ID \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"

# 4. List all sessions
curl -X GET http://localhost:8000/ai-chat/sessions \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

---

## Expected AI Responses

Since you're using Gemini AI with the fitness coaching system prompt, the AI will:

1. ✅ Answer questions helpfully
2. ✅ Provide fitness and health advice (primary purpose)
3. ✅ Add medical disclaimers when discussing injuries/pain
4. ✅ Be supportive and motivating

---

## Troubleshooting

### Error: "Session not found"
- Check your session ID is correct
- Make sure you're using YOUR access token (not someone else's)

### Error: "Unauthorized" / 401
- Your access token expired or is invalid
- Login again to get a fresh token

### Error: "Gemini API error"
- Check your GEMINI_API_KEY in .env
- Verify you have API quota remaining

### No AI response / Empty response
- Check server logs for errors
- Verify Gemini API key is valid
- Check internet connection

---

## What to Test

- [x] Create session ✅ (You did this!)
- [ ] Send a message and get AI response
- [ ] Send multiple messages in same session
- [ ] Get session history
- [ ] List all sessions
- [ ] Create multiple sessions
- [ ] Archive a session
- [ ] Delete a session
- [ ] Test medical disclaimer (ask about injury/pain)

---

**Next Step:** Send your first message to the AI! Use the session ID you just created.

Let me know what response you get! 🚀
