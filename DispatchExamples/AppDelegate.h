//
//  AppDelegate.h
//  DispatchExamples
//
//  Created by Nathan Eror on 8/20/11.
//  Copyright (c) 2011 Nathan Eror & Free Time Studios, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
  IKImageBrowserView *_ImageBrowserView;
  NSProgressIndicator *_progressSpinner;
}


@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet IKImageBrowserView *imageBrowserView;
@property (assign) IBOutlet NSProgressIndicator *progressSpinner;

@end
