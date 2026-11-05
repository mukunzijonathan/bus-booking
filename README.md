# Bus Booking

Twelve seats on the Huye bus, 3,000 RWF each. You sign in, book a seat with the cash the passenger hands over, and the seat map updates live. Each account only sees its own bookings.

**Download:** the Android install file is not attached yet. Build it with the command in [Run it yourself](#run-it-yourself), or use [the latest release](https://github.com/mukunzijonathan/bus-booking/releases/latest) once that file is published.

## What it does

- Email and password login, with three sample bookings on a new account.
- A 12-seat map. Tap a free seat to book it, or a taken seat to see the passenger and cancel.
- Change is counted in 5000, 2000, 1000, 500, and 100 RWF notes.
- Seats sold, money made, and seats left stay correct while you filter All, Free, or Taken.
- When every seat is taken, a waitlist opens. Priority passengers (elderly, pregnant, disabled) jump the queue. Cancelling a booking moves the first waiting person into that seat.
- An optional passenger photo, uploaded to Cloudinary, shows on the seat and on the booking.

## Screenshots

| | |
|---|---|
| Login | ![Login](screenshots/login.png) |
| Seat map | ![Seat map](screenshots/live.png) |
| A second account cannot see the first | ![Denied](screenshots/denied.png) |

## How it's built

Flutter, with Provider holding one `BookingState`. Firebase Authentication signs people in. Cloud Firestore stores `users/{uid}/bookings` and `users/{uid}/waitlist`. Cloudinary stores the photos. The code is split into four layers: models, repositories, state, and screens. Only the models and the data repositories import Cloud Firestore.

## Run it yourself

1. Install Flutter (stable) and open the project in Android Studio.
2. Copy `google-services.json` from the Firebase console into `android/app/`. It is not in this repository.
3. In `lib/repositories/photo_repository.dart`, replace `YOUR_CLOUD_NAME` and `YOUR_UPLOAD_PRESET` with the cloud name and an unsigned upload preset from your Cloudinary dashboard.
4. From this folder:

```bash
flutter pub get
dart run flutter_launcher_icons
flutter run
```

## Author

[Mukunzi Jonathan](https://github.com/mukunzijonathan) · 27132
