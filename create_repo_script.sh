#!/bin/bash
# This script populates the Assist repository with source code and infrastructure.
set -e

# Create directory structure
mkdir -p app/src/main/java/com/jared747/assist/ui/theme
# Ensure main source directory exists instead of creating a directory named AndroidManifest.xml.
mkdir -p app/src/main
mkdir -p backend/src/main/kotlin/com/jared747/assist
mkdir -p backend/src/main/resources
mkdir -p infra
mkdir -p .github/workflows

# settings.gradle.kts
cat > settings.gradle.kts <<'EOF'
rootProject.name = "Assist"

// Include modules for the Android app and the backend service.
include("app")
include("backend")
EOF

# Root build.gradle.kts
cat > build.gradle.kts <<'EOF'
// Top-level build file where you can add configuration options common to all sub-projects/modules.

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.3.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.10")
        classpath("io.ktor:ktor-gradle-plugin:3.0.0")
        // NOTE: Do not place your application dependencies here; they belong
        // in the individual module build.gradle files
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
EOF

# app module build.gradle.kts
cat > app/build.gradle.kts <<'EOF'
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.serialization") version "1.9.10"
}

android {
    namespace = "com.jared747.assist"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.jared747.assist"
        minSdk = 24
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            isMinifyEnabled = false
        }
    }

    flavorDimensions += "environment"
    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            buildConfigField("String", "API_BASE_URL", "\"https://dev-api.example.com\"")
            buildConfigField("String", "OPENAI_PROJECT", "\"realtime-dev\"")
        }
        create("prod") {
            dimension = "environment"
            // No suffix for production
            buildConfigField("String", "API_BASE_URL", "\"https://api.example.com\"")
            buildConfigField("String", "OPENAI_PROJECT", "\"realtime-prod\"")
        }
    }

    buildFeatures {
        compose = true
    }

    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.2"
    }

    packagingOptions {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
}

dependencies {
    val composeBom = platform("androidx.compose:compose-bom:2024.02.01")
    implementation(composeBom)
    androidTestImplementation(composeBom)

    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")
    implementation("androidx.activity:activity-compose:1.8.2")
    implementation("androidx.navigation:navigation-compose:2.7.2")
    implementation("androidx.compose.material3:material3:1.2.0")
    implementation("androidx.compose.material:material:1.5.0")
    implementation("androidx.compose.ui:ui:1.5.0")
    implementation("androidx.compose.ui:ui-tooling-preview:1.5.0")
    debugImplementation("androidx.compose.ui:ui-tooling:1.5.0")
    debugImplementation("androidx.compose.ui:ui-test-manifest:1.5.0")

    // Ktor client for networking
    implementation("io.ktor:ktor-client-cio:2.3.4")
    implementation("io.ktor:ktor-client-content-negotiation:2.3.4")
    implementation("io.ktor:ktor-serialization-kotlinx-json:2.3.4")

    // Kotlinx serialization
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.0")

    // Google Sign-In (optional for login)
    implementation("com.google.android.gms:play-services-auth:20.7.0")
}
EOF

# app/proguard-rules.pro
cat > app/proguard-rules.pro <<'EOF'
# Add project-specific ProGuard rules here.

# If you need to keep any classes for reflection or other use cases, add them here.
EOF

# AndroidManifest.xml
mkdir -p app/src/main
cat > app/src/main/AndroidManifest.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.jared747.assist">

    <!-- Permissions required for network access and audio capture -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />

    <application
        android:allowBackup="true"
        android:label="Assist"
        android:theme="@style/Theme.Material3.DayNight.NoActionBar">

        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>

</manifest>
EOF

# MainActivity.kt
mkdir -p app/src/main/java/com/jared747/assist
cat > app/src/main/java/com/jared747/assist/MainActivity.kt <<'EOF'
package com.jared747.assist

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            com.jared747.assist.ui.theme.AssistTheme {
                AssistApp()
            }
        }
    }
}

@Composable
fun AssistApp() {
    val navController = rememberNavController()
    Scaffold(
        bottomBar = {
            AssistBottomNavigation(navController)
        }
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = NavRoutes.Agent.route,
            modifier = Modifier.fillMaxSize()
        ) {
            composable(NavRoutes.Agent.route) { AgentScreen() }
            composable(NavRoutes.Boards.route) { BoardsScreen() }
            composable(NavRoutes.Todos.route) { TodosScreen() }
        }
    }
}

sealed class NavRoutes(val route: String, val label: String) {
    object Agent : NavRoutes("agent", "Assist")
    object Boards : NavRoutes("boards", "Boards")
    object Todos : NavRoutes("todos", "Todos")
}

@Composable
fun AssistBottomNavigation(navController: NavHostController) {
    val items = listOf(NavRoutes.Agent, NavRoutes.Boards, NavRoutes.Todos)
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = navBackStackEntry?.destination?.route
    NavigationBar {
        items.forEach { item ->
            NavigationBarItem(
                selected = currentRoute == item.route,
                onClick = {
                    navController.navigate(item.route) {
                        popUpTo(navController.graph.findStartDestination().id) { saveState = true }
                        launchSingleTop = true
                        restoreState = true
                    }
                },
                label = { Text(item.label) },
                icon = { /* TODO: add icons if desired */ }
            )
        }
    }
}

@Composable
fun AgentScreen() {
    // TODO: Implement voice assistant UI and interactions
    Box(modifier = Modifier.fillMaxSize()) {
        Text(text = "AI Assistant coming soon")
    }
}

@Composable
fun BoardsScreen() {
    // TODO: Implement boards UI with lists and tickets
    Box(modifier = Modifier.fillMaxSize()) {
        Text(text = "Boards coming soon")
    }
}

@Composable
fun TodosScreen() {
    // TODO: Implement aggregated todo list
    Box(modifier = Modifier.fillMaxSize()) {
        Text(text = "Todos coming soon")
    }
}
EOF

# Theme color definitions
cat > app/src/main/java/com/jared747/assist/ui/theme/Color.kt <<'EOF'
package com.jared747.assist.ui.theme

import androidx.compose.ui.graphics.Color

val md_theme_light_primary = Color(0xFF6750A4)
val md_theme_light_onPrimary = Color(0xFFFFFFFF)
val md_theme_light_primaryContainer = Color(0xFFEADDFF)
val md_theme_light_onPrimaryContainer = Color(0xFF21005D)

val md_theme_dark_primary = Color(0xFFD0BCFF)
val md_theme_dark_onPrimary = Color(0xFF381E72)
val md_theme_dark_primaryContainer = Color(0xFF4F378B)
val md_theme_dark_onPrimaryContainer = Color(0xFFEADDFF)
EOF

# Theme definition
cat > app/src/main/java/com/jared747/assist/ui/theme/Theme.kt <<'EOF'
package com.jared747.assist.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable

private val LightColors = lightColorScheme(
    primary = md_theme_light_primary,
    onPrimary = md_theme_light_onPrimary,
    primaryContainer = md_theme_light_primaryContainer,
    onPrimaryContainer = md_theme_light_onPrimaryContainer
)

private val DarkColors = darkColorScheme(
    primary = md_theme_dark_primary,
    onPrimary = md_theme_dark_onPrimary,
    primaryContainer = md_theme_dark_primaryContainer,
    onPrimaryContainer = md_theme_dark_onPrimaryContainer
)

@Composable
fun AssistTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val colors = if (darkTheme) DarkColors else LightColors
    MaterialTheme(
        colorScheme = colors,
        typography = androidx.compose.material3.Typography(),
        content = content
    )
}
EOF

# backend module build.gradle.kts
mkdir -p backend
cat > backend/build.gradle.kts <<'EOF'
plugins {
    application
    kotlin("jvm") version "1.9.10"
    id("org.jetbrains.kotlin.plugin.serialization") version "1.9.10"
}

group = "com.jared747.assist"
version = "1.0-SNAPSHOT"

application {
    mainClass.set("com.jared747.assist.ApplicationKt")
}

repositories {
    mavenCentral()
}

dependencies {
    implementation("io.ktor:ktor-server-core:2.3.4")
    implementation("io.ktor:ktor-server-netty:2.3.4")
    implementation("io.ktor:ktor-server-content-negotiation:2.3.4")
    implementation("io.ktor:ktor-serialization-kotlinx-json:2.3.4")
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.0")
    implementation("io.ktor:ktor-server-call-logging:2.3.4")
    implementation("ch.qos.logback:logback-classic:1.4.11")
    
    // Exposed ORM for PostgreSQL
    implementation("org.jetbrains.exposed:exposed-core:0.45.0")
    implementation("org.jetbrains.exposed:exposed-dao:0.45.0")
    implementation("org.jetbrains.exposed:exposed-jdbc:0.45.0")
    implementation("org.postgresql:postgresql:42.7.1")
    implementation("com.zaxxer:HikariCP:5.0.1")
}
EOF

# backend Application.kt
mkdir -p backend/src/main/kotlin/com/jared747/assist
cat > backend/src/main/kotlin/com/jared747/assist/Application.kt <<'EOF'
package com.jared747.assist

import io.ktor.server.application.Application
import io.ktor.server.application.call
import io.ktor.server.application.install
import io.ktor.server.features.ContentNegotiation
import io.ktor.serialization.kotlinx.json.json
import io.ktor.server.routing.routing
import io.ktor.server.response.respond
import io.ktor.server.request.receive
import io.ktor.server.features.CallLogging
import kotlinx.serialization.Serializable
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.transactions.transaction

/**
 * Entry point for the backend application. This Ktor server exposes a simple REST API
 * that allows clients to manage boards, lists, tickets, and comments. The API is
 * deliberately minimal at this stage but lays the groundwork for more complex logic
 * such as user authentication, authorization, and AI-assisted operations.
 */
fun main(args: Array<String>): Unit = io.ktor.server.netty.EngineMain.main(args)

fun Application.module() {
    install(CallLogging)
    install(ContentNegotiation) {
        json()
    }

    // Initialize the database connection. See DatabaseFactory for details.
    DatabaseFactory.init()

    routing {
        get("/health") {
            call.respond(mapOf("status" to "ok"))
        }

        // Boards endpoints
        get("/boards") {
            val boards = transaction { BoardTable.selectAll().map { it[BoardTable.name] to it[BoardTable.id].value } }
            call.respond(boards)
        }
        post("/boards") {
            val request = call.receive<BoardRequest>()
            val id = transaction {
                BoardTable.insertAndGetId { it[name] = request.name }.value
            }
            call.respond(BoardResponse(id = id, name = request.name))
        }
    }
}

/** Database configuration using HikariCP and Exposed. */
object DatabaseFactory {
    fun init() {
        val url = System.getenv("DATABASE_URL") ?: "jdbc:postgresql://localhost:5432/assist"
        val user = System.getenv("DATABASE_USERNAME") ?: "assist"
        val password = System.getenv("DATABASE_PASSWORD") ?: "assist"
        val driver = "org.postgresql.Driver"
        val database = Database.connect(url = url, user = user, password = password, driver = driver)
        transaction(database) {
            SchemaUtils.create(BoardTable)
        }
    }
}

/**
 * Table definitions. Exposed uses objects derived from [IntIdTable] to represent tables
 * with auto-increment integer IDs. Relationships between tables will be added later.
 */
object BoardTable : IntIdTable("boards") {
    val name = varchar("name", length = 255)
}

@Serializable
data class BoardRequest(val name: String)

@Serializable
data class BoardResponse(val id: Int, val name: String)
EOF

# backend application.conf
mkdir -p backend/src/main/resources
cat > backend/src/main/resources/application.conf <<'EOF'
ktor {
    deployment {
        port = 8080
        watch = [ "com.jared747.assist" ]
    }
    application {
        modules = [ com.jared747.assist.ApplicationKt.module ]
    }
}
EOF

# Terraform infrastructure files
cat > infra/main.tf <<'EOF'
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_db_instance" "assist" {
  identifier        = "assist-${var.environment}"
  engine            = "postgres"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  username          = var.db_username
  password          = var.db_password
  skip_final_snapshot = true
}

output "db_endpoint" {
  value = aws_db_instance.assist.endpoint
}
EOF

cat > infra/variables.tf <<'EOF'
variable "region" {
  description = "AWS region to deploy resources in"
  type        = string
}

variable "environment" {
  description = "Environment name (dev or prod)"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}
EOF

cat > infra/dev.tfvars <<'EOF'
environment = "dev"
region      = "us-east-1"
db_username = "assist_dev"
db_password = "assist_dev_pass"
EOF

cat > infra/prod.tfvars <<'EOF'
environment = "prod"
region      = "us-east-1"
db_username = "assist_prod"
db_password = "assist_prod_pass"
EOF

# GitHub Actions workflows
mkdir -p .github/workflows
cat > .github/workflows/backend.yml <<'EOF'
name: Backend CI/CD

on:
  push:
    branches: [ "main" ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-java@v3
        with:
          distribution: temurin
          java-version: 17
      - uses: gradle/gradle-build-action@v2
        with:
          arguments: "backend:build"
      # TODO: Add steps to build Docker image, push to ECR, and deploy to App Runner or ECS
EOF

cat > .github/workflows/android.yml <<'EOF'
name: Android CI

on:
  push:
    branches: [ "main" ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-java@v3
        with:
          distribution: temurin
          java-version: 17
      - uses: android-actions/setup-android@v3
      - run: ./gradlew app:assembleDevDebug
EOF