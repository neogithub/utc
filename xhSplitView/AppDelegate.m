//
//  AppDelegate.m
//  xhSplitView
//
//  Created by Xiaohe Hu on 9/3/14.
//  Copyright (c) 2014 Neoscape. All rights reserved.
//

#import "AppDelegate.h"
#import "AgreementViewController.h"
#import "DownloadOperation.h"
#import "UAObfuscatedString.h"
#import "SettingViewController.h"
#import "ViewController.h"
#import "DeploymentType.h"

#define BUNDLE_VERSION_EQUAL_TO(v)                  ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] compare:v  options:NSNumericSearch] == NSOrderedSame)
#define BUNDLE_VERSION_GREATER_THAN(v)              ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define BUNDLE_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define BUNDLE_VERSION_LESS_THAN(v)                 ([[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"]  compare:v options:NSNumericSearch] == NSOrderedAscending)
#define BUNDLE_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface AppDelegate () {
    NSString *appPlistName;
}
@property (nonatomic, strong) NSMutableArray *downloads;
@property (nonatomic, strong) NSOperationQueue *downloadQueue;
@end

@implementation AppDelegate

#ifdef IS_US

// this version is for US Store which gets normal notification of new versions

#else

// this version is for enterprise which gets special notification of new versions


-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    

    NSLog(@"Background fetch started...");
    
    self.downloadQueue = [[NSOperationQueue alloc] init];
    self.downloadQueue.maxConcurrentOperationCount = 4;
    
    self.downloads = [NSMutableArray array];
    
    NSString *wString;
    
    if (kUseStagingURL) {
        wString = Obfuscate.h.t.t.p.s.colon.forward_slash.forward_slash.s.t.a.g.i.n.g.dot.t.o.o.l.s.dot.c.a.r.r.i.e.r.dot.c.o.m.forward_slash.B.u.i.l.d.i.n.g.P.o.s.s.i.b.l.e;
        appPlistName = @"utcbuildingpossible.plist";
    } else {
        wString = Obfuscate.h.t.t.p.s.colon.forward_slash.forward_slash.w.w.w.dot.t.o.o.l.s.dot.c.a.r.r.i.e.r.dot.c.o.m.forward_slash.B.u.i.l.d.i.n.g.P.o.s.s.i.b.l.e;
        appPlistName = @"utcbuildingpossible.plist";
    }
    
    NSArray *filenames = @[appPlistName];
    
    for (NSString *filename in filenames)
    {
        // create url from plist and web location
        NSString *urlString = [wString stringByAppendingPathComponent:filename];
        NSURL *url = [NSURL URLWithString:urlString];
        
        // pass the url to download manager
        DownloadOperation *downloadOperation = [[DownloadOperation alloc] initWithURL:url];
        
        // get completion when download finished
        downloadOperation.downloadCompletionBlock = ^(DownloadOperation *operation, BOOL success, NSError *error) {
            if (error) {
                NSLog(@"%s: downloadCompletionBlock error: %@", __FUNCTION__, error);
                completionHandler(UIBackgroundFetchResultFailed);
            } else {
                // get path to document downloaded
                NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSString* foofile = [documentsPath stringByAppendingPathComponent:appPlistName];
                // check if it exists
                BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:foofile];
                
                // if it is missing
                if (fileExists == NO) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:@"Manifest plist missing or has wrong name"
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                    
                    // cancel all downloads
                    [self.downloadQueue cancelAllOperations];
                    [self.downloads removeAllObjects];
                    
                } else if (fileExists == YES) {
                    
                    NSDictionary *tempDict = [[NSDictionary alloc] initWithContentsOfFile:foofile];
                    NSArray *arrayOfDictionaries = [tempDict objectForKey:@"items"];
                    
                    for (NSDictionary *arr in arrayOfDictionaries) {
                        NSString *webBundleVersion = [[arr valueForKey:@"metadata"] valueForKey:@"bundle-version"];
                        NSLog(@"New Version: = %@", [webBundleVersion description]);
                        
                        if (BUNDLE_VERSION_GREATER_THAN_OR_EQUAL_TO(webBundleVersion)) {
                            NSLog(@"SAME delegate");
                            completionHandler(UIBackgroundFetchResultNoData);
                            
                            [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
                            [[UIApplication sharedApplication] cancelAllLocalNotifications];
                            //
                            //                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Updated"
                            //                                                                            message:@"You are up to date"
                            //                                                                           delegate:self
                            //                                                                  cancelButtonTitle:@"OK"
                            //                                                                  otherButtonTitles:nil];
                            //                            [alert show];
                            
                        } else if (BUNDLE_VERSION_LESS_THAN(webBundleVersion)) {
                            
                            NSLog(@"UPDATE delegate ");
                            completionHandler(UIBackgroundFetchResultNewData);
                            
                            //if ([[[UIApplication sharedApplication] scheduledLocalNotifications] count] == 0) {
                            // Set up Local Notifications
                            [[UIApplication sharedApplication] cancelAllLocalNotifications];
                            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                            NSDate *now = [NSDate date];
                            localNotification.fireDate = now;
                            localNotification.applicationIconBadgeNumber = 1;
                            localNotification.alertBody = @"Update is Available";
                            localNotification.soundName = UILocalNotificationDefaultSoundName;
                            [localNotification setRepeatInterval: NSCalendarUnitDay];
                            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                            //}
                            
                        }
                        
                    }
                }
                
            }
            
        };
        
        [self.downloads addObject:downloadOperation];
        [self.downloadQueue addOperation:downloadOperation];
    }
}

#endif

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    // Play a sound and show an alert only if the application is active, to avoid doubly notifiying the user.
    
    //[[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    //    if ([application applicationState] == UIApplicationStateActive) {
    //        // Initialize the alert view.
    //    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    
#ifdef IS_US
    
    NSLog(@"NO FETCH...");
    
#else
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval: UIApplicationBackgroundFetchIntervalMinimum];
    [self registerForRemoteNotification];

#endif
//    if (launchOptions[UIApplicationLaunchOptionsLocalNotificationKey]) {
//        UILocalNotification *notification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
//    } else if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
//        // Assume that user launched the app from the icon with a notification present.
//        [self launchUpdate];
//    }

    return YES;
}

-(void)launchUpdate
{
    
}

-(void)registerForRemoteNotification
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
}

							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"com.neoscape.SelectedRows"];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    // Check the value of the Agreement Identifier in NSUserDefaults
    // and call the RLAgreementViewController if the user hasn't accepted the terms.
    BOOL validAgreement = [[NSUserDefaults standardUserDefaults] boolForKey:kRLAgreementIdentifier];
    
    if (!validAgreement) {
        
//        AgreementViewController* vc = [AgreementViewController new];
        SettingViewController *vc = [SettingViewController new];
        //vc.delegate = self;
        
        UIViewController *activeController = [UIApplication sharedApplication].keyWindow.rootViewController;
        if ([activeController isKindOfClass:[UINavigationController class]]) {
            activeController = [(UINavigationController*) activeController visibleViewController];
        }
        [activeController presentViewController:vc animated:YES completion:nil];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"com.neoscape.SelectedRows"];
    NSLog(@"terminate");
}

@end
