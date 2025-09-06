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
