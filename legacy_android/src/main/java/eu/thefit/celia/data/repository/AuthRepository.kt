package eu.thefit.celia.data.repository

import android.content.Intent
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseUser
import com.google.firebase.auth.GoogleAuthProvider
import kotlinx.coroutines.tasks.await
import javax.inject.Inject
import javax.inject.Singleton

interface AuthRepository {
    val currentUser: FirebaseUser?
    val isUserAuthenticated: Boolean
    val isEmailVerified: Boolean
    
    suspend fun signIn(email: String, password: String): Result<FirebaseUser>
    suspend fun signUp(email: String, password: String): Result<FirebaseUser>
    suspend fun resetPassword(email: String): Result<Unit>
    suspend fun signInWithGoogle(googleIdToken: String): Result<FirebaseUser>
    suspend fun sendEmailVerification(): Result<Unit>
    suspend fun reloadUser(): Result<FirebaseUser>
    fun getGoogleSignInIntent(): Intent
    fun signOut()
}

@Singleton
class FirebaseAuthRepository @Inject constructor(
    private val auth: FirebaseAuth,
    private val googleSignInClient: GoogleSignInClient
) : AuthRepository {
    
    override val currentUser: FirebaseUser?
        get() = auth.currentUser
        
    override val isUserAuthenticated: Boolean
        get() = auth.currentUser != null

    override val isEmailVerified: Boolean
        get() = auth.currentUser?.isEmailVerified ?: false
    
    override suspend fun signIn(email: String, password: String): Result<FirebaseUser> = try {
        val result = auth.signInWithEmailAndPassword(email, password).await()
        result.user?.let {
            Result.success(it)
        } ?: Result.failure(Exception("Authentication failed"))
    } catch (e: Exception) {
        Result.failure(e)
    }
    
    override suspend fun signUp(email: String, password: String): Result<FirebaseUser> = try {
        val result = auth.createUserWithEmailAndPassword(email, password).await()
        result.user?.let { user ->
            // Send verification email
            try {
                user.sendEmailVerification().await()
            } catch (e: Exception) {
                // Log error but don't fail the sign-up
                println("Failed to send verification email: ${e.message}")
            }
            Result.success(user)
        } ?: Result.failure(Exception("Registration failed"))
    } catch (e: Exception) {
        Result.failure(e)
    }
    
    override suspend fun resetPassword(email: String): Result<Unit> = try {
        auth.sendPasswordResetEmail(email).await()
        Result.success(Unit)
    } catch (e: Exception) {
        Result.failure(e)
    }
    
    override suspend fun signInWithGoogle(googleIdToken: String): Result<FirebaseUser> = try {
        val credential = GoogleAuthProvider.getCredential(googleIdToken, null)
        val result = auth.signInWithCredential(credential).await()
        result.user?.let {
            Result.success(it)
        } ?: Result.failure(Exception("Google sign-in failed"))
    } catch (e: Exception) {
        Result.failure(e)
    }
    
    override suspend fun sendEmailVerification(): Result<Unit> = try {
        auth.currentUser?.let { user ->
            user.sendEmailVerification().await()
            Result.success(Unit)
        } ?: Result.failure(Exception("No user logged in"))
    } catch (e: Exception) {
        Result.failure(e)
    }
    
    override suspend fun reloadUser(): Result<FirebaseUser> = try {
        auth.currentUser?.let { user ->
            user.reload().await()
            Result.success(auth.currentUser!!)
        } ?: Result.failure(Exception("No user logged in"))
    } catch (e: Exception) {
        Result.failure(e)
    }
    
    override fun getGoogleSignInIntent(): Intent {
        return googleSignInClient.signInIntent
    }
    
    override fun signOut() {
        auth.signOut()
        googleSignInClient.signOut()
    }
} 