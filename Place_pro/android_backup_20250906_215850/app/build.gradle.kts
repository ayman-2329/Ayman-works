plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // Google Services plugin
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.firebase.crashlytics") // Crashlytics for crash reporting
    id("com.google.firebase.firebase-perf") // Firebase Performance Monitoring
}

android {
    namespace = "com.saec.placepro"
    compileSdk = 34
    ndkVersion = "27.0.12077973"
    
    // Enable Java 8 features
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        
        // Enable core library desugaring for Java 8+ APIs
        isCoreLibraryDesugaringEnabled = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.saec.placepro"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
        multiDexEnabled = true
        
        // Enable R8 full mode
        setProperty("android.enableR8.fullMode", true)
        
        // Enable vector drawables for older versions
        vectorDrawables.useSupportLibrary = true
        
        // Enable resource shrinking
        resourceConfigurations.addAll(listOf("en", "ar")) // Add supported languages
    }

    signingConfigs {
        create("release") {
            // Configure your release signing config here
            // keyAlias keystoreProperties['keyAlias']
            // keyPassword keystoreProperties['keyPassword']
            // storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            // storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            // Enable code and resource shrinking
            isMinifyEnabled = true
            isShrinkResources = true
            
            // Enable ProGuard rules
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            
            // Use release signing config
            signingConfig = signingConfigs.getByName("release")
            
            // Enable code coverage
            isTestCoverageEnabled = false
        }
        
        debug {
            // Enable test coverage for debug builds
            isTestCoverageEnabled = true
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-DEBUG"
        }
    }
    
    // Enable view binding
    buildFeatures {
        viewBinding = true
        buildConfig = true
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Core dependencies
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.9.24")
    implementation("androidx.multidex:multidex:2.0.1")
    
    // Firebase BoM (Bill of Materials)
    implementation(platform("com.google.firebase:firebase-bom:33.1.1"))
    
    // Firebase dependencies
    implementation("com.google.firebase:firebase-analytics-ktx")
    implementation("com.google.firebase:firebase-auth-ktx")
    implementation("com.google.firebase:firebase-firestore-ktx")
    implementation("com.google.firebase:firebase-crashlytics-ktx")
    implementation("com.google.firebase:firebase-perf-ktx")
    implementation("com.google.firebase:firebase-messaging-ktx")
    
    // Core library desugaring for Java 8+ APIs
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    
    // AndroidX Core
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.11.0")
    
    // Play Core for in-app updates
    implementation("com.google.android.play:core:1.10.3")
    implementation("com.google.android.play:core-ktx:1.8.1")
    
    // Security
    implementation("androidx.security:security-crypto:1.1.0-alpha06")
    
    // WorkManager
    implementation("androidx.work:work-runtime-ktx:2.9.0")
}

// Configure Crashlytics
android.buildTypes.all { type ->
    // Enable Crashlytics for all build types
    type.isCrunchPngs = true
    type.isDebuggable = false
    type.isJniDebuggable = false
    type.isRenderscriptDebuggable = false
    type.isPseudoLocalesEnabled = true
}

// Configure APK splitting
android {
    splits {
        abi {
            isEnable = true
            reset()
            include("armeabi-v7a", "arm64-v8a", "x86_64")
            isUniversalApk = true
        }
    }
    
    // Configure bundle
    bundle {
        language {
            // Enable split for language resources
            enableSplit = true
        }
        density {
            // Enable split for screen density resources
            enableSplit = true
        }
        abi {
            // Enable split for ABI resources
            enableSplit = true
        }
    }
    
    // Configure packaging options
    packagingOptions {
        resources.excludes.add("META-INF/*.kotlin_module")
        resources.excludes.add("META-INF/AL2.0")
        resources.excludes.add("META-INF/LGPL2.1")
    }
}
