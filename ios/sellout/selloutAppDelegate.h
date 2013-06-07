//
//  selloutAppDelegate.h
//  sellout
//
//  Created by Pandu Pradhana on 11/9/11.
//

#import <UIKit/UIKit.h>

@interface selloutAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end
