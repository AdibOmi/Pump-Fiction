-- Rollback Migration: Drop tracker tables
-- Description: Removes tracker tables and all related objects
-- Author: System
-- Date: 2025-10-19

-- ============================================
-- Drop RLS Policies for tracker_entries
-- ============================================
DROP POLICY IF EXISTS "Users can delete their own tracker entries" ON tracker_entries;
DROP POLICY IF EXISTS "Users can update their own tracker entries" ON tracker_entries;
DROP POLICY IF EXISTS "Users can insert their own tracker entries" ON tracker_entries;
DROP POLICY IF EXISTS "Users can view their own tracker entries" ON tracker_entries;


-- ============================================
-- Drop RLS Policies for trackers
-- ============================================
DROP POLICY IF EXISTS "Users can delete their own trackers" ON trackers;
DROP POLICY IF EXISTS "Users can update their own trackers" ON trackers;
DROP POLICY IF EXISTS "Users can insert their own trackers" ON trackers;
DROP POLICY IF EXISTS "Users can view their own trackers" ON trackers;


-- ============================================
-- Drop triggers
-- ============================================
DROP TRIGGER IF EXISTS update_tracker_entries_updated_at ON tracker_entries;
DROP TRIGGER IF EXISTS update_trackers_updated_at ON trackers;


-- ============================================
-- Drop tables (CASCADE will remove foreign keys)
-- ============================================
DROP TABLE IF EXISTS tracker_entries CASCADE;
DROP TABLE IF EXISTS trackers CASCADE;


-- ============================================
-- Drop function (optional - only if not used elsewhere)
-- ============================================
-- Uncomment if you want to remove the function completely
-- DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;


-- ============================================
-- Note: Indexes are automatically dropped with tables
-- ============================================
