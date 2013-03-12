//
//  ImageViewController.m
//  Shutterbug
//
//  Created by Alex Paul on 2/25/13.
//  Copyright (c) 2013 Alex Paul. All rights reserved.
//

#import "ImageViewController.h"
#import "RecentPhotos.h"
#import "RecentPhotosCache.h"
//#import "AttributedStringViewController.h"

@interface ImageViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleBarButtonItem;
@property (nonatomic, strong) UIPopoverController *urlPopover;
@property (nonatomic, strong) RecentPhotos *recentPhoto;
@property (nonatomic, strong) RecentPhotosCache *cache; 
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

@implementation ImageViewController


- (RecentPhotos *)recentPhoto
{
    if (!_recentPhoto) {
        _recentPhoto = [[RecentPhotos alloc] init];
    }
    return _recentPhoto; 
}

- (RecentPhotosCache *)cache
{
    if (!_cache) _cache = [[RecentPhotosCache alloc] init];
    return _cache; 
}

// Maybe disabling the button would be better, but in this instance this was just to use this method
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"Show URL"]) {
        return (self.imageURL && !self.urlPopover.popoverVisible) ? YES : NO; // return YES if image is not nil so popOver can be shown and popover is not visible
    }else{
        return [super shouldPerformSegueWithIdentifier:identifier sender:sender]; // let super take care of segue
    }
}

/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show URL"]) {
        if ([segue.destinationViewController isKindOfClass:[AttributedStringViewController class]]) {
            AttributedStringViewController *asc = (AttributedStringViewController *)segue.destinationViewController;
            asc.text = [[NSAttributedString alloc] initWithString:[self.imageURL description]];
            if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
                self.urlPopover = ((UIStoryboardPopoverSegue *)segue).popoverController; // get the popOver from the segue that presented it
            }
        }
    }
}*/

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    [self resetImage];
}

- (void)setTitle:(NSString *)title
{
    super.title = title;
    self.titleBarButtonItem.title = title; 
}

- (void)resetImage
{
    if (self.scrollView) {
        self.scrollView.contentSize = CGSizeZero;
        self.imageView.image = nil;
        
        //  Handle the image processing off the main thread to prevent the main thread from being blocked
        [self.activityIndicator startAnimating]; 
        dispatch_queue_t imageFetchQ = dispatch_queue_create("image fetcher", NULL); // NULL implies a serial queue
        dispatch_async(imageFetchQ, ^{
            
            //  Set the image url and photo id for the RecentPhotosCache class
            self.cache.imageURL = self.imageURL; 
            self.cache.photoId = self.photoId;
            
            NSLog(@"size of cache is %d", [self.cache currentSizeOfCache]); 
            
            UIImage *image = [UIImage imageWithData:self.cache.imageData];
            
            //  dispatch UIKit updates to the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                if (image) {
                    self.scrollView.zoomScale = 1.0; // Reset zoom scale
                    self.scrollView.contentSize = image.size; // must be set for scrolling
                    self.imageView.image = image;
                    self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
                    
                    // Add photo id to recent photos
                    // RecentPhotos class handles non duplicate entries
                    self.recentPhoto.photoId = self.photoId;
                    [self.activityIndicator stopAnimating];
                }
            });
        });
    }
}

- (UIImageView *)imageView
{
    if (!_imageView) _imageView = [[UIImageView alloc] initWithFrame:CGRectZero]; // origin 0, size 0
    return _imageView; 
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
    self.scrollView.minimumZoomScale = 0.2; // Must be set in order to Zoom
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.delegate = self;
    [self resetImage];
    self.titleBarButtonItem.title = self.title; // in case viewDidLoad gets called from a segue before the setter
}

//  Must be implemented with the view to zoom
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView; 
}

@end
