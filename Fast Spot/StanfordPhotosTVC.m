//
//  StanfordPhotosTVC.m
//  SPoT
//
//  Created by Alex Paul on 2/27/13.
//  Copyright (c) 2013 Alex Paul. All rights reserved.
//

#import "StanfordPhotosTVC.h"
#import "FlickrFetcher.h"
#import "StanfordPhotoTitlesTVC.h"

@interface StanfordPhotosTVC ()

@end

@implementation StanfordPhotosTVC

- (NSUInteger)photosCount
{
    return [[self uniqueTagsArray] count];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFeatured tag:0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadStanfordPhotos];
    self.navigationItem.title = @"Fast SPoT";
    [self.refreshControl addTarget:self action:@selector(loadStanfordPhotos) forControlEvents:UIControlEventValueChanged]; 
}

- (void)loadStanfordPhotos
{
    [self.refreshControl beginRefreshing]; 
    dispatch_queue_t getStanfordPhotos = dispatch_queue_create("Stanford Photos", NULL);
    dispatch_async(getStanfordPhotos, ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSArray *stanfordPhotos = [FlickrFetcher stanfordPhotos];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photos = stanfordPhotos;
            [self.refreshControl endRefreshing]; 
        });
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show All Photos"]) {
        if ([segue.destinationViewController isKindOfClass:[StanfordPhotoTitlesTVC class]]) {
            StanfordPhotoTitlesTVC *sptc = (StanfordPhotoTitlesTVC *)segue.destinationViewController;
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender]; 
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            sptc.titleForRow = cell.textLabel.text;
        }
    }
}

- (NSString *)titleForRow:(NSUInteger)row
{
    return [self uniqueTagsArray][row];
}

- (NSString *)subtitleForRow:(NSUInteger)row
{
    //  count number of occurences of this tag in the all tags array
    //  this is equivalent to the number of photos a particular tag has
    
    NSString *tag = [self uniqueTagsArray][row];
        
    NSUInteger countTags = 0;
    for (NSString *compareTag in [self allTagsArray]) {
        if ([tag isEqualToString:compareTag]) {
            countTags++; 
        }
    }
    return [NSString stringWithFormat:@"%d photos", countTags];     
}

- (NSMutableArray *)allTagsArray
{
    NSMutableArray *tagArray = [[NSMutableArray alloc] init];
    
    for (int index = 0; index < [self.photos count]; index++) {
        NSString *tag = [self.photos[index][FLICKR_TAGS]description];
        NSMutableArray *tags = [[tag componentsSeparatedByString:@" "] mutableCopy];
        for (NSString *result in tags){
            if ([result isEqualToString:@"cs193pspot"] || [result isEqualToString:@"landscape"] || [result isEqualToString:@"portrait"]) {
                // don't add the above tags
            }else{
                [tagArray addObject:[result capitalizedString]];
            }
        }
    }
    return tagArray; 
}

- (NSMutableArray *)uniqueTagsArray
{
    NSMutableArray *uniqueTagsArray = [[NSMutableArray alloc] init];
    
    for (NSString *result in [self allTagsArray]){
        if (![uniqueTagsArray containsObject:result]) {
            [uniqueTagsArray addObject:result];
        }
    }
    return uniqueTagsArray;
}

@end
