package eu.thefit.celia

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import dagger.hilt.android.AndroidEntryPoint
import eu.thefit.celia.ui.auth.AuthScreen
import eu.thefit.celia.ui.auth.AuthViewModel
import eu.thefit.celia.ui.auth.EmailVerificationScreen
import eu.thefit.celia.ui.auth.ForgotPasswordScreen
import eu.thefit.celia.ui.chat.ChatScreen
import eu.thefit.celia.ui.theme.CeliaTheme

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            CeliaTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    AppNavigation()
                }
            }
        }
    }
}

@Composable
fun AppNavigation() {
    val navController = rememberNavController()
    val authViewModel: AuthViewModel = hiltViewModel()
    val authState by authViewModel.uiState.collectAsState()
    
    val startDestination = when {
        !authState.isAuthenticated -> "auth"
        authState.isAuthenticated && !authState.isEmailVerified -> "email_verification"
        else -> "chat"
    }
    
    NavHost(
        navController = navController,
        startDestination = startDestination
    ) {
        composable("auth") {
            AuthScreen(
                onNavigateToChat = {
                    if (authState.isEmailVerified) {
                        navController.navigate("chat") {
                            popUpTo("auth") { inclusive = true }
                        }
                    } else {
                        navController.navigate("email_verification") {
                            popUpTo("auth") { inclusive = true }
                        }
                    }
                },
                onNavigateToForgotPassword = { 
                    navController.navigate("forgot_password") 
                }
            )
        }
        
        composable("forgot_password") {
            ForgotPasswordScreen(
                onNavigateBack = { navController.popBackStack() }
            )
        }
        
        composable("email_verification") {
            EmailVerificationScreen(
                viewModel = authViewModel,
                onEmailVerified = {
                    navController.navigate("chat") {
                        popUpTo("email_verification") { inclusive = true }
                    }
                },
                onSignOut = {
                    authViewModel.signOut()
                    navController.navigate("auth") {
                        popUpTo("email_verification") { inclusive = true }
                    }
                }
            )
        }
        
        composable("chat") {
            ChatScreen(
                onSignOut = {
                    authViewModel.signOut()
                    navController.navigate("auth") {
                        popUpTo("chat") { inclusive = true }
                    }
                }
            )
        }
    }
}