//
//  GPS.m
//
//  Created by mac on 15/9/15.
//  Copyright (c) 2015年 韩刚. All rights reserved.
//

#import "SXGps.h"
#import <CoreLocation/CoreLocation.h>

@interface SXGps () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *manager;
@end

@implementation SXGps

- (instancetype)init {
    if (self = [super init]) {
        [self initLocationManager];
    }
    return self;
}

- (void)initLocationManager {
    if (!self.manager) {
        //实例化一个管理对象
        self.manager = [[CLLocationManager alloc] init];
        //设置精度 精度越高越耗电
        self.manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        //精度大小 1m
        self.manager.distanceFilter = 1;
        
        CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
        //判断版本
        if (version >= 8.0) {
            //申请用户授权使用地理位置信息
            [self.manager requestAlwaysAuthorization];
        }
        //如果要 获取定位的位置 那么需要设置代理
        self.manager.delegate = self;
    }
}

- (void)startLocation {
    //是否支持定位服务
    if ([CLLocationManager locationServicesEnabled]) {
        //开始定位
        //        self.message = nil;
        //        self.manager.delegate = self;
        [self.manager startUpdatingLocation];
    } else {
        self.message = @"NOGPS";
        self.locationBlock(1.0, 1.0);
        NSLog(@"未打开定位设置");
    }
}
//停止定位
- (void)endLocation {
    [self.manager stopUpdatingLocation];
}
#pragma mark - CLLocationManagerDelegate协议
//当定位开始时 位置发生改变的时候 会一直调用
//会把定位的位置 放入 locations数组中
//这个数组实际上只有一个元素
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (locations.count) {
        //数组中只有一个元素
        CLLocation *location = [locations lastObject];
        //CLLocationCoordinate2D是一个结构体 内部存放的是经纬度
        CLLocationCoordinate2D coordinate = location.coordinate;
        self.message = nil;
        //        NSLog(@"longitude:%f",coordinate.longitude);
        //        NSLog(@"latitude:%f",coordinate.latitude);
        self.longitude = coordinate.longitude;
        self.latitude = coordinate.latitude;
        self.locationBlock(coordinate.longitude, coordinate.latitude);
        [self.manager stopUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"定位失败");
    self.message = @"NOGPS";
    self.locationBlock(1.0, 1.0);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([self.manager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [self.manager requestWhenInUseAuthorization];
            }
            
        default:
            break;
    }
}

const double a = 6378245.0;
const double ee = 0.00669342162296594323;

+ (CLLocation *)transformToMars:(CLLocation *)location {
    //是否在中国大陆之外
    if ([[self class] outOfChina:location]) {
        return location;
    }
    double dLat = [[self class] transformLatWithX:location.coordinate.longitude - 105.0 y:location.coordinate.latitude - 35.0];
    double dLon = [[self class] transformLonWithX:location.coordinate.longitude - 105.0 y:location.coordinate.latitude - 35.0];
    double radLat = location.coordinate.latitude / 180.0 * M_PI;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * M_PI);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * M_PI);
    return [[CLLocation alloc] initWithLatitude:location.coordinate.latitude + dLat longitude:location.coordinate.longitude + dLon];
}

+ (BOOL)outOfChina:(CLLocation *)location {
    if (location.coordinate.longitude < 72.004 || location.coordinate.longitude > 137.8347) {
        return YES;
    }
    if (location.coordinate.latitude < 0.8293 || location.coordinate.latitude > 55.8271) {
        return YES;
    }
    return NO;
}

+ (double)transformLatWithX:(double)x y:(double)y {
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0;
    return ret;
}

+ (double)transformLonWithX:(double)x y:(double)y {
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0;
    return ret;
}

- (CLGeocoder*)gecoder{
    if (_gecoder == nil) {
        _gecoder = [[CLGeocoder alloc] init];
    }
    return _gecoder;
}

- (void)searchLocation:(CLLocation*)location completeionBlock:(AddressCompletionBlock)completeion {
    self.locationAddressBlock = completeion;
    [self startReverseGeocode:location];
}

- (void)startReverseGeocode:(CLLocation *)location{
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:@"zh-hans",nil] forKey:@"AppleLanguages"];
    [self.gecoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error || placemarks.count == 0) {
            self.locationAddressBlock(nil,error);
        }else{
            NSDictionary *dictionary = [[placemarks objectAtIndex:0] addressDictionary];
            
            NSArray * addressArr = @[dictionary[@"State"], dictionary[@"City"], dictionary[@"SubLocality"], dictionary[@"Street"], dictionary[@"Name"], dictionary[@"FormattedAddressLines"][0]];
            self.locationAddressBlock(addressArr,nil);
        }
    }];
}


//----------------------------调用此方法可以直接获取地址
- (void)searchReturnAddress:(void (^)(NSString *totalAddress))addressBlock {
    [self startLocation];
    __weak SXGps *weakself = self;
    self.locationBlock = ^(CGFloat longitude, CGFloat latitude) {
        CLLocation * location = [SXGps transformToMars:[[CLLocation alloc] initWithLatitude:latitude longitude:longitude]];
        
        [weakself searchLocation:location completeionBlock:^(NSArray *locationArr, NSError *error) {
            if (addressBlock) {
                addressBlock([locationArr lastObject]);
            }
        }];
    };
}


@end
