//
//  AppDelegate.m
//  DispatchExamples
//
//  Created by Nathan Eror on 8/20/11.
//  Copyright (c) 2011 Nathan Eror & Free Time Studios, LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "TwitterImageItem.h"

@interface AppDelegate () {
  NSMutableArray *_imageItems;
  
  dispatch_queue_t _tweetAccessQueue;
  dispatch_source_t _fetchTimer;
}

- (void)addTweetItem:(TwitterImageItem *)item;
- (TwitterImageItem *)tweetItemAtIndex:(NSInteger)index;
- (NSInteger)tweetCount;

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize imageBrowserView = _imageBrowserView;
@synthesize progressSpinner = _progressSpinner;

- (void)dealloc {
  dispatch_suspend(_fetchTimer);
  dispatch_release(_fetchTimer);
  dispatch_release(_tweetAccessQueue);
  [_imageItems release];
  [super dealloc];
}

#define RPP 5
#define RESULTS_PAGES 5

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  _imageItems = [[NSMutableArray alloc] init];
  dispatch_queue_t globalBGQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
  _tweetAccessQueue = dispatch_queue_create("com.freetimestudios.DispatchTwitter.tweetLoadingQueue", DISPATCH_QUEUE_CONCURRENT);
  
  void(^tweetFetchBlock)(void) = ^(void) {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(2);
    dispatch_group_t group = dispatch_group_create();
    NSLog(@"BEGIN FETCH GROUP");
    [_imageItems removeAllObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.progressSpinner startAnimation:nil];
    });
    dispatch_apply(RESULTS_PAGES, globalBGQueue, ^(size_t index) {
      NSLog(@"Ready to fetch page %lu", index + 1);
      dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
      
      dispatch_group_async(group, globalBGQueue, ^{
        NSString *urlString = [NSString stringWithFormat:@"http://search.twitter.com/search.json?q=360idev&result_type=recent&rpp=%d&page=%d", RPP, index + 1];
        NSURL *twitterSearchURL = [NSURL URLWithString:urlString];
        NSData *jsonData = [NSData dataWithContentsOfURL:twitterSearchURL];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        NSArray *tweets = [jsonDict valueForKey:@"results"];
        NSLog(@"Fetched %lu tweets for page %lu", [tweets count], index + 1);
        for (NSDictionary *tweetDict in tweets) {
          dispatch_async(globalBGQueue, ^{
            TwitterImageItem *item = [[[TwitterImageItem alloc] initWithJSONObjectDict:tweetDict] autorelease];
            [self addTweetItem:item];
            [item loadAvatarWithCallbackBlock:^{
              dispatch_async(dispatch_get_main_queue(), ^{
                [self.imageBrowserView reloadData];
              });
            }];
          });
        }
        dispatch_semaphore_signal(semaphore);
      });
    });

    dispatch_group_notify(group, globalBGQueue, ^{
      dispatch_release(group);
      dispatch_release(semaphore);
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.imageBrowserView reloadData];
        [self.progressSpinner stopAnimation:nil];
      });
      NSLog(@"FETCH GROUP COMPLTETE");
    });
  };
  _fetchTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, globalBGQueue);
  dispatch_source_set_timer(_fetchTimer, dispatch_time(DISPATCH_TIME_NOW, 0), NSEC_PER_SEC * 15, 0);
  dispatch_source_set_event_handler(_fetchTimer, tweetFetchBlock);
  dispatch_resume(_fetchTimer);
}

- (void)addTweetItem:(TwitterImageItem *)item {
  dispatch_barrier_async(_tweetAccessQueue, ^{
    [_imageItems addObject:item];
  });
}

- (TwitterImageItem *)tweetItemAtIndex:(NSInteger)index {
  __block TwitterImageItem *item;
  dispatch_sync(_tweetAccessQueue, ^{
    item = [_imageItems objectAtIndex:index];
  });
  return item;
}

- (NSInteger)tweetCount {
  __block NSInteger count;
  dispatch_sync(_tweetAccessQueue, ^{
    count = [_imageItems count];
  });
  return count;
}

#pragma mark - IKImageBrowserDataSource methods

- (NSUInteger)numberOfItemsInImageBrowser:(IKImageBrowserView *)aBrowser {
  return [self tweetCount];
}

- (id)imageBrowser:(IKImageBrowserView *)aBrowser itemAtIndex:(NSUInteger)index {
  return [self tweetItemAtIndex:index];
}

@end
