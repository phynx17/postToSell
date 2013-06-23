//
//  PriceInputController.m
//  Recall
//
//  Created by Pandu Pradhana on 11/28/11.
//  Copyright (c) 2011 Codejawa. All rights reserved.
//

#import "PriceInputController.h"

@implementation PriceInputController

@synthesize viewCaller;
@synthesize priceField;
@synthesize navigationBar;


- (id)initWithStyle:(UITableViewStyle)style 
             caller:(PostItemViewController *) caller
{
    self = [super initWithStyle:style];
    if (self) {
        [self setViewCaller:caller];        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.viewCaller setHidesBottomBarWhenPushed:FALSE];
    
    self.view.backgroundColor = 
    [UIColor colorWithPatternImage:
     [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] 
                                       stringByAppendingPathComponent:@"background1.png"]]];  
    
    //self.view.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor clearColor];
    
    //self.navigationController.title = @"Price Offer";
    //self.navigationController.navigationBar.topItem.title = @"Price Offer";
    //[self.navigationController setNavigationBar:[self navigationBar]];
    //self.navigationController.navigationBar = navigationBar;
    self.navigationController.title = @"Price Offer";
    
    

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 
                                       reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    priceField = [[UITextField alloc] initWithFrame:CGRectMake(110, 10, 185, 30)];
    priceField.adjustsFontSizeToFitWidth = YES;
    priceField.textColor = [UIColor blackColor];
    priceField.backgroundColor = [UIColor whiteColor];
    // no auto correction support
    priceField.autocorrectionType = UITextAutocorrectionTypeNo; 
    // no auto capitalization support
    priceField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    priceField.textAlignment = UITextAlignmentLeft;
    priceField.tag = 0;            
    
    // no clear 'x' button to the right
    
    priceField.clearButtonMode = UITextFieldViewModeNever;
    [priceField setEnabled: YES];
    
    priceField.placeholder = @"0";
    priceField.delegate = self;
    //Problem nih ntar dulu dah
    //priceField.keyboardType = UIKeyboardTypeNumberPad;
    priceField.keyboardType = UIKeyboardTypeDecimalPad;
    priceField.returnKeyType = UIReturnKeyDone;                
    priceField.clearButtonMode = UITextFieldViewModeWhileEditing;                
    
    /**
     * TODO change this (through a setting)?
     *
     *
     */
    cell.textLabel.text = @"IDR";
    [cell addSubview:priceField];        
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}



#pragma mark -
#pragma mark <UITextFieldDelegate> Methods

- (void)textFieldDidBeginEditing:(UITextField *)theTextField
{
    //activeField = theTextField;  
}    

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"View Caller: %@",self.viewCaller);
    self.viewCaller.priceField.text = textField.text;
    NSLog(@"After set Price Field: %@",textField.text);
}


/*
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
    return YES;
}
*/


- (void) dealloc {
    [priceField release];
    [viewCaller release];
    [super dealloc];
}



@end
