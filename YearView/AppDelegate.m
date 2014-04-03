//
//  AppDelegate.m
//  YearView
//
//  Created by Mark Alldritt on 2014-03-21.
//  Copyright (c) 2014 Late Night Software Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "CHCSVParser.h"

static NSDictionary* sDatabase = nil;
static NSUInteger sMaxValue = 0;


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    self.yearView.dataSource = self;
    self.yearView.delegate = self;
    
    //  Load in some data for testing purposes
    NSArray* data = [NSArray arrayWithContentsOfCSVFile:[[NSBundle mainBundle] pathForResource:@"data" ofType:@"csv"]];
    NSMutableDictionary* database = [NSMutableDictionary dictionary];
    NSDate* startDate = [NSDate date];
    
    for (NSArray* row in [data subarrayWithRange:NSMakeRange(1, data.count - 1)]) {
        if (row.count == 2) {
            NSDate* date = [NSDate dateWithNaturalLanguageString:[NSString stringWithFormat:@"%@ 00:00:00 PDT", row[0]]];
            NSUInteger value = [(NSString*)row[1] intValue];
            
            if ([date compare:startDate] == NSOrderedAscending)
                startDate = date;
            
            sMaxValue = MAX(sMaxValue, value);
            database[date] = @(value);
        }
    }
    
    startDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitMonth value:-12 toDate:[NSDate date] options:0];

    sDatabase = [database copy]; // non-mutable version
    self.yearView.startDate = startDate;
}

- (NSArray*)legendColors {
    return @[[NSColor colorWithCalibratedRed:0.917 green:0.917 blue:0.917 alpha:1.000],
             [NSColor colorWithCalibratedRed:0.805 green:0.886 blue:0.469 alpha:1.000],
             [NSColor colorWithCalibratedRed:0.492 green:0.738 blue:0.342 alpha:1.000],
             [NSColor colorWithCalibratedRed:0.233 green:0.582 blue:0.206 alpha:1.000],
             [NSColor colorWithCalibratedRed:0.111 green:0.338 blue:0.115 alpha:1.000]];
}

- (NSArray*)gridColors {
    CGFloat numBlends = 7;
    NSMutableArray* result = [NSMutableArray array];
    NSArray* colors = self.legendColors;
    NSUInteger numColors = colors.count;
    
    for (NSUInteger i = 0; i < numColors - 1; ++i) {
        NSColor* color1 = colors[i];
        NSColor* color2 = colors[i + 1];
        
        if (i == 0)
            [result addObject:color1];
        for (CGFloat j = 0; j < numBlends; ++j) {
            CGFloat fraction = (j + 1.0) / (numBlends + 1.0);
            
            [result addObject:[color1 blendedColorWithFraction:fraction ofColor:color2]];
        }
        [result addObject:color2];
    }
    
    return [result copy]; // immutable version
}

#if 1 // show a legend?
- (NSArray*)legendColorsForYearView:(LNSYearView*) yearView {
    return self.legendColors;
}

- (NSString*)leftLegentLabelForYearView:(LNSYearView*) year {
    return @"Idle";
}

- (NSString*)rightLegentLabelForYearView:(LNSYearView*) year {
    return @"Busy";
}
#endif

- (CGFloat)_liniarScaleForValue:(CGFloat)value minValue:(CGFloat)minv maxValue:(CGFloat)maxv minPosition:(CGFloat)minp maxPosition:(CGFloat)maxp {
    CGFloat scale = (maxv - minv) / (maxp - minp);
    return (value - minv) / scale + minp;
}

- (CGFloat)_logScaleForValue:(CGFloat)value minValue:(CGFloat)minv maxValue:(CGFloat)maxv minPosition:(CGFloat)minp maxPosition:(CGFloat)maxp {
    minv = log(minv);
    maxv = log(maxv);

    CGFloat scale = (maxv - minv) / (maxp - minp);
    return (log(value) - minv) / scale + minp;
}

- (NSColor*)yearView:(LNSYearView*) yearView colorForDate:(NSDate*) dayDate {
    static NSArray* sColors = nil;
    
    if (!sColors)
        sColors = self.gridColors;
    NSNumber* value = sDatabase[dayDate];
    if (value) {
#if 1
        NSUInteger pos = [self _logScaleForValue:value.integerValue
                                        minValue:1.0
                                        maxValue:sMaxValue
                                     minPosition:1
                                     maxPosition:sColors.count - 1];
#else
        NSUInteger pos = [self _liniarScaleForValue:value.integerValue
                                           minValue:1.0
                                           maxValue:sMaxValue
                                        minPosition:1
                                        maxPosition:sColors.count - 1];
#endif
        return sColors[pos];
    }
    else
        return sColors[0];
}

#if 1 // customize week names?
- (NSArray*)weekdayNamesForYearView:(LNSYearView*) yearView {
    return @[@"", @"M", @"", @"W", @"", @"F", @""];
}
#endif

- (void)yearView:(LNSYearView *)yearView didClickOnDate:(NSDate *)dayDate {
    NSLog(@"yearView: %@ didClickOnDate: %@", yearView, dayDate);
}

@end
