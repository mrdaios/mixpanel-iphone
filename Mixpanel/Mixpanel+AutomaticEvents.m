//
//  Mixpanel+AutomaticEvents.m
//  HelloMixpanel
//
//  Created by Sam Green on 2/23/16.
//  Copyright © 2016 Mixpanel. All rights reserved.
//

#import "Mixpanel+AutomaticEvents.h"
#import "UIApplication+AutomaticEvents.h"
#import "UIViewController+AutomaticEvents.h"
#import "NSNotificationCenter+AutomaticEvents.h"
#import "AutomaticEventsConstants.h"
#import "MPSwizzle.h"
#import "MPLogger.h"

@implementation Mixpanel (AutomaticEvents)

static Mixpanel *gSharedAutomatedInstance = nil;
+ (instancetype)sharedAutomatedInstance {
    return gSharedAutomatedInstance;
}

+ (void)setSharedAutomatedInstance:(Mixpanel *)instance {
    gSharedAutomatedInstance = instance;
}

+ (instancetype)internalTracking {
    static Mixpanel *gMixpanel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gMixpanel = [[Mixpanel alloc] initWithToken:@"05b7195383129757cbf5172dbc5f67e1" andFlushInterval:60];
    });
    return gMixpanel;
}

+ (void)addSwizzles {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSError *error = NULL;
        
        // Navigation
        [UIViewController mp_swizzleMethod:@selector(viewDidAppear:)
                                withMethod:@selector(mp_viewDidAppear:)
                                     error:&error];
        if (error) {
            MixpanelError(@"Failed to swizzle viewDidAppear: on UIViewController. Details: %@", error);
            [[self internalTracking] track:@"Error" properties:@{ @"Details": error.localizedDescription, @"Code": @(error.code) }];
            error = NULL;
        }
        
        // Actions & Events
        [UIApplication mp_swizzleMethod:@selector(sendEvent:)
                             withMethod:@selector(mp_sendEvent:)
                                  error:&error];
        if (error) {
            MixpanelError(@"Failed to swizzle sendEvent: on UIAppplication. Details: %@", error);
            [[self internalTracking] track:@"Error" properties:@{ @"Details": error.localizedDescription, @"Code": @(error.code) }];
            error = NULL;
        }
        
        [UIApplication mp_swizzleMethod:@selector(sendAction:to:from:forEvent:)
                             withMethod:@selector(mp_sendAction:to:from:forEvent:)
                                  error:&error];
        if (error) {
            MixpanelError(@"Failed to swizzle sendAction:to:from:forEvent: on UIAppplication. Details: %@", error);
            [[self internalTracking] track:@"Error" properties:@{ @"Details": error.localizedDescription, @"Code": @(error.code) }];
            error = NULL;
        }
        
        // Notifications
        [NSNotificationCenter mp_swizzleMethod:@selector(postNotification:)
                                    withMethod:@selector(mp_postNotification:)
                                         error:&error];
        if (error) {
            MixpanelError(@"Failed to swizzle postNotification: on NSNotificationCenter. Details: %@", error);
            [[self internalTracking] track:@"Error" properties:@{ @"Details": error.localizedDescription, @"Code": @(error.code) }];
            error = NULL;
        }

        [NSNotificationCenter mp_swizzleMethod:@selector(postNotificationName:object:userInfo:)
                                    withMethod:@selector(mp_postNotificationName:object:userInfo:)
                                         error:&error];
        if (error) {
            MixpanelError(@"Failed to swizzle postNotificationName:object:userInfo: on NSNotificationCenter. Details: %@", error);
            [[self internalTracking] track:@"Error" properties:@{ @"Details": error.localizedDescription, @"Code": @(error.code) }];
            error = NULL;
        }
    });
}

@end
