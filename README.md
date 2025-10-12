# Pump-Fiction
A next-gen fitness platform that merges performance, data, and mindset.

## Frontend (Flutter)

Prerequisites:

- Flutter SDK installed and on PATH: `flutter --version` (tested with Flutter 3.x+)
- For Windows desktop: Windows tooling enabled. For Android/iOS build targets, set up respective SDKs/emulators.

Quick start:

1. Open a terminal and change to the frontend folder:

	cd frontend

2. Get packages (if not already done):

	flutter pub get

3. Run the app (choose a device or desktop):

	flutter run

Notes:

- The frontend was scaffolded with `flutter create` in the `frontend` folder.
- If you see dependency version warnings, run `flutter pub outdated` and update constraints in `pubspec.yaml` as needed.

Architecture (Reso Coder - Clean Architecture):

- lib/
	- core/                     # common utilities (errors, usecases)
	- features/
		- authentication/
			- data/
				- models/
				- repositories/
			- domain/
				- repositories/
				- usecases/
			- presentation/
				- pages/
					- login_page.dart
					- signup_page.dart
		- profile/
			- data/
				- models/
			- domain/
				- usecases/
			- presentation/
				- pages/
					- profile_page.dart

Dependency injection is bootstrapped in `lib/injection_container.dart` (uses `get_it`).
