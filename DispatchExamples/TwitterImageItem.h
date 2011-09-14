//
//  TwitterImageItem.h
//  DispatchExamples
//
//  Created by Nathan Eror on 8/20/11.
//  Copyright (c) 2011 Nathan Eror & Free Time Studios, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^TweetItemCallbackBlock)(void);

@interface TwitterImageItem : NSObject

@property (retain) NSImage *avatar;
@property (copy) NSString *content;

- (id)initWithJSONObjectDict:(NSDictionary *)obj;
- (void)loadAvatarWithCallbackBlock:(TweetItemCallbackBlock)block;


@end
