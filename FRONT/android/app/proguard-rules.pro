# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# HTTP
-keep class com.google.gson.** { *; }
-keep class org.apache.http.** { *; }
-keep class org.apache.james.mime4j.** { *; }
-keep class javax.inject.** { *; }
-keep class javax.annotation.** { *; }
-keep class retrofit2.** { *; }
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# Shared Preferences
-keep class androidx.preference.** { *; }

# SQLite
-keep class androidx.sqlite.** { *; }

# Connectivity
-keep class androidx.work.** { *; }

# Confetti
-keep class nl.dionsegijn.konfetti.** { *; }

# Lottie
-keep class com.airbnb.lottie.** { *; }

# Cached Network Image
-keep class flutter_cached_network_image.** { *; }

# URL Launcher
-keep class io.flutter.plugins.urllauncher.** { *; }

# Share Plus
-keep class dev.fluttercommunity.plus.share.** { *; }

# Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Workmanager
-keep class be.tramckrijte.workmanager.** { *; }

# Screen Util
-keep class flutter_screenutil.** { *; }

# SVG
-keep class flutter_svg.** { *; }

# Rive
-keep class rive.** { *; }

# Card Swiper
-keep class flutter_card_swiper.** { *; }

# Staggered Grid View
-keep class flutter_staggered_grid_view.** { *; }

# Responsive Framework
-keep class responsive_framework.** { *; }

# Flutter Animate
-keep class flutter_animate.** { *; }

# Flutter Hooks
-keep class flutter_hooks.** { *; }

# GetX
-keep class get.** { *; }

# Flutter Bloc
-keep class flutter_bloc.** { *; }

# Equatable
-keep class equatable.** { *; }

# Animations
-keep class animations.** { *; }

# Native Splash
-keep class flutter_native_splash.** { *; }

# Device Preview
-keep class device_preview.** { *; }

# Glassmorphism
-keep class glassmorphism.** { *; }

# Shimmer
-keep class shimmer.** { *; }

# Auto Size Text
-keep class auto_size_text.** { *; }

# Page Transition
-keep class page_transition.** { *; }

# Animated Text Kit
-keep class animated_text_kit.** { *; }

# Flip Card
-keep class flip_card.** { *; }

# Staggered Animations
-keep class flutter_staggered_animations.** { *; }

# General rules
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Remove logging
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}