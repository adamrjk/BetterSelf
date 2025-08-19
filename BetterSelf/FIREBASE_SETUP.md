# Firebase Storage Setup for BetterSelf

## Prerequisites
- Firebase project created at [Firebase Console](https://console.firebase.google.com/)
- iOS app registered in Firebase project
- `GoogleService-Info.plist` file downloaded and added to your project

## Setup Steps

### 1. Firebase Console Configuration
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Storage** in the left sidebar
4. Click **Get Started**
5. Choose a location for your storage bucket
6. Start in **test mode** (for development) or **production mode** (for production)

### 2. Storage Rules
Update your Firebase Storage rules to allow read/write access:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /videos/{videoId} {
      allow read, write: if request.auth != null || true; // For testing - restrict in production
    }
  }
}
```

### 3. iOS Project Configuration
1. Make sure `GoogleService-Info.plist` is in your project root
2. The Firebase dependencies are already added to your project
3. Firebase is configured in `BetterSelfApp.swift`

### 4. Usage
- Videos selected from Photos App will automatically upload to Firebase Storage
- Firebase URLs are stored in the `firebaseVideoURL` field of each Reminder
- Videos can be played directly from Firebase URLs in ReminderView

### 5. Security Considerations
- In production, implement proper authentication
- Restrict storage access to authenticated users only
- Consider implementing video compression before upload
- Add file size limits and type validation

### 6. Testing
1. Run the app
2. Create a new reminder
3. Select a video from Photos
4. The video should upload to Firebase and display a progress indicator
5. Save the reminder
6. View the reminder and tap the video button to play from Firebase

## Troubleshooting
- Check Firebase Console for upload errors
- Verify `GoogleService-Info.plist` is properly configured
- Ensure Firebase Storage is enabled in your project
- Check network connectivity and Firebase project status
