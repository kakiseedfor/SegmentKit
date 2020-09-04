//
//  UIScrollView+Segment.m
//  EMSegmentKit
//
//  Created by HDB-JSKF-004 on 2020/7/6.
//

#import "UIScrollView+Segment.h"

@implementation UIScrollView (Segment)

- (UIViewController *)currentVC{
    UIViewController *tempVC = nil;
    
    UIViewController *rootVC = UIApplication.sharedApplication.keyWindow.rootViewController;
    tempVC = rootVC.presentedViewController ?: tempVC;
    if (tempVC) {
        return tempVC;
    }
    
    if ([NSStringFromClass(rootVC.class) isEqualToString:NSStringFromClass(UINavigationController.class)]) {
        tempVC = ((UINavigationController *)rootVC).topViewController;
        return tempVC;
    }
    
    if ([NSStringFromClass(rootVC.class) isEqualToString:NSStringFromClass(UITabBarController.class)]) {
        tempVC = ((UITabBarController *)rootVC).selectedViewController;
        return tempVC;
    }
    
    return tempVC;
}

@end
