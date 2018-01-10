//
//  CWFlieManager.h
//  QQVoiceDemo
//
//  Created by 张鹏 on 2017/10/13.
//  Copyright © 2017年 张鹏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CWSington.h"

@interface CWFlieManager : NSObject

singtonInterface;
// 文件夹路径
+ (NSString *)CWFolderPath;
// 变声保存的文件路径
+ (NSString *)soundTouchSavePathWithFileName:(NSString *)fileName;
// 音频文件保存的整个路径
+ (NSString *)filePath;
// 删除文件
+ (void)removeFile:(NSString *)filePath;


@end
