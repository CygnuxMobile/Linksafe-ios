//
//  VisitorInductionVC.h
//  LinkSafe
//
//  Created by Hitesh Sarkheliya on 10/12/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "BEMCheckBox.h"

@interface VisitorInductionVC : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource, BEMCheckBoxDelegate, WKNavigationDelegate> {
    int currMinute, remainMinute;
    int currSeconds, remainSeconds;
}

@property (weak, nonatomic) IBOutlet UILabel *lblNote;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionInduction;
@property(nonatomic, strong) NSMutableDictionary *visitorDetails;
@property (weak, nonatomic) IBOutlet UIButton *continueBtn;
@property (retain, nonatomic) NSString *navTitle;

@property(nonatomic) int minimumReadingTime;
@property(nonatomic, strong) NSMutableArray *arrSlides;
@property(nonatomic, strong) NSMutableArray *arrVisitorTypeID;
@property (retain, nonatomic) NSString *inductionHandle;
@property (weak, nonatomic) IBOutlet UILabel *lblRemainingTime;

@end
