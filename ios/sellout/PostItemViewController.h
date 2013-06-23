//
//  PostItemViewController.h
//  Recall
//
//  Created by Pandu Pradhana on 11/20/11.
//  Copyright (c) 2011 PhynxSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CategoryType.h"
#import "RecallAppDelegate.h"
#import "PostItemRequest.h"


@interface PostItemViewController : 
    UIViewController<UITableViewDelegate, 
                    UITableViewDataSource, 
                    UITextFieldDelegate, 
                    UINavigationControllerDelegate,
                    UIActionSheetDelegate, 
                    UIImagePickerControllerDelegate> {
                                                        
    IBOutlet UIWindow *window;
    IBOutlet RecallAppDelegate *appDelegate;
    IBOutlet UITableView *tableView;
    IBOutlet UIView *tableHeaderView;                        
    IBOutlet UIImageView *photoView;
    IBOutlet UIBarButtonItem *postButtonBar;

    
@private 
                        
    /**
     * For keyboard part
     *
     */
    int verticalOffset;
    BOOL keyboardVisible;
    CGPoint offset;
                        
    
    CategoryType *category;
    UITextField *activeField;
        
    UITextField *itemNameField;
    UITextField *descriptionField;
    //UITextField *categoryField;
    UILabel *categoryField;
    UITextField *priceField;
        
    UIImagePickerController* imagePickerController;        
    
                        
    /**
     * Keyboard stuff
     *
     */
    UIEdgeInsets    _priorInset;
    BOOL            _keyboardVisible;
    CGRect          _keyboardRect;
    CGSize          _originalContentSize;                        
}


/**
 * The synthetized properties
 *
 */
@property (nonatomic, retain) RecallAppDelegate *appDelegate;
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) CategoryType *category;
@property (nonatomic, retain) UIImageView *photoView;
@property (nonatomic, retain) UIView *tableHeaderView;
@property (nonatomic, retain) UIBarButtonItem *postButtonBar;




@property (nonatomic, retain) UITextField *itemNameField;
@property (nonatomic, retain) UITextField *descriptionField;
@property (nonatomic, retain) UILabel *categoryField;
@property (nonatomic, retain) UITextField *priceField;
@property (nonatomic, retain) UIImagePickerController *imagePickerController;


-(IBAction) choosePhoto: (id) sender;
-(void) postItem: (UITabBarItem *) sender;



@end


