//
//  TakeSignatureVC.h
//  LinkSafe
//
//  Created by Chirag Paneliya on 12/05/21.
//  Copyright © 2021 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TESignatureView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TakeSignatureVC : UIViewController

@property (weak, nonatomic) IBOutlet UIView *viewSignatureContainer;
@property (weak, nonatomic) IBOutlet TESignatureView *signtureView;
@property (weak, nonatomic) IBOutlet UIButton *signDone;
@property (weak, nonatomic) IBOutlet UIButton *signCancel;

@property(nonatomic,copy) callbackwithImage didFinishWithCapturedSignature;

@end

NS_ASSUME_NONNULL_END
