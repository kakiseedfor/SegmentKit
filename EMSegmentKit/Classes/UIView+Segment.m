//
//  UIScrollView+Segment.m
//  EMSegmentKit
//
//  Created by HDB-JSKF-004 on 2020/7/6.
//

#import "UIView+Segment.h"

@implementation UIView (Segment)

- (UIViewController *)currentVC{
    UIViewController *tempVC = UIApplication.sharedApplication.keyWindow.rootViewController;
FIND:
    if (tempVC.presentedViewController) {
        tempVC = tempVC.presentedViewController;
        return tempVC;
    }

    if ([tempVC isKindOfClass:UINavigationController.class]) {
        tempVC = ((UINavigationController *)tempVC).topViewController;
        goto FIND;
    }
    
    if ([NSStringFromClass(tempVC.class) isEqualToString:NSStringFromClass(UITabBarController.class)]) {
        tempVC = ((UITabBarController *)tempVC).selectedViewController;
        if ([tempVC isKindOfClass:UINavigationController.class]) {
            goto FIND;
        }
        return tempVC;
    }
    
    return tempVC;
}

@end
