-- Migration: Add phone_number column to users table
-- Date: 2025-10-14
-- Description: Adds optional phone_number field to users table for contact and notifications

-- Add phone_number column to users table
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS phone_number VARCHAR(20);

-- Add comment to document the column
COMMENT ON COLUMN public.users.phone_number IS 'Optional phone number for contact and notifications';

-- Optional: Create index for phone number lookups (if you plan to search by phone)
-- CREATE INDEX IF NOT EXISTS idx_users_phone_number ON public.users(phone_number) WHERE phone_number IS NOT NULL;

-- Verify the column was added
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name = 'users' 
  AND column_name = 'phone_number';
