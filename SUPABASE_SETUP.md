# Supabase Setup Instructions

## Step 1: Get Your Supabase Keys

1. Go to [supabase.com](https://supabase.com)
2. Sign in or create account
3. Create a new project (or use existing)
4. Go to **Settings → API**
5. Copy:
   - **Project URL** → SUPABASE_URL
   - **anon public** → SUPABASE_ANON_KEY

## Step 2: Create .env File

In your project root (`c:\Users\kizen\StudioProjects\iLaba\`), create `.env`:

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
```

**Never commit .env to git!** It's in `.gitignore` already.

## Step 3: Create Database Tables

In Supabase, go to **SQL Editor** and run:

```sql
-- Create users table
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone_number TEXT NOT NULL,
  address TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Create policy so users can only read their own data
CREATE POLICY "Users can read own data"
  ON users FOR SELECT
  USING (auth.uid() = id);

-- Create policy so users can update their own data
CREATE POLICY "Users can update own data"
  ON users FOR UPDATE
  USING (auth.uid() = id);
```

## Step 4: Install Dependencies

```bash
cd c:\Users\kizen\StudioProjects\iLaba
flutter pub get
```

## Step 5: How Sessions Work in Your App

### Login Flow

```
1. User enters email/password
2. App calls: authService.login(email, password)
3. Supabase authenticates with Firebase Auth
4. Returns JWT token (stored in Supabase session)
5. User session stored automatically by Supabase SDK
6. Login provider notifies UI
7. Navigate to HomeMenuScreen
```

### Automatic Session Persistence

- Supabase Flutter SDK automatically:
  - Stores the JWT token on device
  - Sends it with every request
  - Keeps it in memory during app session
  - Persists across app restarts

### Checking if User is Logged In

```dart
final isLoggedIn = await authService.isLoggedIn();
```

### Logout Flow

```
1. User taps logout
2. App calls: authService.logout()
3. JWT token is deleted from device
4. Session cleared from Supabase
5. Navigate back to LoginScreen
```

## Step 6: Test Login (Update LoginScreen)

You already have the UI, just need to wire it up. Update `lib/screens/login_screen.dart`:

```dart
import 'package:provider/provider.dart';
import 'package:ilaba/providers/auth_provider.dart';

// In your login button onPressed:
onPressed: () async {
  final authProvider = context.read<AuthProvider>();
  final success = await authProvider.login(
    emailController.text,
    passwordController.text,
  );

  if (success) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeMenuScreen()),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(text: authProvider.errorMessage),
    );
  }
}
```

## Key Points About Mobile Sessions

| Aspect            | Browser                | Mobile                                        |
| ----------------- | ---------------------- | --------------------------------------------- |
| **Storage**       | Browser automatically  | Your app code (SharedPreferences, Hive, etc.) |
| **Sending Token** | Browser automatic      | You send in headers                           |
| **Expiry**        | Browser clears         | Your app checks/refreshes                     |
| **Logout**        | Browser deletes cookie | Your app deletes token                        |
| **Cross-Device**  | Shared account         | Each device has own session                   |

Supabase SDK handles most of this for you automatically!

## Next: Wrap App with Provider

Update `main.dart`:

```dart
import 'package:provider/provider.dart';
import 'package:ilaba/providers/auth_provider.dart';
import 'package:ilaba/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // ... existing setup ...

  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(
        authService: AuthServiceImpl(
          supabaseClient: Supabase.instance.client,
        ),
      ),
      child: const MyApp(),
    ),
  );
}
```

That's it! Your app is now connected to Supabase! 🎉
