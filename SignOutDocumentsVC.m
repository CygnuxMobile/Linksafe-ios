//
//  SignOutDocumentsVC.m
//  LinkSafe
//
//  Created by CygNuxiOS on 21/09/20.
//  Copyright © 2020 Vladislav Kovalyov. All rights reserved.
//

#import "SignOutDocumentsVC.h"
#import "UIButton+Additions.h"
#import "SignOutDocumentTVC.h"
#import "HomeVC.h"
#import "ThankYouVC.h"

@interface SignOutDocumentsVC ()
{
    int minFiles, maxFiles;
    int maxFileSize, maxImageSize;
}
@end

@implementation SignOutDocumentsVC
{
    int selectedFiles;
    NSMutableArray *arrFiles;
}



+(SignOutDocumentsVC *)viewController {
    
    SignOutDocumentsVC *vc = [[Common constraintStoryboard] instantiateViewControllerWithIdentifier:@"SignOutDocumentsVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"SignOut Documents" parameters:@{@"onload": @"20"}];
    arrFiles = [[NSMutableArray alloc]init];
    selectedFiles = 0;
    
    self.menuContainerViewController.panMode=MFSideMenuPanModeNone;
    [Common setBgImage:self.view useDefault:YES];
    [Common loadLogo:((AsyncImageView *)[self.view viewWithTag:3301])];
    
    [_btnSubmit applyBlueShedow];
    [self.btnAddDocument applyBlueShedow];
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [Common applyThemeColorToPowerdBy:self.view];
    
    minFiles = [[self.dictDocumentData valueForKey:@"minimumFiles"] intValue];
    maxFiles = [[self.dictDocumentData valueForKey:@"maximumFiles"] intValue];
    maxFileSize = [[self.dictDocumentData valueForKey:@"maximumDocumentLength"] intValue];
    maxImageSize = [[self.dictDocumentData valueForKey:@"maximumImageLength"] intValue];
    
    self.lblTitle.text = [NSString stringWithFormat:@"Please attach your service report. You may include up to %d photos.", maxFiles];
    if ([self.dictDocumentData valueForKey:@"displayText"]) {
        self.lblTitle.text = [NSString stringWithFormat:@"%@\nYou may include up to %d photos.", [self.dictDocumentData valueForKey:@"displayText"], maxFiles];
    }
    self.tblDocuments.delegate = self;
    self.tblDocuments.dataSource = self;
    [self.tblDocuments registerNib:[UINib nibWithNibName:@"SignOutDocumentTVC" bundle:nil] forCellReuseIdentifier:@"SignOutDocumentTVC"];
    self.tblDocuments.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"";
    [self upadteTime];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(upadteTime)
                                                 name:N_UpdateTime
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBackground)
                                                 name:N_UpdateBackgroundImages
                                               object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationItem.title = @"";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateBackgroundImages object:nil];
}

-(void)upadteTime
{
    [Common updateTime:self.view];
}

-(void)updateBackground
{
    [Common setBgImage:self.view useDefault:YES];
}

//MARK:- Picker
- (void)openPicker:(UIImagePickerController *)picker
{
    if([Common appDelegate].isIpad)
    {
        picker.modalPresentationStyle = UIModalPresentationPopover;
        
        UIPopoverPresentationController *popPC = picker.popoverPresentationController;
        popPC.permittedArrowDirections = UIPopoverArrowDirectionAny;
        
        
        popPC.sourceView = self.btnAddDocument;
        popPC.sourceRect = self.btnAddDocument.bounds;
        
        [self showViewController:picker sender:picker];
    }
    else
    {
        [self presentViewController:picker animated:NO completion:NULL];
    }
}

-(void)openGallery
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self performSelector:@selector(openPicker:) withObject:picker afterDelay:0.5];
}

-(void)openCamera
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        if ([[[USER_DEFAULT valueForKey:KEY_CAMERA] uppercaseString] isEqualToString:[VALUE_CAMERA_FRONT uppercaseString]])
        {
            picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        else
        {
            picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        }
    }
    [self performSelector:@selector(openPicker:) withObject:picker afterDelay:0.5];
    
}

- (IBAction)onAddDocumentClicked:(id)sender {
    
    if (maxFiles == arrFiles.count) {
        [Common showAlert:@"Maximum Allowed Files Are Already Selected" : @""];
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Select Option"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *gallery = [UIAlertAction actionWithTitle:@"Gallery"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
        [self openGallery];
    }];
    [alertController addAction:gallery];
    
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Camera"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
       [self openCamera];
        
    }];
    [alertController addAction:camera];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Pick Document"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
        UIDocumentPickerViewController *documentPickerViewCtr = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.composite-content"] inMode:UIDocumentPickerModeImport];
        documentPickerViewCtr.delegate = self;

        documentPickerViewCtr.allowsMultipleSelection = YES;

        [self presentViewController:documentPickerViewCtr animated:YES completion:nil];
        
    }];
    [alertController addAction:action];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
                                                         }];
    [alertController addAction:cancelAction];

//    [alertController.popoverPresentationController setPermittedArrowDirections:0];
    alertController.popoverPresentationController.sourceView = self.btnAddDocument;
    alertController.popoverPresentationController.sourceRect = self.btnAddDocument.frame;

    [self presentViewController:alertController animated:YES completion:nil];
    

}

-(void)onDeleteClicked:(id)sender{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tblDocuments];
    NSIndexPath *indexPath = [self.tblDocuments indexPathForRowAtPoint:buttonPosition];
    [arrFiles removeObjectAtIndex:indexPath.row];
    selectedFiles = selectedFiles - 1;
    [self.tblDocuments reloadData];
}

- (IBAction)onSubmitClicked:(id)sender {
    if (minFiles > arrFiles.count) {
        NSString *str = [NSString stringWithFormat:@"Please Select  Minimum %d Files",minFiles];
        [Common showAlert:str : @""];
        return;
    }
    
    NSMutableDictionary *dicParameters = [[NSMutableDictionary alloc] init];
    [dicParameters setObject:[NSString stringWithFormat:@"%@",[[USER_DEFAULT valueForKey:SITE_DATA] valueForKey:KEY_TOKEN]] forKey:KEY_TOKEN];
    [dicParameters setValue:[self.dictSignOutData objectForKey:KEY_SIGNOUTHANDLE] forKey:KEY_SIGNOUTHANDLE];
    [dicParameters setObject:arrFiles forKey:@"Documents"];
    [Common callAPI:dicParameters Request:API_SAVE_SIGN_OUT_DOCUMENTS ShowProgress:YES WithCompletionHandler:^(id responseObject)
     {
        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
        {
            [self signOutUsingPin];
        }
        else
        {
            NSString *errorMsg =[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_ERROR_MESSAGE]];
            [Common showAlert:errorMsg : @""];
        }
    }];
    
}

-(void)signOutUsingPin
{
    if ([Common appDelegate].config.isSignOutAcceptanceScreenVisible && [Common appDelegate].config.signOutAcceptanceMessage.length > 0)
    {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@",[Common appDelegate].config.signOutAcceptanceMessage] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [Common callContractorSignOutAPI:self.dictSignOutData ShowProgress:YES WithCompletionHandler:^(id responseObject)
             {
                 if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
                 {
                     [self.navigationController popToRootViewControllerAnimated:NO];
                     ThankYouVC *thankYouVC = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"ThankYouVC"];
                     thankYouVC.resultDictionary = responseObject;
                     thankYouVC.modalPresentationStyle = UIModalPresentationFullScreen;
                     [self presentViewController:thankYouVC animated:YES completion:^{}];
                 }
                 else
                 {
                     NSString *errorMsg =[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_ERROR_MESSAGE]];
                     [Common showAlert:errorMsg : @""];
                 }
             }];
        }];
        [controller addAction:alertAction];
        
        UIAlertAction *alertActionCancel = [UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UINavigationController *navController = (UINavigationController *)[Common appDelegate].window.rootViewController;
            if ([navController isKindOfClass:[MFSideMenuContainerViewController class]])
            {
                MFSideMenuContainerViewController *containerVC = (MFSideMenuContainerViewController *)navController;
                UINavigationController *navigationController = containerVC.centerViewController;
                [navigationController popToRootViewControllerAnimated:YES];
            }
            else
            {
                [navController popToRootViewControllerAnimated:YES];
            }
        }];
        [controller addAction:alertActionCancel];
        
        [[Common appDelegate].window.rootViewController presentViewController:controller animated:YES completion:^{
        }];
    }
    else
    {
        [Common callContractorSignOutAPI:self.dictSignOutData ShowProgress:YES WithCompletionHandler:^(id responseObject)
        {
            if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
            {
                [self.navigationController popToRootViewControllerAnimated:NO];
                ThankYouVC *thankYouVC = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"ThankYouVC"];
                thankYouVC.resultDictionary = responseObject;
                thankYouVC.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:thankYouVC animated:YES completion:^{}];
            }
            else
            {
                NSString *errorMsg =[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_ERROR_MESSAGE]];
                [Common showAlert:errorMsg : @""];
            }
        }];
    }
}

//MARK:- Document Picker
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls
{
    
    for (NSURL *url in urls) {
        
        NSError *err = nil;
        NSError *error = nil;

        NSNumber * fileSize;
        if(![url getPromisedItemResourceValue:&fileSize forKey:NSURLFileSizeKey error:&err]) {
            NSLog(@"Failed error: %@", error);
            return ;
        } else {
            NSLog(@"fileSize : %f",fileSize.doubleValue);
            NSLog(@"fileSize Resize : %@",[NSByteCountFormatter stringFromByteCount:fileSize.doubleValue countStyle:NSByteCountFormatterCountStyleFile]);
            NSLog(@"test file name : \n %@",url.lastPathComponent);
            NSLog(@"test file type : \n %@",url.pathExtension);
        }
        
        
        NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
        [coordinator coordinateReadingItemAtURL:url options:0 error:&error byAccessor:^(NSURL *newURL) {
            NSData *data = [NSData dataWithContentsOfURL:newURL];
            NSString *strTimeStamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
            int timestamps = [strTimeStamp intValue];
            
            NSMutableDictionary *dictTemp = [[NSMutableDictionary alloc]init];
            [dictTemp setValue:[NSString stringWithFormat:@"%d_%d.pdf", timestamps,selectedFiles] forKey:@"Filename"];
            [dictTemp setObject:[Common encodeToBase64StringPDF:data] forKey:@"fileUri"];
            [arrFiles addObject:dictTemp];
            selectedFiles = selectedFiles + 1;
            [self.tblDocuments reloadData];
            
            
        }];
        if (error) {
            // Do something else
            NSLog(@"test error logo : \n %@",error);
        }
        
    }
    
    NSLog(@"**************************************************");
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller
{

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    __block  UIImage *picData = [info valueForKey:UIImagePickerControllerEditedImage];
    if(picData==nil)
    {
        picData = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    if(picData==nil)
    {
        picData = [info objectForKey:UIImagePickerControllerCropRect];
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        picData=[Common imageWithImage:picData scaledToWidth:([Common appDelegate].isIpad?640:320)];
        NSString *strTimeStamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
        int timestamps = [strTimeStamp intValue];
        NSData *data1 = UIImageJPEGRepresentation(picData, 1);
        if (data1.length > maxImageSize) {
            NSData *data2 = UIImageJPEGRepresentation(picData, 0.8);            
            picData = [UIImage imageWithData:data2];
        }
        
        NSMutableDictionary *dictTemp = [[NSMutableDictionary alloc]init];
        [dictTemp setValue:[NSString stringWithFormat:@"%d_%d.png", timestamps,selectedFiles] forKey:@"Filename"];
        [dictTemp setObject:[Common encodeToBase64String:picData] forKey:@"fileUri"];
        [arrFiles addObject:dictTemp];
        selectedFiles = selectedFiles + 1;
        [self.tblDocuments reloadData];
    }];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrFiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    SignOutDocumentTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"SignOutDocumentTVC" forIndexPath:indexPath];
    
    NSDictionary *dict = [arrFiles objectAtIndex:indexPath.row];
    cell.lblName.text = dict[@"Filename"];
    cell.btnDelete.tag = indexPath.row;
    [cell.btnDelete addTarget:self action:@selector(onDeleteClicked:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

@end
