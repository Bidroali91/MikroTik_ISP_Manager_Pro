@echo off
chcp 65001 >nul
echo ============================================
echo    MikroTik ISP Manager Pro - Build Script
echo ============================================
echo.

REM Step 1: Check prerequisites
where flutter >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [خطأ] Flutter غير مثبت في PATH
    echo       تأكد من تشغيل flutter في PATH
    pause
    exit /b 1
)

where java >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [تحذير] Java غير موجود في PATH - تأكد من تثبيت JDK 17+
)

echo [1/4] جلب الاعتماديات...
call flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo [خطأ] فشل flutter pub get
    pause
    exit /b 1
)

echo [2/4] تشغيل code generation...
call flutter pub run build_runner build --delete-conflicting-outputs
if %ERRORLEVEL% NEQ 0 (
    echo [تحذير] build_runner فشل - قد تعمل بعض الأجزاء بدون code generation
)

echo [3/4] تحليل الكود...
call flutter analyze
echo.
echo ملاحظة: الأخطاء info-level طبيعية ولا تمنع البناء

echo [4/4] بناء APK...
call flutter build apk --release
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ============================================
    echo    ✓ تم البناء بنجاح!
    echo    APK في: build\app\outputs\flutter-apk\app-release.apk
    echo ============================================
) else (
    echo.
    echo [خطأ] فشل بناء APK
    echo.
    echo الحلول الممكنة:
    echo 1. انسخ المشروع إلى مسار بدون حروف عربية (مثل C:\project)
    echo 2. تأكد من تثبيت Android SDK مع NDK
    echo 3. أضف ملف google-services.json من Firebase Console
    echo 4. شغل: flutter doctor --android-licenses
)

pause
