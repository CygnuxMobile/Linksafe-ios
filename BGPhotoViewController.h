//
//  BGPhotoViewController.h
//  LinkSafe
//
//  Created by Hitesh Sarkheliya on 28/11/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BGPhotoViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *imageListview;

@end
