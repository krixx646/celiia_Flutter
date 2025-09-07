package eu.thefit.celia.di

import android.content.Context
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.ktx.auth
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.ktx.firestore
import com.google.firebase.ktx.Firebase
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import eu.thefit.celia.R
import eu.thefit.celia.data.repository.AuthRepository
import eu.thefit.celia.data.repository.FirebaseAuthRepository
import eu.thefit.celia.data.repository.ChatHistoryRepository
import eu.thefit.celia.data.repository.FirestoreChatHistoryRepository
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object FirebaseModule {

    @Provides
    @Singleton
    fun provideFirebaseAuth(): FirebaseAuth = Firebase.auth

    @Provides
    @Singleton
    fun provideFirebaseFirestore(): FirebaseFirestore = Firebase.firestore

    @Provides
    @Singleton
    fun provideGoogleSignInOptions(@ApplicationContext context: Context): GoogleSignInOptions {
        return GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestIdToken(context.getString(R.string.default_web_client_id))
            .requestEmail()
            .build()
    }

    @Provides
    @Singleton
    fun provideGoogleSignInClient(
        @ApplicationContext context: Context,
        options: GoogleSignInOptions
    ): GoogleSignInClient = GoogleSignIn.getClient(context, options)

    @Provides
    @Singleton
    fun provideAuthRepository(
        auth: FirebaseAuth,
        googleSignInClient: GoogleSignInClient
    ): AuthRepository = FirebaseAuthRepository(auth, googleSignInClient)

    @Provides
    @Singleton
    fun provideChatHistoryRepository(
        auth: FirebaseAuth,
        firestore: FirebaseFirestore
    ): ChatHistoryRepository = FirestoreChatHistoryRepository(auth, firestore)
} 