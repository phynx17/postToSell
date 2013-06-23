//
//  ChooseCategoryTableViewController.h
//  Recall
//
//  The list of category, follows the v1.0 of Sellout
//
//  Created by Pandu Pradhana on 11/21/11.
//  Copyright (c) 2011 PhynxSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CategoryType.h"
#import "PostItemViewController.h"


//@interface ChooseCategoryTableViewController : UITableViewController {
@interface ChooseCategoryTableViewController : 
    UIViewController<UITableViewDelegate, UITableViewDataSource> {        
    NSMutableArray *listOfcategoryTypes;
    /* IBOutlet */ UITableView *tableView;
        
@private
    CategoryType *category;
    PostItemViewController *viewCaller;
}

@property (nonatomic, retain) NSMutableArray *listOfcategoryTypes;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) CategoryType *category;
@property (nonatomic, retain) PostItemViewController *viewCaller;


@end
