/*
 * AppController.j
 * NewApplication
 *
 * Created by You on July 5, 2009.
 * Copyright 2009, Your Company All rights reserved.
 */

@import <Foundation/CPObject.j>


@implementation AppController : CPObject
{
	CPView _contentView;
	CPString _nickname;
	CPTextField _nicknameTextField;
	CPTextField _chatTextField;
	CPScrollView _chatPanel;
	CPPanel _nicknameHUD;
	CPArray _messages;
	CPCollectionView _messagesCollectionView;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask];
    _contentView = [theWindow contentView];
	var bounds = [_contentView bounds];
		
	_nickname = "Test User";
	_messages = [];
	
	// This makes the appController a global and accessible for the juggernaut-server.
	window._appController = self;
	
	[_contentView setBackgroundColor:[CPColor colorWithHexString:@"A8C0D1"]];
	
	// Enables the juggernaut server
	var juggernautServer = [[CPWebView alloc] initWithFrame:CGRectMakeZero()];
	[juggernautServer setMainFrameURL:@"/juggernaut"];
	[_contentView addSubview:juggernautServer];
	
	var headerLabel = [[CPTextField alloc] initWithFrame:CGRectMake(100, 70, 300, 30)];
	[headerLabel setStringValue:@"Push it real good!"];
	[headerLabel setFont:[CPFont boldSystemFontOfSize:20]];
	[headerLabel setTextColor:[CPColor blackColor]];
	[_contentView addSubview:headerLabel];
	
	// This is needed because otherwise the app falls into sleep and new messages appear
	// only when you move the mouse
	var tickler = [CPTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(tickle) userInfo:nil repeats:YES];
	
	// Show the nick picker panel
	var _nicknameHUD = [[CPPanel alloc] initWithContentRect:CGRectMake(185, 200, 225, 125) styleMask:CPHUDBackgroundWindowMask];
	[_nicknameHUD setTitle:@"Please enter a nickname"];
	[_nicknameHUD setFloatingPanel:YES];
	[_nicknameHUD orderFront:self];
	
	// Set the panel content view
	var panelContentView = [_nicknameHUD contentView],
	    centerX = (CGRectGetWidth([panelContentView bounds]) - 135.0) / 2.0;
	
	var colorWellContainer = [[CPView alloc] initWithFrame:CGRectMake(470, 60, 30, 30)];
	[colorWellContainer setBackgroundColor:[CPColor whiteColor]];
	[_contentView addSubview:colorWellContainer];
	
	// Enables the color-picker
	var colorWell = [[CPColorWell alloc] initWithFrame: CGRectMake(0, 0, 30, 30)];
	[colorWell setBordered:YES];
	[colorWell setColor:[_contentView backgroundColor]];
	[colorWell setTarget:self];
	[colorWell setAction:@selector(colorChangedValue:)];
	[colorWellContainer addSubview:colorWell];
	
	var colorWellShadow = [[CPShadowView alloc] initWithFrame:CGRectMakeZero()];
	[colorWellShadow setFrameForContentFrame:[colorWellContainer frame]];
	[_contentView addSubview:colorWellShadow];
	
	// add the nickname textfield
	_nicknameTextField = [CPTextField roundedTextFieldWithStringValue:@"" placeholder:@"Nickname" width:150.0];
	[_nicknameTextField setFrameOrigin:CGPointMake(37, 20)];
	[_nicknameTextField setAction:@selector(saveNickname)];
	[panelContentView addSubview:_nicknameTextField];
	
	// add the save nickname button
	var saveNicknameButton = [[CPButton alloc] initWithFrame:CGRectMake(85, 60, 50, 24)];
	[saveNicknameButton setTitle:@"OK"];
	[saveNicknameButton setTarget:self];
	[saveNicknameButton setAction:@selector(saveNickname)];
	[panelContentView addSubview:saveNicknameButton];
	
	// Add the chat panel
	_chatPanel = [[CPScrollView alloc] initWithFrame:CGRectMake(100, 100, 400, 300)];
	[_chatPanel setBackgroundColor:[CPColor whiteColor]];
	[_chatPanel setAutohidesScrollers:YES];
	[_chatPanel setHasHorizontalScroller:NO];
	
	// Add shadow to the chat panel
	var chatPanelShadow = [[CPShadowView alloc] initWithFrame:CGRectMakeZero()];
	[chatPanelShadow setFrameForContentFrame:[_chatPanel frame]];
	[_contentView addSubview:chatPanelShadow];
	[_contentView addSubview:_chatPanel];
	
	// Add the message View
	var messageItem = [[CPCollectionViewItem alloc] init];
	[messageItem setView:[[messageCell alloc] initWithFrame:CGRectMakeZero()]];
	
	// Add the messages collection view
	_messagesCollectionView = [[CPCollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([_chatPanel bounds]), CGRectGetHeight([_chatPanel bounds]))];
	[_messagesCollectionView setMinItemSize:CGSizeMake(400, 20.0)];
	[_messagesCollectionView setMaxItemSize:CGSizeMake(400, 20.0)];
	[_messagesCollectionView setDelegate:self];
	[_messagesCollectionView setItemPrototype:messageItem];
	[_chatPanel setDocumentView:_messagesCollectionView];
	
	// Add the chat Textfield
	_chatTextField = [[CPTextField alloc] initWithFrame:CGRectMake(100, 410, 400, 30)];
	[_chatTextField setBezeled:YES];
	[_chatTextField setBezelStyle:CPTextFieldRoundedBezel];
	[_chatTextField setEditable:YES];
	[_chatTextField setObjectValue:@""];
	[_chatTextField setHidden:YES];
	[_chatTextField setAction:@selector(postMessage)];
	[_contentView addSubview:_chatTextField];

    [theWindow orderFront:self];

}

- (void)colorChangedValue:(id)sender {
	[CPApp sendAction:@selector(postColor:) to:nil from:sender];
}

- (void)postColor:(id)sender
{
	var theColor = encodeURI([sender color]._cssString);
	var url = "/juggernaut/send_color?color=" + theColor;
	var request = [[CPURLRequest alloc] initWithURL:url];
	var connection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)renderColor:(JSObject)anObject
{
	[_contentView setBackgroundColor:[CPColor colorWithCSSString:anObject.cssString]];
}

- (void)saveNickname {
	var theNickname = [_nicknameTextField objectValue]
	if (theNickname) {
		_nickname = theNickname;
		[_chatTextField setHidden:NO];
		[_nicknameHUD orderOut:YES];
	}
}

- (void)renderMessages {
	[_messagesCollectionView setContent:_messages];
}

- (void)postMessage {
	var theSender = encodeURI(_nickname);
	var theMessage = encodeURI([_chatTextField objectValue]);
	var url = "/juggernaut/send_message?sender=" + theSender + "&message=" + theMessage;
	var request = [[CPURLRequest alloc] initWithURL:url];
	var connection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)renderNewMessage:(JSObject)anObject
{
	_messages = [_messages arrayByAddingObject:[anObject.sender, anObject.message]];
    [_messagesCollectionView setContent:_messages];
	[_chatTextField setObjectValue:@""];
	[[_chatTextField window] makeFirstResponder:_chatTextField]
}

- (void)tickle
{
	void(0);
}

@end

@implementation messageCell : CPView
{
	CPTextField _sender;
	CPTextField _message;
}

- (void)setRepresentedObject:(JSObject)anObject
{
	if (!_sender) {
		_sender = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
		[_sender setFont:[CPFont boldSystemFontOfSize:12]];
		[_sender setTextColor:[CPColor grayColor]];
		[self addSubview:_sender]
	}
	if (!_message) {
		_message = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
		[_message setFont:[CPFont systemFontOfSize:12]];
		[_message setTextColor:[CPColor blackColor]];
		[self addSubview:_message];
	}

	
	[_sender setStringValue:anObject[0]];
	[_sender setFrameSize:CGSizeMake(85, 20)];
	[_sender setFrameOrigin:CGPointMake(5, 0)];
	
	[_message setStringValue:anObject[1]];
	[_message setFrameSize:CGSizeMake(310, 20)];
	[_message setFrameOrigin:CGPointMake(70, 0)];
	[_message setLineBreakMode:CPLineBreakByWordWrapping];
}

- (void)setSelected:(BOOL)isSelected
{
}

@end
