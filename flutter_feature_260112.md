# Flutter Environment Variable Integration Summary

## Feature Overview

This feature enables the Flutter application to dynamically configure its backend API connection by reading `API_HOST` and `API_PORT` from environment variables. Previously, the application had hardcoded values that could not be changed without rebuilding the application.

## Files Modified

### 1. pubspec.yaml
- Added `flutter_dotenv: ^5.1.0` dependency to enable environment variable loading

### 2. lib/main.dart
- Imported the `flutter_dotenv` package
- Modified the `main()` function to asynchronously load the `.env` file before running the app
- Used `await dotenv.load(fileName: ".env")` to load environment variables at startup

### 3. lib/api_service.dart
- Imported the `flutter_dotenv` package
- Removed the hardcoded `BACKEND_URL` constant
- Implemented a `getBaseURL()` function that prioritizes environment variables over hardcoded values
- Updated all API calls to use the dynamically constructed URL

## Implementation Details

### Priority Order for Configuration Sources

The application now retrieves the API configuration in the following priority order:

1. Compile-time environment variables (using `String.fromEnvironment`)
2. Values loaded from the `.env` file via `flutter_dotenv`
3. Default fallback values (`localhost:8000` for non-HTTPS, `localhost:443` for HTTPS)

### Protocol Detection

The implementation automatically detects the protocol (HTTP vs HTTPS) based on the port number:
- Port 443 defaults to HTTPS
- Other ports default to HTTP

### Supported Endpoints

All API endpoints now use the dynamic URL:
- POST `/evaluate` for text evaluation
- POST `/evaluate-image` for file uploads
- GET `/health` for health checks

## Benefits

- **Flexibility**: Allows switching between different backend environments without code changes
- **Deployment Friendly**: Supports different configurations for development, staging, and production
- **Security**: Eliminates hardcoded URLs from source code
- **Maintainability**: Centralized configuration through environment variables

## Usage

### Local Development
Create a `.env` file in the project root:
```
API_HOST=localhost
API_PORT=8000
```

### Production Deployment
Set environment variables during the build process:
```bash
flutter build --dart-define=API_HOST=production.example.com --dart-define=API_PORT=443
```

## Technical Constraints

- The application will fall back to `localhost:8000` if no environment variables are set
- The `.env` file should be added to `.gitignore` to prevent accidental commits of sensitive information
- Both `API_HOST` and `API_PORT` are optional but recommended for non-local deployments