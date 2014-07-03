//
//  AppDelegate.h
//  gathernumbers
//
//  Created by garyliumac on 14-3-20.
//  Copyright zlot 2014年. All rights reserved.
//

// Added only for iOS 6 support

#import <UIKit/UIKit.h>

@interface MyNavigationController : UINavigationController <CCDirectorDelegate>
@end

@interface AppController : NSObject <UIApplicationDelegate>
{
	UIWindow *window_;
	MyNavigationController *navController_;

	CCDirectorIOS	*director_;							// weak ref
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) MyNavigationController *navController;
@property (readonly) CCDirectorIOS *director;

@end
