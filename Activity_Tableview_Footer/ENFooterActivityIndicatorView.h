//
//  ENTableFooterActivityView.h
//  ENTableFooterActivityIndicator
//
//  Created by Evgeny on 20.12.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ENFooterActivityIndicatorView : UIView
- (instancetype)initWithHeight:(CGFloat)height;
+ (instancetype)activityIndicatorWithHeight:(CGFloat)height;
- (void)updateForTableBottomOffset:(CGFloat)offset;
@end

// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net 
