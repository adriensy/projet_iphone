//
//  DetailViewController.h
//  projet_iphone
//
//  Created by Projet4a on 22/02/2015.
//  Copyright (c) 2015 Projet4a. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

