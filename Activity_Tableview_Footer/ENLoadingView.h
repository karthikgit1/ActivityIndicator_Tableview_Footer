//
//  ENLoadingView.h
//  ENLoadingView
//
//  Created by Evgeny on 29.06.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    ENLoadingViewTypeFullScreen,
    ENLoadingViewTypeModal
} ENLoadingViewType;

typedef enum {
    ENBlurStyleDark,
    ENBlurStyleLight
} ENBlurStyle;

@interface ENLoadingView : UIView


+ (void)showLoaderInView:(UIView *)view;
+ (void)showLoaderInView:(UIView *)view withMessage:(NSString *)message;
+ (void)showLoaderInView:(UIView *)view
             withMessage:(NSString *)message
                    type:(ENLoadingViewType)type
               blurStyle:(ENBlurStyle)blurStyle;
+ (void)hideLoaderForView:(UIView *)view;


@end


@interface ENSpinner : UIView

- (void)startAnimating;
- (void)stopAnimating;

@end