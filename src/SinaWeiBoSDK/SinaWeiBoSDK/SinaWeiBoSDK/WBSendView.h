//
//  WBSendView.h
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

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "WBEngine.h"

@class WBSendView;

@protocol WBSendViewDelegate <NSObject>

@optional
- (void)sendViewDidRequestClose:(WBSendView *)view;

- (void)sendViewDidFinishSending:(WBSendView *)view;
- (void)sendView:(WBSendView *)view didFailWithError:(NSError *)error;

- (void)sendViewNotAuthorized:(WBSendView *)view;
- (void)sendViewAuthorizeExpired:(WBSendView *)view;

@end


@interface WBSendView : UIView <UITextViewDelegate, WBEngineDelegate> 
{
    
    UITextView  *contentTextView;
    UIView      *contentImageContainerView;
    UIImageView *contentImageView;

    UIButton    *sendButton;
    UIButton    *closeButton;
    UIButton    *clearTextButton;
    UIButton    *clearImageButton;

    UILabel     *titleLabel;
    UILabel     *wordCountLabel;

    UIView      *panelView;
    UIImageView *panelImageView;

    NSString    *contentText;
    UIImage     *contentImage;

    UIInterfaceOrientation previousOrientation;

    BOOL        isKeyboardShowing;

    WBEngine    *engine;

    //id<WBSendViewDelegate> delegate;
}

@property (nonatomic, strong) NSString *contentText;
@property (nonatomic, strong) UIImage *contentImage;
@property (nonatomic, weak) id<WBSendViewDelegate> delegate;

- (id)initWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret text:(NSString *)text image:(UIImage *)image;

@end
