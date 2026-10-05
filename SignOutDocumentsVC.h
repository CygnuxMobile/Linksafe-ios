//
//  SignOutDocumentsVC.h
//  LinkSafe
//
//  Created by CygNuxiOS on 21/09/20.
//  Copyright © 2020 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SignOutDocumentsVC : UIViewController<UIDocumentPickerDelegate,UIImagePickerControllerDelegate,  UINavigationControllerDelegate, UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnAddDocument;
@property (weak, nonatomic) IBOutlet UITableView *tblDocuments;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;

- (IBAction)onSubmitClicked:(id)sender;
- (IBAction)onAddDocumentClicked:(id)sender;

@property (retain, nonatomic) NSMutableDictionary *dictSignOutData;
@property (retain, nonatomic) NSMutableDictionary *dictDocumentData;
@property (retain, nonatomic) NSString *strSelectedSiteId;
+(SignOutDocumentsVC *)viewController;

@end

NS_ASSUME_NONNULL_END
