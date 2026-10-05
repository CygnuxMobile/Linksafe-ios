//
//  JZTouchIDManager.h
//  SynjonesPay
//
//  Created by Nestcode on 2018/1/5.
//  Copyright © 2018 Nestcode. All rights reserved.
//

#import <Foundation/Foundation.h>

#define JZTouchID    [JZTouchIDManager shareManager]


@interface JZTouchIDManager : NSObject


+ (instancetype)shareManager;

- (BOOL)openTouchId:(BOOL)config;


@end
