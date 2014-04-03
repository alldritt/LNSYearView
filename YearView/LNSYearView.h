//
//  YearView.h
//  YearView
//
//  Created by Mark Alldritt on 2014-03-21.
//  Copyright (c) 2014 Late Night Software Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol LNSYearViewDataSource;
@protocol LNSYearViewDelegate;


@interface LNSYearView : NSView

@property (strong, nonatomic) id representedObject;
@property (copy, nonatomic) NSString* title;
@property (strong, nonatomic) NSDate* startDate;
@property (strong, nonatomic) NSFont* font;
@property (strong, nonatomic) NSFont* dateFont;
@property (strong, nonatomic) NSColor* backgroundColor;
@property (strong, nonatomic) NSColor* gridBorderColor;
@property (strong, nonatomic) NSColor* monthTextColor;
@property (strong, nonatomic) NSColor* dayTextColor;
@property (strong, nonatomic) NSColor* dateTextColor;
@property (assign, nonatomic) CGFloat gridSize;
@property (assign, nonatomic) CGFloat gridSpace;
@property (assign, nonatomic) CGFloat gridBorderSize;
@property (assign, nonatomic) BOOL showWeekdays;
@property (assign, nonatomic) BOOL showDates;
@property (assign, nonatomic) BOOL showYears;
@property (assign, nonatomic) BOOL selectable;
@property (assign, nonatomic) BOOL drawsBackground;
@property (assign, nonatomic) NSDate* selectedDate;
@property (weak, nonatomic) id<LNSYearViewDataSource> dataSource;
@property (weak, nonatomic) id<LNSYearViewDelegate> delegate;

- (void)reloadData;
- (void)reloadDataForDate:(NSDate*) date;

- (void)sizeToFit;

@end


@protocol LNSYearViewDataSource <NSObject>
@required

- (NSColor*)yearView:(LNSYearView*) yearView colorForDate:(NSDate*) dayDate;

@optional

- (NSArray*)legendColorsForYearView:(LNSYearView*) yearView;
- (NSString*)leftLegentLabelForYearView:(LNSYearView*) yearView;
- (NSString*)rightLegentLabelForYearView:(LNSYearView*) yearView;

- (NSArray*)weekdayNamesForYearView:(LNSYearView*) yearView;
- (NSArray*)monthNamesForYearView:(LNSYearView*) yearView;

@end


@protocol LNSYearViewDelegate <NSObject>
@optional

- (void)yearView:(LNSYearView*) yearView didClickOnDate:(NSDate*) dayDate;

@end