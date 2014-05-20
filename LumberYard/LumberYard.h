//
//  LumberYard.h
//  LumberYard
//
//  Created by Jay Park on 11/18/13.
//  Copyright (c) 2013 SapientNitro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDLog.h"

@interface LumberYard : NSObject

/*Log Roll Interval - The logger archives the current log its writing to
 and creates a new file to continue logging.
 Post Interval - LumberYard searches through the log files and uploads all but the active
 log (archived logs) to the Mongo Database*/
+ (void)initializeWithLogRollInterval:(NSTimeInterval)logInterval PostInterval:(NSTimeInterval)postInterval;
+ (instancetype)sharedInstance;

@end
