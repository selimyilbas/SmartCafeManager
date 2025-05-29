# 🍕 Smart Cafe Manager

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Provider-8B5CF6?style=for-the-badge&logo=flutter&logoColor=white" alt="Provider" />
</div>

<div align="center">
  <h3>A comprehensive restaurant management system built with Flutter and Firebase</h3>
  <p>Streamline your cafe operations with real-time order tracking, inventory management, and role-based access control</p>
</div>

<div align="center">
  <a href="#features">Features</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#getting-started">Getting Started</a> •
  <a href="#screenshots">Screenshots</a> •
  <a href="#contributing">Contributing</a>
</div>

---

## 🚀 Features

### 👥 Multi-Role System
- **Customer**: Browse menu, place orders, make payments
- **Employee**: Manage kitchen orders, track inventory, handle shifts
- **Manager**: Analytics dashboard, staff management, menu administration

### 🔥 Real-Time Operations
- Live order status updates
- Real-time table monitoring
- Instant waiter call notifications
- Dynamic inventory tracking

### 📱 Core Functionalities

#### For Customers
- ✅ QR code table scanning
- ✅ Digital menu browsing with categories
- ✅ Cart management with customizations
- ✅ Group ordering with split payments
- ✅ Order tracking
- ✅ Waiter call system

#### For Employees
- ✅ Kitchen display system (KDS)
- ✅ Order status management (Pending → Preparing → Ready)
- ✅ Shift clock in/out
- ✅ Inventory stock updates
- ✅ Table status monitoring

#### For Managers
- ✅ Sales analytics and reports
- ✅ Menu item management
- ✅ Staff shift tracking
- ✅ Inventory alerts and thresholds
- ✅ Discount management
- ✅ Employee invitation system

## 🏗️ Architecture

### Technology Stack
- **Frontend**: Flutter 3.x
- **State Management**: Provider Pattern
- **Backend**: Firebase (Auth, Firestore, Cloud Functions)
- **Authentication**: Firebase Auth with role-based access
- **Database**: Cloud Firestore
- **Real-time Updates**: Firestore Streams

### Project Structure
```
lib/
├── models/          # Data models
│   └── menu_item.dart
├── providers/       # State management
│   ├── auth_provider.dart
│   ├── cart_provider.dart
│   ├── table_provider.dart
│   └── ...
├── services/        # Business logic & Firebase
│   ├── auth_service.dart
│   ├── order_service.dart
│   ├── table_service.dart
│   └── ...
├── screens/         # UI screens
│   ├── login_screen.dart
│   ├── customer/
│   ├── employee/
│   └── manager/
└── widgets/         # Reusable components
```

### Database Schema

#### Collections
- `users` - User profiles with roles
- `menu` - Menu items with categories and options
- `orders` - Order details with status tracking
- `tables` - Table sessions and occupancy
- `inventory` - Stock levels and thresholds
- `shifts` - Employee work sessions
- `calls` - Waiter call requests
- `invites` - Employee/Manager invitation codes

## 🚦 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK (2.17 or higher)
- Firebase CLI
- Android Studio / VS Code
- A Firebase project

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/selimyilbas/SmartCafeManager.git
   cd SmartCafeManager
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project
   - Enable Authentication, Firestore, and Storage
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in the respective directories

4. **Configure Firebase**
   ```bash
   flutterfire configure
   ```

5. **Environment Setup**
   Create `.env` file in the root directory:
   ```env
   FIREBASE_PROJECT_ID=your_project_id
   FIREBASE_API_KEY=your_api_key
   ```

6. **Run the app**
   ```bash
   flutter run
   ```

### Initial Setup

1. **Create Manager Account**
   - Register with email/password
   - Manually set role to 'manager' in Firestore console

2. **Generate Employee Invite Codes**
   - Login as manager
   - Navigate to Settings → Invite Codes
   - Create codes for employees

3. **Setup Menu Items**
   - Go to Menu Management
   - Add categories and items
   - Set initial stock levels

## 📸 Screenshots

<div align="center">
  <img src="assets/screenshots/login.png" width="200" alt="Login Screen" />
  <img src="assets/screenshots/menu.png" width="200" alt="Menu Screen" />
  <img src="assets/screenshots/cart.png" width="200" alt="Cart Screen" />
  <img src="assets/screenshots/kitchen.png" width="200" alt="Kitchen Screen" />
</div>

## 🧪 Testing

### Run Tests
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test

# Test coverage
flutter test --coverage
```

### Test Accounts
```
Customer: customer@test.com / password123
Employee: employee@test.com / password123
Manager: manager@test.com / password123
```

## 📦 Building for Production

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter analyze` before committing
- Format code with `flutter format .`

## 🐛 Known Issues

- [ ] Offline mode support is limited
- [ ] Push notifications not yet implemented
- [ ] iOS specific UI optimizations needed
- [ ] Performance optimization for large menus (500+ items)

## 🗺️ Roadmap

### Version 2.0
- [ ] Multi-language support
- [ ] Dark mode
- [ ] Offline functionality
- [ ] Push notifications
- [ ] Kitchen printer integration
- [ ] Payment gateway integration

### Version 3.0
- [ ] AI-powered recommendations
- [ ] Voice ordering
- [ ] Multi-branch support
- [ ] Advanced analytics dashboard
- [ ] Loyalty program

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Selim Yılbaş** - *Initial work* - [@selimyilbas](https://github.com/selimyilbas)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for the backend infrastructure
- [Flutter Community](https://flutter.dev/community) for packages and support
- All contributors who have helped shape this project

## 📞 Support

For support, email support@smartcafe.com or join our Slack channel.

---

<div align="center">
  <p>Made with ❤️ by <a href="https://github.com/selimyilbas">Selim Yılbaş</a></p>
  <p>
    <a href="https://github.com/selimyilbas/SmartCafeManager/stargazers">⭐ Star this repository</a> if you find it helpful!
  </p>
</div>
