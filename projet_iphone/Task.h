//
//  Task.h
//  projet_iphone
//
//  Created by Projet4a on 22/02/2015.
//  Copyright (c) 2015 Projet4a. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Project.h"


@interface Task : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * describe;
@property (nonatomic, retain) NSDate * date_start;
@property (nonatomic, retain) NSDate * date_end;
@property (nonatomic, retain) Project* project_id;

@end
