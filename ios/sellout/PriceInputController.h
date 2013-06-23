//
//  PriceInputController.h
//  Recall
//
//  Created by Pandu Pradhana on 11/28/11.
//  Copyright (c) 2011 Codejawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostItemViewController.h"

@interface PriceInputController : UITableViewController<UITextFieldDelegate> {
    PostItemViewController *viewCaller;
    UITextField *priceField;
    IBOutlet UINavigationBar *navigationBar;
}

- (id)initWithStyle:(UITableViewStyle)style 
             caller:(PostItemViewController *) caller;

@property (nonatomic, retain) PostItemViewController *viewCaller;
@property (nonatomic, retain) UITextField *priceField;
@property (nonatomic, retain) UINavigationBar *navigationBar;


@end
