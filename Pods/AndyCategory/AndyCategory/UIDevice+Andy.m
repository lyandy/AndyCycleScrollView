//
//  UIDevice+Andy.m
//  AndyCategory_Test
//
//  Created by 李扬 on 16/8/5.
//  Copyright © 2016年 andyli. All rights reserved.
//

#import "UIDevice+Andy.h"
#import "NSString+Andy.h"
#import "sys/utsname.h"
#import  <CFNetwork/CFNetwork.h>
#import  <sys/stat.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <sys/param.h>
#include <sys/mount.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <netdb.h>
#import  <AdSupport/ASIdentifierManager.h>
#import  <SystemConfiguration/CaptiveNetwork.h>
#include <arpa/inet.h>
#include <ifaddrs.h>
#import  <dlfcn.h>

#define Valid(a) ((a == nil || [a isKindOfClass:[NSNull class]] || ([a respondsToSelector:@selector(isEqualToString:)] && ([a isEqualToString:@"<null>"] || [a isEqualToString:@"(null)"] || [a isEqualToString:@"null"]))) ? @"" : a)

#define ARRAY_SIZE(a) sizeof(a)/sizeof(a[0])
#define USER_APP_PATH                 @"/User/Applications/"
#define CYDIA_APP_PATH                "/Applications/Cydia.app"

const char* jailbreak_tool_pathes[] = {
    "/Applications/Cydia.app",
    "/Library/MobileSubstrate/MobileSubstrate.dylib",
    "/bin/bash",
    "/usr/sbin/sshd",
    "/etc/apt"
};

char* printEnv(void)
{
    char *env = getenv("DYLD_INSERT_LIBRARIES");
    NSLog(@"%s", env);
    return env;
}

@implementation UIDevice (Andy)

+ (NSString *)andy_machineModel {
    static dispatch_once_t one;
    static NSString *model;
    dispatch_once(&one, ^{
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *machine = malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        model = [NSString stringWithUTF8String:machine];
        free(machine);
    });
    return model;
}

+ (NSString *)andy_machineModelName {
    static dispatch_once_t one;
    static NSString *name;
    dispatch_once(&one, ^{
        NSString *model = [self andy_machineModel];
        if (!model) return;
        NSDictionary *dic = @{
                              @"Watch1,1" : @"Apple Watch 38mm",
                              @"Watch1,2" : @"Apple Watch 42mm",
                              @"Watch2,3" : @"Apple Watch Series 2 38mm",
                              @"Watch2,4" : @"Apple Watch Series 2 42mm",
                              @"Watch2,6" : @"Apple Watch Series 1 38mm",
                              @"Watch2,7" : @"Apple Watch Series 1 42mm",
                              
                              @"iPod1,1" : @"iPod touch 1",
                              @"iPod2,1" : @"iPod touch 2",
                              @"iPod3,1" : @"iPod touch 3",
                              @"iPod4,1" : @"iPod touch 4",
                              @"iPod5,1" : @"iPod touch 5",
                              @"iPod7,1" : @"iPod touch 6",
                              
                              @"iPhone1,1" : @"iPhone 1G",
                              @"iPhone1,2" : @"iPhone 3G",
                              @"iPhone2,1" : @"iPhone 3GS",
                              @"iPhone3,1" : @"iPhone 4 (GSM)",
                              @"iPhone3,2" : @"iPhone 4",
                              @"iPhone3,3" : @"iPhone 4 (CDMA)",
                              @"iPhone4,1" : @"iPhone 4S",
                              @"iPhone5,1" : @"iPhone 5",
                              @"iPhone5,2" : @"iPhone 5",
                              @"iPhone5,3" : @"iPhone 5c",
                              @"iPhone5,4" : @"iPhone 5c",
                              @"iPhone6,1" : @"iPhone 5s",
                              @"iPhone6,2" : @"iPhone 5s",
                              @"iPhone7,1" : @"iPhone 6 Plus",
                              @"iPhone7,2" : @"iPhone 6",
                              @"iPhone8,1" : @"iPhone 6s",
                              @"iPhone8,2" : @"iPhone 6s Plus",
                              @"iPhone8,4" : @"iPhone SE",
                              @"iPhone9,1" : @"iPhone 7",
                              @"iPhone9,2" : @"iPhone 7 Plus",
                              @"iPhone9,3" : @"iPhone 7",
                              @"iPhone9,4" : @"iPhone 7 Plus",
                              
                              @"iPad1,1" : @"iPad 1",
                              @"iPad2,1" : @"iPad 2 (WiFi)",
                              @"iPad2,2" : @"iPad 2 (GSM)",
                              @"iPad2,3" : @"iPad 2 (CDMA)",
                              @"iPad2,4" : @"iPad 2",
                              @"iPad2,5" : @"iPad mini 1",
                              @"iPad2,6" : @"iPad mini 1",
                              @"iPad2,7" : @"iPad mini 1",
                              @"iPad3,1" : @"iPad 3 (WiFi)",
                              @"iPad3,2" : @"iPad 3 (4G)",
                              @"iPad3,3" : @"iPad 3 (4G)",
                              @"iPad3,4" : @"iPad 4",
                              @"iPad3,5" : @"iPad 4",
                              @"iPad3,6" : @"iPad 4",
                              @"iPad4,1" : @"iPad Air",
                              @"iPad4,2" : @"iPad Air",
                              @"iPad4,3" : @"iPad Air",
                              @"iPad4,4" : @"iPad mini 2",
                              @"iPad4,5" : @"iPad mini 2",
                              @"iPad4,6" : @"iPad mini 2",
                              @"iPad4,7" : @"iPad mini 3",
                              @"iPad4,8" : @"iPad mini 3",
                              @"iPad4,9" : @"iPad mini 3",
                              @"iPad5,1" : @"iPad mini 4",
                              @"iPad5,2" : @"iPad mini 4",
                              @"iPad5,3" : @"iPad Air 2",
                              @"iPad5,4" : @"iPad Air 2",
                              @"iPad6,3" : @"iPad Pro (9.7 inch)",
                              @"iPad6,4" : @"iPad Pro (9.7 inch)",
                              @"iPad6,7" : @"iPad Pro (12.9 inch)",
                              @"iPad6,8" : @"iPad Pro (12.9 inch)",
                              
                              @"AppleTV2,1" : @"Apple TV 2",
                              @"AppleTV3,1" : @"Apple TV 3",
                              @"AppleTV3,2" : @"Apple TV 3",
                              @"AppleTV5,3" : @"Apple TV 4",
                              
                              @"i386" : @"Simulator x86",
                              @"x86_64" : @"Simulator x64",
                              };
        name = dic[model];
        if (!name) name = model;
    });
    return name;
}

+ (NSString *)andy_IDFA_uuid
{
    //参考 http://www.jianshu.com/p/f1b59dfb482f
    return Valid([[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]);
}

+ (BOOL)andy_touchIdEnable
{
    BOOL deviceEnable = NO;
    
    NSString *device = [self andy_machineModel];
    NSMutableString *first = [NSMutableString stringWithString:Valid([device componentsSeparatedByString:@","].firstObject)];
    NSRange range = [first rangeOfString:@"iPhone"];
    if (range.length > 0 && range.location != NSNotFound)
    {
        [first replaceOccurrencesOfString:@"iPhone" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, first.length)];
        if (first.integerValue >= 6)
        {
            deviceEnable = YES;
        }
    }
    
    return [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 && deviceEnable;
}

+ (BOOL)andy_ios7OrLater
{
    return ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) ? YES : NO;
}

+ (BOOL)andy_ios8OrLater
{
    return ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) ? YES : NO;
}

+ (BOOL)andy_ios9OrLater
{
    return ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) ? YES : NO;
}

+ (BOOL)andy_iphone4
{
    return ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(320*2, 480*2), [[UIScreen mainScreen] currentMode].size) : NO);
}

+ (BOOL)andy_isPush
{
    if ([self andy_ios8OrLater])
    {
        UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (UIUserNotificationTypeNone == setting.types)
        {
            return NO;
        }
        else
        {
            return YES;
        }
    } else {
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
        UIUserNotificationType type = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
#else
        UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
#endif
        
        if (UIUserNotificationTypeNone == type)
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
}

+ (NSString *)andy_validNickName
{
    NSMutableString *nickName = [[NSMutableString alloc] andy_safe_initWithString:[[UIDevice currentDevice] name]];
    [nickName replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, nickName.length)];
    
    return Valid([nickName andy_safe_substringToIndex:10]);
}


// 获取是否是iPhone
+ (double)andy_isIPhone
{
    static BOOL __isIPhone;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __isIPhone = [[self currentDevice].model rangeOfString:@"iPhone"].location != NSNotFound;
    });
    return __isIPhone;
}


+ (double)andy_bootTime
{
    // NSProcessInfo用于获取当前正在执行的进程信息，包括设备的名称，操作系统版本，进程标识符，进程环境，参数等信息。systemUptime属性返回系统自启动时的累计时间，可以用来精确处理涉及到需要考察时间段的场景（如果直接使用系统时间的差值可能会因为用户修改系统时间而出错）。
    return [[NSDate date] timeIntervalSince1970] - [[NSProcessInfo processInfo] systemUptime];
}

+ (double)andy_freeDiskSpace
{
    struct statfs buf;
    long long freespace = -1;
    if(statfs("/var", &buf) >= 0)
    {
        freespace = (long long)(buf.f_bsize * buf.f_bfree);
    }
    return freespace;
}

+ (double)andy_totalDiskSpace
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    struct statfs tStats;
    statfs([paths.lastObject cStringUsingEncoding:NSUTF8StringEncoding], &tStats);
    float totalSpace = (float)(tStats.f_blocks * tStats.f_bsize);
    
    return totalSpace;
}

+ (NSString *)andy_wifiName
{
    return [self andy_wifi:(__bridge NSString *)kCNNetworkInfoKeySSID];
}

+ (NSString *)andy_wifiMac
{
    return [self andy_wifi:(__bridge NSString *)kCNNetworkInfoKeyBSSID];
}

+ (NSString *)andy_wifi:(NSString *)key
{
    NSString *wifi = nil;
    
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    
    if (wifiInterfaces == NULL)
    {
        return nil;
    }
    
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    
    for (NSString *interfaceName in interfaces)
    {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        
        if (dictRef)
        {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            
            wifi = [networkInfo objectForKey:key];
            
            CFRelease(dictRef);
        }
    }
    
    CFRelease(wifiInterfaces);
    return wifi;
}

// 参考 http://www.jianshu.com/p/a6bab07c4062

// en0（Wifi）、pdp_ip0（移动网络）的ip地址
+ (NSString *)andy_localWiFiIPAddress
{
    BOOL success;
    struct ifaddrs * addrs;
    const struct ifaddrs * cursor;
    success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != NULL)
        {
            // the second test keeps from picking up the loopback address
            if ((cursor->ifa_addr->sa_family == AF_INET || cursor->ifa_addr->sa_family == AF_INET6) && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
            {
                NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                if ([name isEqualToString:@"en0"])
                {
                    //如果是IPV4地址，直接转化
                    if (cursor->ifa_addr->sa_family == AF_INET)
                    {
                        // Get NSString from C String
                        return [UIDevice andy_formatIPV4Address:((struct sockaddr_in *)cursor->ifa_addr)->sin_addr];
                    }
                    
                    //如果是IPV6地址
                    else if (cursor->ifa_addr->sa_family == AF_INET6)
                    {
                        return [UIDevice andy_formatIPV6Address:((struct sockaddr_in6 *)cursor->ifa_addr)->sin6_addr];
                    }
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return nil;
}

//for IPV6
+ (NSString *)andy_formatIPV6Address:(struct in6_addr)ipv6Addr
{
    NSString *address = nil;
    
    char dstStr[INET6_ADDRSTRLEN];
    char srcStr[INET6_ADDRSTRLEN];
    memcpy(srcStr, &ipv6Addr, sizeof(struct in6_addr));
    if(inet_ntop(AF_INET6, srcStr, dstStr, INET6_ADDRSTRLEN) != NULL)
    {
        address = [NSString stringWithUTF8String:dstStr];
    }
    
    return address;
}

//for IPV4
+ (NSString *)andy_formatIPV4Address:(struct in_addr)ipv4Addr
{
    NSString *address = nil;
    
    char dstStr[INET_ADDRSTRLEN];
    char srcStr[INET_ADDRSTRLEN];
    memcpy(srcStr, &ipv4Addr, sizeof(struct in_addr));
    if(inet_ntop(AF_INET, srcStr, dstStr, INET_ADDRSTRLEN) != NULL)
    {
        address = [NSString stringWithUTF8String:dstStr];
    }
    
    return address;
}

+ (NSString *)andy_appList
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:USER_APP_PATH])
    {
        NSArray *applist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:USER_APP_PATH error:nil];
        return [applist componentsJoinedByString:@","];
    }
    
    return @"";
}

+ (BOOL)andy_isModify
{
    for (int i = 0; i < ARRAY_SIZE(jailbreak_tool_pathes); i++)
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:jailbreak_tool_pathes[i]]])
        {
            NSLog(@"The device is jail broken!");
            return YES;
        }
    }
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]])
    {
        NSLog(@"The device is jail broken!!");
        return YES;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:USER_APP_PATH])
    {
        NSLog(@"The device is jail broken!!!");
        return YES;
    }
    
    if (printEnv() != NULL)
    {
        NSLog(@"The device is jail broken!!!!!");
        return YES;
    }
    
    return NO;
}

+ (BOOL)andy_isSimulator
{
    return TARGET_IPHONE_SIMULATOR;
}

+ (NSString *)andy_localPhone
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"SBFormattedPhoneNumber"];
}

+ (NSString *)andy_base3GStation
{
    return @""; // 这个后面写吧，太难了
}

+ (BOOL)andy_callPhoneEnable
{
    NSString *deviceType = [UIDevice currentDevice].model;
    
    NSRange podRange = [deviceType rangeOfString:@"iPod" options:NSCaseInsensitiveSearch];
    NSRange padRange = [deviceType rangeOfString:@"iPad" options:NSCaseInsensitiveSearch];
    NSRange simulatorRange = [deviceType rangeOfString:@"Simulator" options:NSCaseInsensitiveSearch];
    
    return !(podRange.location != NSNotFound || padRange.location != NSNotFound || simulatorRange.location != NSNotFound);
}

+ (NSArray *)andy_ipAddress:(NSString *)hostName
{
    Boolean result = NO;
    CFHostRef hostRef;
    CFArrayRef addresses = NULL;
    NSMutableArray *ipAddress = [[NSMutableArray alloc] init];
    
    hostRef = CFHostCreateWithName(kCFAllocatorDefault, (__bridge CFStringRef)hostName);

    if (hostRef)
    {
        result = CFHostStartInfoResolution(hostRef, kCFHostAddresses, NULL); // pass an error instead of NULL here to find out why it failed
        if (result == TRUE)
        {
            addresses = CFHostGetAddressing(hostRef, &result);
        }
    }
    
    if (result == TRUE)
    {
        
        for (int i = 0; i < CFArrayGetCount(addresses); i++)
        {
            
            CFDataRef ref = (CFDataRef) CFArrayGetValueAtIndex(addresses, i);
            struct sockaddr_in* remoteAddr;
            char *ip_address = "";
            remoteAddr = (struct sockaddr_in*) CFDataGetBytePtr(ref);
            if (remoteAddr != NULL)
            {
                ip_address = inet_ntoa(remoteAddr->sin_addr);
            }
            NSString *ip = [NSString stringWithCString:ip_address encoding:NSUTF8StringEncoding];
            [ipAddress addObject:ip];
        }
    }
    
    if (hostRef != NULL)
    {
        CFRelease(hostRef);
    }
    
    return ipAddress;
}

+ (BOOL)andy_isPad
{
    static BOOL __isPad;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __isPad = [[self currentDevice].model rangeOfString:@"iPad"].location != NSNotFound;
    });
    return __isPad;
}

@end
