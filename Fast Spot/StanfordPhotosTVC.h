//
//  StanfordPhotosTVC.h
//  SPoT
//
//  Created by Alex Paul on 2/27/13.
//  Copyright (c) 2013 Alex Paul. All rights reserved.
//

#import "FlickrPhotoTVC.h"

@interface StanfordPhotosTVC : FlickrPhotoTVC

- (NSMutableArray *)allTagsArray; // returns all tags (except cs193pspot, portrait, landscape) with the first letter capitalized 

@end
