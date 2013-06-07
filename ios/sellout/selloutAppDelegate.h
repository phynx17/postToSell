//
//  selloutAppDelegate.h
//  sellout
//
//  Created by Pandu Pradhana on 11/9/11.
//  Copyright 2011 Codejawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface selloutAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end
