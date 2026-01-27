# Welcome to Flutter!

This `hello_flutter` project is your first step into the world of Flutter development.

## What is Flutter?

Flutter is a UI toolkit from Google that allows you to build beautiful, natively compiled applications for mobile, web, and desktop from a single codebase.

## The `lib/main.dart` File

This is the entry point of your application.

- **void main()**: The function where your app starts execution.
- **runApp()**: A Flutter function that takes a `Widget` and makes it the root of the widget tree.
- **StatelessWidget**: A widget that doesn't hold any state (it doesn't change once built).
- **MaterialApp**: A convenience widget that gives you access to Material Design styling and navigation.
- **Scaffold**: Implements the basic Material Design visual layout structure (AppBar, Body, FloatingActionButton, etc.).

## How to Run

1.  Open this folder in VS Code.
2.  Open `lib/main.dart`.
3.  Press `F5` or click "Run" -> "Start Debugging".
4.  You will see your app launch in a simulator or Chrome!

## Running on iOS (iPhone/iPad)

To run on iOS, you **must** have a Mac with **Xcode** installed.

1.  **Install Xcode**: Download it from the Mac App Store (it's large, ~10GB+).
2.  **Configure Command Line Tools**:
    ```bash
    sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
    sudo xcodebuild -runFirstLaunch
    ```
3.  **Install CocoaPods** (Dependency Manager):
    ```bash
    sudo gem install cocoapods
    ```
4.  **Run**:
    - Open a Simulator: `open -a Simulator`
    - Run `flutter run`

**Note**: Since your `flutter doctor` showed Xcode issues, you need to complete Step 1 & 2 before iOS will work.

## Running on Real Android Phone

Yes! You can run on your own phone:

1.  **Enable Developer Mode**: Go to Settings > About Phone. Tap **Build Number** 7 times until it says "You are a developer".
2.  **Enable USB Debugging**: Go to Settings > System > Developer Options. Turn on **USB Debugging**.
3.  **Connect**: Plug your phone into your computer via USB.
4.  **Allow Debugging**: A popup will appear on your phone asking to trust this computer. Tap **Allow**.
5.  **Run**:
    - Run `flutter devices` in terminal to see your phone ID.
    - Run `flutter run -d <your-device-id>`.

## Running on Web (Chrome)

If you don't have Xcode installed (which takes a long time to download), you can easily run on Chrome:

1.  Open the terminal.
2.  Run `flutter run -d chrome`.
3.  The app will open in a new Chrome window.

## Troubleshooting

### "unable to find utility xcodebuild"

This means you don't have Xcode installed or configured.

- **Option A (Quick)**: Run on Chrome using the steps above.
- **Option B (Full)**: Install Xcode from the Mac App Store, then run:
  ```bash
  sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
  sudo xcodebuild -runFirstLaunch
  ```

## Try This

Look at the `lib/main.dart` file. Try changing the text inside the `Text()` widget to say your name, save the file, and watch the app update instantly (this is called Hot Reload!).

List emulators: flutter emulators
Launch emulator: flutter emulators --launch Medium_Phone_API_36.1
Run app: flutter run
