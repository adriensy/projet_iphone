//
//  TaskViewController.h
//  projet_iphone
//
//  Created by Projet4a on 27/02/2015.
//  Copyright (c) 2015 Projet4a. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Project.h"

@interface TaskViewController : UIViewController {
    Project* project;
}

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UITextField *taskTitle;
@property (weak, nonatomic) IBOutlet UITextView *TaskDescription;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void) setProject:(Project*)newProject;
- (IBAction)saveTask:(id)sender;

@end
