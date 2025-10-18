-- Migration: switch journal images to base64 storage
-- Adds cover_image_base64 to journal_sessions and image_base64 to journal_entries
-- If previous columns exist (cover_image_url, cover_image_path, image_url, image_path), they are kept for backward compatibility.

ALTER TABLE journal_sessions
ADD COLUMN IF NOT EXISTS cover_image_base64 TEXT NULL;

ALTER TABLE journal_entries
ADD COLUMN IF NOT EXISTS image_base64 TEXT NOT NULL DEFAULT '';

-- Ensure NOT NULL without default if table is empty-safe; otherwise, keep default and remove it later manually if desired.
