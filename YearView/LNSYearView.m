//
//  YearView.m
//  YearView
//
//  Created by Mark Alldritt on 2014-03-21.
//  Copyright (c) 2014 Late Night Software Ltd. All rights reserved.
//

#import "LNSYearView.h"


#define kDayNameHSpace          5.0
#define kMonthNameYSpace        3.0
#define kLegentLabelHSpace      6.0
#define kLegentVSpace           4.0
#define kMinGridSizeToShowDate  14.0
#define kDaysInWeek             7
#define kFontScaleFactor        0.85


@interface LNSYearView ()

@property (strong, nonatomic) NSCalendar* calendar;

@end

@implementation LNSYearView

- (NSArray*)_weekdayNames {
    NSArray* weekdays = [self.dataSource respondsToSelector:@selector(weekdayNamesForYearView:)] ? [self.dataSource weekdayNamesForYearView:self] : self.calendar.veryShortWeekdaySymbols;
    NSAssert(weekdays.count == kDaysInWeek, @"weekdayNamesForYearView must return an array of %d strings", kDaysInWeek);
    
    return weekdays;
}

- (NSArray*)_monthNames {
    NSArray* months = [self.dataSource respondsToSelector:@selector(monthNamesForYearView:)] ? [self.dataSource monthNamesForYearView:self] : self.calendar.shortMonthSymbols;
    NSRange monthsInYear = [self.calendar rangeOfUnit:NSMonthCalendarUnit inUnit:NSYearCalendarUnit forDate:self.startDate];
    NSAssert1(months.count == monthsInYear.length, @"monthNamesForYearView must return an array of %d strings", (int) monthsInYear.length);
    
    return months;
}

- (NSDate*)_dateForLocation:(NSPoint) location {
    NSRect frame = self.frame;
    CGFloat fontSize = floor(self.gridSize * kFontScaleFactor);
    NSRange weeksInYear = [self.calendar rangeOfUnit:NSWeekCalendarUnit inUnit:NSYearCalendarUnit forDate:self.startDate];
    NSDictionary* monthAttrs = @{NSFontAttributeName: self.font ? self.font : [NSFont systemFontOfSize:fontSize],
                                 NSForegroundColorAttributeName: self.monthTextColor};

    //  Generate a NSDate referring to the first day of self.startDate's month
    NSDateComponents* dateComps = [self.calendar components:NSCalendarUnitYear |
                                                            NSCalendarUnitMonth |
                                                            NSCalendarUnitDay |
                                                            NSCalendarUnitHour |
                                                            NSCalendarUnitMinute |
                                                            NSCalendarUnitSecond
                                                   fromDate:self.startDate];
    
    dateComps.day = 1;
    dateComps.hour = 0;
    dateComps.minute = 0;
    dateComps.second = 0;
    NSDate* startDate = [self.calendar dateFromComponents:dateComps];
    //    NSUInteger month = [self.calendar component:NSCalendarUnitMonth fromDate:startDate];
    CGFloat cellSize = self.gridSpace + self.gridBorderSize * 2.0 + self.gridSize;
    CGFloat xPos = floor((NSWidth(frame) - cellSize * weeksInYear.length) / 2.0 + 0.5);
    CGFloat yPos = floor((NSHeight(frame) - cellSize * kDaysInWeek + kMonthNameYSpace + [@"X" sizeWithAttributes:monthAttrs].height) / 2.0 + 0.5);
    
    if (self.showWeekdays) {
        NSDictionary* dayAttrs = @{NSFontAttributeName: self.font ? self.font : [NSFont systemFontOfSize:fontSize],
                                   NSForegroundColorAttributeName: self.dayTextColor};
        CGFloat maxDayNameWidth = 0.0;
        
        for (NSString* dayName in [self _weekdayNames]) {
            maxDayNameWidth = MAX([dayName sizeWithAttributes:dayAttrs].width, maxDayNameWidth);
        }
        xPos += (kDayNameHSpace + maxDayNameWidth) / 2.0;
    }
    
    if ([self.dataSource respondsToSelector:@selector(legendColorsForYearView:)] || self.title.length > 0) {
        yPos -= (kLegentVSpace + cellSize) / 2.0;
    }

    if (location.x >= xPos && location.x <= xPos + weeksInYear.length * cellSize &&
        location.y >= yPos && location.y <= yPos + kDaysInWeek * cellSize) {
        NSUInteger year = [self.calendar component:NSCalendarUnitYear fromDate:startDate];
        NSUInteger month = [self.calendar component:NSCalendarUnitMonth fromDate:startDate];
        NSUInteger weekOfYear = [self.calendar component:NSCalendarUnitWeekOfYear fromDate:startDate];
        NSUInteger week = (location.x - xPos) / cellSize + weekOfYear; // X
        NSUInteger weekday = (location.y - yPos) / cellSize + 1; // Y
        
        dateComps = [self.calendar components:NSCalendarUnitYear |
                                              NSCalendarUnitWeekOfYear |
                                              NSCalendarUnitWeekday
                                     fromDate:startDate];
        dateComps.weekOfYear = week;
        dateComps.weekday = weekday;
        dateComps.yearForWeekOfYear = year;
        NSDate* date = [self.calendar dateFromComponents:dateComps];
        NSUInteger dateYear = [self.calendar component:NSCalendarUnitYear fromDate:date];
        NSUInteger dateMonth = [self.calendar component:NSCalendarUnitMonth fromDate:date];
        
        if (dateYear == year && dateMonth < month)
            return nil; // user clicked before the first month
        else if (month == 1 && dateYear > year)
            return nil; // user clicked after the last month
        else if (dateYear > year && dateMonth >= month)
            return nil; // user clicked after the last month
        else
            return date;
    }

    return nil; // user clicked outside the calendar
}

- (void)_setupView {
    self.startDate = [NSDate date];
    self.backgroundColor = [NSColor whiteColor];
    self.gridBorderColor = [NSColor blackColor];
    self.monthTextColor = [NSColor grayColor];
    self.dayTextColor = [NSColor lightGrayColor];
    self.dateTextColor = [NSColor darkGrayColor];
    self.gridSize = 15.0;
    self.gridBorderSize = 1.0;
    self.gridSpace = 2.0;
    self.showWeekdays = YES;
    self.showDates = YES;
    self.usesAlternatingMonthBackgroundColors = YES;
    
    self.calendar = [NSCalendar currentCalendar];
    self.calendar.minimumDaysInFirstWeek = 1;
}

- (id)initWithFrame:(NSRect)frameRect {
    if ((self = [super initWithFrame:frameRect])) {
        [self _setupView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self _setupView];
    }
    return self;
}

- (BOOL)isFlipped { return YES; }

- (void)drawRect:(NSRect)dirtyRect {
    [self.backgroundColor set];
    NSRectFill(dirtyRect);
    
    NSRect frame = self.frame;
    CGFloat fontSize = floor(self.gridSize * kFontScaleFactor);
    NSRange weeksInYear = [self.calendar rangeOfUnit:NSWeekCalendarUnit inUnit:NSYearCalendarUnit forDate:self.startDate];
    NSRange monthsInYear = [self.calendar rangeOfUnit:NSMonthCalendarUnit inUnit:NSYearCalendarUnit forDate:self.startDate];
    NSUInteger month = [self.calendar component:NSCalendarUnitMonth fromDate:self.startDate];
    NSArray* alternatingMonthColors = [self.dataSource respondsToSelector:@selector(alternatingMonthColorsForYearView:)] ? [self.dataSource alternatingMonthColorsForYearView:self] : [NSColor controlAlternatingRowBackgroundColors];
    NSArray* months = [self _monthNames];
    NSDictionary* monthAttrs = @{NSFontAttributeName: self.font ? self.font : [NSFont systemFontOfSize:fontSize],
                                 NSForegroundColorAttributeName: self.monthTextColor};

    //  Generate a NSDate referring to the first day of self.startDate's month
    NSDateComponents* dateComps = [self.calendar components:NSCalendarUnitMonth | NSCalendarUnitYear fromDate:self.startDate];

    dateComps.month = month;
    dateComps.day = 1;
    dateComps.hour = 0;
    dateComps.minute = 0;
    dateComps.second = 0;
    NSDate* startDate = [self.calendar dateFromComponents:dateComps];
    
    dateComps = [self.calendar components:NSCalendarUnitMonth | NSCalendarUnitYear | NSWeekdayCalendarUnit fromDate:startDate];

    NSUInteger weekOfYear = [self.calendar component:NSCalendarUnitWeekOfYear fromDate:startDate];
    NSUInteger monthOfYear = [self.calendar component:NSCalendarUnitMonth fromDate:startDate];

    CGFloat cellSize = self.gridSpace + self.gridBorderSize * 2.0 + self.gridSize;
    CGFloat xPos = floor((NSWidth(frame) - cellSize * weeksInYear.length) / 2.0 + 0.5);
    CGFloat yPos = floor((NSHeight(frame) - cellSize * kDaysInWeek + kMonthNameYSpace + [@"X" sizeWithAttributes:monthAttrs].height) / 2.0 + 0.5);
    
    if ([self.dataSource respondsToSelector:@selector(legendColorsForYearView:)] || self.title.length > 0) {
        yPos -= (kLegentVSpace + cellSize) / 2.0;
    }
    
    //  Draw day names
    if (self.showWeekdays) {
        NSArray* weekdays = [self _weekdayNames];
        NSDictionary* dayAttrs = @{NSFontAttributeName: self.font ? self.font : [NSFont systemFontOfSize:fontSize],
                                   NSForegroundColorAttributeName: self.dayTextColor};
        CGFloat maxDayNameWidth = 0.0;

        for (NSString* dayName in weekdays) {
            maxDayNameWidth = MAX([dayName sizeWithAttributes:dayAttrs].width, maxDayNameWidth);
        }
        maxDayNameWidth = ceil(maxDayNameWidth);
        xPos += (kDayNameHSpace + maxDayNameWidth) / 2.0;
        
        for (NSUInteger d = 0; d < weekdays.count; ++d) {
            NSString* dayName = weekdays[d];

            if ([dayName isKindOfClass:[NSString class]] && dayName.length > 0) {
                NSSize daySize = [dayName sizeWithAttributes:dayAttrs];
                NSRect r = NSMakeRect(xPos - kDayNameHSpace - maxDayNameWidth + (maxDayNameWidth - daySize.width), yPos + d * cellSize + (cellSize - daySize.height) / 2.0, daySize.width, daySize.height);
                
                [dayName drawInRect:r withAttributes:dayAttrs];
            }
        }
    }
    
    NSUInteger monthIndex = 0;

    //  Iterate over the months in this year
    for (NSUInteger m = monthOfYear; m <= monthsInYear.length; ++m, ++monthIndex) {
        NSString* monthName = months[m - 1];
        NSSize monthSize = [monthName sizeWithAttributes:monthAttrs];
        dateComps.month = m;
        dateComps.day = 1;
        NSDate* date = [self.calendar dateFromComponents:dateComps];
        NSRange daysInMonth = [self.calendar rangeOfUnit:NSDayCalendarUnit
                                                  inUnit:NSMonthCalendarUnit
                                                 forDate:date];
        NSUInteger firstWeekOfMonth = [self.calendar component:NSCalendarUnitWeekOfYear fromDate:date];
        NSUInteger firstWeekdayOfMonth = [self.calendar component:NSCalendarUnitWeekday fromDate:date];
        dateComps.day = daysInMonth.length;
        date = [self.calendar dateFromComponents:dateComps];
        NSUInteger lastWeekOfMonth = [self.calendar component:NSCalendarUnitWeekOfYear fromDate:date];
        NSUInteger lastWeekdayOfMonth = [self.calendar component:NSCalendarUnitWeekday fromDate:date];
        
        if (lastWeekOfMonth < firstWeekOfMonth)
            lastWeekOfMonth = weeksInYear.length;

        //  Calculate the border of the month
        if (self.usesAlternatingMonthBackgroundColors && alternatingMonthColors) {
            [(NSColor*)alternatingMonthColors[monthIndex % alternatingMonthColors.count] set];
            NSRectFill(NSMakeRect(xPos + (firstWeekOfMonth - weekOfYear) * cellSize,
                                  yPos + cellSize * (firstWeekdayOfMonth - 1) - (firstWeekdayOfMonth == 1 ? kMonthNameYSpace + monthSize.height : 0.0),
                                  cellSize,
                                  (kDaysInWeek + 1 - firstWeekdayOfMonth) * cellSize + (firstWeekdayOfMonth == 1 ? kMonthNameYSpace + monthSize.height : 0.0)));
            NSRectFill(NSMakeRect(xPos + (firstWeekOfMonth - weekOfYear + 1) * cellSize,
                                  yPos - kMonthNameYSpace - monthSize.height,
                                  (lastWeekOfMonth - firstWeekOfMonth - 1) * cellSize,
                                  kDaysInWeek * cellSize + kMonthNameYSpace + monthSize.height));
            NSRectFill(NSMakeRect(xPos + (lastWeekOfMonth - weekOfYear) * cellSize,
                                  yPos - kMonthNameYSpace - monthSize.height,
                                  cellSize,
                                  lastWeekdayOfMonth * cellSize + kMonthNameYSpace + monthSize.height));
        }
        
        //  Draw the month name
        [monthName drawInRect:NSMakeRect(xPos + (firstWeekOfMonth - weekOfYear + (firstWeekdayOfMonth == 1 ? 0 : 1)) * cellSize + self.gridSpace / 2.0 + self.gridBorderSize,
                                         yPos - kMonthNameYSpace - monthSize.height,
                                         monthSize.width, monthSize.height)
               withAttributes:monthAttrs];

        //  Iterate over days in the month
        for (NSUInteger day = 1; day <= daysInMonth.length; ++day) {
            dateComps.day = day;
            date = [self.calendar dateFromComponents:dateComps];
            NSUInteger weekdayOfMonth = [self.calendar component:NSCalendarUnitWeekday fromDate:date];
            NSUInteger dayWeekOfYear = [self.calendar component:NSCalendarUnitWeekOfYear fromDate:date];
            NSColor* dayColor = [self.dataSource yearView:self colorForDate:date];

            if (dayWeekOfYear < firstWeekOfMonth)
                dayWeekOfYear = weeksInYear.length - dayWeekOfYear + 1;

            [(dayColor ? dayColor : [NSColor lightGrayColor]) set];
            NSRectFill(NSInsetRect(NSMakeRect(xPos + (dayWeekOfYear - weekOfYear) * cellSize, yPos + cellSize * (weekdayOfMonth - 1), cellSize, cellSize), self.gridBorderSize + self.gridSpace / 2.0, self.gridBorderSize + self.gridSpace / 2.0));

            if (self.gridBorderSize > 0.0) {
                [self.gridBorderColor set];
                NSFrameRectWithWidth(NSInsetRect(NSMakeRect(xPos + (dayWeekOfYear - weekOfYear) * cellSize,
                                                            yPos + cellSize * (weekdayOfMonth - 1), cellSize, cellSize),
                                                            self.gridSpace / 2.0, self.gridSpace / 2.0), self.gridBorderSize);
            }

            if ((self.dateFont || self.gridSize >= kMinGridSizeToShowDate) && self.showDates)
                [[NSString stringWithFormat:@"%d", (int) day] drawInRect:NSInsetRect(NSMakeRect(xPos + (dayWeekOfYear - weekOfYear) * cellSize + 1.0, yPos + cellSize * (weekdayOfMonth - 1), cellSize, cellSize), self.gridBorderSize + self.gridSpace / 2.0, self.gridBorderSize + self.gridSpace / 2.0)
                                                          withAttributes:@{NSFontAttributeName: self.dateFont ? self.dateFont : [NSFont systemFontOfSize:9.0],
                                                                           NSForegroundColorAttributeName: self.dateTextColor}];

            if (self.selectedDate && [self.calendar isDate:date inSameDayAsDate:self.selectedDate]) {
                [[NSColor blackColor] set];
                NSFrameRectWithWidth(NSInsetRect(NSMakeRect(xPos + (dayWeekOfYear - weekOfYear) * cellSize,
                                                            yPos + cellSize * (weekdayOfMonth - 1), cellSize, cellSize),
                                                            self.gridSpace / 2.0 - 1.0, self.gridSpace / 2.0 - 1.0), self.gridBorderSize + 2.0);
            }
        }
    }
    
    //  Iterate over the months in the next year
    //
    //  No doubt there is a way to get this working with one loop, but I've found some edge cases when flipping from one
    //  year to the next that have forced me to structure things in this way.  Hopefully in the future I can simplify
    //  this code and avoid all this duplication.
    dateComps.year += 1;
    dateComps.month = 1;
    dateComps.day = 1;

    for (NSUInteger m = 1; m < monthOfYear; ++m, ++monthIndex) {
        NSString* monthName = months[m - 1];
        NSSize monthSize = [monthName sizeWithAttributes:monthAttrs];
        dateComps.month = m;
        dateComps.day = 1;
        NSDate* date = [self.calendar dateFromComponents:dateComps];
        NSRange daysInMonth = [self.calendar rangeOfUnit:NSDayCalendarUnit
                                                  inUnit:NSMonthCalendarUnit
                                                 forDate:date];
        NSUInteger firstWeekOfMonth = [self.calendar component:NSCalendarUnitWeekOfYear fromDate:date] - 1;
        NSUInteger firstWeekdayOfMonth = [self.calendar component:NSCalendarUnitWeekday fromDate:date];
        dateComps.day = daysInMonth.length;
        date = [self.calendar dateFromComponents:dateComps];
        NSUInteger lastWeekOfMonth = [self.calendar component:NSCalendarUnitWeekOfYear fromDate:date] - 1;
        NSUInteger lastWeekdayOfMonth = [self.calendar component:NSCalendarUnitWeekday fromDate:date];

        //  Calculate the border of the month
        if (self.usesAlternatingMonthBackgroundColors && alternatingMonthColors) {
            [(NSColor*)alternatingMonthColors[monthIndex % alternatingMonthColors.count] set];
            NSRectFill(NSMakeRect(xPos + (firstWeekOfMonth + weeksInYear.length - weekOfYear) * cellSize,
                                  yPos + cellSize * (firstWeekdayOfMonth - 1) - (firstWeekdayOfMonth == 1 ? kMonthNameYSpace + monthSize.height : 0.0),
                                  cellSize,
                                  (kDaysInWeek + 1 - firstWeekdayOfMonth) * cellSize + (firstWeekdayOfMonth == 1 ? kMonthNameYSpace + monthSize.height : 0.0)));
            NSRectFill(NSMakeRect(xPos + (firstWeekOfMonth + weeksInYear.length - weekOfYear + 1) * cellSize,
                                  yPos - kMonthNameYSpace - monthSize.height,
                                  (lastWeekOfMonth - firstWeekOfMonth - 1) * cellSize,
                                  kDaysInWeek * cellSize + kMonthNameYSpace + monthSize.height));
            NSRectFill(NSMakeRect(xPos + (lastWeekOfMonth + weeksInYear.length - weekOfYear) * cellSize,
                                  yPos - kMonthNameYSpace - monthSize.height,
                                  cellSize,
                                  lastWeekdayOfMonth * cellSize + kMonthNameYSpace + monthSize.height));
        }

        //  Draw month name
        [monthName drawInRect:NSMakeRect(xPos + (firstWeekOfMonth + weeksInYear.length - weekOfYear + (firstWeekdayOfMonth == 1 ? 0 : 1)) * cellSize + self.gridSpace / 2.0 + self.gridBorderSize,
                                         yPos - kMonthNameYSpace - monthSize.height,
                                         monthSize.width, monthSize.height)
               withAttributes:monthAttrs];
        
        //  Iterate over days in the month
        for (NSUInteger day = 1; day <= daysInMonth.length; ++day) {
            dateComps.day = day;
            date = [self.calendar dateFromComponents:dateComps];
            NSUInteger weekdayOfMonth = [self.calendar component:NSCalendarUnitWeekday fromDate:date];
            NSUInteger dayWeekOfYear = [self.calendar component:NSCalendarUnitWeekOfYear fromDate:date] - 1;
            NSColor* dayColor = [self.dataSource yearView:self colorForDate:date];

            [(dayColor ? dayColor : [NSColor lightGrayColor]) set];
            NSRectFill(NSInsetRect(NSMakeRect(xPos + (dayWeekOfYear + weeksInYear.length - weekOfYear) * cellSize, yPos + cellSize * (weekdayOfMonth - 1), cellSize, cellSize), self.gridBorderSize + self.gridSpace / 2.0, self.gridBorderSize + self.gridSpace / 2.0));
            
            if (self.gridBorderSize > 0.0) {
                [self.gridBorderColor set];
                NSFrameRectWithWidth(NSInsetRect(NSMakeRect(xPos + (dayWeekOfYear + weeksInYear.length - weekOfYear) * cellSize, yPos + cellSize * (weekdayOfMonth - 1), cellSize, cellSize), self.gridSpace / 2.0, self.gridSpace / 2.0), self.gridBorderSize);
            }

            if ((self.dateFont || self.gridSize >= kMinGridSizeToShowDate) && self.showDates)
                [[NSString stringWithFormat:@"%d", (int) day] drawInRect:NSInsetRect(NSMakeRect(xPos + (dayWeekOfYear + weeksInYear.length - weekOfYear) * cellSize + 1.0, yPos + cellSize * (weekdayOfMonth - 1), cellSize, cellSize), self.gridBorderSize + self.gridSpace / 2.0, self.gridBorderSize + self.gridSpace / 2.0)
                                                          withAttributes:@{NSFontAttributeName: self.dateFont ? self.dateFont : [NSFont systemFontOfSize:9.0],
                                                                           NSForegroundColorAttributeName: self.dateTextColor}];
            
            if (self.selectedDate && [self.calendar isDate:date inSameDayAsDate:self.selectedDate]) {
                [[NSColor blackColor] set];
                NSFrameRectWithWidth(NSInsetRect(NSMakeRect(xPos + (dayWeekOfYear + weeksInYear.length - weekOfYear) * cellSize,
                                                            yPos + cellSize * (weekdayOfMonth - 1),
                                                            cellSize, cellSize),
                                                            self.gridSpace / 2.0 - 1.0, self.gridSpace / 2.0 - 1.0), self.gridBorderSize + 2);
            }
        }
    }
    
    //  Draw the legend
    CGFloat legendLeft = 0;
    if ([self.dataSource respondsToSelector:@selector(legendColorsForYearView:)]) {
        NSArray* colors = [self.dataSource legendColorsForYearView:self];
        NSString* leftLabel = [self.dataSource respondsToSelector:@selector(leftLegentLabelForYearView:)] ? [self.dataSource leftLegentLabelForYearView:self] : @"<";
        NSSize leftLabelSize = [leftLabel sizeWithAttributes:monthAttrs];
        NSString* rightLabel = [self.dataSource respondsToSelector:@selector(rightLegentLabelForYearView:)] ? [self.dataSource rightLegentLabelForYearView:self] : @">";
        NSSize rightLabelSize = [rightLabel sizeWithAttributes:monthAttrs];
        CGFloat legendWidth = leftLabelSize.width + kLegentLabelHSpace + cellSize * colors.count + kLegentLabelHSpace + rightLabelSize.width;
        CGFloat legendX = xPos + weeksInYear.length * cellSize - legendWidth;
        CGFloat legendY = yPos + kDaysInWeek * cellSize + kLegentVSpace;
        
        legendLeft = legendX;
        [leftLabel drawInRect:NSMakeRect(legendX, legendY + (cellSize - leftLabelSize.height) / 2.0, leftLabelSize.width, leftLabelSize.height) withAttributes:monthAttrs];
        legendX += leftLabelSize.width + kLegentLabelHSpace;
        
        for (NSUInteger i = 0; i < colors.count; ++i) {
            
            [(NSColor*)colors[i] set];
            NSRectFill(NSInsetRect(NSMakeRect(legendX, legendY, cellSize, cellSize), self.gridBorderSize + self.gridSpace / 2.0, self.gridBorderSize + self.gridSpace / 2.0));
            
            if (self.gridBorderSize > 0.0) {
                [self.gridBorderColor set];
                NSFrameRectWithWidth(NSInsetRect(NSMakeRect(legendX, legendY, cellSize, cellSize), self.gridSpace / 2.0, self.gridSpace / 2.0), self.gridBorderSize);
            }
            legendX += cellSize;
        }
        
        legendX += kLegentLabelHSpace;
        [rightLabel drawInRect:NSMakeRect(legendX, legendY + (cellSize - rightLabelSize.height) / 2.0, rightLabelSize.width, rightLabelSize.height) withAttributes:monthAttrs];
    }

    //  Draw the title
    if (self.title.length > 0) {
        NSSize titleSize = [self.title sizeWithAttributes:monthAttrs];
        [self.title drawInRect:NSMakeRect(xPos, yPos + kDaysInWeek * cellSize + kLegentVSpace + (cellSize - titleSize.height) / 2.0, titleSize.width, titleSize.height) withAttributes:monthAttrs];
    }
    
#if 0
    //  For MARK
    NSArray* colors = [self.dataSource legendColorsForYearView:self];
#if 1
    NSColor* color1 = colors[2];
    NSColor* color2 = [NSColor whiteColor]; // colors[1];
    NSGradient* gradient = [[NSGradient alloc] initWithStartingColor:color1 endingColor:color2];
#else
    NSGradient* gradient = [[NSGradient alloc] initWithColors:[[[colors subarrayWithRange:NSMakeRange(1, colors.count - 1)] reverseObjectEnumerator] allObjects]];
#endif
    
    [gradient drawFromCenter:NSMakePoint(xPos - 50, yPos) radius:20 toCenter:NSMakePoint(xPos - 50, yPos) radius:40.0 options:NSGradientDrawsBeforeStartingLocation];
#endif
}

- (void)mouseDown:(NSEvent*) theEvent {
    NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSDate* date = [self _dateForLocation:location];

    if (date) {
        self.selectedDate = date;
        [self reloadDataForDate:date];
    }
}

- (void)mouseDragged:(NSEvent *)theEvent {
    NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSDate* date = [self _dateForLocation:location];
    
    if (self.selectedDate)
        [self reloadDataForDate:self.selectedDate];
    self.selectedDate = date;
    if (date)
        [self reloadDataForDate:date];
}

- (void)mouseUp:(NSEvent *)theEvent {
    NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSDate* date = [self _dateForLocation:location];
    
    [self reloadDataForDate:self.selectedDate];
    self.selectedDate = nil;
    
    if ([self.delegate respondsToSelector:@selector(yearView:didClickOnDate:)])
        [self.delegate yearView:self didClickOnDate:date];
}

- (void)setStartDate:(NSDate *)startDate {
    if (![self.startDate isEqualToDate:startDate]) {
        _startDate = startDate;
        [self setNeedsDisplay:YES];
    }
}

- (void)setSelectable:(BOOL)selectable {
    if (self.selectable != selectable) {
        _selectable = NO;
        if (!selectable)
            self.selectedDate = nil;
        [self setNeedsDisplay:YES];
    }
}

- (void)setSelectedDate:(NSDate *)selectedDate {
    if (![self.selectedDate isEqual:selectedDate]) {
        _selectedDate = selectedDate;
        [self setNeedsDisplay:YES];
    }
}

- (void)setFont:(NSFont *)font {
    if (![self.font isEqual:font]) {
        _font = font;
        [self setNeedsDisplay:YES];
    }
}

- (void)setDateFont:(NSFont *)dateFont {
    if (![self.dateFont isEqual:dateFont]) {
        _dateFont = dateFont;
        [self setNeedsDisplay:YES];
    }
}

- (void)setBackgroundColor:(NSColor *)backgroundColor {
    if (![self.backgroundColor isEqual:backgroundColor]) {
        _backgroundColor = backgroundColor;
        [self setNeedsDisplay:YES];
    }
}

- (void)setMonthTextColor:(NSColor *)monthTextColor {
    if (![self.monthTextColor isEqual:monthTextColor]) {
        _monthTextColor = monthTextColor;
        [self setNeedsDisplay:YES];
    }
}

- (void)setDayTextColor:(NSColor *)dayTextColor {
    if (![self.dayTextColor isEqual:dayTextColor]) {
        _dayTextColor = dayTextColor;
        [self setNeedsDisplay:YES];
    }
}

- (void)setDateTextColor:(NSColor *)dateTextColor {
    if (![self.dateTextColor isEqual:dateTextColor]) {
        _dateTextColor = dateTextColor;
        [self setNeedsDisplay:YES];
    }
}

- (void)setGridSize:(CGFloat)gridSize {
    gridSize = floor(gridSize + 0.5);
    if (self.gridSize != gridSize) {
        _gridSize = gridSize;
        [self setNeedsDisplay:YES];
    }
}

- (void)setGridSpace:(CGFloat)gridSpace {
    gridSpace = floor(gridSpace + 0.5);
    if (self.gridSpace != gridSpace) {
        _gridSpace = gridSpace;
        [self setNeedsDisplay:YES];
    }
}

- (void)setGridBorderSize:(CGFloat)gridBorderSize {
    gridBorderSize = floor(gridBorderSize + 0.5);
    if (self.gridBorderSize != gridBorderSize) {
        _gridBorderSize = gridBorderSize;
        [self setNeedsDisplay:YES];
    }
}

- (void)setShowWeekdays:(BOOL)showWeekdays {
    if (self.showWeekdays != showWeekdays) {
        _showWeekdays = showWeekdays;
        [self setNeedsDisplay:YES];
    }
}

- (void)setShowDates:(BOOL)showDates {
    if (self.showDates != showDates) {
        _showDates = showDates;
        [self setNeedsDisplay:YES];
    }
}

- (void)setUsesAlternatingMonthBackgroundColors:(BOOL)usesAlternatingMonthBackgroundColors {
    if (self.usesAlternatingMonthBackgroundColors != usesAlternatingMonthBackgroundColors) {
        _usesAlternatingMonthBackgroundColors = usesAlternatingMonthBackgroundColors;
        [self setNeedsDisplay:YES];
    }
}

- (void)setDataSource:(id<LNSYearViewDataSource>)dataSource {
    if (self.dataSource != dataSource) {
        _dataSource = dataSource;
        [self setNeedsDisplay:YES];
    }
}

- (void)setTitle:(NSString *)title {
    if (![self.title isEqualToString:title]) {
        _title = title;
        [self setNeedsDisplay:YES];
    }
}

- (void)reloadData {
    [self setNeedsDisplay:YES];
}

- (void)reloadDataForDate:(NSDate*) date {
    //  In time, I'll optimize the drawing code to redraw only the dirtied date ranges.  For now, just
    //  invalidate the entire view
    [self reloadData];
}

- (void)sizeToFit {
    CGFloat fontSize = floor(self.gridSize * kFontScaleFactor);
    NSRange weeksInYear = [self.calendar rangeOfUnit:NSWeekCalendarUnit inUnit:NSYearCalendarUnit forDate:self.startDate];
    NSDictionary* monthAttrs = @{NSFontAttributeName: self.font ? self.font : [NSFont systemFontOfSize:fontSize],
                                 NSForegroundColorAttributeName: self.monthTextColor};
    NSSize monthSize = [@"Test" sizeWithAttributes:monthAttrs]; // I only need the height
    CGFloat cellSize = self.gridSpace + self.gridBorderSize * 2.0 + self.gridSize;
    NSDictionary* dayAttrs = @{NSFontAttributeName: self.font ? self.font : [NSFont systemFontOfSize:fontSize],
                               NSForegroundColorAttributeName: self.dayTextColor};
    CGFloat maxDayNameWidth = 0.0;
    
    for (NSString* dayName in [self _weekdayNames]) {
        maxDayNameWidth = MAX([dayName sizeWithAttributes:dayAttrs].width, maxDayNameWidth);
    }

    CGFloat width = (self.showWeekdays ? maxDayNameWidth + kDayNameHSpace : 0.0) + weeksInYear.length * cellSize;
    CGFloat height = monthSize.height + kMonthNameYSpace + cellSize * kDaysInWeek + ([self.dataSource respondsToSelector:@selector(legendColorsForYearView:)] || self.title.length > 0 ? kLegentVSpace + cellSize : 0.0);
    
    [self setFrameSize:NSMakeSize(width, height)];
}

@end
