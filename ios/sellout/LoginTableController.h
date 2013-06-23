//
//  LoginTableController.h
//  Recall
//
//  Created by Pandu Pradhana on 11/14/11.
//  Copyright 2011 PhynxSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginTableController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    IBOutlet UITableView *tableView;
    NSArray *requiredFields;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSArray *requiredFields;


@end
