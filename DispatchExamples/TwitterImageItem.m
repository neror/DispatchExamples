//
//  TwitterImageItem.m
//  DispatchExamples
//
//  Created by Nathan Eror on 8/20/11.
//  Copyright (c) 2011 Nathan Eror & Free Time Studios, LLC. All rights reserved.
//

#import "TwitterImageItem.h"

@interface TwitterImageItem () {
  NSDictionary *_tweetData;
}
@end

@implementation TwitterImageItem

@synthesize avatar = _avatar;
@synthesize content = _content;


- (id)initWithJSONObjectDict:(NSDictionary *)obj {
  self = [super init];
  if(self) {
    _tweetData = [obj copy];
    _content = [[obj valueForKey:@"text"] retain];
    _avatar = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:@"Blank44x44"]];
  }
  return self;
}

- (void)dealloc {
  [_tweetData release];
  [_content release];
  [_avatar release];
  [super dealloc];
}

- (void)loadAvatarWithCallbackBlock:(TweetItemCallbackBlock)block {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSURL *avatarURL = [NSURL URLWithString:[_tweetData objectForKey:@"profile_image_url"]];
    NSImage *avatarImage = [[NSImage alloc] initWithContentsOfURL:avatarURL];
    self.avatar = avatarImage;
    [avatarImage release];
//    NSLog(@"Loaded avatar image for tweet %@", [_tweetData objectForKey:@"id_str"]);
    block();
  });
}

#pragma mark - IKImageBrowserItem methods

- (NSString *)imageUID {
  return [_tweetData objectForKey:@"profile_image_url"];
}

- (id)imageRepresentation {
  return self.avatar;
}

- (NSString *)imageRepresentationType {
  return IKImageBrowserNSImageRepresentationType;
}

- (NSString *)imageTitle {
  return [_tweetData objectForKey:@"from_user"];
}

- (NSString *)imageSubtitle {
  return [_tweetData objectForKey:@"text"];
}

@end
