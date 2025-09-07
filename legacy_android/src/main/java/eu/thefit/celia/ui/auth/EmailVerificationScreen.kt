package eu.thefit.celia.ui.auth

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Email
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import eu.thefit.celia.R
import kotlinx.coroutines.delay
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.compose.foundation.BorderStroke

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EmailVerificationScreen(
    viewModel: AuthViewModel = hiltViewModel(),
    onEmailVerified: () -> Unit,
    onSignOut: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsState()
    
    // Check verification status periodically
    LaunchedEffect(key1 = Unit) {
        while (true) {
            viewModel.checkEmailVerification()
            if (viewModel.isEmailVerified) {
                onEmailVerified()
                break
            }
            delay(3000) // Check every 3 seconds
        }
    }
    
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            TopAppBar(
                title = { Text("Email Verification") },
                actions = {
                    IconButton(onClick = onSignOut) {
                        Icon(
                            imageVector = Icons.Default.Refresh,
                            contentDescription = "Sign Out"
                        )
                    }
                },
                modifier = Modifier.fillMaxWidth(),
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = Color.Black,
                    titleContentColor = Color.White,
                    actionIconContentColor = Color.White
                )
            )
            
            Spacer(modifier = Modifier.height(32.dp))
            
            // App title
            Text(
                text = "celia",
                style = MaterialTheme.typography.displayLarge,
                fontWeight = FontWeight.Bold,
                color = Color(0xFFF57C00),
                fontSize = 60.sp
            )
            
            Spacer(modifier = Modifier.height(8.dp))
            
            // Subtitle
            Text(
                text = "Your fitness buddy",
                style = MaterialTheme.typography.headlineSmall,
                color = Color(0xFFF57C00)
            )
            
            Spacer(modifier = Modifier.height(32.dp))
            
            Icon(
                imageVector = Icons.Default.Email,
                contentDescription = "Email Icon",
                tint = Color(0xFFF57C00),
                modifier = Modifier.size(64.dp)
            )
            
            Spacer(modifier = Modifier.height(16.dp))
            
            Text(
                text = "Verify Your Email",
                style = MaterialTheme.typography.headlineMedium,
                color = Color.White,
                fontWeight = FontWeight.Bold
            )
            
            Spacer(modifier = Modifier.height(16.dp))
            
            // Debug current values
            LaunchedEffect(uiState) {
                println("DEBUG: Email verification - currentUser email: ${uiState.currentUser?.email}")
                println("DEBUG: Email verification - lastUsedEmail: ${uiState.lastUsedEmail}")
            }
            
            Spacer(modifier = Modifier.height(16.dp))
            
            Text(
                text = "We've sent a verification email to you",
                style = MaterialTheme.typography.bodyLarge,
                color = Color.White,
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(horizontal = 32.dp)
            )
            
            Spacer(modifier = Modifier.height(8.dp))
            
            Text(
                text = "Please check your inbox and verify your email address to continue.",
                style = MaterialTheme.typography.bodyMedium,
                color = Color.Gray,
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(horizontal = 32.dp)
            )
            
            Spacer(modifier = Modifier.height(24.dp))
            
            if (uiState.verificationEmailSent) {
                Text(
                    text = "Verification email sent!",
                    color = Color(0xFF4CAF50),
                    style = MaterialTheme.typography.bodyLarge,
                    fontWeight = FontWeight.Bold
                )
                Spacer(modifier = Modifier.height(16.dp))
            }
            
            // Primary action button
            Button(
                onClick = {
                    viewModel.checkEmailVerification()
                },
                enabled = !uiState.isLoading,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(50.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color(0xFFF57C00)
                ),
                shape = RoundedCornerShape(24.dp)
            ) {
                if (uiState.isLoading) {
                    CircularProgressIndicator(
                        color = Color.White,
                        modifier = Modifier.size(24.dp)
                    )
                } else {
                    Text("I've Verified My Email")
                }
            }
            
            Spacer(modifier = Modifier.height(16.dp))
            
            // Resend verification email button
            OutlinedButton(
                onClick = {
                    viewModel.sendVerificationEmail()
                },
                enabled = !uiState.isLoading,
                modifier = Modifier.fillMaxWidth(),
                border = BorderStroke(1.dp, Color(0xFFF57C00)),
                colors = ButtonDefaults.outlinedButtonColors(
                    contentColor = Color(0xFFF57C00)
                ),
                shape = RoundedCornerShape(24.dp)
            ) {
                if (uiState.isLoading) {
                    CircularProgressIndicator(
                        color = Color(0xFFF57C00),
                        modifier = Modifier.size(24.dp)
                    )
                } else {
                    Text("Resend Verification Email")
                }
            }
            
            Spacer(modifier = Modifier.height(16.dp))
            
            // Sign out button
            TextButton(
                onClick = onSignOut,
                colors = ButtonDefaults.textButtonColors(
                    contentColor = Color.Gray
                ),
                shape = RoundedCornerShape(16.dp)
            ) {
                Text("Sign Out")
            }
            
            // Version number
            Text(
                text = "Version 1.1.2",
                color = Color.Gray,
                style = MaterialTheme.typography.bodySmall
            )
        }
        
        // Loading indicator
        if (uiState.isLoading) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Color.Black.copy(alpha = 0.5f)),
                contentAlignment = Alignment.Center
            ) {
                CircularProgressIndicator(
                    color = Color(0xFFF57C00)
                )
            }
        }
    }
} 