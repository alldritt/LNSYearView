//
//  AppDelegate.h
//  YearView
//
//  Created by Mark Alldritt on 2014-03-21.
//  Copyright (c) 2014 Late Night Software Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LNSYearView.h"


@interface AppDelegate : NSObject <NSApplicationDelegate, LNSYearViewDataSource, LNSYearViewDelegate>

@property (assign, nonatomic) IBOutlet NSWindow *window;
@property (assign, nonatomic) IBOutlet LNSYearView* yearView;

@end
