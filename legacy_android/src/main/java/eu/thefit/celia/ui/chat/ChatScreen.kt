package eu.thefit.celia.ui.chat

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.expandVertically
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.Image
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Send
import androidx.compose.material.icons.filled.ExitToApp
import androidx.compose.material.icons.filled.Logout
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.History
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import eu.thefit.celia.data.model.Message
import eu.thefit.celia.data.model.MessageOption
import coil.compose.AsyncImage
import androidx.compose.foundation.text.ClickableText
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.platform.LocalSoftwareKeyboardController
import androidx.compose.ui.platform.LocalUriHandler
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.text.withStyle
import java.util.regex.Pattern
import androidx.compose.ui.text.font.FontWeight
import eu.thefit.celia.R
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.AlertDialog
import androidx.compose.foundation.clickable
import androidx.compose.ui.draw.clip

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ChatScreen(
    viewModel: ChatViewModel = hiltViewModel(),
    onSignOut: () -> Unit = {}
) {
    val uiState by viewModel.uiState.collectAsState()
    var showRestartConfirmation by remember { mutableStateOf(false) }
    
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.White)
            .padding(8.dp)
            .navigationBarsPadding()
    ) {
        // Add a top app bar with sign-out button
        TopAppBar(
            title = { Text("Coach Celia") },
            actions = {
                IconButton(onClick = { onSignOut() }) {
                    Icon(
                        imageVector = Icons.Default.Logout,
                        contentDescription = "Sign Out"
                    )
                }
            },
            colors = TopAppBarDefaults.topAppBarColors(
                containerColor = Color(0xFFF57C00),
                titleContentColor = Color.White,
                actionIconContentColor = Color.White
            ),
            modifier = Modifier
                .padding(horizontal = 8.dp, vertical = 4.dp)
                .clip(RoundedCornerShape(16.dp))
        )
        
        // Add some extra space at the top to keep clear of the status bar pull-down area
        Spacer(modifier = Modifier.height(8.dp))
        
        // Add Row for "New Chat" and "History" buttons
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 12.dp),
            horizontalArrangement = Arrangement.SpaceBetween, // Change to SpaceBetween to place buttons on opposite sides
            verticalAlignment = Alignment.CenterVertically
        ) {
            // New Chat button (left side)
            Button(
                onClick = { showRestartConfirmation = true },
                modifier = Modifier
                    .padding(vertical = 8.dp, horizontal = 8.dp)
                    .height(48.dp),
                shape = RoundedCornerShape(24.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color(0xFFF57C00)
                )
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    modifier = Modifier.padding(horizontal = 8.dp)
                ) {
                    Icon(
                        imageVector = Icons.Filled.Refresh,
                        contentDescription = "Restart conversation",
                        modifier = Modifier.height(24.dp)
                    )
                    Text(
                        "New Chat",
                        style = MaterialTheme.typography.titleMedium
                    )
                }
            }
            
            // History button (right side)
            Button(
                onClick = { viewModel.showHistoryDialog() },
                modifier = Modifier
                    .padding(vertical = 8.dp, horizontal = 8.dp)
                    .height(48.dp),
                shape = RoundedCornerShape(24.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color(0xFFF57C00)
                )
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    modifier = Modifier.padding(horizontal = 8.dp)
                ) {
                    Icon(
                        imageVector = Icons.Default.History,
                        contentDescription = "Chat History",
                        modifier = Modifier.height(24.dp)
                    )
                    Text(
                        "History",
                        style = MaterialTheme.typography.titleMedium
                    )
                }
            }
        }
        
        // Restart confirmation dialog
        if (showRestartConfirmation) {
            androidx.compose.material3.AlertDialog(
                onDismissRequest = { showRestartConfirmation = false },
                title = { 
                    Text(
                        "Restart Conversation",
                        style = MaterialTheme.typography.headlineSmall
                    ) 
                },
                text = { 
                    Text(
                        "Are you sure you want to start a new conversation? This will clear all current messages.",
                        style = MaterialTheme.typography.bodyLarge
                    ) 
                },
                confirmButton = {
                    androidx.compose.material3.Button(
                        onClick = {
                            viewModel.resetConversation()
                            showRestartConfirmation = false
                        }
                    ) {
                        Text("Restart")
                    }
                },
                dismissButton = {
                    androidx.compose.material3.OutlinedButton(
                        onClick = { showRestartConfirmation = false }
                    ) {
                        Text("Cancel")
                    }
                },
                containerColor = MaterialTheme.colorScheme.surface,
                tonalElevation = 8.dp
            )
        }
        
        // Chat History Dialog
        if (uiState.showHistoryDialog) {
            AlertDialog(
                onDismissRequest = { viewModel.dismissHistoryDialog() },
                title = { Text("Chat History") },
                text = {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .heightIn(max = 400.dp)
                    ) {
                        if (uiState.savedConversations.isEmpty()) {
                            Text(
                                "No saved conversations yet. Start chatting and save your conversations to see them here.",
                                style = MaterialTheme.typography.bodyMedium,
                                textAlign = TextAlign.Center,
                                modifier = Modifier.padding(vertical = 16.dp)
                            )
                        } else {
                            LazyColumn {
                                items(uiState.savedConversations) { conversation ->
                                    Card(
                                        modifier = Modifier
                                            .fillMaxWidth()
                                            .padding(vertical = 4.dp)
                                            .clickable { viewModel.loadConversation(conversation) },
                                        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
                                    ) {
                                        Row(
                                            modifier = Modifier
                                                .fillMaxWidth()
                                                .padding(16.dp),
                                            horizontalArrangement = Arrangement.SpaceBetween,
                                            verticalAlignment = Alignment.CenterVertically
                                        ) {
                                            Column(
                                                modifier = Modifier.weight(1f)
                                            ) {
                                                Text(
                                                    text = conversation.title,
                                                    style = MaterialTheme.typography.titleMedium,
                                                    fontWeight = FontWeight.Bold
                                                )
                                                Text(
                                                    text = conversation.timestamp,
                                                    style = MaterialTheme.typography.bodySmall,
                                                    color = Color.Gray
                                                )
                                                Text(
                                                    text = "${conversation.messages.size} messages",
                                                    style = MaterialTheme.typography.bodySmall,
                                                    color = Color.Gray
                                                )
                                            }
                                            IconButton(
                                                onClick = { viewModel.deleteConversation(conversation.id) }
                                            ) {
                                                Icon(
                                                    imageVector = Icons.Default.Delete,
                                                    contentDescription = "Delete conversation",
                                                    tint = Color.Gray
                                                )
                                            }
                                        }
                                    }
                                    Spacer(modifier = Modifier.height(8.dp))
                                }
                            }
                        }
                    }
                },
                confirmButton = {
                    Button(
                        onClick = { viewModel.dismissHistoryDialog() },
                        colors = ButtonDefaults.buttonColors(
                            containerColor = Color(0xFFF57C00)
                        )
                    ) {
                        Text("Close")
                    }
                },
                dismissButton = {
                    if (uiState.messages.isNotEmpty()) {
                        Button(
                            onClick = { 
                                viewModel.dismissHistoryDialog()
                                viewModel.showSaveConversationDialog()
                            },
                            colors = ButtonDefaults.buttonColors(
                                containerColor = Color(0xFF4CAF50) // Green color for save
                            )
                        ) {
                            Text("Save Current")
                        }
                    }
                }
            )
        }
        
        // Save Conversation Dialog
        if (uiState.saveDialogOpen) {
            AlertDialog(
                onDismissRequest = { viewModel.dismissSaveDialog() },
                title = { Text("Save Conversation") },
                text = {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(8.dp)
                    ) {
                        Text(
                            "Give your conversation a title:",
                            style = MaterialTheme.typography.bodyMedium
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        OutlinedTextField(
                            value = uiState.saveConversationTitle,
                            onValueChange = { viewModel.updateSaveTitle(it) },
                            modifier = Modifier.fillMaxWidth(),
                            placeholder = { Text("Enter title", color = Color(0xFFF57C00).copy(alpha = 0.7f)) },
                            singleLine = true,
                            shape = RoundedCornerShape(24.dp),
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedTextColor = Color(0xFFF57C00),
                                unfocusedTextColor = Color(0xFFF57C00),
                                focusedBorderColor = Color(0xFFF57C00),
                                unfocusedBorderColor = Color.Gray,
                                cursorColor = Color(0xFFF57C00)
                            )
                        )
                    }
                },
                confirmButton = {
                    Button(
                        onClick = { viewModel.saveCurrentConversation() },
                        colors = ButtonDefaults.buttonColors(
                            containerColor = Color(0xFFF57C00)
                        ),
                        shape = RoundedCornerShape(24.dp)
                    ) {
                        Text("Save")
                    }
                },
                dismissButton = {
                    Button(
                        onClick = { viewModel.dismissSaveDialog() },
                        colors = ButtonDefaults.buttonColors(
                            containerColor = Color.Gray
                        ),
                        shape = RoundedCornerShape(24.dp)
                    ) {
                        Text("Cancel")
                    }
                },
                shape = RoundedCornerShape(16.dp)
            )
        }
        
        // Messages
        val listState = rememberLazyListState()
        
        Box(
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth()
        ) {
            // Show welcome screen when there are no messages
            if (uiState.messages.isEmpty()) {
                WelcomeScreen()
            }
            
            // Regular message list (will overlay welcome screen when messages exist)
            LazyColumn(
                modifier = Modifier
                    .fillMaxSize(),
                state = listState,
                verticalArrangement = Arrangement.spacedBy(6.dp)
            ) {
                items(uiState.messages) { message ->
                    // Get index of this message for alternating styles
                    val messageIndex = uiState.messages.indexOf(message)
                    
                    MessageItem(
                        message = message,
                        messageIndex = messageIndex,
                        onOptionSelected = { option ->
                            viewModel.sendMessage(option.value)
                        }
                    )
                }
            }
        }
        
        // Scroll to bottom when new messages arrive
        LaunchedEffect(uiState.messages.size) {
            if (uiState.messages.isNotEmpty()) {
                listState.animateScrollToItem(uiState.messages.size - 1)
            }
        }
        
        Spacer(modifier = Modifier.height(8.dp))
        
        // Message input
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            val focusRequester = remember { FocusRequester() }
            val keyboardController = LocalSoftwareKeyboardController.current
            val focusManager = LocalFocusManager.current
            
            OutlinedTextField(
                value = uiState.inputText,
                onValueChange = { viewModel.onInputChange(it) },
                placeholder = { Text("Type a message") },
                modifier = Modifier
                    .weight(1f)
                    .focusRequester(focusRequester),
                keyboardOptions = KeyboardOptions(
                    imeAction = ImeAction.Send
                ),
                keyboardActions = KeyboardActions(
                    onSend = {
                        if (uiState.inputText.isNotBlank()) {
                            viewModel.sendMessage(uiState.inputText)
                            focusManager.clearFocus()
                        }
                    }
                ),
                maxLines = 3,
                singleLine = false,
                shape = RoundedCornerShape(24.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedTextColor = Color.Black,
                    unfocusedTextColor = Color.Black,
                    focusedBorderColor = Color(0xFFF57C00),
                    unfocusedBorderColor = Color.Gray,
                    cursorColor = Color.Black
                )
            )
            
            Spacer(modifier = Modifier.width(8.dp))
            
            IconButton(
                onClick = { 
                    if (uiState.inputText.isNotBlank()) {
                        viewModel.sendMessage(uiState.inputText)
                        focusManager.clearFocus()
                    }
                },
                enabled = uiState.inputText.isNotBlank()
            ) {
                Icon(
                    imageVector = Icons.AutoMirrored.Filled.Send,
                    contentDescription = "Send",
                    tint = Color(0xFFF57C00),
                    modifier = Modifier.size(32.dp)
                )
            }
        }
    }
}

@Composable
private fun WelcomeScreen() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Image(
            painter = androidx.compose.ui.res.painterResource(id = R.drawable.logo_the_fit),
            contentDescription = "The Fit Logo",
            modifier = Modifier
                .size(200.dp)
                .padding(bottom = 32.dp)
        )
        Text(
            text = "Hi, I'm Coach Celia.",
            style = MaterialTheme.typography.headlineMedium,
            color = Color(0xFFF57C00),
            fontWeight = FontWeight.Bold,
            modifier = Modifier.padding(bottom = 16.dp)
        )
        Text(
            text = "How can I get you in shape today?",
            style = MaterialTheme.typography.titleLarge,
            color = Color(0xFFF57C00),
            fontWeight = FontWeight.Bold
        )
    }
}

@Composable
private fun MessageItem(
    message: Message,
    messageIndex: Int,
    onOptionSelected: (MessageOption) -> Unit,
    modifier: Modifier = Modifier
) {
    // FORCE ALTERNATING PATTERN with special exceptions:
    // Even-indexed messages (0, 4, 8...) are generally treated as user messages (right/orange)
    // Odd-indexed messages (1, 3, 5...) are generally treated as bot messages (left/white)
    // EXCEPTION: Indices 2 and 6 should be bot messages
    
    val specialBotIndices = listOf(2, 6) // Special indices that should be bot messages
    
    val forcedIsUserMessage = if (specialBotIndices.contains(messageIndex)) {
        // Force these indices to be bot messages
        false
    } else {
        // Regular alternating pattern
        messageIndex % 2 == 0
    }
    
    // Color assignment based on our forced pattern
    val backgroundColor = if (forcedIsUserMessage) 
        Color(0xFFF57C00) // Orange color for user messages
    else 
        Color.White // White color for bot messages
    
    val textColor = if (forcedIsUserMessage) 
        Color.White // White text for user messages (already high contrast)
    else 
        Color(0xFF000000) // Pitch black text for bot messages for highest visibility
    
    // Align messages based on our forced pattern
    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp, horizontal = 4.dp),
        horizontalArrangement = if (forcedIsUserMessage) Arrangement.End else Arrangement.Start
    ) {
        // Allow messages to take up more screen space - increased percentages
        val bubbleWidth = when (message.type) {
            "image" -> 0.85f // 85% of screen width for images
            "dropdown", "button", "choice" -> 0.85f // 85% for interactive elements
            else -> 0.75f // 75% for text messages
        }
        
        val bubbleModifier = Modifier
            .fillMaxWidth(bubbleWidth)
        
        // Create a wrapper for onOptionSelected that also marks the message as interacted
        val handleOptionSelected: (MessageOption) -> Unit = { option ->
            // Mark this message as interacted immediately in the UI
            message.interacted = true
            // Call the original onOptionSelected handler
            onOptionSelected(option)
        }
            
        when (message.type) {
            "image" -> ImageMessage(
                imageUrl = message.imageUrl,
                isUserMessage = forcedIsUserMessage,
                backgroundColor = backgroundColor,
                modifier = bubbleModifier
            )
            "dropdown" -> DropdownMessage(
                text = message.text,
                options = message.options,
                isUserMessage = forcedIsUserMessage,
                backgroundColor = backgroundColor,
                textColor = textColor,
                onOptionSelected = handleOptionSelected,
                modifier = bubbleModifier,
                isInteracted = message.interacted
            )
            "button", "choice" -> ButtonMessage(
                text = message.text,
                options = message.options,
                isUserMessage = forcedIsUserMessage,
                backgroundColor = backgroundColor,
                textColor = textColor,
                onOptionSelected = handleOptionSelected,
                modifier = bubbleModifier,
                isInteracted = message.interacted
            )
            else -> TextMessage(
                text = message.text ?: "[Content]",
                isUserMessage = forcedIsUserMessage,
                backgroundColor = backgroundColor,
                textColor = textColor,
                modifier = bubbleModifier
            )
        }
    }
}

// Helper function to get consistent bubble shapes
private fun getMessageBubbleShape(isUserMessage: Boolean): RoundedCornerShape {
    return RoundedCornerShape(
        topStart = 16.dp,
        topEnd = 16.dp,
        bottomStart = if (isUserMessage) 16.dp else 4.dp,
        bottomEnd = if (isUserMessage) 4.dp else 16.dp
    )
}

@Composable
private fun ImageMessage(
    imageUrl: String?,
    isUserMessage: Boolean,
    backgroundColor: Color,
    modifier: Modifier = Modifier
) {
    // Add border for bot messages
    val border = if (!isUserMessage) {
        androidx.compose.foundation.BorderStroke(
            width = 1.dp,
            color = Color.LightGray
        )
    } else null
    
    Surface(
        modifier = modifier,
        color = backgroundColor,
        shape = getMessageBubbleShape(isUserMessage),
        shadowElevation = 2.dp,
        border = border // Add border for bot messages
    ) {
        Column(modifier = Modifier.padding(12.dp)) {
            if (imageUrl != null) {
                AsyncImage(
                    model = imageUrl,
                    contentDescription = "Image message",
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(bottom = 4.dp)
                )
            } else {
                Text(
                    text = "[Image not available]",
                    style = MaterialTheme.typography.bodyMedium
                )
            }
        }
    }
}

@Composable
private fun TextMessage(
    text: String,
    isUserMessage: Boolean,
    backgroundColor: Color,
    textColor: Color,
    modifier: Modifier = Modifier
) {
    // Add border for bot messages
    val border = if (!isUserMessage) {
        androidx.compose.foundation.BorderStroke(
            width = 1.dp,
            color = Color.LightGray
        )
    } else null
    
    // URI handler to open links in browser
    val uriHandler = LocalUriHandler.current
    
    Surface(
        modifier = modifier,
        color = backgroundColor,
        shape = getMessageBubbleShape(isUserMessage),
        shadowElevation = 2.dp,
        border = border // Add border for bot messages
    ) {
        // Parse the text for links and format them nicely
        val annotatedText = buildAnnotatedString {
            // Pattern for formatted links like: |Download for Android|(https://play.google.com/...)
            // or [Download for Android](https://play.google.com/...)
            val formattedLinkPattern = Pattern.compile(
                "\\|(.*?)\\|\\((https?://[^\\s)]+)\\)|\\[(.*?)\\]\\((https?://[^\\s)]+)\\)",
                Pattern.CASE_INSENSITIVE
            )
            
            // Pattern for raw URLs
            val urlPattern = Pattern.compile(
                "((https?|ftp|gopher|telnet|file):((//)|(\\\\))+[\\w\\d:#@%/;$()~_?\\+-=\\\\\\.&]*)",
                Pattern.CASE_INSENSITIVE
            )
            
            val linkMatcher = formattedLinkPattern.matcher(text)
            
            if (linkMatcher.find()) {
                // Text contains formatted links, process them
                linkMatcher.reset()
                var lastEnd = 0
                
                while (linkMatcher.find()) {
                    // Add any text before this link
                    append(text.substring(lastEnd, linkMatcher.start()))
                    
                    // Extract display text and URL
                    val displayText = linkMatcher.group(1) ?: linkMatcher.group(3) ?: "Link"
                    val url = linkMatcher.group(2) ?: linkMatcher.group(4) ?: ""
                    
                    // Add the display text as a clickable link
                    val linkColor = if (isUserMessage) Color.White.copy(alpha = 0.9f) else Color.Blue
                    
                    pushStringAnnotation(tag = "URL", annotation = url)
                    withStyle(
                        style = SpanStyle(
                            color = linkColor,
                            textDecoration = TextDecoration.Underline
                        )
                    ) {
                        append(displayText)
                    }
                    pop()
                    
                    lastEnd = linkMatcher.end()
                }
                
                // Append any remaining text
                if (lastEnd < text.length) {
                    append(text.substring(lastEnd))
                }
            } else {
                // No formatted links, check for raw URLs
                val urlMatcher = urlPattern.matcher(text)
                var lastEnd = 0
                
                while (urlMatcher.find()) {
                    // Add text before URL
                    append(text.substring(lastEnd, urlMatcher.start()))
                    
                    // Add URL with special style and annotation
                    val urlText = text.substring(urlMatcher.start(), urlMatcher.end())
                    val linkColor = if (isUserMessage) Color.White.copy(alpha = 0.9f) else Color.Blue
                    
                    pushStringAnnotation(tag = "URL", annotation = urlText)
                    withStyle(
                        style = SpanStyle(
                            color = linkColor,
                            textDecoration = TextDecoration.Underline
                        )
                    ) {
                        append(urlText)
                    }
                    pop()
                    
                    lastEnd = urlMatcher.end()
                }
                
                // Add remaining text after last URL
                if (lastEnd < text.length) {
                    append(text.substring(lastEnd))
                }
            }
        }
        
        // Use ClickableText instead of Text to handle URL clicks
        ClickableText(
            text = annotatedText,
            onClick = { offset ->
                annotatedText.getStringAnnotations(tag = "URL", start = offset, end = offset)
                    .firstOrNull()?.let { annotation ->
                        // Open URL when clicked
                        try {
                            uriHandler.openUri(annotation.item)
                        } catch (e: Exception) {
                            // Silently handle error - don't print to console for production
                            // We could add error reporting or analytics here instead
                        }
                    }
            },
            style = MaterialTheme.typography.bodyMedium.copy(
                color = textColor,
                fontWeight = FontWeight.Bold
            ),
            modifier = Modifier.padding(12.dp)
        )
    }
}

@Composable
private fun DropdownMessage(
    text: String?,
    options: List<MessageOption>?,
    isUserMessage: Boolean,
    backgroundColor: Color,
    textColor: Color,
    onOptionSelected: (MessageOption) -> Unit,
    modifier: Modifier = Modifier,
    isInteracted: Boolean = false
) {
    // Add border for bot messages
    val border = if (!isUserMessage) {
        androidx.compose.foundation.BorderStroke(
            width = 1.dp,
            color = Color.LightGray
        )
    } else null
    
    Surface(
        modifier = modifier,
        color = backgroundColor,
        shape = getMessageBubbleShape(isUserMessage),
        shadowElevation = 2.dp,
        border = border // Add border for bot messages
    ) {
        Column(modifier = Modifier.padding(12.dp)) {
            if (text != null) {
                Text(
                    text = text,
                    color = textColor,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.padding(bottom = 8.dp)
                )
            }
            
            if (!options.isNullOrEmpty()) {
                Column(
                    verticalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    options.forEach { option ->
                        OutlinedButton(
                            onClick = { onOptionSelected(option) },
                            enabled = !isInteracted, // Disable button if already interacted
                            modifier = Modifier.fillMaxWidth(),
                            colors = ButtonDefaults.outlinedButtonColors(
                                contentColor = Color.Black
                            )
                        ) {
                            Text(
                                text = option.label,
                                color = if (isInteracted) Color.Black.copy(alpha = 0.5f) else Color.Black,
                                fontWeight = FontWeight.Bold
                            )
                        }
                    }
                }
            } else {
                Text(
                    text = "[Options unavailable]",
                    color = textColor.copy(alpha = 0.7f)
                )
            }
        }
    }
}

@Composable
private fun ButtonMessage(
    text: String?,
    options: List<MessageOption>?,
    isUserMessage: Boolean,
    backgroundColor: Color,
    textColor: Color,
    onOptionSelected: (MessageOption) -> Unit,
    modifier: Modifier = Modifier,
    isInteracted: Boolean = false
) {
    // Add border for bot messages
    val border = if (!isUserMessage) {
        androidx.compose.foundation.BorderStroke(
            width = 1.dp,
            color = Color.LightGray
        )
    } else null
    
    Surface(
        modifier = modifier,
        color = backgroundColor,
        shape = getMessageBubbleShape(isUserMessage),
        shadowElevation = 2.dp,
        border = border // Add border for bot messages
    ) {
        Column(modifier = Modifier.padding(12.dp)) {
            if (text != null) {
                Text(
                    text = text,
                    color = textColor,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.padding(bottom = 8.dp)
                )
            }
            
            if (!options.isNullOrEmpty()) {
                Column(
                    verticalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    options.forEach { option ->
                        Button(
                            onClick = { onOptionSelected(option) },
                            enabled = !isInteracted, // Disable button if already interacted
                            modifier = Modifier.fillMaxWidth(),
                            colors = ButtonDefaults.buttonColors(
                                containerColor = Color(0xFFF57C00),
                                contentColor = Color.White,
                                disabledContainerColor = Color(0xFFF57C00).copy(alpha = 0.5f),
                                disabledContentColor = Color.White.copy(alpha = 0.7f)
                            )
                        ) {
                            Text(
                                text = option.label,
                                fontWeight = FontWeight.Bold
                            )
                        }
                    }
                }
            } else {
                Text(
                    text = "[Options unavailable]",
                    color = textColor.copy(alpha = 0.7f)
                )
            }
        }
    }
} 