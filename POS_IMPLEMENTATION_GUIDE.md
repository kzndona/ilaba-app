# POS UI Implementation Guide

## 1. Handling Premium Basket Services Disabling Logic

### Overview
The basket pane has premium toggles for Wash and Dry services. The disabling logic prevents users from selecting services that:
- Have no weight in the basket (can't wash empty baskets)
- Are not active in the database
- Have no premium variant available

### Current Implementation Pattern

Located in `paneBaskets.tsx`, the `TileWithDuration` component accepts a `disabled` prop that uses this logic:

```typescript
// For non-premium services (basic services)
disabled={
  b.weightKg === 0 ||                           // No weight
  (!b.washPremium && !isServiceActive("wash"))  // Service not active
}

// For premium services
disabled={
  b.weightKg === 0 ||                              // No weight
  (b.washPremium && !isPremiumServiceActive("wash")) // Premium variant not active
}
```

### How to Understand the Premium Toggle

The premium toggle works like this:
1. User clicks Wash tile - `washCount` increases (basic wash selected)
2. If they click the premium toggle button → `washPremium` flips to `true`
3. Now the tile shows "(Prem)" and displays premium pricing
4. Disabled state checks if the premium variant exists and is active

### Key Helper Functions

```typescript
// Check if basic (non-premium) service is available
const isServiceActive = (serviceType: string): boolean => {
  const service = services.find(
    (s) =>
      s.service_type === serviceType &&
      !s.name.toLowerCase().includes("premium")  // Find non-premium version
  );
  return service?.is_active ?? false;
};

// Check if premium version is available
const isPremiumServiceActive = (serviceType: string): boolean => {
  const premiumService = services.find(
    (s) =>
      s.service_type === serviceType &&
      s.name.toLowerCase().includes("premium")  // Find premium version
  );
  return premiumService?.is_active ?? false;
};

// Get price based on premium flag
const getServicePrice = (
  serviceType: string,
  premium: boolean = false
): number => {
  const matches = services.filter((s) => s.service_type === serviceType);
  if (matches.length === 0) return 0;

  if (premium) {
    // Return premium service rate (higher price)
    return (
      matches.find((s) => s.name.toLowerCase().includes("premium"))
        ?.rate_per_kg ||
      matches[0]?.rate_per_kg ||
      0
    );
  }

  // Return basic service rate (lower price)
  return (
    matches.find((s) => !s.name.toLowerCase().includes("premium"))
      ?.rate_per_kg ||
    matches[0]?.rate_per_kg ||
    0
  );
};
```

### Implementation Checklist

When adding a new service type with premium variant:

1. **Database**: Add two service records
   - Basic: `name: "Wash"`, `service_type: "wash"`, `is_active: true`
   - Premium: `name: "Wash (Premium)"`, `service_type: "wash"`, `is_active: true`

2. **Add Basket Fields** (if needed):
   ```typescript
   // In types.ts - Basket interface
   servicePremium: boolean;  // true = premium, false = basic
   ```

3. **Add to Basket State**:
   ```typescript
   // In usePOSState.tsx - newBasket() function
   const newBasket = (index: number): Basket => ({
     // ... existing fields
     myServicePremium: false,  // Toggle field for premium
   });
   ```

4. **Add Increment/Decrement Logic**:
   ```typescript
   // In paneBaskets.tsx - add to the grid
   <TileWithDuration
     label="−"
     title="My Service"
     count={b.myServiceCount}
     serviceType="myservice"
     onClick={() => updateActiveBasket({ myServiceCount: Math.max(0, b.myServiceCount - 1) })}
     color="blue"
     getServicePrice={getServicePrice}
     isPremium={b.myServicePremium}
     disabled={
       b.weightKg === 0 ||
       (!b.myServicePremium && !isServiceActive("myservice")) ||
       (b.myServicePremium && !isPremiumServiceActive("myservice"))
     }
   />
   ```

5. **Add Premium Toggle Button**:
   ```typescript
   // After the increment/decrement tiles
   <button
     onClick={() => updateActiveBasket({ myServicePremium: !b.myServicePremium })}
     className={`col-span-1 p-3 rounded-lg transition ${
       b.myServicePremium
         ? "bg-purple-500 text-white"
         : "bg-gray-200 text-gray-700"
     }`}
   >
     {b.myServicePremium ? "Premium" : "Basic"}
   </button>
   ```

---

## 2. Loading Product Images in Products Pane

### Current Implementation

The products pane already supports images! Images are loaded from the `image_url` field:

```typescript
{p.image_url && (
  <img
    src={p.image_url}
    alt={p.item_name}
    className="w-20 h-20 object-cover rounded mb-2"
  />
)}
```

### How Images Work

1. **Database**: `products` table has `image_url` field
   - Store full URL or relative path to image
   - Example: `https://supabase.example.com/products/detergent.jpg`

2. **Supabase Storage Setup** (if not using external URLs):
   
   ```sql
   -- Create storage bucket (in Supabase dashboard or SQL)
   INSERT INTO storage.buckets (id, name, public) 
   VALUES ('product-images', 'product-images', true);
   
   -- Or via dashboard: Storage > New Bucket > product-images > Public
   ```

3. **Generate Image URLs** in your backend:
   
   ```typescript
   // When uploading product image
   const { data, error } = await supabase.storage
     .from('product-images')
     .upload(`products/${productId}.jpg`, file);
   
   // Get public URL
   const { data: { publicUrl } } = supabase.storage
     .from('product-images')
     .getPublicUrl(`products/${productId}.jpg`);
   
   // Save publicUrl to products.image_url in database
   await supabase
     .from('products')
     .update({ image_url: publicUrl })
     .eq('id', productId);
   ```

### Image Display Logic

**Current behavior in PaneProducts**:

```typescript
// Shows image if image_url exists and is not null
{p.image_url && (
  <img
    src={p.image_url}
    alt={p.item_name}
    className="w-20 h-20 object-cover rounded mb-2"
  />
)}

// If no image, just shows product name and price
```

### Image Loading Improvements

#### 1. Add Loading State

```typescript
const [imageLoadingStates, setImageLoadingStates] = React.useState<Record<string, boolean>>({});

const handleImageLoad = (productId: string) => {
  setImageLoadingStates(prev => ({
    ...prev,
    [productId]: true
  }));
};

// In JSX:
{p.image_url && (
  <div className="relative">
    {!imageLoadingStates[p.id] && (
      <div className="w-20 h-20 bg-gray-200 rounded animate-pulse" />
    )}
    <img
      src={p.image_url}
      alt={p.item_name}
      onLoad={() => handleImageLoad(p.id)}
      className={`w-20 h-20 object-cover rounded mb-2 transition ${
        imageLoadingStates[p.id] ? 'opacity-100' : 'opacity-0'
      }`}
      onError={(e) => {
        e.currentTarget.style.display = 'none'; // Hide broken images
      }}
    />
  </div>
)}
```

#### 2. Add Image Fallback Placeholder

```typescript
import { Package } from 'lucide-react';

// In product tile:
{p.image_url ? (
  <img
    src={p.image_url}
    alt={p.item_name}
    className="w-20 h-20 object-cover rounded mb-2"
    onError={(e) => {
      e.currentTarget.style.display = 'none';
      e.currentTarget.nextElementSibling?.classList.remove('hidden');
    }}
  />
) : null}

{!p.image_url && (
  <Package className="w-20 h-20 text-gray-300 mb-2" />
)}
```

#### 3. Add Image Caching for Performance

```typescript
// Optimize images with next/image
import Image from 'next/image';

<Image
  src={p.image_url}
  alt={p.item_name}
  width={80}
  height={80}
  className="rounded mb-2"
  placeholder="blur"  // Show blur while loading
  blurDataURL="data:image/svg+xml,..."
/>
```

### Image URL Formats

#### Option 1: Supabase Storage (Recommended)
```
https://[project].supabase.co/storage/v1/object/public/product-images/detergent.jpg
```

#### Option 2: External CDN
```
https://cdn.example.com/products/detergent.jpg
```

#### Option 3: Relative Path (if serving from public folder)
```
/product-images/detergent.jpg
```

### Troubleshooting

**Images not loading?**

1. Check browser console for errors
2. Verify `image_url` is not null in database
3. Test URL in new tab - does it load?
4. Check Supabase bucket permissions (should be public)
5. Check CORS settings if using external CDN

**Images showing but blurry?**

1. Upload higher resolution images (at least 200x200px)
2. Use `object-cover` in CSS for consistent sizing
3. Consider serving multiple resolutions for different screen sizes

### Complete Example Implementation

```typescript
"use client";

import React from "react";
import Image from "next/image";
import { Package } from "lucide-react";
import { Product } from "../logic/types";

type Props = {
  products: Product[];
  orderProductCounts: Record<string, number>;
  addProduct: (id: string) => void;
  removeProduct: (id: string) => void;
  onNext: () => void;
};

export default function PaneProducts({
  products,
  orderProductCounts,
  addProduct,
  removeProduct,
  onNext,
}: Props) {
  const [imageLoadingStates, setImageLoadingStates] = React.useState<Record<string, boolean>>({});

  return (
    <div>
      <h2 className="text-xl font-bold text-gray-900 mb-6">Products</h2>

      <div className="grid grid-cols-4 gap-3 mb-6">
        {products.map((p) => {
          const count = orderProductCounts[p.id] || 0;
          const isLoading = !imageLoadingStates[p.id];

          return (
            <React.Fragment key={p.id}>
              {/* Remove Tile */}
              <div
                className={`col-span-1 p-3 rounded-lg flex flex-col items-center justify-center cursor-pointer select-none transition shadow-md ${
                  count === 0
                    ? "bg-gray-100 opacity-40 pointer-events-none border border-gray-300"
                    : "bg-linear-to-br from-red-50 to-red-100 border-l-4 border-red-500 hover:shadow-lg"
                }`}
                onClick={() => removeProduct(p.id)}
                title={`Remove one ${p.item_name}`}
              >
                <div className="text-2xl font-bold mb-3 text-red-600">−</div>
                {p.image_url ? (
                  <>
                    {isLoading && (
                      <div className="w-20 h-20 bg-gray-200 rounded mb-2 animate-pulse" />
                    )}
                    <img
                      src={p.image_url}
                      alt={p.item_name}
                      className={`w-20 h-20 object-cover rounded mb-2 transition ${
                        isLoading ? 'hidden' : 'block'
                      }`}
                      onLoad={() => setImageLoadingStates(prev => ({ ...prev, [p.id]: true }))}
                      onError={(e) => e.currentTarget.style.display = 'none'}
                    />
                  </>
                ) : (
                  <Package className="w-20 h-20 text-gray-300 mb-2" />
                )}
                <div className="text-sm font-bold text-center mb-2 text-gray-900">
                  {p.item_name}
                </div>
                <div className="text-xs font-semibold text-red-700">({count})</div>
              </div>

              {/* Add Tile */}
              <div
                className="col-span-1 p-3 rounded-lg flex flex-col items-center justify-center cursor-pointer select-none transition shadow-md bg-linear-to-br from-green-50 to-green-100 border-l-4 border-green-500 hover:shadow-lg"
                onClick={() => addProduct(p.id)}
                title={`Add one ${p.item_name}`}
              >
                <div className="text-2xl font-bold mb-3 text-green-600">+</div>
                {p.image_url ? (
                  <>
                    {isLoading && (
                      <div className="w-20 h-20 bg-gray-200 rounded mb-2 animate-pulse" />
                    )}
                    <img
                      src={p.image_url}
                      alt={p.item_name}
                      className={`w-20 h-20 object-cover rounded mb-2 transition ${
                        isLoading ? 'hidden' : 'block'
                      }`}
                      onLoad={() => setImageLoadingStates(prev => ({ ...prev, [p.id]: true }))}
                      onError={(e) => e.currentTarget.style.display = 'none'}
                    />
                  </>
                ) : (
                  <Package className="w-20 h-20 text-gray-300 mb-2" />
                )}
                <div className="text-sm font-bold text-center mb-2 text-gray-900">
                  {p.item_name}
                </div>
                <div className="text-xs font-semibold text-green-700">
                  ₱{p.unit_price}
                </div>
              </div>
            </React.Fragment>
          );
        })}
      </div>

      {/* Selected Products Summary */}
      {Object.entries(orderProductCounts).length > 0 && (
        <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
          <div className="text-sm font-semibold text-gray-900 mb-3">
            Selected Products
          </div>
          <div className="space-y-2">
            {Object.entries(orderProductCounts).map(([pid, qty]) => {
              const p = products.find((x) => x.id === pid)!;
              return (
                <div key={pid} className="flex justify-between text-sm">
                  <div className="text-gray-700">
                    {p.item_name} <span className="text-gray-500">× {qty}</span>
                  </div>
                  <div className="font-semibold text-gray-900">
                    ₱{(p.unit_price * qty).toFixed(2)}
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      )}

      <button
        onClick={onNext}
        className="mt-6 w-full px-6 py-3 rounded-lg bg-blue-600 text-white font-bold hover:bg-blue-700 transition"
      >
        Continue to Pickup & Delivery
      </button>
    </div>
  );
}
```

---

## Summary

### Premium Services Pattern
- Use database to define basic and premium variants
- Toggle premium with `isPremium` flag on basket
- Disable based on: weight > 0, service is active, variant exists
- Show "(Prem)" label and adjusted pricing when premium is selected

### Product Images Pattern
- Store `image_url` in products table (full URL or relative path)
- Load from Supabase Storage for best performance
- Add loading placeholders and error handling
- Use fallback icons if image fails to load
- Consider Next.js Image component for optimization

---

**Created**: 2026-01-21  
**For**: POS Development Team  
**Status**: Ready for reference and implementation
