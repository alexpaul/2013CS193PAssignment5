//
//  StanfordPhotoTitlesTVC.m
//  SPoT
//
//  Created by Alex Paul on 3/2/13.
//  Copyright (c) 2013 Alex Paul. All rights reserved.
//

#import "StanfordPhotoTitlesTVC.h"
#import "FlickrFetcher.h"
#import "ImageViewController.h"

@interface StanfordPhotoTitlesTVC ()

@end

@implementation StanfordPhotoTitlesTVC

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // return number of photos with this tag (titleForRow)    
    NSUInteger numberOfPhotos = 0;
    for (NSString *tag in [self allTagsArray]) {
        if ([self.titleForRow isEqualToString:tag]) {
            numberOfPhotos++;
        }
    }
    return numberOfPhotos;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show Image"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setImageURL:)]) {
                    NSURL *url = [FlickrFetcher urlForPhoto:[self photosArray][indexPath.row] format:FlickrPhotoFormatLarge];
                    [segue.destinationViewController performSelector:@selector(setImageURL:) withObject:url];
                    if ([segue.destinationViewController isKindOfClass:[ImageViewController class]]) {
                        ImageViewController *imageVC = (ImageViewController *)segue.destinationViewController;
                        imageVC.title = [self photosArray][indexPath.row][FLICKR_PHOTO_TITLE];
                        imageVC.photoId = [self photosArray][indexPath.row][FLICKR_PHOTO_ID];
                    }
                }
            }
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.navigationItem.title = self.titleForRow;    
}

- (NSString *)titleForRow:(NSUInteger)row
{
    return [self photoTitles][row]; 
}

- (NSString *)subtitleForRow:(NSUInteger)row
{
    return [self photoDescription][row]; 
}

- (NSMutableArray *)photoTitles
{
    NSMutableArray *photoTitles = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in self.photos) {
        NSString *tags = [dict valueForKey:@"tags"];
        NSRange range = [tags rangeOfString:[self.titleForRow lowercaseString]]; // titleForRow is Photo tag name
        if (range.location != NSNotFound) {
            [photoTitles addObject:[dict valueForKey:@"title"]];
        }
    }
    return photoTitles;
}

- (NSMutableArray *)photoDescription
{
    NSMutableArray *photoDescription = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in self.photos) {
        NSString *tags = [dict valueForKey:@"tags"];
        NSRange range = [tags rangeOfString:[self.titleForRow lowercaseString]]; // titleForRow is Photo tag name
        if (range.location != NSNotFound) {
            [photoDescription addObject:[[dict valueForKey:@"description"]valueForKey:@"_content"]];
        }
    }
    return photoDescription;
}

- (NSMutableArray *)photosArray // array of dictionaries of photos
{
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in self.photos) {
        NSString *tags = [dict valueForKey:@"tags"];
        NSRange range = [tags rangeOfString:[self.titleForRow lowercaseString]]; // titleForRow is Photo tag name
        if (range.location != NSNotFound) {
            [photos addObject:dict];
        }
    }
    return photos;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"All Photos Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    cell.textLabel.text = [self titleForRow:indexPath.row]; 
    cell.detailTextLabel.text = [self subtitleForRow:indexPath.row];
    
    return cell;
}


@end
