//
//  BGPhotoViewController.m
//  LinkSafe
//
//  Created by Hitesh Sarkheliya on 28/11/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import "BGPhotoViewController.h"
#import "GGFullScreenImageViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface BGPhotoViewController ()
{
    NSArray *wallpaper;
    CGSize fsize;
}
@end

@implementation BGPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    wallpaper=[[NSArray alloc] init];
    [self loadBackGroundImage];
    self.navigationItem.title=@"Select Image";
    fsize=CGSizeMake(self.view.frame.size.width/2,self.view.frame.size.width/2);
    self.menuContainerViewController.panMode=MFSideMenuPanModeNone;
    [Common setBgImage:self.view useDefault:YES];
    [Common applyThemeColorToPowerdBy:self.view];
}
-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(popMe)
                                                 name:N_PopMe
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBackground)
                                                 name:N_UpdateBackgroundImages
                                               object:nil];
}
-(void)popMe
{
    [self.navigationController popViewControllerAnimated:NO];
}
-(void)updateBackground
{
    [Common setBgImage:self.view useDefault:YES];
}
-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationItem.title = @"";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_PopMe object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateBackgroundImages object:nil];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return wallpaper.count;
}
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return fsize;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"HGPhoto";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
//    AsyncImageView *asyncImageView = (AsyncImageView *)[cell viewWithTag:1];
    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[[wallpaper objectAtIndex:indexPath.row] valueForKey:([Common appDelegate].isIpad?KEY_IMAGE_TABLET:KEY_IMAGE_MOBILE)]]];
//    asyncImageView.imageURL = imageURL;
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    [imageView sd_setImageWithURL:imageURL
                 placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    
    UICollectionViewCell *cell = (UICollectionViewCell *)[self.imageListview cellForItemAtIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    
    GGFullscreenImageViewController *vc = [[GGFullscreenImageViewController alloc] init];
    vc.liftedImageView = imageView;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)loadBackGroundImage{
    
    NSMutableDictionary *dicParameters =[[NSMutableDictionary alloc] init];
    
    [dicParameters setObject:[Common appDelegate].isIpad?KEY_DEVICE_TABLET:KEY_DEVICE_PHONE forKey:@"device"];
    
    [Common callAPI:dicParameters Request:REQUEST_GETWallpapers ShowProgress:YES WithCompletionHandler:^(id responseObject) {
        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
        {
            if ([[responseObject objectForKey:KEY_WALLPAPER] count]>0)
            {
                wallpaper=[responseObject objectForKey:KEY_WALLPAPER];
                [_imageListview reloadData];
                if ([wallpaper count]>0)
                {
                    [self loadImage:[NSString stringWithFormat:@"%@",[[wallpaper objectAtIndex:0] valueForKey:([Common appDelegate].isIpad?KEY_IMAGE_TABLET:KEY_IMAGE_MOBILE)]]];
                }
            }
            else
            {
                [Common showAlert:@"Message" :@"No image exist."];
            }
        }
        else
        {
            [Common showAlert:@"Error" :@"Server response fail."];
        }
    }];
}

-(void)loadImage:(NSString *)urlString
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
        NSData *data0 = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        UIImage *image = [UIImage imageWithData:data0];
        CGFloat oldWidth = image.size.width;
        CGFloat oldHeight = image.size.height;
        CGFloat newWidth=self.view.frame.size.width/2;
        CGFloat  newHeight = (oldHeight / oldWidth) * newWidth;
        fsize=CGSizeMake(newWidth,newHeight);
        dispatch_sync(dispatch_get_main_queue(), ^(void) {
            [_imageListview reloadData];
        });
    });
}

@end
