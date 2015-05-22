//
//  ENLoadingView.m
//  ENLoadingView
//
//  Created by Evgeny on 29.06.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

#import "ENLoadingView.h"
#import "JWBlurView.h"

static CGFloat const kLabelMaxWidth = 120.0f;
static CGFloat const kLabelTopPadding = 10.0f;
static CGFloat const kBlurViewHeight = 120.0f;


@interface ENLoadingView ()
@property (nonatomic, strong) ENSpinner *spinner;
@property (nonatomic, strong) JWBlurView *blurView;
@property (nonatomic, strong) UILabel *label;
@end

@implementation ENLoadingView

#pragma mark - Class methods
+ (void)showLoaderInView:(UIView *)view
{
    [self showLoaderInView:view withMessage:nil];
}

+ (void)showLoaderInView:(UIView *)view withMessage:(NSString *)message
{
    [self showLoaderInView:view withMessage:message type:ENLoadingViewTypeFullScreen blurStyle:ENBlurStyleDark];
}

+ (void)showLoaderInView:(UIView *)view
             withMessage:(NSString *)message
                    type:(ENLoadingViewType)type
               blurStyle:(ENBlurStyle)blurStyle
{
    ENLoadingView *loaderView = [[self alloc] initWithView:view type:type];
    [view addSubview:loaderView];
    if (message) {
        loaderView.label.text = message;
    }
    if (blurStyle == ENBlurStyleDark) {
        loaderView.blurView.blurBar.barStyle = UIBarStyleBlack;
    }
    else {
        loaderView.blurView.blurBar.barStyle = UIBarStyleDefault;
    }
    
    [loaderView show];
}


+ (void)hideLoaderForView:(UIView *)view
{
    ENLoadingView *loaderView = [self loaderViewForView:view];
    [loaderView hide];
}

+ (instancetype)loaderViewForView:(UIView *)view {
	NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
	for (UIView *subview in subviewsEnum) {
		if ([subview isKindOfClass:self]) {
			return (ENLoadingView *)subview;
		}
	}
	return nil;
}

#pragma mark - Lifecycle
- (instancetype)initWithView:(UIView *)view type:(ENLoadingViewType)type
{
    return [self initWithFrame:view.bounds type:type];
}

- (instancetype)initWithFrame:(CGRect)frame type:(ENLoadingViewType)type
{
    self = [super initWithFrame:frame];
	if (self) {
        self.backgroundColor = [UIColor clearColor];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        if (type == ENLoadingViewTypeFullScreen) {
            _blurView = [[JWBlurView alloc] initWithFrame:frame];
            _blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        }
        else {
            _blurView = [[JWBlurView alloc] initWithFrame:CGRectMake(0, 0, kBlurViewHeight, kBlurViewHeight)];
            _blurView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
            _blurView.layer.cornerRadius = 10.0f;
            _blurView.center = self.center;
        }
        
        [_blurView setAlpha:.0f];
        [_blurView setBlurAlpha:.0f];
        [_blurView setBlurColor:[UIColor clearColor]];
        [_blurView setBackgroundColor:[UIColor clearColor]];
        
        
        [self addSubview:_blurView];
        
        [self addSpinner];
        [self addLabel];
	}
	return self;
}

#pragma mark - UI
- (void)addSpinner
{
    _spinner = [[ENSpinner alloc] init];
    _spinner.alpha = .0f;
    [self addSubview:_spinner];
}

- (void)addLabel
{
    _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kLabelMaxWidth, 0.0f)];
    _label.textColor = [UIColor lightGrayColor];
    _label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.alpha = .0f;
    [self addSubview:_label];
}

#pragma mark - Show & hide
- (void)show
{
    [self.spinner startAnimating];
    [UIView animateWithDuration:.3f animations:^{
        [self.blurView setAlpha:1.0f];
        [self.spinner setAlpha:1.0f];
        [self.label setAlpha:1.0f];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hide
{
    [self.spinner stopAnimating];
    [UIView animateWithDuration:.3f animations:^{
        [self.blurView setAlpha:.0f];
        [self.spinner setAlpha:.0f];
        [self.label setAlpha:.0f];
    } completion:^(BOOL finished) {
        [self.spinner removeFromSuperview];
        [self.blurView removeFromSuperview];
        [self removeFromSuperview];
    }];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _spinner.center = self.center;
    
    CGSize labelSize = [self.label sizeThatFits:CGSizeMake(kLabelMaxWidth, MAXFLOAT)];
    
    if (labelSize.height>0) {
        CGRect spinnerFrame = _spinner.frame;
        spinnerFrame.origin.y-=(labelSize.height+kLabelTopPadding)/2.0f;
        _spinner.frame = spinnerFrame;
        _label.frame = CGRectMake(0, spinnerFrame.origin.y+spinnerFrame.size.height+kLabelTopPadding, labelSize.width, labelSize.height);
        _label.center = CGPointMake(_spinner.center.x, _label.center.y);
    }
}

@end


///////////////////////////////////////////////////////////
#pragma mark - ENSpinner

@interface ENSpinner()
@property (nonatomic, strong) UIView *spinner;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation ENSpinner

#pragma mark - Lifecycle
- (id)init
{
    self = [super init];
    if (self) {
        [self configureView];
        self.timer = [NSTimer timerWithTimeInterval:0.009f
                                             target:self
                                           selector:@selector(makeRotation)
                                           userInfo:Nil
                                            repeats:YES];
        
    }
    
    return self;
}

#pragma mark - UI
- (void)configureView
{
    UIImage *_circleImage = [UIImage imageNamed:@"spinner_circle"];
    self.frame = CGRectMake(0, 0, _circleImage.size.width, _circleImage.size.height);
    CALayer *_maskingCircleLayer = [CALayer layer];
    _maskingCircleLayer.frame = self.bounds;
    [_maskingCircleLayer setContents:(id)[_circleImage CGImage]];
    [self.layer setMask:_maskingCircleLayer];
    self.backgroundColor = [UIColor colorWithRed:0.125 green:0.671 blue:0.678 alpha:1];
    
    UIImage *triangleImage = [UIImage imageNamed:@"spinner_triangle"];
    _spinner = [[UIView alloc] initWithFrame:CGRectMake(0, 0, triangleImage.size.width, triangleImage.size.height)];
    CALayer *_maskingTriangleLayer = [CALayer layer];
    _maskingTriangleLayer.frame = self.spinner.bounds;
    [_maskingTriangleLayer setContents:(id)[triangleImage CGImage]];
    [_spinner.layer setMask:_maskingTriangleLayer];
    _spinner.layer.anchorPoint = CGPointMake(0.5, 1);
    _spinner.backgroundColor = [UIColor colorWithRed:0.914 green:0.141 blue:0.173 alpha:1];
    _spinner.center = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
    
    [self addSubview:_spinner];
}

#pragma mark - Timer callback
- (void)makeRotation
{
    self.spinner.transform = CGAffineTransformRotate(self.spinner.transform,2.0f*M_PI/180);
}


#pragma mark - Public methods
- (void)startAnimating
{
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopAnimating
{
    if ([self.timer isValid]) {
        [self.timer invalidate];
    }
}



@end

