//
//  VCMVietCalendar.h
//  LichVanNien
//
//  Created by Daniel Nguyen on 1/5/13.
//  Copyright (c) 2013 VCM Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VCMVietCalendar : NSObject

+ (VCMVietCalendar *)share;

- (int)jdFromDate:(int)dd month:(int)mm year:(int)yy;
- (NSArray *)jdToDate:(int)jd;
- (double) NewMoonAA98:(int)k;
- (int)INT:(double)d;
- (int)getNewMoonDay:(int)k TimeZone:(double)timeZone;
- (double)SunLongitude:(double)jdn;
- (double)SunLongitudeAA98:(double)jdn;
- (double)getSunLongitude:(int)dayNumber TimeZone:(double)timeZone;
- (int)getLunarMonth11:(int)yy TimeZone:(double)timeZone;
- (int)getLeapMonthOffset:(int)a11 TimeZone:(double)timeZone;
- (NSArray *)to_am:(int)dd month:(int)mm year:(int)yy TimeZone:(double)timeZone;
- (NSArray *)to_duong:(int)lunarDay LunaMonth:(int)lunarMonth LunaYear:(int)lunarYear LunaLeap:(int)lunarLeap TimeZone:(double)timeZone;
- (BOOL)Namnhuan:(int)yy;
- (int)ByteThang:(int)mm Year:(int)yy;
- (NSString *)Gio_chi:(int)h;
- (NSArray *)Ngay_can_chi:(int)dd Month:(int)mm Year:(int)yy;
- (NSArray *)Thang_can_chi:(int)dd Month:(int)mm Year:(int)yy;
- (NSArray *)Nam_can_chi:(int)dd Month:(int)mm Year:(int)yy;
- (NSString *)HyThan:(int)dd Mounth:(int)mm Year:(int)yy;
- (NSString *)TaiThan:(int)dd Month:(int)mm Year:(int)yy;
- (int)indexhoangdao:(int)dd Month:(int)mm Year:(int)yy;
- (BOOL)h_hoang_dao:(int)dd Month:(int)mm Year:(int)yy index:(int)INDEX;
- (BOOL)isTetAL:(NSDate *)ddate;
- (BOOL)isTetDL:(NSDate *)ddate;
- (BOOL)isTrungThu:(NSDate *)ddate;
- (NSArray *)CacNgayLe:(int)dd Month:(int)mm Year:(int)yy;
- (NSArray *)getKiengNen:(int)dd Month:(int)mm Year:(int)yy;
- (NSArray *)NgayTruc:(int)dd Month:(int)mm Year:(int)yy;
- (int)TrucKien:(int)mm;
- (double)jdAtVST:(int)d Month:(int)m Year:(int)y Hour:(int)hour Minute:(int)min;
- (NSString *)getTietKhi:(int)d Month:(int)m Year:(int)y Hour:(int)hour Minute:(int)min;
- (int)getTietKhiInt:(int)d Month:(int)m Year:(int)y Hour:(int)hour Minute:(int)min;
-(int)getDayCountOfaMonth:(int)month Year:(int)year;

@end
