# Final Report on Marapp

## Introduction
This report presents a detailed overview of the development process of our mobile application, including, as asked, the challenges faced, solutions implemented, and the final execution steps. The application was developed using Dart and Flutter, with Firebase as the backend service.

## Implementation Details
The application was built with the following technologies:
- **Frontend:** Flutter (Dart)
- **Backend:** Firebase (Firestore, Authentication, Storage)
- **Additional Services:** Alternative solutions for maps and image storage due to Firebase limitations

### Key Features
- User authentication
- Data storage and retrieval using Firebase Firestore
- Image storage workaround due to Firebase free-tier limitations
- Alternative map solution instead of Google Maps API

## Challenges and Solutions

### 1. Firebase API Limitations
**Issue:** One of the primary challenges we encountered was related to Firebase, particularly with user permissions and the limitations of the free tier. The basic plan of Firebase imposes restrictions on API usage, which significantly impacted our development process, particularly for photo storage and mapping services.
**Solution:** To work around this, we optimized our queries to minimize read operations and implemented an alternative image storage solution that involved using a third-party cloud storage service that offered more flexibility and higher limits under their free tier. To circumnavigate the restrictions on Firebase's mapping services, we integrated an alternative mapping API that provided similar functionality without the stringent limitations.

### 2. User Permissions
**Issue:** Managing user permissions within Firebase Authentication was more complex than anticipated.

**Solution:** We implemented custom rules within Firebase to handle authentication and access levels effectively.

### 3. Absence of Firebase Functions
**Issue:** The Firebase free-tier does not support Cloud Functions, which would have been useful for automating tasks and triggers.

**Solution:** We replaced Firebase Functions with client-side logic and scheduled background tasks in the app where necessary.

### 4. Query Complexity
**Issue:** Firestore's querying system is restrictive compared to traditional databases, making certain queries cumbersome.

**Solution:** We restructured our database schema to optimize querying and improve performance.

### 5. Learning Dart and Flutter
Another significant challenge was adapting to Dart, the programming language used for Flutter development. As a new language for our team, there was a steep learning curve involved.

#### Problems:
- **Initial Learning Curve**: Understanding Dart's syntax and features required substantial time and effort, slowing down the initial development phase.
- **Integration with Firebase**: Combining Dart with Firebase's APIs presented additional complexities, particularly in handling asynchronous operations and data streams.

#### Solutions:
- **Comprehensive Learning Resources**: We utilized a variety of learning resources, including official documentation, tutorials, and community forums, to accelerate our understanding of Dart.
- **Incremental Implementation**: We adopted an incremental approach to development, starting with simple features and gradually incorporating more complex functionality as our proficiency with Dart improved.

## Implementation Choices
Our implementation choices were guided by the need to balance functionality, performance, and the constraints imposed by Firebase's free tier.

- **Flutter Framework**: We chose Flutter for its cross-platform capabilities, allowing us to develop for both iOS and Android from a single codebase.
- **Firebase Integration**: Despite its limitations, Firebase was selected for its real-time database capabilities and ease of integration with Flutter.
- **Third-Party Services**: To address Firebase's limitations, we integrated third-party services for photo storage and mapping, ensuring that our app could deliver the required features without exceeding API quotas.

## How to Execute the Application
### Prerequisites
To run the application, you need to install:
- Flutter SDK
- Android Studio (or an alternative IDE like Visual Studio Code)
- Dart SDK

### Steps to Run the App
1. **Download the Source Code**: The source code is available on AulaWeb.
2. **Extract the Project**: Unzip the project folder.
3. **Install Dependencies**: Open a terminal in the project folder and run:
   ```sh
   flutter pub get
   ```
4. **Run the App**:
   ```sh
   flutter run
   ```
   Ensure that an emulator or a physical device is connected.

### Alternative to Android Studio
If you are not using Android Studio:
- Install Flutter CLI and set up environment variables.
- Use a terminal to navigate to the project directory and execute `flutter run`.
- If needed, install required dependencies manually via `flutter pub get`.

## Conclusion
Despite several challenges, we successfully developed a fully functional mobile application. By overcoming Firebase limitations, adapting to Dart, and optimizing queries, we managed to create an efficient and scalable solution. The experience has been valuable in understanding backend constraints and frontend optimizations in a mobile development environment.

