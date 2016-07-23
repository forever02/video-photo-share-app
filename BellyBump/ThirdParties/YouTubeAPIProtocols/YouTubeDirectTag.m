//
//  YouTubeDirectTag.m
//  YouTube Direct Lite for iOS
//
//  Created by Ibrahim Ulukaya on 10/29/13.
//  Copyright (c) 2013 Google. All rights reserved.
//

#import "YouTubeDirectTag.h"
#import "VideoData.h"
#import "UploadController.h"
#import "Utils.h"

// Thumbnail image size.
//static const CGFloat kCropDimension = 44;

@implementation YouTubeDirectTag


- (void)directTagWithService:(GTLServiceYouTube *)service videoData:(VideoData*)videoData
{
    GTLYouTubeVideo *updateVideo = [GTLYouTubeVideo alloc];
    GTLYouTubeVideoSnippet *snippet = [videoData addTags:@[DEFAULT_KEYWORD, [UploadController generateKeywordFromPlaylistId:UPLOAD_PLAYLIST]]];
    updateVideo.snippet = snippet;
    updateVideo.identifier = videoData.getYouTubeId;
    
    GTLQueryYouTube *videosUpdateQuery = [GTLQueryYouTube queryForVideosUpdateWithObject:updateVideo
                                                                                    part:@"snippet"];
    [service executeQuery:videosUpdateQuery completionHandler:^(GTLServiceTicket *ticket, GTLYouTubeVideo *response, NSError *error) {
        if (error == nil) {
            
            NSLog(@"Tags updated");
            [Utils showAlert:@"YouTube" message:@"Video uploaded!"];
            [self.delegate directTag:self didFinishWithResults:response];
        }
        else {
            NSLog(@"An error occurred: %@", error);
            [Utils showAlert:@"YouTube" message:@"Sorry, an error occurred!"];
            [self.delegate directTag:self didFinishWithResults:nil];
        }
    }];
}

@end
