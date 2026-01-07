# 🛒 MYBasket - Flutter Grocery App

**MYBasket** is a complete mobile e-commerce application designed to streamline daily grocery shopping. Built with **Flutter** and **Firebase**, it offers a seamless, real-time shopping experience with features like smart discounts, order tracking, and multi-address management.

##  App Overview

**MYBasket** solves the problem of inefficient physical grocery shopping by providing a centralized digital marketplace. It targets busy professionals and families who value convenience, allowing them to browse fresh produce, manage carts, and secure deliveries with just a few taps.

##  Key Features

*  Secure Authentication: Full Sign Up/Login system powered by Firebase Auth, linked to Firestore User Profiles.
* Dynamic Storefront: Real-time "Top Categories," "Featured Products," and "Top Products" fetched directly from Firestore.
* Smart Search: Instant product filtering allows users to find items quickly by name.
* Advanced Cart System:
    * State Management: Robust Provider-based logic for adding/removing items and calculating live totals.
    * Smart Discounts: Logic-based coupon engine (e.g., *50% off first order*, *$5 off orders > $20*) and promo code application.
* Order Management:
    * Checkout Flow: Multi-address selection (Home/Office) and delivery details.
    * Order History: A visual timeline showing order status (Pending → Delivered), date, and item summary.
* User Profile: A complete hub to manage personal details, saved addresses, FAQs, and support.

## Tech Stack

* **Frontend**: Flutter (Dart)
* **Backend**: Firebase (Firestore Database, Authentication)
* **State Management**: Provider
* **Architecture**: MVC (Model-View-Controller) pattern
* **IDE**: Android Studio / VS Code

## Installation & Setup

Follow these steps to run the project locally:

1.  **Clone the repository**
    ```bash
    git clone [https://github.com/yourusername/mybasket.git](https://github.com/yourusername/mybasket.git)
    ```
2.  **Install dependencies**
    Navigate to the project folder and run:
    ```bash
    flutter pub get
    ```
3.  **Firebase Setup**
    * Create a new project in the [Firebase Console](https://console.firebase.google.com/).
    * Download `google-services.json` (for Android) and place it in `android/app/`.
    * Enable **Authentication** (Email/Password) and **Cloud Firestore** in your Firebase Console.
4.  **Run the App**
    Connect your device or emulator and run:
    ```bash
    flutter run
    ```

    ### 🗄️ Database Setup
To run this app, you must create a Cloud Firestore database with the following collections:

**1. products**
- name (string)
- price (number)
- image (string URL)
- description (string)
- unit (string, e.g., "1kg")
- isFeatured (boolean)

**2. categories**
- name (string)
- image (string URL)
- color (string hex, e.g., "0xFFE2F3F2")

## Future Improvements

* **Admin Panel**: A web-based dashboard for store managers to add products and update order statuses.
* **Live Tracking**: Integration with Google Maps API for real-time driver tracking.
* **Push Notifications**: Automated alerts for order confirmations and delivery updates.

## Author

**Ayeza Irfan**

* **Project Type**: Semester Project

---
*This project demonstrates full-stack mobile development capabilities using Flutter and Firebase.*
