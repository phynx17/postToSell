//
//  LoginTableController.m
//  Recall
//
//  Created by Pandu Pradhana on 11/14/11.
//  Copyright 2011 PhynxSoft. All rights reserved.
//

#import "LoginTableController.h"


@implementation LoginTableController

@synthesize tableView;
@synthesize requiredFields;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];    
    if (self) {        
        // Custom initialization
        [self setWantsFullScreenLayout:TRUE];    
        
        //[self.tableView style: UITableViewCellStyleValue2];
        //[tableView style:UITableViewStylePlain];
        //[tableView setBackgroundColor:[UIColor clearColor]];
        [tableView setEditing: TRUE];   
        [tableView reloadData];        
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
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
    self.view.backgroundColor = 
    //    [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background_sellout.png"]];
    
    [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"background1.png"]]];    
    tableView.backgroundColor = [UIColor clearColor];
    [super viewDidLoad];    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark <UITextFieldDelegate> Methods


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //NSLog(textField.text);
	[textField resignFirstResponder];
    return YES;
}



#pragma mark <UITableViewDelegate> Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyIdentifier";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 
                                       reuseIdentifier:MyIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }    
    if (indexPath.section == 0) {
        
        UITextField *playerTextField = [[UITextField alloc] initWithFrame:CGRectMake(110, 10, 185, 30)];
        playerTextField.adjustsFontSizeToFitWidth = YES;
        playerTextField.textColor = [UIColor blackColor];
        if ([indexPath row] == 0) {
            //playerTextField.placeholder = @"example@gmail.com";
            playerTextField.placeholder = @"Username";
            //playerTextField.keyboardType = UIKeyboardTypeEmailAddress;
            playerTextField.keyboardType = UIKeyboardTypeASCIICapable;
            playerTextField.returnKeyType = UIReturnKeyNext;
        }
        else {
            playerTextField.placeholder = @"Required";
            playerTextField.keyboardType = UIKeyboardTypeDefault;
            playerTextField.returnKeyType = UIReturnKeyDone;
            playerTextField.secureTextEntry = YES;
        }       
        playerTextField.backgroundColor = [UIColor whiteColor];
        playerTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
        playerTextField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
        playerTextField.textAlignment = UITextAlignmentLeft;
        playerTextField.tag = 0;
        playerTextField.delegate = self;
        
        playerTextField.clearButtonMode = UITextFieldViewModeNever; // no clear 'x' button to the right
        [playerTextField setEnabled: YES];
        
        [cell addSubview:playerTextField];
        
        [playerTextField release];
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Username";
        } else {
            cell.textLabel.text = @"Password";
        }
        
    }   
    [cell setSelectionStyle:UITableViewCellEditingStyleNone];
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Number of rows is the number of time zones in the region for the specified section.
    //Region *region = [regions objectAtIndex:section];
    //return [region.timeZoneWrappers count];
    return 2;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // The header for the section is the region name -- get this from the region at the section index.
    /*
     Region *region = [regions objectAtIndex:section];
     return [region name];
     */
    return @"";
}

@end
