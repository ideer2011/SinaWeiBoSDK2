//
//  WBSendView.m
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

#import "WBSendView.h"

@interface WBSendView (Private)

- (void)onCloseButtonTouched:(id)sender;
- (void)onSendButtonTouched:(id)sender;
- (void)onClearTextButtonTouched:(id)sender;
- (void)onClearImageButtonTouched:(id)sender;

- (int)textLength:(NSString *)text;
- (void)calculateTextLength;

@end

@implementation WBSendView

@synthesize contentText;
@synthesize contentImage;
@synthesize delegate;

#pragma mark - WBSendView Life Circle

- (id)initWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret text:(NSString *)text image:(UIImage *)image
{
    if (self = [super initWithFrame:CGRectMake(0, 0, 320, 480)])
    {
        engine = [[WBEngine alloc] initWithAppKey:appKey appSecret:appSecret];
        [engine setDelegate:self];

        // background settings
        [self setBackgroundColor:[UIColor clearColor]];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

        // add the panel view
        panelView = [[UIView alloc] initWithFrame:self.bounds];
        panelImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        //[panelImageView setImage:[[UIImage imageNamed:@"bg.png"] stretchableImageWithLeftCapWidth:18 topCapHeight:18]];
        [panelImageView setImage:[[UIImage imageNamed:@"bg_strechable"] resizableImageWithCapInsets:UIEdgeInsetsMake(45, 7, 35, 36)]];
        panelView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        panelImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        [panelView addSubview:panelImageView];
        [self addSubview:panelView];

        // add the buttons & labels
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 6, self.bounds.size.width, 30)];
        [titleLabel setText:NSLocalizedString(@"新浪微博", nil)];
        [titleLabel setTextColor:[UIColor blackColor]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setTextAlignment:UITextAlignmentCenter];
        [titleLabel setShadowOffset:CGSizeMake(0, 1)];
		[titleLabel setShadowColor:[UIColor whiteColor]];
        [titleLabel setFont:[UIFont systemFontOfSize:19]];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[panelView addSubview:titleLabel];

		closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[closeButton setShowsTouchWhenHighlighted:YES];
		[closeButton setFrame:CGRectMake(9, 7, 48, 30)];
		[closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[closeButton setBackgroundImage:[UIImage imageNamed:@"btn.png"] forState:UIControlStateNormal];
		[closeButton setTitle:NSLocalizedString(@"关闭", nil) forState:UIControlStateNormal];
		[closeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
		[closeButton addTarget:self action:@selector(onCloseButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
		[panelView addSubview:closeButton];

        sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[sendButton setShowsTouchWhenHighlighted:YES];
		[sendButton setFrame:CGRectMake(self.bounds.size.width - 15 - 48, 7, 48, 30)];
		[sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sendButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
		[sendButton setBackgroundImage:[UIImage imageNamed:@"btn.png"] forState:UIControlStateNormal];
		[sendButton setTitle: NSLocalizedString(@"发送", nil) forState:UIControlStateNormal];
		[sendButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
		[sendButton addTarget:self action:@selector(onSendButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        sendButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		[panelView addSubview:sendButton];

        contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(13, 60, self.bounds.size.width - 26, 140)];
		[contentTextView setEditable:YES];
		[contentTextView setDelegate:self];
        [contentTextView setText:text];
		[contentTextView setBackgroundColor:[UIColor clearColor]];
		[contentTextView setFont:[UIFont systemFontOfSize:16]];
        /*contentTextView.layer.borderColor = [[UIColor grayColor] CGColor];
        contentTextView.layer.borderWidth = 1.0f;
        contentTextView.layer.cornerRadius = 5.0f;*/
        contentTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
 		[panelView addSubview:contentTextView];

        wordCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - 80, panelView.frame.size.height - 140, 30, 30)];
		[wordCountLabel setBackgroundColor:[UIColor clearColor]];
		[wordCountLabel setTextColor:[UIColor darkGrayColor]];
		[wordCountLabel setFont:[UIFont systemFontOfSize:16]];
		[wordCountLabel setTextAlignment:UITextAlignmentCenter];
        wordCountLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		[panelView addSubview:wordCountLabel];

        clearTextButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[clearTextButton setShowsTouchWhenHighlighted:YES];
		[clearTextButton setFrame:CGRectMake(self.bounds.size.width - 50, panelView.frame.size.height - 140, 30, 30)];
		[clearTextButton setContentMode:UIViewContentModeCenter];
 		[clearTextButton setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
		[clearTextButton addTarget:self action:@selector(onClearTextButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        clearTextButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		[panelView addSubview:clearTextButton];

        // calculate the text length
        [self calculateTextLength];

        self.contentText = contentTextView.text;

        // image
        contentImageContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        contentImageContainerView.clipsToBounds = NO;
        contentImageContainerView.hidden = YES;
        contentImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [contentImageContainerView addSubview:contentImageView];

        CALayer *layer = [contentImageView layer];
        [layer setBorderColor:[[UIColor whiteColor] CGColor]];
        [layer setBorderWidth:5.0f];

        [contentImageContainerView.layer setShadowColor:[UIColor blackColor].CGColor];
        [contentImageContainerView.layer setShadowOffset:CGSizeMake(0, 0)];
        [contentImageContainerView.layer setShadowOpacity:0.5]; 
        [contentImageContainerView.layer setShadowRadius:3.0];

        [panelView addSubview:contentImageContainerView];

        clearImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [clearImageButton setShowsTouchWhenHighlighted:YES];
        [clearImageButton setFrame:CGRectMake(0, 0, 30, 30)];
        [clearImageButton setContentMode:UIViewContentModeCenter];
        [clearImageButton setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
        [clearImageButton addTarget:self action:@selector(onClearImageButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [contentImageContainerView addSubview:clearImageButton];

        self.contentImage = image;
        
    }
    return self;
}

- (void)dealloc
{
    [engine setDelegate:nil];
    [engine release], engine = nil;

    [panelView release], panelView = nil;
    [panelImageView release], panelImageView = nil;
    [titleLabel release], titleLabel = nil;
    [contentTextView release], contentTextView = nil;
    [wordCountLabel release], wordCountLabel = nil;
    [contentImageContainerView release], contentImageContainerView = nil;
    [contentImageView release], contentImageView = nil;

    [contentText release], contentText = nil;
    [contentImage release], contentImage = nil;

    delegate = nil;

    [super dealloc];
}

- (void)setContentImage:(UIImage *)image
{
    self->contentImage = image;

    if (image) {
        contentImageContainerView.hidden = NO;

        CGSize imageSize = image.size;	
        CGFloat width = imageSize.width;
        CGFloat height = imageSize.height;
        CGRect imageFrame = CGRectMake(0, 0, 0, 0);
        if (width > height) {
            imageFrame.size.width = 120;
            imageFrame.size.height = height * (120 / width);
        }
        else {
            imageFrame.size.height = 80;
            imageFrame.size.width = width * (80 / height);
        }
        CGRect containerFrame = imageFrame;
        containerFrame.size.width  += 30;
        containerFrame.size.height += 30;
        containerFrame.origin.x = 40;
        containerFrame.origin.y = contentTextView.frame.origin.y + contentTextView.frame.size.height + 20;

        imageFrame.origin.x += 15;
        imageFrame.origin.y += 15;

        contentImageView.frame = imageFrame;
        contentImageContainerView.frame = containerFrame;
        [contentImageView setImage:image];

        contentImageContainerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    } else {
        contentImageContainerView.hidden = YES;
    }
}

- (void)setContentText:(NSString *)text
{
    self->contentText = text;
    [contentTextView setText:text];
    [self calculateTextLength];
}

#pragma mark - WBSendView Private Methods

#pragma mark Actions

- (void)onCloseButtonTouched:(id)sender
{
    if (delegate && [delegate respondsToSelector:@selector(sendViewDidRequestClose:)]) {
        [delegate sendViewDidRequestClose:self];
    }
}

- (void)onSendButtonTouched:(id)sender
{
    if ([contentTextView.text isEqualToString:@""])
    {
		UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"新浪微博", nil)
                                                             message:NSLocalizedString(@"请输入微博内容", nil)
                                                            delegate:nil
                                                   cancelButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		return;
	}
    
    [engine sendWeiBoWithText:contentTextView.text image:contentImage];
}

- (void)onClearTextButtonTouched:(id)sender
{
    [contentTextView setText:@""];
	[self calculateTextLength];
}

- (void)onClearImageButtonTouched:(id)sender
{
    [contentImageContainerView setHidden:YES];
    [clearImageButton setHidden:YES];
	[contentImage release], contentImage = nil;
}

#pragma mark Text Length

- (int)textLength:(NSString *)text
{
    float number = 0.0;
    for (int index = 0; index < [text length]; index++)
    {
        NSString *character = [text substringWithRange:NSMakeRange(index, 1)];
        
        if ([character lengthOfBytesUsingEncoding:NSUTF8StringEncoding] == 3)
        {
            number++;
        }
        else
        {
            number = number + 0.5;
        }
    }
    return ceil(number);
}

- (void)calculateTextLength
{
    if (contentTextView.text.length > 0) 
	{ 
		[sendButton setEnabled:YES];
	}
	else 
	{
		[sendButton setEnabled:NO];
	}
	
	int wordcount = [self textLength:contentTextView.text];
	NSInteger count  = 140 - wordcount;
	if (count < 0)
    {
		[wordCountLabel setTextColor:[UIColor redColor]];
		[sendButton setEnabled:NO];
	}
	else
    {
		[wordCountLabel setTextColor:[UIColor darkGrayColor]];
		[sendButton setEnabled:YES];
	}

	[wordCountLabel setText:[NSString stringWithFormat:@"%i",count]];
}

#pragma mark - UITextViewDelegate Methods

- (void)textViewDidChange:(UITextView *)textView
{
	[self calculateTextLength];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{	
    return YES;
}

#pragma mark - WBEngineDelegate Methods

- (void)engine:(WBEngine *)engine requestDidSucceedWithResult:(id)result
{
    if ([delegate respondsToSelector:@selector(sendViewDidFinishSending:)])
    {
        [delegate sendViewDidFinishSending:self];
    }
}

- (void)engine:(WBEngine *)engine requestDidFailWithError:(NSError *)error
{
    if ([delegate respondsToSelector:@selector(sendView:didFailWithError:)])
    {
        [delegate sendView:self didFailWithError:error];
    }
}

- (void)engineNotAuthorized:(WBEngine *)engine
{
    if ([delegate respondsToSelector:@selector(sendViewNotAuthorized:)])
    {
        [delegate sendViewNotAuthorized:self];
    }
}

- (void)engineAuthorizeExpired:(WBEngine *)engine
{
    if ([delegate respondsToSelector:@selector(sendViewAuthorizeExpired:)])
    {
        [delegate sendViewAuthorizeExpired:self];
    }
}

@end
