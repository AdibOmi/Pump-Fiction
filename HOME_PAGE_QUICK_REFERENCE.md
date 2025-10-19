# 🎯 Home Page Features - Quick Reference

## ✅ What's New?

### 1️⃣ Tap to Update Weight
```
Current Card → Tap → Enter Weight → Save
```
- Opens dialog to update your weight
- Auto-creates "Body Weight" tracker if missing
- Updates instantly across the app

---

### 2️⃣ BMI-Based Suggested Weight
```
"Suggested" replaces "Goal"
Formula: 22 × (height_m)²
```
- Shows healthy target weight
- Based on WHO BMI recommendations
- Updates when height changes

---

### 3️⃣ Auto Workout Tracking
```
✓ Green checkmark = Workout logged today
◯ Gray outline = No workout yet
```
- Checks automatically on page load
- Searches last 30 days of logs
- Shows "Completed ✓" when done

---

### 4️⃣ Smart Protein Calculator
```
Target = Body Weight (kg) × 2.0g
Example: 70kg → 140g target
```
- Recommended for active individuals
- Updates when weight changes
- Shows formula for transparency

---

## 📱 How to Use

### Update Your Weight
1. Open **Home** page
2. Tap the **"Current"** card (has edit icon)
3. Enter your weight in kg
4. Tap **"Save"**
5. See instant update!

### Check Your Stats
- **Current**: Your latest tracked weight
- **Suggested**: Healthy BMI target (22 BMI)

### Track Habits
- **Workout today**: Auto-checks if you logged exercises
- **Protein intake**: Target based on your weight (2.0g per kg)

---

## 🔧 Technical Details

### Weight Priority
1. Tracker "Body Weight" → latest entry
2. Profile weight → fallback
3. Display as `XX.X kg`

### Workout Detection
- Queries WorkoutLogRepository
- Matches today's date (year/month/day)
- Updates icon color & text

### BMI Formula
```
Ideal BMI = 22 (middle of 18.5-24.9)
Suggested Weight = 22 × (height/100)²
```

### Protein Formula
```
Standard: 1.6-2.2g per kg
Our target: 2.0g per kg
Display: current/target g (weight × 2.0g)
```

---

## 🐛 Troubleshooting

### Weight not updating?
- Check tracker provider is loaded
- Verify "Body Weight" tracker exists
- Refresh page (pull down to reload)

### Workout not showing?
- Log at least one exercise today
- Wait for page to finish loading
- Check workout_logs table has entry

### Suggested weight seems off?
- Verify profile height is set correctly
- BMI of 22 is healthy average
- Talk to trainer for personalized goals

---

## 📊 Example Scenarios

### User Profile
- Height: 175cm
- Current Weight: 68kg (from tracker)
- Profile Weight: 70kg (old)

### Displayed Values
- **Current**: `68.0 kg` (uses tracker, not profile!)
- **Suggested**: `67.4 kg` (22 × 1.75² = 67.4)
- **Protein**: `0/136 g (68.0kg × 2.0g)`

---

## 🎨 UI Elements

### Current Card
- Title: "Current"
- Value: Latest weight
- Icon: Edit (tap to update)
- Style: Default theme

### Suggested Card
- Title: "Suggested"
- Value: BMI calculation
- Icon: None
- Style: Primary color accent

### Workout Row
- Title: "Workout today"
- Subtitle: "Completed ✓" or "Mark as done"
- Icon: Green ✓ or Gray ◯
- Loading: Spinner while checking

### Protein Row
- Title: "Protein intake"
- Subtitle: `0/target g (weight × 2.0g)`
- Icon: Add button (+ icon)
- Tap: Shows "Coming soon" message

---

## 🚀 Coming Soon

- [ ] Nutrition tracking (actual protein intake)
- [ ] Quick-add workout button
- [ ] Weight trend graph
- [ ] Water intake tracker
- [ ] Sleep quality tracker

---

**Status**: ✅ Live  
**Version**: 1.0  
**Last Updated**: December 2024
