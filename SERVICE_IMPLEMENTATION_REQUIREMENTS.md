# Service Implementation Requirements - Mobile vs Web POS

## Overview
The mobile app must implement the exact same service constraints as the web POS. This document specifies the required structure and behavior for each service.

---

## Service Definitions & Constraints

### 1. WASH Service
**Web POS Model:**
```typescript
wash: "off" | "basic" | "premium"
wash_cycles: 1 | 2 | 3  // Only relevant if wash != "off"
```

**Mobile Requirements:**
- 3-state selector: Off / Basic / Premium
- When wash != "off", show cycles selector: 1 / 2 / 3 cycles
- Price: depends on tier (basic vs premium) from services table
- **Service Type**: "wash"
- **Modifiers**: `{ wash_cycles: 1 | 2 | 3 }`

**Implementation**:
```dart
// In BasketService modifiers
{
  "service_type": "wash",
  "tier": "basic" | "premium",
  "base_price": <from DB>,
  "modifiers": { "wash_cycles": 1 | 2 | 3 }
}
```

---

### 2. DRY Service
**Web POS Model:**
```typescript
dry: "off" | "basic" | "premium"
additional_dry_time_minutes: 0 | 8 | 16 | 24  // 0, 8, 16, or 24 mins
```

**Mobile Requirements:**
- 3-state selector: Off / Basic / Premium
- Additional dry time incrementer: 0, 8, 16, 24 minutes (4 values)
- When dry is selected, show additional dry time selector
- Price includes base + (increments × price_per_increment)
- **Service Type**: "dry"
- **Modifiers**: `{ additional_dry_time_minutes: 0 | 8 | 16 | 24 }`

**Implementation**:
```dart
{
  "service_type": "dry",
  "tier": "basic" | "premium",
  "base_price": <from DB>,
  "modifiers": { "additional_dry_time_minutes": 0 | 8 | 16 | 24 }
}
```

---

### 3. SPIN Service
**Web POS Model:**
```typescript
spin: boolean  // On/Off toggle
```

**Mobile Requirements:**
- Boolean toggle: On / Off
- Only selectable if weight > 0kg
- No modifiers
- **Service Type**: "spin"

**Implementation**:
```dart
{
  "service_type": "spin",
  "base_price": <from DB>,
  // No tier, no modifiers for spin
}
```

---

### 4. IRON Service
**Web POS Model:**
```typescript
iron_weight_kg: 0 | 2 | 3 | 4 | 5 | 6 | 7 | 8  // 0 = off, min 2kg
```

**Mobile Requirements:**
- Weight selector with values: Off (0), 2kg, 3kg, 4kg, 5kg, 6kg, 7kg, 8kg
- **Constraint**: If weight > 0, must be >= 2kg (skip 1kg option)
- Only selectable if total basket weight >= iron_weight_kg
- Price: base_price × (iron_weight_kg / 2) or per-increments from modifiers
- **Service Type**: "iron"
- **Modifiers**: `{ iron_weight_kg: 0 | 2 | 3 | 4 | 5 | 6 | 7 | 8 }`

**Implementation**:
```dart
{
  "service_type": "iron",
  "base_price": <from DB>,
  "modifiers": { "iron_weight_kg": 0 | 2 | 3 | 4 | 5 | 6 | 7 | 8 }
}
```

---

### 5. FOLD Service
**Web POS Model:**
```typescript
fold: boolean  // On/Off toggle
```

**Mobile Requirements:**
- Boolean toggle: On / Off
- Only selectable if weight > 0kg
- No modifiers
- **Service Type**: "fold"

**Implementation**:
```dart
{
  "service_type": "fold",
  "base_price": <from DB>,
  // No tier, no modifiers for fold
}
```

---

### 6. PLASTIC BAGS (Retail Product)
**Web POS Model:**
```typescript
plastic_bags: number  // Quantity of plastic bags
```

**Mobile Requirements:**
- NOT a service in the basket - this is a retail product added in Step 2
- Quantity incrementer (0, 1, 2, 3, ...)
- Price per bag from products table
- Added to `selectedProducts` not basket services
- **Example**: Find "Plastic Bag" product, increment quantity

**Implementation**:
```dart
// In selectedProducts map
selectedProducts["plastic_bag_id"] = 3  // 3 bags
```

---

## Service Display Rules (Mobile)

### Step 1: Basket Configuration Screen

**Layout** (Left Column):
1. **Wash** section
   - Title: "Wash"
   - Display: 3 buttons "Off" / "Basic" / "Premium"
   - Show: Cycles selector (1/2/3) if wash != "off"
   - Price display
   - Enabled: Always (unless no weight)

2. **Dry** section
   - Title: "Dry"
   - Display: 3 buttons "Off" / "Basic" / "Premium"
   - Show: Additional dry time selector (0/8/16/24 min) if dry != "off"
   - Price display + increments cost
   - Enabled: Always (unless no weight)

3. **Spin** section
   - Title: "Spin"
   - Display: Toggle button (On/Off)
   - Enabled: Only if weight > 0kg

**Layout** (Right Column):
4. **Iron** section
   - Title: "Iron"
   - Display: Weight selector (Off, 2kg, 3kg, ..., 8kg)
   - Price display
   - Enabled: Only if weight >= selected_iron_weight_kg

5. **Fold** section
   - Title: "Fold"
   - Display: Toggle button (On/Off)
   - Enabled: Only if weight > 0kg

6. **Plastic Bags** section (Alternative: In Step 2 Products)
   - Title: "Plastic Bags"
   - Display: Quantity incrementer
   - Price: From products table

---

## Data Structure Alignment

### Current Mobile Basket Model (CORRECT ✓)
```dart
class Basket {
  final int basketNumber;
  final double weightKg;          // 0-8kg (auto-creates new basket if > 8kg)
  final List<BasketService> services;  // ✓ Services as list
  final String? notes;
  double? subtotal;
}
```

### Current BasketService Model (CORRECT ✓)
```dart
class BasketService {
  final String serviceType;       // wash, dry, spin, iron, fold ✓
  final String? tier;             // basic, premium ✓
  final double basePrice;         // ✓
  final Map<String, dynamic>? modifiers;  // wash_cycles, additional_dry_time_minutes, iron_weight_kg ✓
}
```

---

## State Provider Methods Needed

### Adding Services
```dart
// WASH: Add with cycles
void addWashService(String tier, int cycles) {
  // Create BasketService with modifiers: { wash_cycles: cycles }
  // Tier: "basic" or "premium"
}

// DRY: Add with additional dry time
void addDryService(String tier, int additionalDryTimeMinutes) {
  // Create BasketService with modifiers: { additional_dry_time_minutes }
  // Tier: "basic" or "premium"
}

// SPIN: Add toggle
void toggleSpinService() {
  // Add/remove spin service (no modifiers needed)
}

// IRON: Add with weight
void setIronWeight(int weightKg) {
  // Create BasketService with modifiers: { iron_weight_kg: weightKg }
  // If weightKg == 0, remove service (off)
  // If weightKg > 0, enforce >= 2kg
}

// FOLD: Add toggle
void toggleFoldService() {
  // Add/remove fold service (no modifiers needed)
}
```

### Removing Services
```dart
void removeServiceFromBasket(String serviceType) {
  // Remove service by type from active basket
  // E.g., "wash", "dry", "spin", "iron", "fold"
}
```

### Updating Service Modifiers
```dart
void updateServiceModifier(String serviceType, Map<String, dynamic> modifiers) {
  // Update existing service's modifiers
  // E.g., change wash_cycles from 1 to 2
  // E.g., change additional_dry_time_minutes from 0 to 8
  // E.g., change iron_weight_kg from 2 to 5
}
```

---

## Validation Rules

### Wash
- ✓ Can be off, basic, or premium
- ✓ Cycles only relevant if not "off"
- ✓ Cycles must be 1, 2, or 3

### Dry
- ✓ Can be off, basic, or premium
- ✓ Additional dry time only relevant if not "off"
- ✓ Additional dry time must be 0, 8, 16, or 24 minutes

### Spin
- ✓ Boolean on/off
- ✓ Only if weight > 0kg

### Iron
- ✓ Weight must be 0 (off), 2, 3, 4, 5, 6, 7, or 8 kg
- ✓ Cannot be 1kg (must skip to 2kg)
- ✓ Only if basket weight >= iron_weight_kg

### Fold
- ✓ Boolean on/off
- ✓ Only if weight > 0kg

### Plastic Bags
- ✓ Added as product in Step 2, not as basket service
- ✓ Quantity can be 0-unlimited

---

## Key Differences from Current Implementation

1. **Wash & Dry**: Currently simplified, need to support OFF state + tier selection + cycles/dry-time
2. **Iron**: Currently boolean, needs to be weight selector (0-8kg)
3. **Plastic Bags**: Should be product, not basket service
4. **Modifiers**: All services must store appropriate modifiers in BasketService.modifiers Map

---

## Next Steps

1. Update mobile_booking_baskets_screen.dart to display all 6 service sections with correct controls
2. Update mobile_booking_state_provider.dart methods to handle modifiers correctly
3. Ensure order payload builder calculates prices correctly based on modifiers
4. Test end-to-end order creation with all service combinations
