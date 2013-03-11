//
//  RecentPhotosTVC.m
//  SPoT
//
//  Created by Alex Paul on 3/6/13.
//  Copyright (c) 2013 Alex Paul. All rights reserved.
//

#import "RecentPhotosTVC.h"
#import "RecentPhotos.h"
#import "FlickrFetcher.h"
#import "ImageViewController.h"

@interface RecentPhotosTVC ()
@property (nonatomic, strong) RecentPhotos *receentPhotos; 
@end

@implementation RecentPhotosTVC

- (RecentPhotos *)receentPhotos
{
    if (!_receentPhotos) _receentPhotos = [[RecentPhotos alloc] init];
    return _receentPhotos; 
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemRecents tag:0];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show Image"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setImageURL:)]) {
                    NSURL *url = [FlickrFetcher urlForPhoto:[self recentPhotosUsingPhotoId][indexPath.row] format:FlickrPhotoFormatLarge];
                    [segue.destinationViewController performSelector:@selector(setImageURL:) withObject:url];
                    if ([segue.destinationViewController isKindOfClass:[ImageViewController class]]) {
                        ImageViewController *imageVC = (ImageViewController *)segue.destinationViewController;
                        imageVC.photoId = [self recentPhotosUsingPhotoId][indexPath.row][FLICKR_PHOTO_ID];
                    }
                }
            }
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self recentPhotosUsingPhotoId] count]; // recect photos count
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Recent Photo Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    cell.textLabel.text = [self titleForRow:indexPath.row];
    cell.detailTextLabel.text = [self subtitleForRow:indexPath.row];
    
    return cell;
}


- (NSString *)titleForRow:(NSUInteger)row
{
    return [self recentPhotosUsingPhotoId][row][FLICKR_PHOTO_TITLE];
}


- (NSString *)subtitleForRow:(NSUInteger)row
{
    return [[[self recentPhotosUsingPhotoId][row] valueForKey:@"description"]valueForKey:@"_content"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadStanfordPhotos];
    [self.refreshControl addTarget:self action:@selector(loadStanfordPhotos) forControlEvents:UIControlEventValueChanged];

}

- (void)loadStanfordPhotos
{
    [self.refreshControl beginRefreshing]; 
    dispatch_queue_t stanfordPhotos = dispatch_queue_create("Get Stanford Photos", NULL);
    dispatch_async(stanfordPhotos, ^{
        NSArray *stanfordPhotos = [FlickrFetcher stanfordPhotos];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photos = stanfordPhotos;
            [self.refreshControl endRefreshing]; 
        });
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadStanfordPhotos];
    [self.refreshControl addTarget:self action:@selector(loadStanfordPhotos) forControlEvents:UIControlEventValueChanged];
            
    self.navigationItem.title = @"Recents";    
}

- (NSArray *)recentPhotosUsingPhotoId
{
    NSMutableArray *recentPhotosUsingPhotoId = [[NSMutableArray alloc] init]; // the photos containing those photo ids
    
    //  Locate the photo in all the Stanford Photos for the particular recent photo id
    //  Add that photo to the recentPhotosUsingPhotoId array
    for (RecentPhotos *recents in [RecentPhotos recentPhotos]) {
        for (NSDictionary *dict in self.photos) {
            if ([[dict objectForKey:@"id"] isEqualToString:recents.photoId]) {
                [recentPhotosUsingPhotoId addObject:dict];
            }
        }
    }
    
    return recentPhotosUsingPhotoId;
}

@end
