# Journal API

Base path: `/journal`

## Create Session
POST `/journal/sessions`
Body (JSON):
- name: string

Response 200:
```
{
  id: number,
  name: string,
  cover_image_url: string | null,
  created_at: string
}
```

## List Sessions
GET `/journal/sessions`
Response 200: array of sessions

## Add Entry
POST `/journal/sessions/{session_id}/entries`
Form-Data (multipart):
- file: image/* (required)
- weight: number (optional)

Response 200:
```
{
  id: number,
  session_id: number,
  date: string,
  image_url: string,
  weight: number | null,
  created_at: string
}
```

## List Entries
GET `/journal/sessions/{session_id}/entries`
Response 200:
```
{
  entries: [ ... ]
}
```
