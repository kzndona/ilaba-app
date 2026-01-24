# Email Receipt Setup Guide

## ✅ Setup Complete

You now have email receipt functionality set up with Resend:

### Files Created

1. **[src/app/api/email/send-receipt/route.ts](src/app/api/email/send-receipt/route.ts)** - Email API endpoint
2. **[src/app/utils/emailUtils.ts](src/app/utils/emailUtils.ts)** - Helper function to call the email API

### Environment Variable

✅ Already in your `.env.local`:
```
RESEND_API_KEY=re_ZeUUdhEV_AKNBZQufAYKFSxP7T1CSSz4m
```

### Important: Update Sender Email

In `src/app/api/email/send-receipt/route.ts`, change:
```typescript
from: "noreply@katflix.com", // UPDATE THIS
```

**To send emails, you need a verified domain in Resend:**
1. Go to [Resend Dashboard](https://resend.com/emails)
2. Click "Domains" → Add your domain
3. Follow verification steps (DNS records)
4. Once verified, use: `from: "noreply@yourdomain.com"`

**For testing before domain setup:**
- Use your own email that you'll verify in Resend
- Or use the default Resend test email: `from: "onboarding@resend.dev"`

---

## 🚀 How to Use in Your App

### 1. After Order Creation Success

In your mobile app order flow (after receiving `orderId`):

```typescript
import { sendReceiptEmail } from "@/src/app/utils/emailUtils";
import { generateCompactReceipt } from "@/src/app/in/pos/logic/receiptGenerator";

// After order is created successfully
const orderId = data.orderId;

// Generate receipt
const compactReceipt = generateCompactReceipt(
  orderId,
  new Date(),
  customer,
  productLines,
  basketLines,
  handling,
  { method: "gcash" },
  totals,
);

// Save receipt to server
await fetch("/api/receipts", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({
    receipt: compactReceipt,
    orderId,
  }),
});

// Send receipt email
if (customer.email_address) {
  await sendReceiptEmail({
    email: customer.email_address,
    orderId,
    receipt: compactReceipt,
    customerName: `${customer.first_name} ${customer.last_name}`,
  });
}
```

### 2. Error Handling

The `sendReceiptEmail` function doesn't throw - it returns success/error:

```typescript
const result = await sendReceiptEmail({...});

if (!result.success) {
  console.warn("Email failed:", result.error);
  // Email failure won't break order flow
}
```

---

## 📧 Email Content

The email sent includes:

- Personalized greeting
- Full receipt text (same as displayed on screen)
- Order ID
- HTML formatted for readability

---

## 🔒 Security Notes

- API key is in `.env.local` (never commit this!)
- Email sending happens server-side (safe)
- No customer data exposed to email service

---

## TODO: Domain Setup

When ready for production:
1. Add your domain to Resend
2. Update `from:` email in the endpoint
3. Test with real customer emails
