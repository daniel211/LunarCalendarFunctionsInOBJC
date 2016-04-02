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

- (NSInteger)jdFromDate:(NSInteger)dd month:(NSInteger)mm year:(NSInteger)yy;
- (NSArray *)jdToDate:(NSInteger)jd;
- (double) NewMoonAA98:(NSInteger)k;
- (NSInteger)INT:(double)d;
- (NSInteger)getNewMoonDay:(NSInteger)k TimeZone:(double)timeZone;
- (double)SunLongitude:(double)jdn;
- (double)SunLongitudeAA98:(double)jdn;
- (double)getSunLongitude:(int)dayNumber TimeZone:(double)timeZone;
- (int)getLunarMonth11:(int)yy TimeZone:(double)timeZone;
- (int)getLeapMonthOffset:(int)a11 TimeZone:(double)timeZone;
- (NSArray *)to_am:(NSInteger)dd month:(NSInteger)mm year:(NSInteger)yy TimeZone:(double)timeZone;
- (NSArray *)to_duong:(NSInteger)lunarDay LunaMonth:(NSInteger)lunarMonth LunaYear:(NSInteger)lunarYear LunaLeap:(NSInteger)lunarLeap TimeZone:(double)timeZone;
- (BOOL)Namnhuan:(NSInteger)yy;
- (NSInteger)ByteThang:(NSInteger)mm Year:(NSInteger)yy;
- (NSString *)Gio_chi:(NSInteger)h;
- (NSArray *)Ngay_can_chi:(NSInteger)dd Month:(NSInteger)mm Year:(NSInteger)yy;
- (NSArray *)Thang_can_chi:(NSInteger)dd Month:(NSInteger)mm Year:(NSInteger)yy;
- (NSArray *)Nam_can_chi:(NSInteger)dd Month:(NSInteger)mm Year:(NSInteger)yy;
- (NSString *)HyThan:(NSInteger)dd Mounth:(NSInteger)mm Year:(NSInteger)yy;
- (NSString *)TaiThan:(NSInteger)dd Month:(NSInteger)mm Year:(NSInteger)yy;
- (NSInteger)indexhoangdao:(NSInteger)dd Month:(NSInteger)mm Year:(NSInteger)yy;
- (BOOL)h_hoang_dao:(NSInteger)dd Month:(NSInteger)mm Year:(NSInteger)yy index:(NSInteger)INDEX;
- (BOOL)isTetAL:(NSDate *)ddate;
- (BOOL)isTetDL:(NSDate *)ddate;
- (BOOL)isTrungThu:(NSDate *)ddate;
- (NSArray *)CacNgayLe:(NSInteger)dd Month:(NSInteger)mm Year:(NSInteger)yy;
- (NSArray *)getKiengNen:(NSInteger)dd Month:(NSInteger)mm Year:(NSInteger)yy;
- (NSArray *)NgayTruc:(NSInteger)dd Month:(NSInteger)mm Year:(NSInteger)yy;
- (NSInteger)TrucKien:(NSInteger)mm;
- (double)jdAtVST:(NSInteger)d Month:(NSInteger)m Year:(NSInteger)y Hour:(NSInteger)hour Minute:(NSInteger)min;
- (NSString *)getTietKhi:(NSInteger)d Month:(NSInteger)m Year:(NSInteger)y Hour:(NSInteger)hour Minute:(NSInteger)min;
- (NSInteger)getTietKhiInt:(NSInteger)d Month:(NSInteger)m Year:(NSInteger)y Hour:(NSInteger)hour Minute:(NSInteger)min;
-(int)getDayCountOfaMonth:(NSInteger)month Year:(NSInteger)year;

@end
