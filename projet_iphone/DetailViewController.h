//
//  DetailViewController.h
//  projet_iphone
//
//  Created by Projet4a on 22/02/2015.
//  Copyright (c) 2015 Projet4a. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Project.h"

@interface DetailViewController : UIViewController <NSFetchedResultsControllerDelegate, UITextFieldDelegate, UITextViewDelegate> {
    NSArray * tasks;
    BOOL isNew;
}

@property (strong, nonatomic) Project* detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UITextField *projectTitle;
@property (weak, nonatomic) IBOutlet UITextView *projectDescription;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *addTaskButton;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveButton:(id)sender;
- (IBAction)addTask:(id)sender;
- (void) setIsNew:(int)newIsNew;

@end

