//
//  TaskViewController.h
//  projet_iphone
//
//  Created by Projet4a on 27/02/2015.
//  Copyright (c) 2015 Projet4a. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Project.h"

@interface TaskViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate> {
    Project* project;
    BOOL isNew;
}

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UITextField *taskTitle;
@property (weak, nonatomic) IBOutlet UITextView *TaskDescription;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIDatePicker *dateStart;
@property (weak, nonatomic) IBOutlet UIDatePicker *dateEnd;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void) setProject:(Project*)newProject;
- (IBAction)saveTask:(id)sender;
- (void) setIsNew:(int)newIsNew;

@end
