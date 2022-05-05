//
//  UIView+Segment.h
//  EMSegmentKit
//
//  Created by HDB-JSKF-004 on 2020/7/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Segment)

- (UIViewController *)currentVC;

- (UIViewController *)topVC;

@end

NS_ASSUME_NONNULL_END
