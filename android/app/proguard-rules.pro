# Ignore missing ML Kit language recognizer classes
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

#for imagepicker
-keep class io.flutter.plugins.imagepicker.** { *; }

-keep class io.flutter.embedding.engine.plugins.** { *; }
-keep class io.flutter.plugin.common.** { *; }

#for file provider
-keep class androidx.core.content.FileProvider { *; }