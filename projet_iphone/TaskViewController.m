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
    
    NSLocale *frLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"];
    
    [[self pickerView] setHidden:YES];
    [[self pickerViewEnd] setHidden:YES];
    
    [[self dateStart] setLocale: frLocale];
    [[self dateEnd] setLocale: frLocale];
    
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
        
        BOOL iss = [[self.detailItem valueForKey:@"checked"] boolValue];
        NSLog(iss ? @"YES" : @"NO");
        
        
        [[self state] setOn: [[self.detailItem valueForKey:@"checked"] boolValue] animated:NO];
        
        project = [self.detailItem valueForKey:@"project_id"];
        
        NSDate *dateSelectedFin = [self.dateEnd date];
        NSDate *dateSelectedDebut = [self.dateStart date];
        NSString *dateFinStamp = [[NSString alloc]initWithFormat:@"%@", dateSelectedFin];
        NSString *dateDebutStamp = [[NSString alloc]initWithFormat:@"%@", dateSelectedDebut];
        [[self dateEndButton] setTitle:dateFinStamp forState:UIControlStateNormal];
        [[self dateStartButton] setTitle:dateDebutStamp forState:UIControlStateNormal];
    }
    
    //[self generateTextFromCurrentState];
}

- (void) setProject:(Project*)newProject {
    project = newProject;
}

- (void) generateTextFromCurrentState {
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
}

- (IBAction)showDatePickerStart:(id)sender {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [[self pickerView] setHidden:NO];
    [UIView commitAnimations];
    
    [[self view] setBackgroundColor:[UIColor lightGrayColor]];
}

- (IBAction)hideDatePickerStart:(id)sender {
    NSDate *dateSelectedDebut = [self.dateStart date];
    NSString *dateDebutStamp = [[NSString alloc]initWithFormat:@"%@", dateSelectedDebut];
    self.dateStartButton.titleLabel.text = dateDebutStamp;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [[self pickerView] setHidden:YES];
    [UIView commitAnimations];
    
    [[self view] setBackgroundColor:[UIColor whiteColor]];
}

- (IBAction)showDatePickerEnd:(id)sender {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [[self pickerViewEnd] setHidden:NO];
    [UIView commitAnimations];
    
    [[self view] setBackgroundColor:[UIColor lightGrayColor]];
}

- (IBAction)hideDatePickerEnd:(id)sender {
    NSDate *dateSelectedFin = [self.dateEnd date];
    NSString *dateFinStamp = [[NSString alloc]initWithFormat:@"%@", dateSelectedFin];
    self.dateEndButton.titleLabel.text = dateFinStamp;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [[self pickerViewEnd] setHidden:YES];
    [UIView commitAnimations];
    
    [[self view] setBackgroundColor:[UIColor whiteColor]];
}

- (IBAction)changeState:(id)sender {
    NSLOG(@"%@",self.state.isOn);
    if (self.state.isOn) {
        [[self state] setOn:NO animated:YES];
    } else {
        [[self state] setOn:YES animated:YES];
    }
    
    [self generateTextFromCurrentState];
}

















@end
