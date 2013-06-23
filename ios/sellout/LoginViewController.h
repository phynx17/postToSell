//
//  LoginViewController.h
//  Recall
//
//  Created by Pandu Pradhana on 11/13/11.
//  Copyright 2011 PhynxSoft. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoginViewController : UIViewController <UITextFieldDelegate> {
    IBOutlet id loginButton;
    IBOutlet UITextField *loginField;
    IBOutlet UITextField *passwordField;
}

@property (nonatomic, retain) UITextField *loginField;
@property (nonatomic, retain) UITextField *passwordField;

- (IBAction)cancel:(id)sender;
- (IBAction)login:(id)sender;

@end
