# Bus Booking

<img src="screenshots/live.png" alt="The Huye seat map, with four seats booked" width="280">

Twelve seats on the Huye bus, 3,000 RWF each. Sign in, hand over the passenger's cash, and the seat map updates live. Each account sees only its own bookings.

## Download

The Android install file is not attached yet. Build it with the steps in [Run it yourself](#run-it-yourself). When a release is published, it will be at [the latest release](https://github.com/mukunzijonathan/bus-booking/releases/latest).

## Features

- Create an account and log in. A new account starts with three sample bookings.
- Book a free seat, see the change in 5000, 2000, 1000, 500, and 100 RWF notes, or cancel a booking.
- Seats sold, money made, and seats left stay correct while you filter All, Free, or Taken.
- When the bus is full, a waitlist opens. Priority passengers go first, and cancelling a seat moves the next person in.
- An optional passenger photo, saved on Cloudinary, shows on the seat and on the booking.
- Your data is private: a second account cannot read yours.

## Screenshots

| Login | Seat map | A second account |
|---|---|---|
| <img src="screenshots/login.png" alt="Login" width="220"> | <img src="screenshots/live.png" alt="Seat map with four bookings" width="220"> | <img src="screenshots/denied.png" alt="A second account sees only its own seat" width="220"> |

## How it's built

- Flutter, with Provider for state management
- Firebase Authentication and Cloud Firestore; photos on Cloudinary
- Four layers: models, repositories, state, screens

## Run it yourself

1. Clone the repository and run `flutter pub get`.
2. Connect your own Firebase project (`google-services.json` in `android/app/`). It is not in this repository.
3. Put your Cloudinary cloud name and unsigned upload preset in `lib/repositories/photo_repository.dart`.
4. `flutter run`

## Author

Mukunzi Jonathan · 27132 · [GitHub](https://github.com/mukunzijonathan)
