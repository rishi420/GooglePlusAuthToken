//
//  SignInViewController.m
//
//  Copyright 2012 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "SignInViewController.h"

#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>
#import <QuartzCore/QuartzCore.h>

@interface SignInViewController () <GPPSignInDelegate>
- (void)enableSignInSettings:(BOOL)enable;
- (void)reportAuthStatus;
- (void)retrieveUserInfo;
@end

@implementation SignInViewController

@synthesize signInButton = signInButton_;
@synthesize signInAuthStatus = signInAuthStatus_;
@synthesize signInDisplayName = signInDisplayName_;
@synthesize signOutButton = signOutButton_;
@synthesize disconnectButton = disconnectButton_;
@synthesize userinfoEmailScope = userinfoEmailScope_;

- (void)dealloc {
  [signInButton_ release];
  [signInAuthStatus_ release];
  [signInDisplayName_ release];
  [signOutButton_ release];
  [userinfoEmailScope_ release];
  [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
  // Make sure the GPPSignInButton class is linked in because references from
  // xib file doesn't count.
  [GPPSignInButton class];

  GPPSignIn *signIn = [GPPSignIn sharedInstance];
  userinfoEmailScope_.on =
      signIn.shouldFetchGoogleUserEmail;

  // Set up sign-out and disconnect buttons.
  [self setUpButton:signOutButton_];
  [self setUpButton:disconnectButton_];

  // Set up sample view of Google+ sign-in.
  // The client ID has been set in the app delegate.
  signIn.delegate = self;
  signIn.shouldFetchGoogleUserEmail = userinfoEmailScope_.on;
  signIn.actions = [NSArray arrayWithObjects:
      @"http://schemas.google.com/AddActivity",
      @"http://schemas.google.com/BuyActivity",
      @"http://schemas.google.com/CheckInActivity",
      @"http://schemas.google.com/CommentActivity",
      @"http://schemas.google.com/CreateActivity",
      @"http://schemas.google.com/ListenActivity",
      @"http://schemas.google.com/ReserveActivity",
      @"http://schemas.google.com/ReviewActivity",
      nil];

  [self reportAuthStatus];
  [signIn trySilentAuthentication];
  [super viewDidLoad];
}

- (void)viewDidUnload {
  [self setSignInButton:nil];
  [self setSignInAuthStatus:nil];
  [self setSignInDisplayName:nil];
  [self setSignOutButton:nil];
  [self setDisconnectButton:nil];
  [self setUserinfoEmailScope:nil];
  [super viewDidUnload];
}

#pragma mark - GPPSignInDelegate

- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth
                   error:(NSError *)error {
  if (error) {
    signInAuthStatus_.text =
        [NSString stringWithFormat:@"Status: Authentication error: %@", error];
    return;
  }
  [self reportAuthStatus];
    
    NSLog(@"%@", auth.userID);
    NSLog(@"%@", auth.userEmailIsVerified);
    NSLog(@"%@", auth.userEmail);
    NSLog(@"%@", auth.userData);
    NSLog(@"%@", auth.userAgent);
    NSLog(@"%@", auth.tokenURL);
    
    NSLog(@"%@", auth.tokenType);
    NSLog(@"%@", auth.serviceProvider);
    NSLog(@"%@", auth.scope);
    
    NSLog(@"%@", auth.refreshToken);
    NSLog(@"%@", auth.refreshScope);
    NSLog(@"%@", auth.redirectURI);
    
    NSLog(@"%@", auth.persistenceResponseString);
    NSLog(@"%@", auth.expiresIn);
    NSLog(@"%@", auth.expirationDate);
    
    NSLog(@"%@", auth.description);
    NSLog(@"%@", auth.clientSecret);
    NSLog(@"%@", auth.clientID);
    
    NSLog(@"%@", auth.accessToken);
}

- (void)didDisconnectWithError:(NSError *)error {
  if (error) {
    signInAuthStatus_.text =
        [NSString stringWithFormat:@"Status: Failed to disconnect: %@", error];
  } else {
    signInAuthStatus_.text =
        [NSString stringWithFormat:@"Status: Disconnected"];
    signInDisplayName_.text = @"";
    [self enableSignInSettings:YES];
  }
}

#pragma mark - Helper methods

- (void)setUpButton:(UIButton *)button {
  [[button layer] setCornerRadius:5];
  [[button layer] setMasksToBounds:YES];
  CGColorRef borderColor = [[UIColor colorWithWhite:203.0/255.0
                                              alpha:1.0] CGColor];
  [[button layer] setBorderColor:borderColor];
  [[button layer] setBorderWidth:1.0];
}

- (void)enableSignInSettings:(BOOL)enable {
  userinfoEmailScope_.enabled = enable;
}

- (void)reportAuthStatus {
  if ([GPPSignIn sharedInstance].authentication) {
    signInAuthStatus_.text = @"Status: Authenticated";
    [self retrieveUserInfo];
    [self enableSignInSettings:NO];
  } else {
    // To authenticate, use Google+ sign-in button.
    signInAuthStatus_.text = @"Status: Not authenticated";
    [self enableSignInSettings:YES];
  }
}

- (void)retrieveUserInfo {
  signInDisplayName_.text = [NSString stringWithFormat:@"Email: %@",
      [GPPSignIn sharedInstance].authentication.userEmail];
}

//-(void)getAccessTokenWithAuthorizationCode:(NSString *)code
//{
//    
//    NSURL *accessTokenURL = [NSURL     URLWithString:@"https://accounts.google.com/o/oauth2/token"];
//    
//    OAMutableURLRequest *accessRequest = [[OAMutableURLRequest alloc] initWithURL:accessTokenURL
//                                                                         consumer:consumer
//                                                                            token:requestToken
//                                                                            realm:nil   // our service provider doesn't specify a realm
//                                                                signatureProvider:nil]; // use the default method, HMAC-SHA1
//    [accessRequest setHTTPMethod:@"POST"];
//    
//    OARequestParameter *authCode = [[OARequestParameter alloc] initWithName:@"code" value:code];
//    OARequestParameter *redirectURI = [[OARequestParameter alloc] initWithName:@"redirect_uri" value:kRedirectURI];
//    OARequestParameter *granType = [[OARequestParameter alloc] initWithName:@"grant_type" value:@"authorization_code"];
//    
//    [accessRequest setParameters:[NSArray arrayWithObjects:authCode, redirectURI, granType, nil]];
//    
//    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
//    
//    [fetcher fetchDataWithRequest:accessRequest
//                         delegate:self
//                didFinishSelector:@selector(accessTokenTicket:didFinishWithData:)
//                  didFailSelector:@selector(accessTokenTicket:didFailWithError:)];
//}

#pragma mark - IBActions

- (IBAction)signOut:(id)sender {
  [[GPPSignIn sharedInstance] signOut];

  [self reportAuthStatus];
  signInDisplayName_.text = @"";
}

- (IBAction)disconnect:(id)sender {
  [[GPPSignIn sharedInstance] disconnect];
}

- (IBAction)userinfoEmailScopeToggle:(id)sender {
  [GPPSignIn sharedInstance].shouldFetchGoogleUserEmail =
      userinfoEmailScope_.on;
}

@end
