//
//  ContactMapperAppDelegate.h
//  ContactMapper
//
//  Created by Steve Baker on 1/30/10.
//  Copyright Beepscore LLC 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ContactMapperViewController;

@interface ContactMapperAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    ContactMapperViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ContactMapperViewController *viewController;

@end

