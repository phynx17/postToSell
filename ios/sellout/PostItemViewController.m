//
//  PostItemViewController.m
//  Recall
//
//  Created by Pandu Pradhana on 11/20/11.
//  Copyright (c) 2011 PhynxSoft. All rights reserved.
//

#import "PostItemViewController.h"
#import "ChooseCategoryTableViewController.h"
#import "DescriptionViewController.h"
#import "PriceInputController.h"

#import "UIImage+ProportionalFill.h"
#import "UIImage+Tint.h"



#define _UIKeyboardFrameEndUserInfoKey (&UIKeyboardFrameEndUserInfoKey != NULL ? UIKeyboardFrameEndUserInfoKey : @"UIKeyboardBoundsUserInfoKey")

#define EXTRA_OFFSET_FROM_BELOW 1
#define DEFAULT_CATEGORY @" -- "

/*
 * Should adjust this to retina display?
 */
#define MAX_IMAGE_SIZE_WIDTH 320
#define MAX_IMAGE_SIZE_HEIGHT 240



// Forward declarations
@interface PostItemViewController()
@property (nonatomic, retain) UITextField *activeField;

- (void)registerForKeyboardNotifications;

//For Keyboard workaround
- (UIView*)findFirstResponderBeneathView:(UIView*)view;
- (UIEdgeInsets)contentInsetForKeyboard;
- (CGFloat)idealOffsetForView:(UIView *)view withSpace:(CGFloat)space;
- (CGRect)keyboardRect;


- (BOOL) validateRequiredFields;
- (void) showAlert:(NSString *)title message:(NSString *)message;

- (void) sendHTTPRequest;
@end



@implementation PostItemViewController


@synthesize itemNameField;
@synthesize descriptionField;
@synthesize categoryField;
@synthesize priceField;
@synthesize tableHeaderView;
@synthesize photoView;
@synthesize postButtonBar;

@synthesize window;
@synthesize appDelegate;
@synthesize activeField;
@synthesize tableView;
@synthesize category;
@synthesize imagePickerController;

//@synthesize theNavigationController;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //[self setNavigationController:[[UINavigationController alloc] init]];
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    self.view.backgroundColor = 
                [UIColor colorWithPatternImage:
                            [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] 
                                                              stringByAppendingPathComponent:@"background1.png"]]];    
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.separatorColor = [UIColor clearColor];
    
    [self registerForKeyboardNotifications];
    
    [super viewDidLoad];
    
    //Initially the keyboard is hidden
    keyboardVisible = NO;
    
    /**
     * < iOS4 uses : UIKeyboardWillShowNotification
     * iOS >= 4 uses : UIKeyboardDidShowNotification
     *
     *
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardDidShowNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillHideNotification 
                                            object:nil];
     */
    

    imagePickerController = [[UIImagePickerController alloc] init];
    [imagePickerController setDelegate:self];
    
    
    /*
    photoView = [[UIImageView alloc] initWithFrame:CGRectMake(96, 0, 128, 119)];
    [photoView setImage:[UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"clipping_pictures.png"]]];
    */
    
    // Create and set the table header view.
    if (tableHeaderView == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"PostItemHeaderView" owner:self options:nil];
        //tableHeaderView.backgroundColor = nil;        
        self.tableView.tableHeaderView = tableHeaderView;
        //self.tableView.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        self.tableView.allowsSelectionDuringEditing = YES;
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] 
                                   initWithTarget:self
                                   action:@selector(dialogSimpleAction:)];    
    [self.photoView addGestureRecognizer:tap];
    [tap release];
    
    [self.postButtonBar setTarget:self];
    [self.postButtonBar setAction:@selector(postItem:)];
    
    
    //self.tableView.tableHeaderView = photoView;
    //[photoView release];    

    
     /*
    [self.photoView addTarget:self 
                  action:@selector(dialogSimpleAction:) 
        forControlEvents:UIControlEventTouchUpInside];
    */
    
    
    /*
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    [self.view addSubview:navigationController.view];       
     */
    //self.navigationController
    //self.navigationController.tabBarController.
    
    //self.navigationItem.rightBarButtonItem = UIBarButtonSystemItemDone;
    //self.navigationItem.rightBarButtonItem = UIBarButtonSystemItemDone;
    
    /**
     * So when the user tap background it dismiss the Keyboard
     *
     *
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] 
                                        initWithTarget:self
                                                action:@selector(dismissKeyboard:)];    
    [self.view addGestureRecognizer:tap];
    [tap release];
     */
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if(interfaceOrientation == UIDeviceOrientationPortrait) return YES;
    if(interfaceOrientation == UIDeviceOrientationLandscapeRight) return YES;
    return NO;
}


- (void)viewWillDisappear:(BOOL)animtated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated]; 
}

- (void)viewDidAppear:(BOOL)animated
{
    //NSLog(@"IT-viewDidAppear");
    [super viewDidAppear:animated];
    //NSLog(@"IT-after-viewDidAppear");
}



/**
 * @deprecated
 */
- (void) dismissKeyboard:(UIGestureRecognizer *)sender
{
    NSLog(@"dismissKeyboard");
    if ([itemNameField isFirstResponder]) {
        [itemNameField resignFirstResponder];
    } else {
        /*
        CGPoint tapPoint = [sender locationInView:sender.view.superview];
        [UIView beginAnimations:nil context:NULL];
        sender.view.center = tapPoint;
        [UIView commitAnimations];    
        if ([categoryField isFirstResponder])
            [categoryField resignFirstResponder];
         */

    }
}



/**
 * For tricking the hiding keyboard
 *
 */
- (void)registerForKeyboardNotifications
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}


// Called when the UIKeyboardDidShowNotification is sent.
/* 
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    //NSLog(@"FUCK");
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    //NSLog([NSString stringWithFormat:@"%d", kbSize.height]);
    
    tableView.contentInset = contentInsets;
    tableView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.tableView.frame;
    aRect.size.height -= kbSize.height;
    NSLog([NSString stringWithFormat:@"activeField %@",activeField]);
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        NSLog(@"IT");
        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y-kbSize.height);
        [tableView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    tableView.contentInset = contentInsets;
    tableView.scrollIndicatorInsets = contentInsets; 
}
 */



#pragma mark - 
#pragma mark On Post Item Bar Action 


-(void) postItem: (UITabBarItem *) sender {
    if ([self validateRequiredFields]) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;        
        [self sendHTTPRequest];
    }
}


- (BOOL) validateRequiredFields {
    BOOL ok = TRUE;
    
	NSString *_tmpname = [[itemNameField text] 
                          stringByTrimmingCharactersInSet:
                                [NSCharacterSet whitespaceAndNewlineCharacterSet]]; 
    
    if ([_tmpname isEqualToString:@""]) {
        [self showAlert:@"Missing Fields" message:@"Item name is empty"];
        ok = FALSE;
    } else if ([categoryField.text isEqualToString:DEFAULT_CATEGORY]) {
        [self showAlert:@"Missing Fields" message:@"Please choose category"];
        ok = FALSE;
    } 
    return ok;
}

/**
 * Show alert
 *
 */
- (void) showAlert:(NSString *)title message:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];    
}



/**
 * Send the HTTP request
 *
 */
- (void) sendHTTPRequest {
	   
    NSMutableDictionary *params =     
                    [NSMutableDictionary dictionaryWithObject:photoView.image forKey:@"userfile"];
    
    /**
     * TODO FIX THIS!
     *
     */
    [params setValue:@"1" forKey:@"user_id"];
    [params setValue:itemNameField.text forKey:@"item_name"];
    [params setValue:priceField.text forKey:@"price_offer"];
    [params setValue:descriptionField.text forKey:@"description"];
    [params setValue:[NSString stringWithFormat:@"%d",category.categoryId] 
              forKey:@"category_id"];
    
    /**
     * TODO Location: 
     *
     */
    
    /**
     * Post image first
     */
    //if (DEBUG) NSLog(@"sendHTTPRequest...");
    PostItemRequest *postRequest = 
                [PostItemRequest getRequestWithParams:params                                 
                                             delegate:[self appDelegate]
                                          requestType:PostItemRequest_Upload_Image];
    [postRequest sendRequest];
    //if (DEBUG) NSLog(@"After sendRequest");

    
}









#pragma mark - 
#pragma mark A solution from Michael Tyson for hiding keyboard
/**
 * Source: https://github.com/michaeltyson/TPKeyboardAvoiding
 *
 *
 */
- (void)keyboardWasShown:(NSNotification*)notification {
    _keyboardRect = [[[notification userInfo] objectForKey:_UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _keyboardVisible = YES;
    
    UIView *firstResponder = [self findFirstResponderBeneathView:self.view];
    if ( !firstResponder ) {
        // No child view is the first responder - nothing to do here
        return;
    }
    
    _priorInset = tableView.contentInset;
    
    // Shrink view's inset by the keyboard's height, and scroll to show the text field/view being edited
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] 
                                objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] 
                                   objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    
    tableView.contentInset = [self contentInsetForKeyboard];
    [tableView setContentOffset:CGPointMake(
                                        tableView.contentOffset.x, 
                                       [self idealOffsetForView:firstResponder 
                                                      withSpace:[self keyboardRect].origin.y - 
                                                                (tableView.bounds.origin.y-EXTRA_OFFSET_FROM_BELOW)]) 
                  animated:YES];
    
    firstResponder = nil;
    [UIView commitAnimations];
}

- (void)keyboardWillBeHidden:(NSNotification*)notification {
    _keyboardRect = CGRectZero;
    _keyboardVisible = NO;
    
    // Restore dimensions to prior size
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    tableView.contentInset = _priorInset;
    [UIView commitAnimations];
}

- (UIView*)findFirstResponderBeneathView:(UIView*)view {
    // Search recursively for first responder
    for ( UIView *childView in view.subviews ) {
        if ( [childView respondsToSelector:@selector(isFirstResponder)] && [childView isFirstResponder] ) return childView;
        UIView *result = [self findFirstResponderBeneathView:childView];
        if ( result ) return result;
    }
    return nil;
}

- (UIEdgeInsets)contentInsetForKeyboard {
    UIEdgeInsets newInset = tableView.contentInset;
    CGRect keyboardRect = [self keyboardRect];
    newInset.bottom = keyboardRect.size.height - 
                    ((keyboardRect.origin.y+keyboardRect.size.height) - 
                     (tableView.bounds.origin.y+tableView.bounds.size.height));
    return newInset;
}

-(CGFloat)idealOffsetForView:(UIView *)view withSpace:(CGFloat)space {
    
    // Convert the rect to get the view's distance from the top of the scrollView.
    CGRect rect = [view convertRect:view.bounds toView:self.view];
    
    // Set starting offset to that point
    CGFloat _offset = rect.origin.y;
        
    if ( tableView.contentSize.height - _offset < space ) {
        // Scroll to the bottom
        _offset = tableView.contentSize.height - space;
    } else {
        if ( view.bounds.size.height < space ) {
            // Center vertically if there's room
            _offset -= floor((space-view.bounds.size.height)/2.0);
        }
        if ( _offset + space > tableView.contentSize.height ) {
            // Clamp to content size
            _offset = tableView.contentSize.height - space;
        }
    }
    
    if (_offset < 0) _offset = 0;
    
    return _offset;
}

-(void)adjustOffsetToIdealIfNeeded {
    
    // Only do this if the keyboard is already visible
    if ( !_keyboardVisible ) return;
    
    CGFloat visibleSpace = tableView.bounds.size.height 
                                    - tableView.contentInset.top 
                                    - tableView.contentInset.bottom;
    
    CGPoint idealOffset = CGPointMake(0, 
                                      [self idealOffsetForView:
                                        [self findFirstResponderBeneathView:self.view] 
                                                     withSpace:visibleSpace]); 
    
    [tableView setContentOffset:idealOffset animated:YES];                
}

- (CGRect)keyboardRect {
    CGRect keyboardRect = [tableView convertRect:_keyboardRect fromView:nil];
    if ( keyboardRect.origin.y == 0 ) {
        CGRect screenBounds = [tableView convertRect:[UIScreen mainScreen].bounds fromView:nil];
        keyboardRect.origin = CGPointMake(0, screenBounds.size.height - keyboardRect.size.height);
    }
    return keyboardRect;
}


- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self findFirstResponderBeneathView:self.view] resignFirstResponder];
    [super touchesEnded:touches withEvent:event];
} 




-(IBAction) choosePhoto: (id) sender;
{
    NSLog(@"choosePhoto()");
	// open a dialog with just an OK button
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self 
                                                    cancelButtonTitle:@"Cancel" 
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:
                                  @"Choose Photo", 
                                  @"Take Photo",nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    // show from our table view (pops up in the middle of the table)
	[actionSheet showInView:tableView];	
	[actionSheet release];    
}





- (void)dialogSimpleAction:(UIGestureRecognizer *)sender
{
	// open a dialog with just an OK button
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self 
                                                    cancelButtonTitle:@"Cancel" 
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:
                                                        @"Choose Photo", 
                                                        @"Take Photo",nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    // show from our table view (pops up in the middle of the table)
	[actionSheet showInView:tableView];	
	[actionSheet release];    
}


#pragma mark -
#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 0)
	{
		//NSLog(@"ok");
        // Create window

        // Set up the image picker controller and add it to the view
        
        if (imagePickerController) {
            [imagePickerController release];
            imagePickerController = nil;
        }
        imagePickerController = [[UIImagePickerController alloc] init];
        [imagePickerController setDelegate:self];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [window addSubview:imagePickerController.view];
        // [imagePickerController.view release];
        
        //imagePickerController
        
        // Set up the image view and add it to the view but make it hidden
        /*
        photoView = [[UIImageView alloc] initWithFrame:[window bounds]];
        imageView.hidden = YES;
        [window addSubview:imageView];        
         */
	}
	else if (buttonIndex == 1)
	{
        if (imagePickerController) {
            [imagePickerController release];
            imagePickerController = nil;
        }        
        imagePickerController = [[UIImagePickerController alloc] init];
        [imagePickerController setDelegate:self];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [window addSubview:imagePickerController.view];
	}
    //[self setHidesBottomBarWhenPushed:FALSE];
    //NSLog([NSString stringWithFormat:@"Boooo %d",buttonIndex]);    
}




#pragma --
#pragma mark Methods to handle the DONE in UIKeyboardTypeNumberPad

- (void)keyboardWillHide:(NSNotification *)note { 
    //NSLog(@"keyboardWillHide"); 
}

- (void)keyboardWillShow:(NSNotification *)note { 
    NSLog(@"keyboardWillShow");    
    if (activeField.keyboardType == UIKeyboardTypeNumberPad) {
        // create custom button
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        doneButton.frame = CGRectMake(0, 163, 106, 53);
        doneButton.adjustsImageWhenHighlighted = NO;
        [doneButton setImage:[UIImage imageNamed:@"DoneUp.png"] forState:UIControlStateNormal];
        [doneButton setImage:[UIImage imageNamed:@"DoneDown.png"] forState:UIControlStateHighlighted];
        [doneButton addTarget:self action:@selector(doneButton:) forControlEvents:UIControlEventTouchUpInside];
        
        // locate keyboard view
        UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
        UIView* keyboard;
        for(int i=0; i<[tempWindow.subviews count]; i++) {
            keyboard = [tempWindow.subviews objectAtIndex:i];
            // keyboard view found; add the custom button to it
            // iOS < 4 is using prefix: UIKeyboard
            // iOS >= 4 using prefix : UIPeripheralHostView
            if([[keyboard description] hasPrefix:@"<UIPeripheralHostView"] == YES)
                [keyboard addSubview:doneButton];
        }
    }
}

- (void)doneButton:(id)sender {
    //NSLog(@"Input: %@", activeField.text);
    [activeField resignFirstResponder];
}





#pragma mark <UITableViewDelegate> Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyIdentifier";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 
                                       reuseIdentifier:MyIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }    
    
    /*
    if (indexPath.section == 0) {
        
        photoView = [[UIImageView alloc] initWithFrame:CGRectMake(96, 0, 128, 119)];
        [photoView setImage:[UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"clipping_pictures.png"]]];
        
        [cell addSubview:photoView];
        [photoView release];
        
    } else */ if (indexPath.section == 0) {

        if ([indexPath row] == 0) {
            itemNameField = [[UITextField alloc] initWithFrame:CGRectMake(110, 10, 185, 30)];
            itemNameField.adjustsFontSizeToFitWidth = YES;
            itemNameField.textColor = [UIColor blackColor];
            itemNameField.backgroundColor = [UIColor whiteColor];
            // no auto correction support
            itemNameField.autocorrectionType = UITextAutocorrectionTypeNo; 
            // no auto capitalization support
            itemNameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            itemNameField.textAlignment = UITextAlignmentLeft;
            itemNameField.tag = 0;            
            
            // no clear 'x' button to the right            
            itemNameField.clearButtonMode = UITextFieldViewModeNever;
            [itemNameField setEnabled: YES];
            
            itemNameField.placeholder = @"Item";
            itemNameField.delegate = self;
            itemNameField.keyboardType = UIKeyboardTypeASCIICapable;
            itemNameField.returnKeyType = UIReturnKeyDone;  
            cell.textLabel.text = @"Item";

            /*
            [itemNameField addTarget:self 
                              action:@selector(dismissKeyboard:)iwan 
                    //forControlEvents:UIControlEventTouchUpOutside];
                    forControlEvents:UIControlEventEditingDidEndOnExit];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] 
                                           initWithTarget:self
                                           action:@selector(dismissKeyboard:)];    
            [itemNameField addGestureRecognizer:tap];
            [tap release];
            */
            
            [cell addSubview:itemNameField];        
            [itemNameField release]; 
            
            
            
        } else if ([indexPath row] == 1) {
            
            categoryField = [[UILabel alloc] initWithFrame:CGRectMake(110, 5, 185, 30)];
            categoryField.text = DEFAULT_CATEGORY;
            
            //Buat kasih tanda panah di ujung
            cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator; 
            cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;            
            [categoryField setEnabled: NO];
            cell.textLabel.text = @"Category";                        
            
            [cell addSubview:categoryField];        
            [categoryField release];              
            
            /*
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
            
            priceField.placeholder = @"Price Offer";
            priceField.delegate = self;
            //Problem nih ntar dulu dah
            //priceField.keyboardType = UIKeyboardTypeNumberPad;
            priceField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;            
            priceField.returnKeyType = UIReturnKeyDone;                
            priceField.clearButtonMode = UITextFieldViewModeWhileEditing;                
            cell.textLabel.text = @"Price Offer";
            [cell addSubview:priceField];        
            [priceField release]; 
            
            */
        }
           

    } else if (indexPath.section == 1) {
        /*
        categoryField = [[UILabel alloc] initWithFrame:CGRectMake(110, 5, 185, 30)];
        categoryField.text = DEFAULT_CATEGORY;
        
        //Buat kasih tanda panah di ujung
        cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator; 
        cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;            
        [categoryField setEnabled: NO];
        cell.textLabel.text = @"Category";                        
        
        [cell addSubview:categoryField];        
        [categoryField release];       
         */
        
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
        //priceField.clearButtonMode = UITextFieldViewModeNever;
        
        priceField.placeholder = @"0";
        priceField.delegate = self;
        //Problem nih ntar dulu dah
        //priceField.keyboardType = UIKeyboardTypeNumberPad;
        //priceField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;            
        //priceField.keyboardType = UIKeyboardTypeDecimalPad;
        priceField.returnKeyType = UIReturnKeyDone;                
        priceField.clearButtonMode = UITextFieldViewModeWhileEditing;                
        [priceField setEnabled: NO];
        
        cell.textLabel.text = @"Price Offer";
        [cell addSubview:priceField];        
        [priceField release];         
        
        
    } else if (indexPath.section == 2) {
        descriptionField = [[UITextField alloc] initWithFrame:CGRectMake(110, 10, 185, 30)];
        descriptionField.adjustsFontSizeToFitWidth = YES;
        descriptionField.textColor = [UIColor blackColor];
        descriptionField.backgroundColor = [UIColor whiteColor];
        // no auto correction support
        descriptionField.autocorrectionType = UITextAutocorrectionTypeNo; 
        // no auto capitalization support
        descriptionField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        descriptionField.textAlignment = UITextAlignmentLeft;
        descriptionField.tag = 0;            
        
        // no clear 'x' button to the right
        
        descriptionField.clearButtonMode = UITextFieldViewModeNever;
        [descriptionField setEnabled: YES];            
        
        descriptionField.placeholder = @"Description";
        descriptionField.delegate = self;
        //playerTextField.keyboardType = UIKeyboardTypeASCIICapable;
        //playerTextField.returnKeyType = UIReturnKeyDone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;            
        [descriptionField setEnabled: NO];
        
        cell.textLabel.text = @"Description";
        [cell addSubview:descriptionField];        
        [descriptionField release];          
    }
    
    //[cell setSelectionStyle:UITableViewCellEditingStyleNone];
    return cell;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    /**
     * Currently on item, description, category, price
     *
     *
     */
    if (section == 0) {
        return 2;
    } /*else if (section == 1) {
        return 1;
    } */ else {
        return 1;
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 2) {
        //return @"Category";
    }
    return @"";
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
    if (indexPath.row == 1 && indexPath.section == 0) {
        UIViewController *nextViewController = nil;
        nextViewController = 
                [[ChooseCategoryTableViewController alloc] init];
                                //initWithStyle:UITableViewStyleGrouped];   

        ((ChooseCategoryTableViewController *)nextViewController).viewCaller = self;
        
        [self setHidesBottomBarWhenPushed:TRUE];
		[self.navigationController 
            pushViewController:nextViewController animated:YES];
        
        [nextViewController release];
    } else if (indexPath.section == 1) {
        
        UIViewController *nextViewController = nil;
        nextViewController = [[PriceInputController alloc] 
                              initWithStyle:UITableViewStyleGrouped
                              caller:self];

        ((PriceInputController *)nextViewController).viewCaller = self;
        
        [self setHidesBottomBarWhenPushed:TRUE];
		[self.navigationController 
         pushViewController:nextViewController animated:YES];
        
        [nextViewController release];           
    } else if (indexPath.row == 0 && indexPath.section == 2) {

        UIViewController *nextViewController = nil;
        nextViewController = [[DescriptionViewController alloc] init];
        //initWithStyle:UITableViewStyleGrouped];   
        
        ((DescriptionViewController *)nextViewController).viewCaller = self;
        
        [self setHidesBottomBarWhenPushed:TRUE];
		[self.navigationController 
         pushViewController:nextViewController animated:YES];
        
        [nextViewController release];           
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}



/*
// Animate the entire view up or down, to prevent the keyboard from covering the text field.
- (void)moveView:(int)offset
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    // Make changes to the view's frame inside the animation block. They will be animated instead
    // of taking place immediately.
    CGRect rect = self.view.frame;
    rect.origin.y -= offset;
    rect.size.height += offset;
    self.view.frame = rect;
    
    [UIView commitAnimations];
}
*/


#pragma mark - 
#pragma mark <UIImagePickerControllerDelegate> Method

- (void)imagePickerController:(UIImagePickerController *)picker 
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    //NSLog([NSString stringWithFormat:@"didFinishPickingImage "]);
    
    // Dismiss the image selection, hide the picker and
    //show the image view with the picked image
    [picker dismissModalViewControllerAnimated:YES];
    imagePickerController.view.hidden = YES;
    
    CGSize size = image.size;

    /*
    if (DEBUG) {
        NSLog(@"Image size: (width, height): %f, %f",size.width, size.height);
        
        NSData *imageData = [[NSData alloc] 
                             initWithData:UIImageJPEGRepresentation((image), 0.5)];
        int imageSize = imageData.length;
        NSLog(@"SIZE OF IMAGE: %i ", imageSize); 
        [imageData release];
        imageData = nil;
    }
     */
    
    CGSize maxSize = CGSizeMake(MAX_IMAGE_SIZE_WIDTH, MAX_IMAGE_SIZE_HEIGHT);
    
    
    if ((size.width*size.height) > (maxSize.width*maxSize.height)) {
        CGSize newSize = CGSizeMake(MAX_IMAGE_SIZE_WIDTH, MAX_IMAGE_SIZE_HEIGHT);
        UIImage *newimage = [image imageScaledToFitSize:newSize];
        size = newimage.size;
        /*
        if (DEBUG) {
            NSLog(@"NEW Image size: (width, height): %f, %f",size.width, size.height);
            NSData *imageData = [[NSData alloc] 
                         initWithData:UIImageJPEGRepresentation((newimage), 0.5)];
            int imageSize = imageData.length;
            NSLog(@"SIZE OF IMAGE: %i ", imageSize); 
            [imageData release];
        }
        */
        photoView.image = newimage;
    } else {
        photoView.image = image;
    }

    
    photoView.hidden = NO;
    
    [window bringSubviewToFront:photoView];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // Dismiss the image selection and close the program
    [picker dismissModalViewControllerAnimated:YES];
}





#pragma mark -
#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController 
      willShowViewController:(UIViewController *)viewController 
                    animated:(BOOL)animated {
    //NSLog(@"willShowViewController");
}

- (void)navigationController:(UINavigationController *)navigationController 
       didShowViewController:(UIViewController *)viewController 
                    animated:(BOOL)animated {
    //NSLog(@"didShowViewController");    
}



#pragma mark -
#pragma mark <UITextFieldDelegate> Methods

- (void)textFieldDidBeginEditing:(UITextField *)theTextField
{
    //NSLog(@"textFieldDidBeginEditing");
    /*
     NSLog(@"masuk");s
     int wantedOffset = theTextField.frame.origin.y-200;
     if ( wantedOffset < 0 ) { 
     wantedOffset = 0;
     } 
     if ( wantedOffset != verticalOffset ) {
     [self moveView: wantedOffset - verticalOffset];
     verticalOffset = wantedOffset;
     }
     */
    activeField = theTextField;  
}    


/*
 - (BOOL)textFieldShouldBeginEditing:(UITextField *)theTextField
 {
 NSLog(@"textFieldShouldBeginEditing");
 activeField = theTextField;
 return YES;
 }  
 */



- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //NSLog(textField.text);    
    if ([textField isEqual:priceField]) {
        
        //Remove the alphabet
        NSString *_t = textField.text;
        _t = [_t stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]];

        //Now remove the space;
        _t = [_t stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        NSNumberFormatter *currencyStyle = [[NSNumberFormatter alloc] init];
        // set options.
        [currencyStyle setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [currencyStyle setNumberStyle:NSNumberFormatterCurrencyStyle];
        
        
        //Sampai dengan 
        textField.text = [NSString stringWithFormat:@"%@",
                          [currencyStyle stringForObjectValue:textField.text]]; //_must;
        
        
        
    }
	[textField resignFirstResponder];
    return YES;
}



- (void)dealloc
{
    if (imagePickerController) {
        [imagePickerController release];
        imagePickerController = nil;
    }    
    [priceField release];
    [categoryField release];
    [category release];
    [itemNameField release];
    [descriptionField release];
    
    [appDelegate release];    
    [tableView release];
    [tableHeaderView release];
    [photoView release];
    //[category release];
    [window release];
    [super dealloc];
}

@end
