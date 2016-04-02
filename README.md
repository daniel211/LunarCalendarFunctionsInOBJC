# LunarCalendarFunctionsInOBJC
the source-code in Obj-C for "Computing the Vietnamese lunar calendar", converted from java source (http://www.informatik.uni-leipzig.de/~duc/amlich/)
.

## Example Usage

```objective-c
#import "VCMVietCalendar.h"

NSArray *al = [[VCMVietCalendar share] to_am:2 month:4 year:2016 TimeZone:7];
    NSLog(@"%@", al);
    
    NSArray *ngay = [[VCMVietCalendar share] Ngay_can_chi:2 Month:4 Year:2016];
    NSLog(@"ngay: %@", ngay);
    NSArray *thang = [[VCMVietCalendar share] Thang_can_chi:2 Month:4 Year:2016];
    NSLog(@"thang: %@", thang);
    NSArray *nam = [[VCMVietCalendar share] Nam_can_chi:2 Month:4 Year:2016];
    NSLog(@"nam: %@", nam);

```
