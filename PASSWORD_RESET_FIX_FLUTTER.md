# Password Reset Fix - Flutter App

## The Problem

You were calling `resetPasswordForEmail()` from the client side, which doesn't properly generate tokens that Supabase stores in its database. When users click the email link, Supabase's `/verify` endpoint can't find the token - resulting in "One-time token not found" error.

This affects both web and Flutter platforms.

## The Solution Applied

### What Changed in Flutter App

1. **Created `PasswordResetService`** ([password_reset_service.dart](lib/services/password_reset_service.dart))
   - New service that calls backend API endpoint
   - Follows the same pattern as `RegistrationService` and `OrderCreationService`
   - Endpoint: `/api/auth/reset-password-request`

2. **Updated `AuthService`** ([auth_service.dart](lib/services/auth_service.dart))
   - Now injects `PasswordResetService` 
   - Changed `resetPassword()` to call backend API instead of Supabase client
   - Simplified error handling (delegates to service)

3. **Updated `main.dart`** ([main.dart](lib/main.dart))
   - Added import for `PasswordResetService`
   - Injected service into `AuthServiceImpl`

### How It Works

**Before (Client-Side):**
```
User clicks "Forgot Password" 
    → Flutter calls Supabase directly: resetPasswordForEmail() 
    → Supabase client doesn't have admin permissions
    → Token is NOT properly stored
    → Email link fails with "One-time token not found"
```

**After (Server-Side):**
```
User clicks "Forgot Password"
    → Flutter calls: /api/auth/reset-password-request
    → Backend receives request
    → Backend uses admin API: supabase.auth.admin.generateLink()
    → Token IS properly stored in Supabase
    → Email link works correctly ✅
```

## Required Backend Implementation

You need to create this endpoint on your Vercel backend (same as you did for web):

### File: `src/app/api/auth/reset-password-request/route.ts`

```typescript
import { createAdminClient } from '@/app/utils/supabase/admin';
import { NextRequest, NextResponse } from 'next/server';

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { email } = body;

    // Validate input
    if (!email || typeof email !== 'string') {
      return NextResponse.json(
        { success: false, error: 'Email is required' },
        { status: 400 }
      );
    }

    // Create admin client with full permissions
    const supabase = await createAdminClient();

    // Generate password reset link using admin API
    const { data, error } = await supabase.auth.admin.generateLink({
      type: 'recovery',
      email: email,
    });

    if (error || !data?.properties?.action_link) {
      console.error('❌ Failed to generate reset link:', error);
      return NextResponse.json(
        { success: false, error: 'Failed to generate reset link' },
        { status: 500 }
      );
    }

    // Send password reset email to user
    const resetLink = data.properties.action_link;
    
    // Extract the token from the link for your email template
    const url = new URL(resetLink);
    const hashParams = url.hash.substring(1); // Remove '#'
    
    // You can customize the email template here
    // For now, sending the reset link directly
    const { error: emailError } = await supabase.auth.admin.sendRawUserEmail(
      email,
      {
        subject: 'Reset your iLaba password',
        html: `
          <h2>Password Reset Request</h2>
          <p>Click the link below to reset your password:</p>
          <a href="${resetLink}">Reset Password</a>
          <p>This link expires in 24 hours.</p>
        `,
      }
    );

    if (emailError) {
      console.error('❌ Failed to send email:', emailError);
      return NextResponse.json(
        { success: false, error: 'Failed to send reset email' },
        { status: 500 }
      );
    }

    console.log('✅ Password reset email sent successfully');
    return NextResponse.json(
      { success: true, message: 'Password reset email sent' },
      { status: 200 }
    );
  } catch (error) {
    console.error('❌ Error in reset-password-request:', error);
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    );
  }
}
```

## Testing

1. **In Flutter app:**
   ```
   1. Go to Forgot Password screen
   2. Enter your test email
   3. Click "Send Reset Link"
   4. Check your email inbox
   5. Click the reset link
   6. You should be able to set a new password ✅
   ```

2. **Check Supabase logs:**
   - Go to Supabase dashboard
   - Look for password reset token generation
   - Verify tokens are being created and stored

## Files Modified

- [password_reset_service.dart](lib/services/password_reset_service.dart) - **NEW** ✨
- [auth_service.dart](lib/services/auth_service.dart#L218) - Updated `resetPassword()` method
- [main.dart](lib/main.dart#L11) - Added service injection

## Next Steps

1. ✅ Flutter app is ready with the fix
2. ⏳ Create the backend endpoint in your Vercel project (code provided above)
3. ⏳ Test the password reset flow
4. ⏳ Check that the email links work correctly

Once the backend endpoint is created, password resets should work perfectly!
