//
//  LumberYard.m
//  LumberYard
//
//  Created by Jay Park on 11/18/13.
//  Copyright (c) 2013 SapientNitro. All rights reserved.
//

#import "LumberYard.h"
#import "DDTTYLogger.h"
#import "DDASLLogger.h"
#import "DDFileLogger.h"

const NSString *databaseURL = @"https://api.mongolab.com/api/1/databases/lumberyard/collections/lumberyardDump?apiKey=plDVmboBbOsiTsTzv8NO6TztOd59pjbr";

@interface LumberYard ()
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) DDFileLogger *fileLogger;
@end

@implementation LumberYard
static LumberYard *sharedInstance;

+ (void)initializeWithLogRollInterval:(NSTimeInterval)logInterval PostInterval:(NSTimeInterval)postInterval
{
    static BOOL initialized = NO;
    if (!initialized)
    {
        initialized = YES;
        sharedInstance = [[LumberYard alloc]init];
        [NSTimer scheduledTimerWithTimeInterval:postInterval target:self selector:@selector(addArchivedLogsToDatabase) userInfo:nil repeats:YES];

        // Configure CocoaLumberjack
        [DDLog addLogger:[DDASLLogger sharedInstance]];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        
        //configure colors
        [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
        [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor redColor] backgroundColor:nil forFlag:LOG_FLAG_ERROR];
        [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor yellowColor] backgroundColor:nil forFlag:LOG_FLAG_WARN];
        [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor blueColor] backgroundColor:nil forFlag:LOG_FLAG_INFO];
        [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor greenColor] backgroundColor:nil forFlag:LOG_FLAG_DEBUG];
        [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor greenColor] backgroundColor:nil forFlag:LOG_FLAG_VERBOSE];
        
        // Create and configure File Logger
        sharedInstance.fileLogger = [[DDFileLogger alloc] init];
        [sharedInstance.fileLogger setMaximumFileSize:(1024 * 1024)]; //size in bytes
        [sharedInstance.fileLogger setRollingFrequency:(logInterval)];
        [[sharedInstance.fileLogger logFileManager] setMaximumNumberOfLogFiles:10];
        [DDLog addLogger:sharedInstance.fileLogger];
        //this writes to User/Library/Application Support/iPhone Simulator/"Choose directory based on architecture"/Applications/"Application GUID"/Library/Caches/Logs/log-xxxxxx
    }
}

+ (instancetype)sharedInstance
{
    return sharedInstance;
}

+ (void)addArchivedLogsToDatabase
{
    NSArray *logFileInfos = [sharedInstance.fileLogger.logFileManager sortedLogFileInfos];
    
    for (DDLogFileInfo *fileInfo in logFileInfos)
    {
        if (fileInfo.isArchived)
        {
            [self sendLogToDatabase:fileInfo.filePath];
        }
    }
}

+ (void)sendLogToDatabase:(NSString *)logFilePath
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[databaseURL copy]]];
    request.HTTPMethod = @"POST";
    
    NSString* logContents = [NSString stringWithContentsOfFile:logFilePath encoding:NSUTF8StringEncoding error:nil];
    NSArray *logContentsArray = [logContents componentsSeparatedByString:@"\n"];
    NSDictionary *postDict = @{@"appName":[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
                               @"log":logContentsArray
                               };
    NSData *postBody = [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:nil];
    request.HTTPBody = postBody;
    
    [request setAllHTTPHeaderFields:@{@"Content-type":@"application/json"}];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(!connectionError)
        {
            [[NSFileManager defaultManager]removeItemAtPath:logFilePath error:nil];
            
        }
        else
        {
            DDLogVerbose(@"Lumberyard: Connection Error. Post to database failed");
        }
    }];
}

@end
