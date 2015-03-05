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

static NSString* const EnCoursString = @"En cours";
static NSString* const TermineeString = @"Terminée";

@synthesize managedObjectContext;
@synthesize pickerView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _TaskDescription.layer.borderWidth = 0.5f;
    _TaskDescription.layer.borderColor = [[UIColor grayColor] CGColor];
    _TaskDescription.layer.cornerRadius = 5.0f;
    
    // Gestion bouton retour
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"< Retour" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    NSLocale *frLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"];
    
    [[self pickerView] setHidden:YES];
    [[self pickerViewEnd] setHidden:YES];
    
    [[self dateStart] setLocale: frLocale];
    [[self dateEnd] setLocale: frLocale];
    
    [self configureView];
}

- (void) backButtonPressed {
    DetailViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    [controller setDetailItem:project];
    [controller setManagedObjectContext:[self managedObjectContext]];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) enablePrincipaleViewControls:(BOOL)enabled {
    [self.taskTitle setEnabled:enabled];
    [self.TaskDescription setEditable:enabled];
    [self.dateStartButton setEnabled:enabled];
    [self.dateEndButton setEnabled:enabled];
    [self.state setEnabled:enabled];
}

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        [self configureView];
    }
}

- (void) setIsNew:(int)newIsNew {
    isNew = newIsNew;
}

- (NSString *) formatDate:(NSDate*)date withFormat:(NSString *) format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString * dateString = @"";
    
    [formatter setDateFormat:format];
    dateString = [formatter stringFromDate:date];
    
    return dateString;
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
    
    self.navigationItem.leftBarButtonItem.title = @"Retour";
    
    // Bouton valider arrondi
    CALayer *btnLayer = [[self saveButton] layer];
    [btnLayer setBorderWidth:0.5f];
    [btnLayer setBorderColor:[[UIColor blueColor] CGColor]];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    [[self saveButton] setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
    
    if (self.detailItem) {
        // Init title and text dates
        self.navigationItem.title = @"Modifier ma tâche";
        NSString* dateStartStr = [self formatDate: [self.detailItem valueForKey:@"date_start"] withFormat:@"dd-MM-yyyy"];
        NSString* dateEndStr = [self formatDate: [self.detailItem valueForKey:@"date_end"] withFormat:@"dd-MM-yyyy"];
        
        // Init value title and describes
        self.taskTitle.text = [[self.detailItem valueForKey:@"title"] description];
        self.TaskDescription.text = [[self.detailItem valueForKey:@"describe"] description];
        
        // Datepicker
        [[self dateStart] setDate: [self.detailItem valueForKey:@"date_start"]];
        [[self dateEnd] setDate: [self.detailItem valueForKey:@"date_end"]];
        
        // Text date button
        [[self dateStartButton] setTitle:dateStartStr forState:UIControlStateNormal];
        [[self dateEndButton] setTitle:dateEndStr forState:UIControlStateNormal];
        
        // State of task
        [[self state] setOn: [[self.detailItem valueForKey:@"checked"] boolValue] animated:NO];
        
        // Set project ID
        project = [self.detailItem valueForKey:@"project_id"];
    } else {
        // New task
        self.navigationItem.title = @"Créer ma tâche";
    }
    
    [self generateTextFromCurrentState:nil];
}

- (void) setProject:(Project*)newProject {
    project = newProject;
}

- (IBAction) generateTextFromCurrentState:(id)sender {
    if (self.state.isOn) {
        [[self stateText] setText: TermineeString];
    } else {
        [[self stateText] setText: EnCoursString];
    }
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
        
        [self.navigationItem setTitle:@"Créer une tâche"];
    } else {
        task = self.detailItem;
    }
    
    [task setValue: dateStartPicker forKey:@"date_start"];
    [task setValue: dateEndPicker forKey:@"date_end"];
    [task setValue:[[self taskTitle] text] forKey:@"title"];
    [task setValue:[[self TaskDescription] text] forKey:@"describe"];
    [task setValue: [NSNumber numberWithBool: self.state.isOn] forKey:@"checked"];
    [task setValue:project forKey:@"project_id"];
    
    NSSet* tasks = [[NSSet alloc] initWithSet:[project tasks]];
    tasks = [tasks setByAddingObject:task];
    
    [project setValue:[NSSet setWithSet:tasks] forKey:@"tasks"];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    DetailViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    [controller setDetailItem:project];
    [controller setManagedObjectContext:[self managedObjectContext]];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)showDatePickerStart:(id)sender {
    [self enablePrincipaleViewControls:NO];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [[self pickerView] setHidden:NO];
    [UIView commitAnimations];
    
    [[self view] setBackgroundColor:[UIColor lightGrayColor]];
}

- (IBAction)hideDatePickerStart:(id)sender {
    [self enablePrincipaleViewControls:YES];
    NSString* dateStartStr = [self formatDate: [self.dateStart date] withFormat:@"dd-MM-yyyy"];
    
    [[self dateStartButton] setTitle:dateStartStr forState:UIControlStateNormal];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [[self pickerView] setHidden:YES];
    [UIView commitAnimations];
    
    [[self view] setBackgroundColor:[UIColor whiteColor]];
}

- (IBAction)showDatePickerEnd:(id)sender {
    [self enablePrincipaleViewControls:NO];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [[self pickerViewEnd] setHidden:NO];
    [UIView commitAnimations];
    
    [[self view] setBackgroundColor:[UIColor lightGrayColor]];
}

- (IBAction)hideDatePickerEnd:(id)sender {
    [self enablePrincipaleViewControls:YES];
    NSString* dateEndStr = [self formatDate: [self.dateEnd date] withFormat:@"dd-MM-yyyy"];
    
    [[self dateEndButton] setTitle:dateEndStr forState:UIControlStateNormal];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [[self pickerViewEnd] setHidden:YES];
    [UIView commitAnimations];
    
    [[self view] setBackgroundColor:[UIColor whiteColor]];
}

















@end
