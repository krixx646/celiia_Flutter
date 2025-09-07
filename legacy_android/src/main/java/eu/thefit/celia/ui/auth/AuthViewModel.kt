package eu.thefit.celia.ui.auth

import android.content.Intent
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInAccount
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.tasks.Task
import com.google.firebase.auth.FirebaseUser
import dagger.hilt.android.lifecycle.HiltViewModel
import eu.thefit.celia.data.repository.AuthRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class AuthViewModel @Inject constructor(
    private val authRepository: AuthRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(AuthUiState())
    val uiState: StateFlow<AuthUiState> = _uiState.asStateFlow()

    // Store the email address used for sign-up
    private var signUpEmail: String = ""

    val isUserAuthenticated: Boolean
        get() = authRepository.isUserAuthenticated

    val isEmailVerified: Boolean
        get() = authRepository.isEmailVerified

    init {
        // Check if user is already signed in
        authRepository.currentUser?.let { user ->
            // Update authenticated state
            _uiState.update { it.copy(
                isAuthenticated = true,
                currentUser = user,
                isEmailVerified = user.isEmailVerified
            ) }
            
            // If email verification is required but email is not verified
            if (!user.isEmailVerified) {
                _uiState.update { it.copy(
                    needsEmailVerification = true
                ) }
            }
        }
    }

    fun signIn(email: String, password: String) {
        _uiState.update { it.copy(
            isLoading = true,
            authError = null
        ) }

        viewModelScope.launch {
            authRepository.signIn(email, password)
                .onSuccess { user ->
                    // Reload user to get latest verification status
                    authRepository.reloadUser()
                    
                    _uiState.update { it.copy(
                        isAuthenticated = true,
                        isLoading = false,
                        currentUser = user,
                        isEmailVerified = user.isEmailVerified,
                        needsEmailVerification = !user.isEmailVerified,
                        authError = null,
                        lastUsedEmail = email
                    ) }
                }
                .onFailure { exception ->
                    _uiState.update { it.copy(
                        isAuthenticated = false,
                        isLoading = false,
                        authError = exception.message ?: "Authentication failed"
                    ) }
                }
        }
    }

    fun saveEmailForVerification(email: String) {
        // Explicitly save the email for verification screen
        println("DEBUG: Saving email for verification: $email")
        _uiState.update { it.copy(lastUsedEmail = email) }
    }

    fun signUp(email: String, password: String) {
        // Save email immediately, before any async operations
        saveEmailForVerification(email)
        
        _uiState.update { it.copy(
            isLoading = true,
            authError = null
        ) }
        
        // Store the email for verification screen (redundant backup)
        signUpEmail = email

        viewModelScope.launch {
            authRepository.signUp(email, password)
                .onSuccess { user ->
                    _uiState.update { it.copy(
                        isAuthenticated = true,
                        isLoading = false,
                        currentUser = user,
                        isEmailVerified = false,
                        needsEmailVerification = true,
                        authError = null,
                        lastUsedEmail = email // Store email in the UI state again
                    ) }
                }
                .onFailure { exception ->
                    _uiState.update { it.copy(
                        isAuthenticated = false,
                        isLoading = false,
                        authError = exception.message ?: "Registration failed"
                    ) }
                }
        }
    }

    fun resetPassword(email: String) {
        _uiState.update { it.copy(
            isLoading = true,
            authError = null,
            passwordResetEmailSent = false
        ) }

        viewModelScope.launch {
            authRepository.resetPassword(email)
                .onSuccess {
                    _uiState.update { it.copy(
                        isLoading = false,
                        passwordResetEmailSent = true,
                        authError = null
                    ) }
                }
                .onFailure { exception ->
                    _uiState.update { it.copy(
                        isLoading = false,
                        passwordResetEmailSent = false,
                        authError = exception.message ?: "Password reset failed"
                    ) }
                }
        }
    }

    fun sendVerificationEmail() {
        _uiState.update { it.copy(
            isLoading = true,
            verificationEmailSent = false,
            authError = null
        ) }

        viewModelScope.launch {
            authRepository.sendEmailVerification()
                .onSuccess {
                    _uiState.update { it.copy(
                        isLoading = false,
                        verificationEmailSent = true
                    ) }
                }
                .onFailure { exception ->
                    _uiState.update { it.copy(
                        isLoading = false,
                        authError = exception.message ?: "Failed to send verification email"
                    ) }
                }
        }
    }

    fun checkEmailVerification() {
        viewModelScope.launch {
            authRepository.reloadUser()
                .onSuccess { user ->
                    _uiState.update { it.copy(
                        isEmailVerified = user.isEmailVerified,
                        needsEmailVerification = !user.isEmailVerified
                    ) }
                }
        }
    }

    fun getGoogleSignInIntent(): Intent {
        return authRepository.getGoogleSignInIntent()
    }

    fun handleGoogleSignInResult(task: Task<GoogleSignInAccount>) {
        try {
            val account = task.getResult(ApiException::class.java)
            account?.idToken?.let { token ->
                signInWithGoogle(token)
            }
        } catch (e: ApiException) {
            _uiState.update { it.copy(
                isLoading = false,
                authError = "Google sign-in failed: ${e.message}"
            ) }
        }
    }

    private fun signInWithGoogle(idToken: String) {
        _uiState.update { it.copy(
            isLoading = true,
            authError = null
        ) }

        viewModelScope.launch {
            authRepository.signInWithGoogle(idToken)
                .onSuccess { user ->
                    _uiState.update { it.copy(
                        isAuthenticated = true,
                        isLoading = false,
                        currentUser = user,
                        isEmailVerified = true, // Google sign-in emails are pre-verified
                        needsEmailVerification = false,
                        authError = null
                    ) }
                }
                .onFailure { exception ->
                    _uiState.update { it.copy(
                        isAuthenticated = false,
                        isLoading = false,
                        authError = exception.message ?: "Google sign-in failed"
                    ) }
                }
        }
    }

    fun signOut() {
        authRepository.signOut()
        _uiState.update {
            AuthUiState()
        }
    }

    fun clearError() {
        _uiState.update { it.copy(authError = null) }
    }

    fun clearPasswordResetEmailSent() {
        _uiState.update { it.copy(passwordResetEmailSent = false) }
    }
    
    fun clearVerificationEmailSent() {
        _uiState.update { it.copy(verificationEmailSent = false) }
    }

    // Add method to set auth error message
    fun setAuthError(errorMessage: String) {
        _uiState.update { it.copy(
            authError = errorMessage,
            isLoading = false
        ) }
    }
}

data class AuthUiState(
    val isAuthenticated: Boolean = false,
    val isLoading: Boolean = false,
    val currentUser: FirebaseUser? = null,
    val isEmailVerified: Boolean = false,
    val needsEmailVerification: Boolean = false,
    val verificationEmailSent: Boolean = false,
    val authError: String? = null,
    val passwordResetEmailSent: Boolean = false,
    val lastUsedEmail: String = ""
) 