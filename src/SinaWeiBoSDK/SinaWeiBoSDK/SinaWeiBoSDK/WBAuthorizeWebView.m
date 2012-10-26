//
//  WBAuthorizeWebView.m
//  SinaWeiBoSDK
//  Based on OAuth 2.0
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//
//  Copyright 2011 Sina. All rights reserved.
//

#import "WBAuthorizeWebView.h"
#import <QuartzCore/QuartzCore.h> 

@interface WBAuthorizeWebView (Private)

- (void)bounceOutAnimationStopped;
- (void)bounceInAnimationStopped;
- (void)bounceNormalAnimationStopped;
- (void)allAnimationsStopped;

- (BOOL)shouldRotateToOrientation:(UIInterfaceOrientation)orientation;

- (void)addObservers;
- (void)removeObservers;

@property (nonatomic,readonly) UIInterfaceOrientation currentOrientation;

@end

@implementation WBAuthorizeWebView

@synthesize delegate;

#pragma mark - WBAuthorizeWebView Life Circle

- (id)init
{
    if (self = [super initWithFrame:CGRectMake(0, 0, 320, 480)])
    {
        // background settings
        [self setBackgroundColor:[UIColor clearColor]];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

        // add the panel view
        panelView = [[UIView alloc] initWithFrame:CGRectMake(10, 30, 300, 440)];
        [panelView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.55]];
        [[panelView layer] setMasksToBounds:NO]; // very important
        [[panelView layer] setCornerRadius:10.0];
        [self addSubview:panelView];

        // add the conainer view
        containerView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 280, 420)];
        //[[containerView layer] setBorderColor:[UIColor colorWithRed:0. green:0. blue:0. alpha:0.7].CGColor];
        //[[containerView layer] setBorderWidth:1.0];

        // add the web view
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 280, 390)];
        webView.scalesPageToFit = YES;
		[webView setDelegate:self];
		[containerView addSubview:webView];

        [panelView addSubview:containerView];

        indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [indicatorView setCenter:CGPointMake(160, 240)];
        [self addSubview:indicatorView];
    }
    return self;
}

- (void)dealloc
{
    [panelView release], panelView = nil;
    [containerView release], containerView = nil;
    [webView release], webView = nil;
    [indicatorView release], indicatorView = nil;
    
    [super dealloc];
}

#pragma mark Actions

- (void)onCloseButtonTouched:(id)sender
{
    [self hide:YES];
}

#pragma mark Orientations
- (UIInterfaceOrientation)currentOrientation
{
    return [UIApplication sharedApplication].statusBarOrientation;
}

- (BOOL)shouldRotateToOrientation:(UIInterfaceOrientation)orientation
{
    if (orientation == previousOrientation)
    {
        return NO;
    }
    return YES;
}

- (void)deviceOrientationDidChange:(id)object
{
    if (![self shouldRotateToOrientation:self.currentOrientation]) {
        return;
    }

    previousOrientation = self.currentOrientation;

    [UIView beginAnimations:nil context:nil];
    [self layoutSubviews];
    [UIView commitAnimations];
}

#pragma mark Obeservers
- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name:@"UIDeviceOrientationDidChangeNotification"
                                               object:nil];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UIDeviceOrientationDidChangeNotification"
                                                  object:nil];
}

#pragma mark subview layout
- (void)layoutSubviews
{
    int offsetA = 20, offsetB = 40, offsetC = 60, offsetD = 90;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        offsetA >>= 1;
        offsetB >>= 1;
        offsetC >>= 1;
        offsetD = 40;
    }

    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    panelView.center = center;
    panelView.bounds = CGRectMake(0, 0, self.bounds.size.width - offsetA, self.bounds.size.height - offsetC);

    containerView.center = CGPointMake(panelView.bounds.size.width/2, panelView.bounds.size.height/2);
    containerView.bounds = CGRectMake(0, 0, self.bounds.size.width - offsetB, self.bounds.size.height - offsetC);

    webView.center = CGPointMake(containerView.bounds.size.width/2, containerView.bounds.size.height/2);;
    webView.bounds = CGRectMake(0, 0, self.bounds.size.width - offsetB, self.bounds.size.height - offsetD);
    
    indicatorView.center = center;
}

#pragma mark Animations

- (void)bounceOutAnimationStopped
{
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.13];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounceInAnimationStopped)];
    [panelView setAlpha:0.8];
	[panelView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9)];
	[UIView commitAnimations];
}

- (void)bounceInAnimationStopped
{
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.13];
    [UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounceNormalAnimationStopped)];
    [panelView setAlpha:1.0];
	[panelView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0)];
	[UIView commitAnimations];
}

- (void)bounceNormalAnimationStopped
{
    [self allAnimationsStopped];
}

- (void)allAnimationsStopped
{
    [self layoutSubviews];
}

#pragma mark Dismiss

- (void)hideAndCleanUp
{
    [self removeObservers];
	[self removeFromSuperview];
}

#pragma mark - WBAuthorizeWebView Public Methods

- (void)loadRequestWithURL:(NSURL *)url
{
    NSURLRequest *request =[NSURLRequest requestWithURL:url
                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                        timeoutInterval:60.0];
    [webView loadRequest:request];
}

- (void)show:(BOOL)animated
{
    UIViewController *controller = self.delegate.rootViewController;
    [controller.view addSubview:self];
    self.frame = controller.view.bounds;

    if (animated)
    {
        [panelView setAlpha:0];
        CGAffineTransform transform = CGAffineTransformIdentity;
        [panelView setTransform:CGAffineTransformScale(transform, 0.3, 0.3)];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(bounceOutAnimationStopped)];
        [panelView setAlpha:0.5];
        [panelView setTransform:CGAffineTransformScale(transform, 1.1, 1.1)];
        [UIView commitAnimations];
    }
    else
    {
        [self allAnimationsStopped];
    }

    [self addObservers];
}

- (void)hide:(BOOL)animated
{
	if (animated)
    {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.3];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(hideAndCleanUp)];
		[self setAlpha:0];
		[UIView commitAnimations];
	} 
    [self hideAndCleanUp];
}

#pragma mark - UIWebViewDelegate Methods

- (void)webViewDidStartLoad:(UIWebView *)aWebView
{
	[indicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
	[indicatorView stopAnimating];
/*    NSLog(@"URL: %@", aWebView.request.URL.absoluteString);
    NSRange range = [aWebView.request.URL.absoluteString rangeOfString:@"code="];

    if (range.location != NSNotFound)
    {
        NSString *code = [aWebView.request.URL.absoluteString substringFromIndex:range.location + range.length];

        NSString *responseContents = [aWebView stringByEvaluatingJavaScriptFromString:@"document.body.innerText"];
        NSLog(@"CODE: %@, RESPONSE-CONTENTS: %@", code, responseContents);
        if ([delegate respondsToSelector:@selector(authorizeWebView:didReceiveAuthorizeCode:state:)])
        {
            [delegate authorizeWebView:self didReceiveAuthorizeCode:code state:responseContents];
        }
    }*/
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error
{
    [indicatorView stopAnimating];
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSRange range = [request.URL.absoluteString rangeOfString:@"code="];

    if (range.location != NSNotFound)
    {
        NSRange rangeOfQ = [request.URL.absoluteString rangeOfString:@"?"];
        if (rangeOfQ.location != NSNotFound) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            NSString *paramString = [request.URL.absoluteString substringFromIndex:rangeOfQ.location + rangeOfQ.length];
            for (NSString *keyValuePair in [paramString componentsSeparatedByString:@"&"]) {
                NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
                NSString *key = [pairComponents objectAtIndex:0];
                NSString *value = [pairComponents objectAtIndex:1];
                [params setObject:value forKey:key];
            }

            NSString *code = [params objectForKey:@"code"];
            NSString *stateCode = [params objectForKey:@"state"];

            if ([delegate respondsToSelector:@selector(authorizeWebView:didReceiveAuthorizeCode:state:)])
            {
                [delegate authorizeWebView:self didReceiveAuthorizeCode:code state:stateCode];
            }
        }
    }

    return YES;
}

@end
