//
//  MessageBoardVC.h
//  LinkSafe
//
//  Created by uday on 4/11/18.
//  Copyright © 2018 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface MessageBoardVC : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource,WKNavigationDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionInduction;
@property (weak, nonatomic) IBOutlet UIButton *continueBtn;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (nonatomic, strong) NSMutableDictionary *visitorDetails;
@property (nonatomic, strong) NSMutableArray *arrMessages;

@property (copy) callbackwithDic didFinishAcknowledge;

@end
