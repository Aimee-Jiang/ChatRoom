//
//  HttpTool.h
//  WeChat
//
//  Created by Weiwei Jiang on 14/12/19.
//  Copyright (c) 2014年 Weiwei Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^HttpToolProgressBlock)(CGFloat progress);
typedef void (^HttpToolCompletionBlock)(NSError *error);



@interface HttpTool : NSObject

-(void)uploadData:(NSData *)data
              url:(NSURL *)url
    progressBlock : (HttpToolProgressBlock)progressBlock
            completion:(HttpToolCompletionBlock) completionBlock;

/**
 下载数据
 */
-(void)downLoadFromURL:(NSURL *)url
        progressBlock : (HttpToolProgressBlock)progressBlock
            completion:(HttpToolCompletionBlock) completionBlock;


-(NSString *)fileSavePath:(NSString *)fileName;

@end
