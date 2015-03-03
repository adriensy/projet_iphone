//
//  TaskViewController.m
//  projet_iphone
//
//  Created by Projet4a on 27/02/2015.
//  Copyright (c) 2015 Projet4a. All rights reserved.
//

#import "TaskViewController.h"

@interface TaskViewController ()

@end

@implementation TaskViewController
@synthesize managedObjectContext;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
    
    
    _TaskDescription.layer.borderWidth = 0.5f;
    _TaskDescription.layer.borderColor = [[UIColor grayColor] CGColor];
    _TaskDescription.layer.cornerRadius = 5.0f;
    
    NSLocale *frLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"];
    
    [[self dateStart] setLocale: frLocale];
    [[self dateEnd] setLocale: frLocale];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void) setIsNew:(int)newIsNew {
    isNew = newIsNew;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)configureView {
    self.taskTitle.delegate = self;
    self.TaskDescription.delegate = self;
    
    if (self.detailItem) {
        self.taskTitle.text = [[self.detailItem valueForKey:@"title"] description];
        self.TaskDescription.text = [[self.detailItem valueForKey:@"describe"] description];
        [[self dateStart] setDate: [self.detailItem valueForKey:@"date_start"]];
        [[self dateEnd] setDate: [self.detailItem valueForKey:@"date_end"]];
        project = [self.detailItem valueForKey:@"project_id"];
    }
}

- (void) setProject:(Project*)newProject {
    project = newProject;
}

- (IBAction)saveTask:(id)sender {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSManagedObject *task = nil;
    
    // Gestion date
    NSDate *dateStartPicker = [[self dateStart] date];
    NSDate *dateEndPicker = [[self dateEnd] date];
    
    if (isNew) {
    task = [NSEntityDescription
            insertNewObjectForEntityForName:@"Task"
            inManagedObjectContext:context];

    } else {
        task = self.detailItem;
    }
    
    [task setValue: dateStartPicker forKey:@"date_start"];
    [task setValue: dateEndPicker forKey:@"date_end"];
    [task setValue:[[self taskTitle] text] forKey:@"title"];
    [task setValue:[[self TaskDescription] text] forKey:@"describe"];
    [task setValue:project forKey:@"project_id"];
    
    NSSet* tasks = [[NSSet alloc] initWithSet:[project tasks]];
    tasks = [tasks setByAddingObject:task];
    
    [project setValue:[NSSet setWithSet:tasks] forKey:@"tasks"];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
