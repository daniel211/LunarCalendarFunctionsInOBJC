//
//  VCMVietCalendar.m
//  LichVanNien
//
//  Created by Daniel Nguyen on 1/5/13.
//  Copyright (c) 2013 VCM Studios. All rights reserved.
//

#import "VCMVietCalendar.h"
#import "calLibConstants.h"

@implementation VCMVietCalendar

+ (VCMVietCalendar *)share
{
    static dispatch_once_t once;
    static VCMVietCalendar * share;
    dispatch_once(&once, ^{
        share = [self new];
        // Configure smth
    });
    return share;
}

/**
 *
 * @param dd
 * @param mm
 * @param yy
 * @return the number of days since 1 January 4713 BC (Julian calendar)
 */
- (NSInteger)jdFromDate:(NSInteger)dd month:(NSInteger)mm year:(NSInteger)yy {
    int a = (14 - mm) / 12;
    int y = yy + 4800 - a;
    int m = mm + 12 * a - 3;
    int jd = dd + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400
    - 32045;
    if (jd < 2299161) {
        jd = dd + (153 * m + 2) / 5 + 365 * y + y / 4 - 32083;
    }
    return jd;
}

- (NSArray *)jdToDate:(NSInteger)jd {
    int a, b, c;
    if (jd > 2299160) { // sau 5/10/1582, lich Gregorian
        a = jd + 32044;
        b = (4 * a + 3) / 146097;
        c = a - (b * 146097) / 4;
    } else {
        b = 0;
        c = jd + 32082;
    }
    int d = (4 * c + 3) / 1461;
    int e = c - (1461 * d) / 4;
    int m = (5 * e + 2) / 153;
    int day = e - (153 * m + 2) / 5 + 1;
    int month = m + 3 - 12 * (m / 10);
    int year = b * 100 + d - 4800 + m / 10;
    NSArray *tmpl = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", day], [NSString stringWithFormat:@"%d", month], [NSString stringWithFormat:@"%d", year], nil];
    // khi dùng phải đổi lại các objects thành NSInteger
    return tmpl;
}

- (double) NewMoonAA98:(NSInteger)k {
    double T = k / 1236.85;
    double T2 = T * T;
    double T3 = T2 * T;
    double dr = PI / 180;
    double Jd1 = 2415020.75933 + 29.53058868 * k + 0.0001178 * T2
    - 0.000000155 * T3;
    Jd1 = Jd1 + 0.00033 * sin((166.56 + 132.87 * T - 0.009173 * T2) * dr);
    double M = 359.2242 + 29.10535608 * k - 0.0000333 * T2 - 0.00000347 * T3;
    double Mpr = 306.0253 + 385.81691806 * k + 0.0107306 * T2 + 0.00001236 * T3;
    double F = 21.2964 + 390.67050646 * k - 0.0016528 * T2 - 0.00000239 * T3;
    double C1 = (0.1734 - 0.000393 * T) * sin(M * dr) + 0.0021 * sin(2 * dr * M);
    C1 = C1 - 0.4068 * sin(Mpr * dr) + 0.0161 * sin(dr * 2 * Mpr);
    C1 = C1 - 0.0004 * sin(dr * 3 * Mpr);
    C1 = C1 + 0.0104 * sin(dr * 2 * F) - 0.0051 * sin(dr * (M + Mpr));
    C1 = C1 - 0.0074 * sin(dr * (M - Mpr)) + 0.0004 * sin(dr * (2 * F + M));
    C1 = C1 - 0.0004 * sin(dr * (2 * F - M)) - 0.0006 * sin(dr * (2 * F + Mpr));
    C1 = C1 + 0.0010 * sin(dr * (2 * F - Mpr)) + 0.0005 * sin(dr * (2 * Mpr + M));
    double deltat;
    if (T < -11) {
        deltat = 0.001 + 0.000839 * T + 0.0002261 * T2 - 0.00000845 * T3
        - 0.000000081 * T * T3;
    } else {
        deltat = -0.000278 + 0.000265 * T + 0.000262 * T2;
    }
    
    double JdNew = Jd1 + C1 - deltat;
    
    return JdNew;
}

- (NSInteger)INT:(double)d {
    return (int)floor(d);
}

- (NSInteger)getNewMoonDay:(NSInteger)k TimeZone:(double)timeZone {
    double jd = [self NewMoonAA98:k];
    return [self INT:(jd + 0.5 + timeZone / 24)];
}

- (double)SunLongitude:(double)jdn {
    return [self SunLongitudeAA98:jdn];
}

- (double)SunLongitudeAA98:(double)jdn {
    double T = (jdn - 2451545.0) / 36525;
    double T2 = T * T;
    double dr = PI / 180;
    double M = 357.52910 + 35999.05030 * T - 0.0001559 * T2 - 0.00000048 * T * T2;
    double L0 = 280.46645 + 36000.76983 * T + 0.0003032 * T2;
    double DL = (1.914600 - 0.004817 * T - 0.000014 * T2) * sin(dr * M);
    DL = DL + (0.019993 - 0.000101 * T) * sin(dr * 2 * M) + 0.000290 * sin(dr * 3 * M);
    double L = L0 + DL;
    L = L - 360 * [self INT:(L / 360)];
    return L;
}

- (double)getSunLongitude:(int)dayNumber TimeZone:(double)timeZone {
    return [self SunLongitude:(dayNumber - 0.5 - timeZone / 24)];
}

- (int)getLunarMonth11:(int)yy TimeZone:(double)timeZone {
    double off = [self jdFromDate:31 month:12 year:yy] - 2415021.076998695;
    int k = [self INT:(off / 29.530588853)];
    int nm = [self getNewMoonDay:k TimeZone:timeZone];
    int sunLong = [self INT:([self getSunLongitude:nm TimeZone:timeZone] / 30)];
    if (sunLong >= 9) {
        nm = [self getNewMoonDay:k-1 TimeZone:timeZone];
    }
    return nm;
}

- (int)getLeapMonthOffset:(int)a11 TimeZone:(double)timeZone {
    int k = [self INT:(0.5 + (a11 - 2415021.076998695) / 29.530588853)];
    int last;
    int i = 1;
    
    int arc = [self INT:([self getSunLongitude:[self getNewMoonDay:(k+1) TimeZone:timeZone] TimeZone:timeZone] / 30)];
    
    do {
        last = arc;
        i++;
        arc = [self INT:([self getSunLongitude:([self getNewMoonDay:(k+i) TimeZone:timeZone]) TimeZone:timeZone] / 30)];
    } while (arc != last && i < 14);
    return i - 1;
}

- (NSArray *)to_am:(NSInteger)dd month:(NSInteger)mm year:(NSInteger)yy TimeZone:(double)timeZone {
    int lunarDay, lunarMonth, lunarYear, lunarLeap;
    int dayNumber = [self jdFromDate:dd month:mm year:yy];
    int k = [self INT:((dayNumber - 2415021.076998695) / 29.530588853)];
    int monthStart = [self getNewMoonDay:(k+1) TimeZone:timeZone];
    if (monthStart > dayNumber) {
        monthStart = [self getNewMoonDay:k TimeZone:timeZone];
    }
    int a11 = [self getLunarMonth11:yy TimeZone:timeZone];
    int b11 = a11;
    if (a11 >= monthStart) {
        lunarYear = yy;
        a11 = [self getLunarMonth11:(yy-1) TimeZone:timeZone];
    } else {
        lunarYear = yy + 1;
        b11 = [self getLunarMonth11:(yy+1) TimeZone:timeZone];
    }
    lunarDay = dayNumber - monthStart + 1;
    int diff = [self INT:((monthStart - a11) / 29)];
    lunarLeap = 0;
    lunarMonth = diff + 11;
    if (b11 - a11 > 365) {
        int leapMonthDiff = [self getLunarMonth11:a11 TimeZone:timeZone];
        if (diff >= leapMonthDiff) {
            lunarMonth = diff + 10;
            if (diff == leapMonthDiff) {
                lunarLeap = 1;
            }
        }
    }
    if (lunarMonth > 12) {
        lunarMonth = lunarMonth - 12;
    }
    if (lunarMonth >= 11 && diff < 4) {
        lunarYear -= 1;
    }
    
    NSArray *tmpl = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", lunarDay], [NSString stringWithFormat:@"%d", lunarMonth], [NSString stringWithFormat:@"%d", lunarYear], nil];
    // khi dùng phải đổi lại các objects thành NSInteger
    return tmpl;
    
    //return new short[] { (short) lunarDay, (short) lunarMonth, (short) lunarYear };
    // return new int[]{lunarDay, lunarMonth, lunarYear, lunarLeap};
}

- (NSArray *)to_duong:(NSInteger)lunarDay LunaMonth:(NSInteger)lunarMonth LunaYear:(NSInteger)lunarYear LunaLeap:(NSInteger)lunarLeap TimeZone:(double)timeZone {
    int a11, b11;
    if (lunarMonth < 11) {
        a11 = [self getLunarMonth11:(lunarYear-1) TimeZone:timeZone];// getLunarMonth11(lunarYear - 1, timeZone);
        b11 = [self getLunarMonth11:lunarYear TimeZone:timeZone];// getLunarMonth11(lunarYear, timeZone);
    } else {
        a11 = [self getLunarMonth11:lunarYear TimeZone:timeZone]; //getLunarMonth11(lunarYear, timeZone);
        b11 = [self getLunarMonth11:(lunarYear+1) TimeZone:timeZone]; //getLunarMonth11(lunarYear + 1, timeZone);
    }
    int k = [self INT:(0.5 + (a11 - 2415021.076998695) / 29.530588853)];
    int off = lunarMonth - 11;
    if (off < 0) {
        off += 12;
    }
    if (b11 - a11 > 365) {
        int leapOff = [self getLeapMonthOffset:a11 TimeZone:timeZone];// getLeapMonthOffset(a11, timeZone);
        int leapMonth = leapOff - 2;
        if (leapMonth < 0) {
            leapMonth += 12;
        }
        if (lunarLeap != 0 && lunarMonth != leapMonth) {
            //return new int[] { 0, 0, 0};
            NSArray *tmp1 = [NSArray arrayWithObjects:@"0", @"0", @"0", nil];
            return tmp1;
        } else if (lunarLeap != 0 || off >= leapOff)
            off += 1;
    }
    
    int monthStart = [self getNewMoonDay:(k+off) TimeZone:timeZone];// getNewMoonDay(k + off, timeZone);
    //int[] s = jdToDate(monthStart + lunarDay - 1);
    //return new int[] { s[0], s[1], s[2] };
    // return jdToDate(monthStart+lunarDay-1);
    return [self jdToDate:(monthStart + lunarDay - 1)];
}

- (BOOL)Namnhuan:(NSInteger)yy {
    if ((yy % 4 == 0 && yy % 100 != 0) || (yy % 400 == 0))
        return true; // nam nhuan,0
    return false; // khong nhuan,1
}

// 1,3,5,7,8,10,12 ->31 ngay
// 4,6,9,11 ->30 ngay
// 2-> tuy
- (NSInteger)ByteThang:(NSInteger)mm Year:(NSInteger)yy {// so ngay cua 1 thang
    if (mm == 1 || mm == 3 || mm == 5 || mm == 7 || mm == 8 || mm == 10 || mm == 12) {
        return 31;
    }
    
    if (mm == 4 || mm == 6 || mm == 9 || mm == 11) {
        return 30;
    }
    
    if (mm == 2 && [self Namnhuan:yy]) {
        return 29;
    }
    
    return 28;
}

- (NSString *)Gio_chi:(NSInteger)h {
    if (h == 23 || (h >= 0 && h <= 1))
        return @"Tí";
    else if (h > 1 && h <= 3)
        return @"Sửu";
    else if (h > 3 && h <= 5)
        return @"Dần";
    else if (h > 5 && h <= 7)
        return @"Mão";
    else if (h > 7 && h <= 9)
        return @"Thìn";
    else if (h > 9 && h <= 11)
        return @"Tỵ";
    else if (h > 11 && h <= 13)
        return @"Ngọ";
    else if (h > 13 && h <= 15)
        return @"Mùi";
    else if (h > 15 && h <= 17)
        return @"Thân";
    else if (h > 17 && h <= 19)
        return @"Dậu";
    else if (h > 19 && h <= 21)
        return @"Tuất";
    else if (h > 21 && h <= 23)
        return @"Hợi";
    return nil;
}

- (NSArray *)Ngay_can_chi:(NSInteger)dd Month:(NSInteger)mm Year:(NSInteger)yy {
    NSArray *paramCan = [NSArray arrayWithObjects:@"Giáp", @"Ất", @"Bính", @"Đinh", @"Mậu", @"Kỷ", @"Canh", @"Tân", @"Nhâm", @"Quý", nil];
    NSArray *paramCanNgay = [NSArray arrayWithObjects:@"Dần", @"Mão", @"Thìn", @"Tỵ", @"Ngọ", @"Mùi", @"Thân", @"Dậu", @"Tuất", @"Hợi", @"Tý", @"Sửu", nil];
    
    int t = [self jdFromDate:dd month:mm year:yy];// jdFromDate(dd, mm, yy);
    //return new String[] { Parameter.can[(t + 9) % 10], Parameter.can_ngay[(t + 11) % 12] };
    return [NSArray arrayWithObjects:[paramCan objectAtIndex:( (t+9)%10 )], [paramCanNgay objectAtIndex:( (t + 11) % 12 )], nil];
}

- (NSArray *)Thang_can_chi:(NSInteger)dd Month:(NSInteger)mm Year:(NSInteger)yy {
    NSArray *paramCan = [NSArray arrayWithObjects:@"Giáp", @"Ất", @"Bính", @"Đinh", @"Mậu", @"Kỷ", @"Canh", @"Tân", @"Nhâm", @"Quý", nil];
    NSArray *paramCanNgay = [NSArray arrayWithObjects:@"Dần", @"Mão", @"Thìn", @"Tỵ", @"Ngọ", @"Mùi", @"Thân", @"Dậu", @"Tuất", @"Hợi", @"Tý", @"Sửu", nil];
    
    //short[] t = to_am(dd, mm, yy, TZ);
    NSArray *tmpl = [self to_am:dd month:mm year:yy TimeZone:TZ];
    //return new String[] { Parameter.can[(t[2] * 12 + t[1] + 3) % 10], Parameter.can_ngay[t[1] - 1] };
    return [NSArray arrayWithObjects:[paramCan objectAtIndex:(([[tmpl objectAtIndex:2] integerValue] * 12 + [[tmpl objectAtIndex:1] integerValue] + 3) % 10)], [paramCanNgay objectAtIndex:([[tmpl objectAtIndex:1] integerValue] - 1)], nil];
}

- (NSArray *)Nam_can_chi:(NSInteger)dd Month:(NSInteger)mm Year:(NSInteger)yy {
    NSArray *paramCan = [NSArray arrayWithObjects:@"Giáp", @"Ất", @"Bính", @"Đinh", @"Mậu", @"Kỷ", @"Canh", @"Tân", @"Nhâm", @"Quý", nil];
    NSArray *paramChi = [NSArray arrayWithObjects:@"Tý", @"Sửu", @"Dần", @"Mão", @"Thìn", @"Tỵ", @"Ngọ", @"Mùi", @"Thân", @"Dậu", @"Tuất", @"Hợi", nil];
    
    NSArray *tmpl = [self to_am:dd month:mm year:yy TimeZone:TZ];
    
    //short[] t = to_am(dd, mm, yy, TZ);
    //return new String[] { Parameter.can[(t[2] + 6) % 10], Parameter.chi[(t[2] + 8) % 12] };
    return [NSArray arrayWithObjects:[paramCan objectAtIndex:(([[tmpl objectAtIndex:2] integerValue] + 6) % 10)], [paramChi objectAtIndex:(([[tmpl objectAtIndex:2] integerValue] + 8) % 12)], nil];
}

- (NSString *)HyThan:(NSInteger)dd Mounth:(NSInteger)mm Year:(NSInteger)yy {
    int t = ([self jdFromDate:dd month:mm year:yy] + 9) % 10;// jdFromDate(dd, mm, yy) + 9) % 10;
    switch (t) {
		case 0:
		case 5:
			return @"Hỷ Thần: Đông Bắc";
		case 1:
		case 6:
			return @"Hỷ Thần: Tây Bắc";
		case 2:
		case 7:
			return @"Hỷ Thần: Tây Nam";
		case 3:
		case 8:
			return @"Hỷ Thần: Chính Nam";
		case 4:
		case 9:
			return @"Hỷ Thần: Đông Nam";
    }
    return nil;
}

- (NSString *)TaiThan:(NSInteger)dd Month:(NSInteger)mm Year:(NSInteger)yy {
    int t = ([self jdFromDate:dd month:mm year:yy] + 9) % 10;// (jdFromDate(dd, mm, yy) + 9) % 10;
    switch (t) {
		case 0:
		case 1:
			return @"Tài Thần: Đông Nam";
		case 2:
		case 3:
			return @"Tài Thần: Đông";
		case 4:
			return @"Tài Thần: Bắc";
		case 5:
			return @"Tài Thần: Nam";
		case 6:
		case 7:
			return @"Tài Thần: Tây Nam";
		case 8:
			return @"Tài Thần: Tây";
		case 9:
			return @"Tài Thần: Tây Bắc";
    }
    return nil;
}

- (NSInteger)indexhoangdao:(NSInteger)dd Month:(NSInteger)mm Year:(NSInteger)yy {
    int t = ([self jdFromDate:dd month:mm year:yy] + 11) % 12; //(jdFromDate(dd, mm, yy) + 11) % 12;
    switch (t) {
		case 0:
		case 6:
			return 0;
		case 1:
		case 7:
			return 1;
		case 2:
		case 8:
			return 2;
		case 3:
		case 9:
			return 3;
		case 4:
		case 10:
			return 4;
		case 5:
		case 11:
			return 5;
    }
    return -1;
}

- (BOOL)h_hoang_dao:(NSInteger)dd Month:(NSInteger)mm Year:(NSInteger)yy index:(NSInteger)INDEX {
    id h[6][12];
    h[0][0] = @"1"; h[0][1] = @"1"; h[0][2] = @"0"; h[0][3] = @"0"; h[0][4] = @"1"; h[0][5] = @"1"; h[0][6] = @"0"; h[0][7] = @"1"; h[0][8] = @"0"; h[0][9] = @"0"; h[0][10] = @"1"; h[0][11] = @"0";
    h[1][0] = @"1"; h[1][1] = @"0"; h[1][2] = @"1"; h[1][3] = @"1"; h[1][4] = @"0"; h[1][5] = @"0"; h[1][6] = @"1"; h[1][7] = @"1"; h[1][8] = @"0"; h[1][9] = @"1"; h[1][10] = @"0"; h[1][11] = @"0";
    h[2][0] = @"0"; h[2][1] = @"0"; h[2][2] = @"1"; h[2][3] = @"0"; h[2][4] = @"1"; h[2][5] = @"1"; h[2][6] = @"0"; h[2][7] = @"0"; h[2][8] = @"1"; h[2][9] = @"1"; h[2][10] = @"0"; h[2][11] = @"1";
    h[3][0] = @"0"; h[3][1] = @"1"; h[3][2] = @"0"; h[3][3] = @"0"; h[3][4] = @"1"; h[3][5] = @"0"; h[3][6] = @"1"; h[3][7] = @"1"; h[3][8] = @"0"; h[3][9] = @"0"; h[3][10] = @"1"; h[3][11] = @"1";
    h[4][0] = @"1"; h[4][1] = @"1"; h[4][2] = @"0"; h[4][3] = @"1"; h[4][4] = @"0"; h[4][5] = @"0"; h[4][6] = @"1"; h[4][7] = @"0"; h[4][8] = @"1"; h[4][9] = @"1"; h[4][10] = @"0"; h[4][11] = @"0";
    h[5][0] = @"0"; h[5][1] = @"0"; h[5][2] = @"1"; h[5][3] = @"1"; h[5][4] = @"0"; h[5][5] = @"1"; h[5][6] = @"0"; h[5][7] = @"0"; h[5][8] = @"1"; h[5][9] = @"0"; h[5][10] = @"1"; h[5][11] = @"1";
    
    /*
    {
        { 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0 },// dần,thân - 0,6
        { 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0 },// mão,dậu - 1,7
        { 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1 },// thìn,tuất - 2,8
        { 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1 },// tỵ,hợi - 3,9
        { 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0 },// tý,ngọ - 4,10
        { 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1 } // sửu,mùi - 5,11
    };
    */
    
    if ([h[[self indexhoangdao:dd Month:mm Year:yy]][INDEX] integerValue] == 1)
        return true;
    else
        return false;
}

- (BOOL)isTetAL:(NSDate *)ddate
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekdayComponents = [gregorian components:(NSDayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:ddate];
    
    NSInteger day = [weekdayComponents day];
    NSInteger month = [weekdayComponents month];
    NSInteger year = [weekdayComponents year];
    
    NSArray *ngayAL = [self to_am:day month:month year:year TimeZone:TZ];
    
    if ([[ngayAL objectAtIndex:0] integerValue] >= 1 && [[ngayAL objectAtIndex:0] integerValue] <= 3 && [[ngayAL objectAtIndex:1] integerValue] == 1) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isTetDL:(NSDate *)ddate
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekdayComponents = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit) fromDate:ddate];
    
    NSInteger day = [weekdayComponents day];
    NSInteger month = [weekdayComponents month];
    
    if (day == 1 && month == 1) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isTrungThu:(NSDate *)ddate
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekdayComponents = [gregorian components:(NSDayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:ddate];
    
    NSInteger day = [weekdayComponents day];
    NSInteger month = [weekdayComponents month];
    NSInteger year = [weekdayComponents year];
    
    NSArray *ngayAL = [self to_am:day month:month year:year TimeZone:TZ];
    
    if ([[ngayAL objectAtIndex:0] integerValue] == 15 && [[ngayAL objectAtIndex:1] integerValue] == 8) {
        return YES;
    }
    
    return NO;
}

- (NSArray *)CacNgayLe:(NSInteger)dd Month:(NSInteger)mm Year:(NSInteger)yy {
    NSMutableArray *arrNgayLes = [[NSMutableArray alloc] init];
    
    // am lich
    NSArray *Ngayle = [self to_am:dd month:mm year:yy TimeZone:TZ];
    
    if ([[Ngayle objectAtIndex:0] integerValue] == 10 && [[Ngayle objectAtIndex:1] integerValue] == 3)
        [arrNgayLes addObject:kSDayGioToHungVuong]; //Parameter.NgayLeTet[17];// gio to hung vuong
    if ([[Ngayle objectAtIndex:0] integerValue] == 15 && [[Ngayle objectAtIndex:1] integerValue] == 1) {
        [arrNgayLes addObject:kSDayTetNguyenTieu]; // Ram thang gieng - tet nguyen tieu
    }
    if ([[Ngayle objectAtIndex:0] integerValue] == 3 & [[Ngayle objectAtIndex:1] integerValue] == 3) {
        [arrNgayLes addObject:kSDayTetHanThuc]; // tet han thuc
    }
    if ([[Ngayle objectAtIndex:0] integerValue] == 14 & [[Ngayle objectAtIndex:1] integerValue] == 4) {
        [arrNgayLes addObject:kSDayTetKhmer]; // tet dan toc Khmer
    }
    if ([[Ngayle objectAtIndex:0] integerValue] == 15 & [[Ngayle objectAtIndex:1] integerValue] == 7) {
        [arrNgayLes addObject:kSDayLeVuLan]; // le Vulan - Xa toi vong nhan
    }
    if ([[Ngayle objectAtIndex:0] integerValue] == 1 & [[Ngayle objectAtIndex:1] integerValue] == 8) {
        [arrNgayLes addObject:kSDayLeHoiKate]; // le hoi Kate
    }
    if ([[Ngayle objectAtIndex:0] integerValue] == 9 & [[Ngayle objectAtIndex:1] integerValue] == 9) {
        [arrNgayLes addObject:kSDayTetTrungCuu]; // tet trung cuu
    }
    if ([[Ngayle objectAtIndex:0] integerValue] == 10 & [[Ngayle objectAtIndex:1] integerValue] == 10) {
        [arrNgayLes addObject:kSDayTetTrungThap]; // tet trung thap
    }
    if ([[Ngayle objectAtIndex:0] integerValue] == 9 & [[Ngayle objectAtIndex:1] integerValue] == 8) {
        [arrNgayLes addObject:kSDayHoiChoiTrau]; // hoi Choi trau do son
    }
    if ([[Ngayle objectAtIndex:0] integerValue] == 5 && [[Ngayle objectAtIndex:1] integerValue] == 5)
        [arrNgayLes addObject:kSDayTetDoanNgo]; //Parameter.NgayLeTet[18];// Diệt Sâu Bọ
    if ([[Ngayle objectAtIndex:0] integerValue] == 15 && [[Ngayle objectAtIndex:1] integerValue] == 8)
        [arrNgayLes addObject:kSDayTrungThu]; //Parameter.NgayLeTet[19];// tet trung thu
    if ([[Ngayle objectAtIndex:0] integerValue] == 23 && [[Ngayle objectAtIndex:1] integerValue] == 12)
        [arrNgayLes addObject:kSDayTaoQuanVeTroi]; //Parameter.NgayLeTet[20];// ong tao chau troi
    if ([[Ngayle objectAtIndex:0] integerValue] >= 1 && [[Ngayle objectAtIndex:0] integerValue] <= 3 && [[Ngayle objectAtIndex:1] integerValue] == 1)
        [arrNgayLes addObject:kSDayTetNguyenDan]; //Parameter.NgayLeTet[21];// tet nguyen dan
    
    if (dd == 1 && mm == 1)
        [arrNgayLes addObject:kSDayTetDuongLich]; //Parameter.NgayLeTet[0];// tét duong lich
    if (dd == 3 && mm == 2)
        [arrNgayLes addObject:kSDayDCSVN]; //Parameter.NgayLeTet[1];// ngay thanh lap DCSVN
    if (dd == 14 && mm == 2)
        [arrNgayLes addObject:kSDayValentine]; //Parameter.NgayLeTet[2];// valentine
    if (dd == 27 && mm == 2)
        [arrNgayLes addObject:kSDayThayThuocVN]; //Parameter.NgayLeTet[3];// ngay thay thuoc
    if (dd == 8 && mm == 3)
        [arrNgayLes addObject:kSDayQuocTePhuNu]; //Parameter.NgayLeTet[4];// ngay quoc te phu nu
    if (dd == 26 && mm == 3)
        [arrNgayLes addObject:kSDayThanhLapDoanTNCS]; //Parameter.NgayLeTet[5];// ngay thanh lap DTNCSHCM
    if (dd == 1 && mm == 4)
        [arrNgayLes addObject:kSDayCaThangTu]; //Parameter.NgayLeTet[6];// Ca thang 4
    if (dd == 30 && mm == 4)
        [arrNgayLes addObject:kSDayGiaiPhongMienNam]; //Parameter.NgayLeTet[7];// giai phong mien nam
    if (dd == 1 && mm == 5)
        [arrNgayLes addObject:kSDayQuocTeLaoDong]; //Parameter.NgayLeTet[8];// ngay quoc te lao dong
    if (dd == 19 && mm == 5) {
        [arrNgayLes addObject:kSDaySNHCM];
    }
    if (dd == 1 && mm == 6)
        [arrNgayLes addObject:kSDayQuocTeThieuNhi]; //Parameter.NgayLeTet[9];// ngay quoc te thieu nhi
    if (dd == 27 && mm == 7)
        [arrNgayLes addObject:kSDayThuongBinhLietSi]; //Parameter.NgayLeTet[10];// ngay Thương binh liệt sĩ
    if (dd == 2 && mm == 9)
        [arrNgayLes addObject:kSDayQuocKhanhVN]; // Parameter.NgayLeTet[11];// ngay quoc khanh
    if (dd == 20 && mm == 10)
        [arrNgayLes addObject:kSDayPhuNuVN]; //Parameter.NgayLeTet[12];// ngay phu nu VN
    if (dd == 13 && mm == 10)
        [arrNgayLes addObject:kSDayDoanhNhanVN]; // Parameter.NgayLeTet[13];// Ngày doanh nhân Việt Nam
    if (dd == 30 && mm == 10)
        [arrNgayLes addObject:kSDayHalloween]; // Parameter.NgayLeTet[14];// ngay halloween
    if (dd == 20 && mm == 11)
        [arrNgayLes addObject:kSDayNhaGiaoVN]; // Parameter.NgayLeTet[15];// ngay nha giao viet nam
    if (dd == 19 && mm == 8) {
        [arrNgayLes addObject:kSDayCMT8];
    }
    if (dd == 25 && mm == 12)
        [arrNgayLes addObject:kSDayGiangSinh]; // Parameter.NgayLeTet[16];// le giang sinh
    
    return arrNgayLes;
}

- (NSArray *)getKiengNen:(NSInteger)dd Month:(NSInteger)mm Year:(NSInteger)yy {
    // luu y ngay tot xau nay la suu tam tai lieu cua cac cu ngay xua
    // nen khong chiu trach nhiem ve cac thong tin dua ra.
    // de tinh ngay tot xau dua rat nhieu vao yeu to nhu:
    // gio hoang dao, hac dao - huong xuat hanh - cac cv muon lam ....
    NSArray *toAm = [self to_am:dd month:mm year:yy TimeZone:TZ];// to_am(dd, mm, yy, TZ);
    // cac ngay dac biet nen tranh trong moi thang
    // dan mao thin ty ngo mui than dau tuat hoi tys suu
    //private static final byte[] ngayxau = new byte[] { 5, 14, 23,// Nguyệt kỵ
    //    3, 7, 13, 18, 22, 27 // Tam nương
    //};// Các ngày trên thì không nên làm những việc quan trọng
    // tuy nhiên có thể chọn giờ tốt để thực hiện các việc khác
    
    NSArray *NgayXau = [NSArray arrayWithObjects:@"5", @"14", @"23", @"3", @"7", @"13", @"18", @"22", @"27", nil];
    
    for (int j = 0; j < [NgayXau count]; j++)
        if ([[toAm objectAtIndex:0] integerValue] == [[NgayXau objectAtIndex:j] integerValue]) {
            
            switch ([[NgayXau objectAtIndex:j] integerValue]) {
				case 5:
				case 14:
				case 23:
					return [NSArray arrayWithObjects:@"Có sao xấu là Nguyệt kỵ nên cẩn thận khi dùng cho các việc mang tính chất đại sự và trọng đại.",
                                                    @"Kiện cáo. Thương lượng. Dời nhà cũ qua nhà mới. Dọn dẹp nhà cửa. Gieo mạ.",
                                                    nil];
				case 3:
				case 7:
				case 13:
				case 18:
				case 22:
				case 27:
					return [NSArray arrayWithObjects:@"Có sao xấu là Tam Nương nên cẩn thận khi dùng cho các việc mang tính chất đại sự và trọng đại.",
                                                    @"Cung cấp sửa chữa lắp đặt ống nước. Dời nhà cũ qua nhà mới. Đặt bàn thờ. Đem tiền gửi nhà Bank. Gieo hạt trồng cây. Giao dịch hoặc hủy bỏ hợp đồng. Làm đường sá. Phá cây lấp đất trồng trọt. Thu tiền - đòi nợ. Tiếp thị quảng cáo hàng hóa.",
                                                    nil];
            }
        }
    
    int jd = ([self jdFromDate:dd month:mm year:yy] + 11) % 12;// (jdFromDate(dd, mm, yy) + 11) % 12;
    if (([[toAm objectAtIndex:1] integerValue] == 1 && jd == 3) || ([[toAm objectAtIndex:1] integerValue] == 2 && jd == 10)
        || ([[toAm objectAtIndex:1] integerValue] == 3 && jd == 5) || ([[toAm objectAtIndex:1] integerValue] == 4 && jd == 1)
        || ([[toAm objectAtIndex:1] integerValue] == 5 && jd == 6) || ([[toAm objectAtIndex:1] integerValue] == 6 && jd == 8)
        || ([[toAm objectAtIndex:1] integerValue] == 7 && jd == 9) || ([[toAm objectAtIndex:1] integerValue] == 8 && jd == 11)
        || ([[toAm objectAtIndex:1] integerValue] == 9 && jd == 4) || ([[toAm objectAtIndex:1] integerValue] == 10 && jd == 7)
        || ([[toAm objectAtIndex:1] integerValue] == 11 && jd == 0) || ([[toAm objectAtIndex:1] integerValue] == 12 && jd == 2))
        return [NSArray arrayWithObjects:@"Có sao xấu là Sát Chủ nên cẩn thận khi dùng cho các việc mang tính chất đại sự và trọng đại. Nhất là kỵ xây nhà mới và cưới gả."
                                        ,@"Dời nhà cũ qua nhà mới. Giao dịch. Mua sắm quần áo - may mặc. Mở tiệc party. Sửa sang nhà cửa. Hội họp bạn bè."
                                        , nil];
    
    if (([[toAm objectAtIndex:1] integerValue] == 1 && jd == 8) || ([[toAm objectAtIndex:1] integerValue] == 2 && jd == 2)
        || ([[toAm objectAtIndex:1] integerValue] == 3 && jd == 9) || ([[toAm objectAtIndex:1] integerValue] == 4 && jd == 3)
        || ([[toAm objectAtIndex:1] integerValue] == 5 && jd == 10) || ([[toAm objectAtIndex:1] integerValue] == 6 && jd == 4)
        || ([[toAm objectAtIndex:1] integerValue] == 7 && jd == 11) || ([[toAm objectAtIndex:1] integerValue] == 8 && jd == 5)
        || ([[toAm objectAtIndex:1] integerValue] == 9 && jd == 0) || ([[toAm objectAtIndex:1] integerValue] == 10 && jd == 6)
        || ([[toAm objectAtIndex:1] integerValue] == 11 && jd == 1) || ([[toAm objectAtIndex:1] integerValue] == 12 && jd == 7))
        return [NSArray arrayWithObjects:@"Có sao xấu là Thọ Tử nên cẩn thận khi dùng cho các việc mang tính chất đại sự và trọng đại.",
                                        @"Ta vẫn có thể thực hiện các công việc như: Cung cấp sửa chữa lắp đặt ống nước. Dời nhà cũ qua nhà mới. Đặt bàn thờ. Đem tiền gửi nhà Bank. Gieo hạt trồng cây. Làm đường sá. Phá cây lấp đất trồng trọt. Thu tiền - đòi nợ. Tiếp thị quảng cáo hàng hóa.",
                                        nil];
    
    if (([[toAm objectAtIndex:1] integerValue] == 1 && jd == 0) || ([[toAm objectAtIndex:1] integerValue] == 2 && jd == 3)
        || ([[toAm objectAtIndex:1] integerValue] == 3 && jd == 6) || ([[toAm objectAtIndex:1] integerValue] == 4 && jd == 9)
        || ([[toAm objectAtIndex:1] integerValue] == 5 && jd == 1) || ([[toAm objectAtIndex:1] integerValue] == 6 && jd == 4)
        || ([[toAm objectAtIndex:1] integerValue] == 7 && jd == 7) || ([[toAm objectAtIndex:1] integerValue] == 8 && jd == 10)
        || ([[toAm objectAtIndex:1] integerValue] == 9 && jd == 0) || ([[toAm objectAtIndex:1] integerValue] == 10 && jd == 2)
        || ([[toAm objectAtIndex:1] integerValue] == 11 && jd == 5) || ([[toAm objectAtIndex:1] integerValue] == 8 && jd == 11))
        return [NSArray arrayWithObjects:@"Có sao xấu là Vãng Vong là ngày trăm sự đều kỵ. Kỵ nhất là xuất hành.",
                                        @"Gieo hạt trồng cây. Làm đường sá. Phá cây lấp đất trồng trọt. Thu tiền - đòi nợ. Dọn dẹp nhà cửa. Gieo mạ. Hội họp bạn bè.",
                                        nil];
    
    if (([[toAm objectAtIndex:1] integerValue] == 1 && jd == 0) || ([[toAm objectAtIndex:1] integerValue] == 2 && jd == 3)
        || ([[toAm objectAtIndex:1] integerValue] == 3 && jd == 6) || ([[toAm objectAtIndex:1] integerValue] == 4 && jd == 9)
        || ([[toAm objectAtIndex:1] integerValue] == 5 && jd == 1) || ([[toAm objectAtIndex:1] integerValue] == 6 && jd == 4)
        || ([[toAm objectAtIndex:1] integerValue] == 7 && jd == 7) || ([[toAm objectAtIndex:1] integerValue] == 8 && jd == 10)
        || ([[toAm objectAtIndex:1] integerValue] == 9 && jd == 0) || ([[toAm objectAtIndex:1] integerValue] == 10 && jd == 2)
        || ([[toAm objectAtIndex:1] integerValue] == 11 && jd == 5) || ([[toAm objectAtIndex:1] integerValue] == 8 && jd == 11))
        return [NSArray arrayWithObjects:@"Có sao xấu là Vãng Vong là ngày trăm sự đều phải kỵ. Kỵ nhất là xuất hành.",
                                        @"Gieo hạt trồng cây. Làm đường sá. Phá cây lấp đất trồng trọt. Thu tiền đòi nợ. Dọn dẹp nhà cửa. Gieo mạ. Hội họp bạn bè.",
                                        nil];
    
    return [self NgayTruc:dd Month:mm Year:yy];//NgayTruc(dd, mm, yy);
}

- (NSArray *)NgayTruc:(NSInteger)dd Month:(NSInteger)mm Year:(NSInteger)yy {
    int truckien = [self TrucKien:mm];// TrucKien(mm);
    int jd = ([self jdFromDate:dd month:mm year:yy] + 11) % 12;
    if (truckien == jd)
        return [NSArray arrayWithObjects:@"Đây là ngày Trực Kiến là ngày tốt tuy nhiên nên tránh động thổ.",
                                        @"Tốt nhất nên làm những việc nhỏ như khởi công xây dựng. Kiến tạo và đào móng. Tốt với xuất hành hay giá thú.",
                                        nil];
    
    int i = 0;
    if (truckien != 0)
        i = 1;
    
    while (true) {
        if (truckien == 11) {
            truckien = 0;
            continue;
        }
        if (truckien == jd)
            break;
        truckien++;
        i++;
        
        if (truckien == jd)
            break;
    }
    
    switch (i) {
		case 1:
			return [NSArray arrayWithObjects:@"Đây là ngày Trực Trừ là ngày bình thường nên tránh cầu tài. Xuất vốn. Cho vay nợ",
                                            @"Nên chữa bệnh. Hốt thuốc hoặc bắt kẻ gian.",
                                            nil];
		case 2:
			return [NSArray arrayWithObjects:@"Đây là ngày Trực Mãn là ngày tốt.",
                                            @"Nên cầu tài. Cầu phúc hoặc tế tự. Tốt cho việc nhập học. Bài sư hoặc ra nghề.",
                                            nil];
		case 3:
			return [NSArray arrayWithObjects:@"Đây là ngày Trực Bình là ngày tốt.",
                                            @"Nên giải hòa. bãi nại. Cầu minh oan hoặc ráp máy.",
                                            nil];
		case 4:
			return [NSArray arrayWithObjects:@"Đây là ngày Trực Định là ngày tốt tuy nhiên tránh kiện tụng. Tranh chấp và chữa bệnh",
                                            @"Tốt về cầu tài. Ký hợp đồng. Yến tiệc. Hội họp bạn bè. Dọn dẹp nhà cửa. Đi mua sắm quần áo - may mặc.",
                                            nil];
		case 5:
			return [NSArray arrayWithObjects:@"Đây là ngày Trực Chấp là ngày bình thường tuy vậy kiêng xuất hành. Di chuyển. Khai trương. Dọn nhà cũ qua nhà mới.",
                                            @"Nên khởi công - xây dựng. Nhận nhân công. Nhập kho hay đặt máy móc. Mở tiệc party.",
                                            nil];
		case 6:
			return [NSArray arrayWithObjects:@"Đây là ngày Trực Phá là ngày xấu.",
                                            @"Nên sửa chữa nhà hay dọn dẹp nhà cửa. Đi khám chữa bệnh.",
                                            nil];
		case 7:
			return [NSArray arrayWithObjects:@"Đây là ngày Trực Nguy là ngày xấu.",
                                            @"Tuy là ngày xấu nhưng nên chọn những công việc mang tính chất mạo hiểm hay khó khăn thì công việc sẽ tốt hơn.",
                                            nil];
		case 8:
			return [NSArray arrayWithObjects:@"Đây là ngày Trực Thành là ngày tốt tuy nhiên nên tránh kiện tụng. Tranh chấp.",
                                            @"Tốt cho xuất hành. Khai trương. Khuyếch trương. Giao dịch. Mưu sự. Tiếp thị quảng cáo hàng hóa. Giá thú.",
                                            nil];
		case 9:
			return [NSArray arrayWithObjects:@"Đây là ngày Trực Thu là ngày bình thường nhưng kỵ khởi công. Xuất hành. An táng.",
                                            @"Nên Thu tiền - đòi nợ. Nhận việc. Nhận nhân công hay Nhập kho.",
                                            nil];
		case 10:
			return [NSArray arrayWithObjects:@"Đây là ngày Trực Khai là ngày tốt nhưng tránh động thổ hay an táng.",
                                            @"Nên Khánh thành. Khai mạc. An vị Phật. Yến kiến.",
                                            nil];
		case 11:
			return [NSArray arrayWithObjects:@"Đây là ngày Trực Bế là ngày xấu nên kiêng mọi việc.",
                                            @"Nên Hành sự pháp luật. Bắt kẻ gian và trộm cắp.",
                                            nil];
    }
    return [NSArray arrayWithObjects:@"", @"", nil];
}

- (NSInteger)TrucKien:(NSInteger)mm {
    if (mm == 2)
        return 0;// dần
    if (mm == 3)
        return 1;// mão
    if (mm == 4)
        return 2;// thìn
    if (mm == 5)
        return 3;// tỵ
    if (mm == 6)
        return 4;// ngọ
    if (mm == 7)
        return 5;// mùi
    if (mm == 8)
        return 6;// thân
    if (mm == 9)
        return 7;// dậu
    if (mm == 10)
        return 8;// tuất
    if (mm == 11)
        return 9;// hợi
    if (mm == 12)
        return 10;// tý
    if (mm == 1)
        return 11;// sửu
    return -1;
}

// dan mao thin ty ngo mui than dau tuat hoi tys suu
//private static final byte[] ngayxau = new byte[] { 5, 14, 23,// Nguyệt kỵ
//    3, 7, 13, 18, 22, 27 // Tam nương
//};// Các ngày trên thì không nên làm những việc quan trọng
// tuy nhiên có thể chọn giờ tốt để thực hiện các việc khác

- (double)jdAtVST:(NSInteger)d Month:(NSInteger)m Year:(NSInteger)y Hour:(NSInteger)hour Minute:(NSInteger)min {
    int ret = [self jdFromDate:d month:m year:y];
    return (double)(ret - 0.5 + (hour - 7) / 24.0 + min / 1440.0);
}

- (NSString *)getTietKhi:(NSInteger)d Month:(NSInteger)m Year:(NSInteger)y Hour:(NSInteger)hour Minute:(NSInteger)min {
    double jd = [self jdAtVST:d Month:m Year:y Hour:hour Minute:min];
    double s1 = [self SunLongitude:jd];
    //int s2 = (int) s1;
    // Log.d("fd00", "" + s1 + " " + s2);
    
    switch ((int)s1) {
        case 0:
            return @"Xuân phân";
            break;
            
        case 15:
            return @"Thanh minh";
            break;
            
        case 30:
            return @"Cốc vũ";
            break;
            
        case 45:
            return @"Lập hạ";
            break;
            
        case 60:
            return @"Tiểu mãn";
            break;
            
        case 75:
            return @"Mang chủng";
            break;
            
        case 90:
            return @"Hạ chí";
            break;
            
        case 105:
            return @"Tiểu thử";
            break;
            
        case 120:
            return @"Đại thử";
            break;
            
        case 135:
            return @"Lập thu";
            break;
            
        case 150:
            return @"Xử thử";
            break;
            
        case 165:
            return @"Bạch lộ";
            break;
            
        case 180:
            return @"Thu phân";
            break;
            
        case 195:
            return @"Hàn lộ";
            break;
            
        case 210:
            return @"Sương giáng";
            break;
            
        case 225:
            return @"Lập đông";
            break;
            
        case 240:
            return @"Tiểu tuyết";
            break;
            
        case 255:
            return @"Đại tuyết";
            break;
            
        case 270:
            return @"Đông chí";
            break;
            
        case 285:
            return @"Tiểu hàn";
            break;
            
        case 300:
            return @"Đại hàn";
            break;
            
        case 315:
            return @"Lập xuân";
            break;
            
        case 330:
            return @"Vũ thuỷ";
            break;
            
        case 345:
            return @"Kinh trập";
            break;
            
        default:
            break;
    }
    
    if (s1 > 0.0 && s1 < 15.0) {
        return @"Giữa Xuân phân - Thanh minh";
    } else if (s1 > 15.0 && s1 < 30.0) {
        return @"Giữa Thanh minh - Cốc vũ";
    } else if (s1 > 30.0 && s1 < 45.0) {
        return @"Giữa Cốc vũ - Lập hạ";
    } else if (s1 > 45.0 && s1 < 60.0) {
        return @"Giữa Lập hạ - Tiểu mãn";
    } else if (s1 > 60.0 && s1 < 75.0) {
        return @"Giữa Tiểu mãn - Mang chủng";
    } else if (s1 > 75.0 && s1 < 90.0) {
        return @"Giữa Mang chủng - Hạ chí";
    } else if (s1 > 90.0 && s1 < 105.0) {
        return @"Giữa Hạ chí - Tiểu thử";
    } else if (s1 > 105.0 && s1 < 120.0) {
        return @"Giữa Tiểu thử - Đại thử";
    } else if (s1 > 120.0 && s1 < 135.0) {
        return @"Giữa Đại thử - Lập thu";
    } else if (s1 > 135.0 && s1 < 150.0) {
        return @"Giữa Lập thu - Xử thử";
    } else if (s1 > 150.0 && s1 < 165.0) {
        return @"Giữa Xử thử - Bạch lộ";
    } else if (s1 > 165.0 && s1 < 180.0) {
        return @"Giữa Bạch lộ - Thu phân";
    } else if (s1 > 180.0 && s1 < 195.0) {
        return @"Giữa Thu phân - Hàn lộ";
    } else if (s1 > 195.0 && s1 < 210.0) {
        return @"Gữa Hàn lộ - Sương giáng";
    } else if (s1 > 210.0 && s1 < 225.0) {
        return @"Giữa Sương giáng - Lập đông";
    } else if (s1 > 225.0 && s1 < 240.0) {
        return @"Giữa Lập đông - Tiểu tuyết";
    } else if (s1 > 240.0 && s1 < 255.0) {
        return @"Giữa Tiểu tuyết - Đại tuyết";
    } else if (s1 > 255.0 && s1 < 270.0) {
        return @"Giữa Đại tuyết - Đông chí";
    } else if (s1 > 270.0 && s1 < 285.0) {
        return @"Giữa Đông chí - Tiểu hàn";
    } else if (s1 > 285.0 && s1 < 300.0) {
        return @"Giữa Tiểu hàn - Đại hàn";
    } else if (s1 > 300.0 && s1 < 315.0) {
        return @"Giữa Đại hàn - Lập xuân";
    } else if (s1 > 315.0 && s1 < 330.0) {
        return @"Giữa Lập xuân - Vũ thuỷ";
    } else if (s1 > 330.0 && s1 < 345.0) {
        return @"Giữa Vũ thủy - Kinh trập";
    } else if (s1 > 345.0 && s1 < 360.0) {
        return @"Giữa Kinh trập - Xuân phân";
    }
    return nil;
}

- (NSInteger)getTietKhiInt:(NSInteger)d Month:(NSInteger)m Year:(NSInteger)y Hour:(NSInteger)hour Minute:(NSInteger)min {
    double jd = [self jdAtVST:d Month:m Year:y Hour:hour Minute:min];// jdAtVST(d, m, y, hour, min);
    double s1 = [self SunLongitude:jd];// SunLongitude(jd);
    if (s1 >= 0.0 && s1 < 15.0) {
        return 1;// return "Xuân phân";
    } else if (s1 >= 15.0 && s1 < 30.0) {
        return 2;// return "Thanh minh";---
    } else if (s1 >= 30.0 && s1 < 45.0) {
        return 3;// return "Cốc Vũ";
    } else if (s1 >= 45.0 && s1 < 60.0) {
        return 4;// return "Lập Hạ";
    } else if (s1 >= 60.0 && s1 < 75.0) {
        return 5;// return "Tiểu mãn";
    } else if (s1 >= 75.0 && s1 < 90.0) {
        return 6;// return "Mang chủng";
    } else if (s1 >= 90.0 && s1 < 105.0) {
        return 7;// return "Hạ Chí";
    } else if (s1 >= 105.0 && s1 < 120.0) {
        return 8;// return "Tiểu Thử";
    } else if (s1 >= 120.0 && s1 < 135.0) {
        return 9;// return "Đại Thử";
    } else if (s1 >= 135.0 && s1 < 150.0) {
        return 10;// return "Lập Thu";
    } else if (s1 >= 150.0 && s1 < 165.0) {
        return 11;// return "Xử Thử";
    } else if (s1 >= 165.0 && s1 < 180.0) {
        return 12;// return "Bạch Lộ";---
    } else if (s1 >= 180.0 && s1 < 195.0) {
        return 13;// return "Thu phân";
    } else if (s1 >= 195.0 && s1 < 210.0) {
        return 14;// return "Hàn Lộ";
    } else if (s1 >= 210.0 && s1 < 225.0) {
        return 15;// return "Sương Giáng";
    } else if (s1 >= 225.0 && s1 < 240.0) {
        return 16;// return "Lập Đông";
    } else if (s1 >= 240.0 && s1 < 255.0) {
        return 17;// return "Tiểu Tuyết";
    } else if (s1 >= 255.0 && s1 < 270.0) {
        return 18;// return "Đại Tuyết";
    } else if (s1 >= 270.0 && s1 < 285.0) {
        return 19;// return "Đông Chí";
    } else if (s1 >= 285.0 && s1 < 300.0) {
        return 20;// return "Tiểu Hàn";
    } else if (s1 >= 300.0 && s1 < 315.0) {
        return 21;// return "Đại Hàn";
    } else if (s1 >= 315.0 && s1 < 330.0) {
        return 22;// return "Lập Xuân";
    } else if (s1 >= 330.0 && s1 < 345.0) {
        return 23;// return "Vũ Thủy";
    } else if (s1 >= 345.0 && s1 < 360.0) {
        return 24;// return "Kinh Trập";
    }
    return 1;
}

-(int)getDayCountOfaMonth:(NSInteger)month Year:(NSInteger)year {
	switch (month) {
		case 1:
		case 3:
		case 5:
		case 7:
		case 8:
		case 10:
		case 12:
			return 31;
			
		case 2:
			if(year%4==0 && year%100!=0)
				return 29;
			else
				return 28;
		case 4:
		case 6:
		case 9:
		case 11:
			return 30;
		default:
			return 31;
	}
}

@end
