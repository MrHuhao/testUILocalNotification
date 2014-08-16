//
//  testUILocalNotificationAppDelegate.m
//  testUILocalNotification
//
//  Created by huhao on 14-8-16.
//  Copyright (c) 2014年 胡皓. All rights reserved.
//

#import "testUILocalNotificationAppDelegate.h"
@interface testUILocalNotificationAppDelegate(){
    UILocalNotification *locationNotification;
    NSTimer *timer;
    UIBackgroundTaskIdentifier backtaskIdentifier;
}
@end
@implementation testUILocalNotificationAppDelegate

-(id)forwardingTargetForSelector:(SEL)sel
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    return [super forwardingTargetForSelector:sel];
}

static int i = 0;
-(void)cycleDocheck{
    if (!timer) {
        timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(docheck) userInfo:nil repeats:YES];
    }
}
-(void)docheck{
    NSLog(@"[timer]:%d",i = i+1);
    NSURLRequest *theNSURLRequest = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:@"http://localhost:8000/index.txt"]];
    AFHTTPRequestOperation *theAFHTTPRequestOperation = [[AFHTTPRequestOperation alloc]initWithRequest:theNSURLRequest];
    [theAFHTTPRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"[STATUS]: %@ ",@"Success");
        NSLog(@"[RESPONSE]: %@ ",[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self doschemeNotifition:[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[STATUS]: %@",@"failure");
    }];
    [theAFHTTPRequestOperation start];
}

- (void)initLocationNotification
{
     NSLog(@"[METHOD]: %@",@"注册本地消息推送");
    //初始化
    locationNotification = [[UILocalNotification alloc] init];
    //设置推送时间，这里使用相对时间，如果fireDate采用GTM标准时间，timeZone可以至nil
    locationNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    locationNotification.timeZone = [NSTimeZone defaultTimeZone];
    //设置重复周期
    locationNotification.repeatInterval = NSWeekCalendarUnit;
    //设置通知的音乐
    locationNotification.soundName = UILocalNotificationDefaultSoundName;
    //设置通知内容
    locationNotification.alertBody = @"初始化测试信息";
    //设置程序的Icon数量
    locationNotification.applicationIconBadgeNumber = 1;
    NSLog(@"[METHOD]: %@",@"完成注册本地消息推送");
}

-(void)doschemeNotifition:(NSString *)message{
    //设置程序的Icon数量
    locationNotification.applicationIconBadgeNumber = locationNotification.applicationIconBadgeNumber + 1;
    //设置推送时间
    locationNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    //设置通知内容
    locationNotification.alertBody = message;
    //执行本地推送
//    [[UIApplication sharedApplication] scheduleLocalNotification:locationNotification];
    [[UIApplication sharedApplication] presentLocalNotificationNow:locationNotification];
}
-(void)beginAV{
    NSError *setCategoryErr = nil;
    NSError *activationErr  = nil;
    [[AVAudioSession sharedInstance]setCategory: AVAudioSessionCategoryPlayback
                                          error: &setCategoryErr];
    [[AVAudioSession sharedInstance]
     setActive: YES
     error: &activationErr];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initLocationNotification];
    [self beginAV];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    //点击提示框的打开
    application.applicationIconBadgeNumber = 0;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    //检测多任务的可用性
    if ([self isMultitaskingSupported] == NO) {
        return;
    }
    //定义要完成的任务 ，开始执行，
  
    UIApplication*   app = [UIApplication sharedApplication];
    __block    UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
                    [self cycleDocheck];
            }
        });
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
                    [self cycleDocheck];
            }
        });
    });
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (BOOL) isMultitaskingSupported{
    
    BOOL result;
    if ([[UIDevice currentDevice]respondsToSelector:@selector(isMultitaskingSupported)]) {
        result = [[UIDevice currentDevice] isMultitaskingSupported];
    }
    return result;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    //结束该任务
    [[UIApplication sharedApplication] endBackgroundTask:backtaskIdentifier];
    //将任务标识符标记为 UIBackgroundTasksInvalid,标志任务结束
    backtaskIdentifier = UIBackgroundTaskInvalid;
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
     application.applicationIconBadgeNumber = 0;
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
