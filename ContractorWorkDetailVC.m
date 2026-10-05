//
//  ContractorWorkDetailVC.m
//  LinkSafe
//
//  Created by uday on 06/12/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import "ContractorWorkDetailVC.h"
#import "UIButton+Additions.h"
#import "UITextField+Additions.h"
#import "AsyncImageView.h"
#import "ExceptionVC.h"

@interface ContractorWorkDetailVC ()
{
    NSMutableArray *attechRisk,*attechSWMS;
    NSNumber *documentType;
    long attchmentSizeLimit;
    SiteConfig *config;
}

@end

@implementation ContractorWorkDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Contractor Work Detail" parameters:@{@"onload": @"27"}];
    self.lblHeader.textColor = kGetHomeLabelColor;
    if (![Common appDelegate].isIpad)
    {
        self.contentView.frame = CGRectMake(0, 0, self.view.frame.size.width,(self.view.frame.size.height>750?self.view.frame.size.height:1070));
        self.tpKeyBoard.contentSize = CGSizeMake(self.view.frame.size.width-10,1070);
        [self performSelector:@selector(setScrollView) withObject:nil afterDelay:0.3];
    }
    else
    {
        self.contentView.frame = CGRectMake(0, 0, self.view.frame.size.width,((self.view.frame.size.height-64)>768?(self.view.frame.size.height-64):768));
        self.tpKeyBoard.contentSize = CGSizeMake(self.view.frame.size.width-10,self.contentView.frame.size.height);
        
        [Common ApplyUIViewTheme:[self.view viewWithTag:5501]];
        [self.view viewWithTag:5501].layer.borderColor=[UIColor clearColor].CGColor;
    }
    config = [Common appDelegate].config;
    attchmentSizeLimit = 8;
    if (config.maximumPermitFileLength != NULL) {
//        NSString *ml = @"";
//        ml = [NSString stringWithFormat:@"%@",config.maximumPermitFileLength];
        attchmentSizeLimit = [config.maximumPermitFileLength longLongValue];
    }
    //attchmentSizeLimit = 2;//test
    attchmentSizeLimit = attchmentSizeLimit * 1024 * 1024;
    //attchmentSizeLimit = 999999;
    [self setLabelColor];
    
    attechRisk=[[NSMutableArray alloc] init];
    attechSWMS=[[NSMutableArray alloc] init];
    
    [_btnAddAttechSWMS applyBlueBorderShedow];
    [_btnAddAttechRiskAssesment applyBlueBorderShedow];
    [_btnContinue applyBlueShedow];
    [_btnAddAttechSWMS applyBlueShedow];
    [_btnAddAttechRiskAssesment applyBlueShedow];
    
    [_tfAttechRiskAssessment setTagFont:kThemeRegularFonts(17.0)];
    [_tfAttechSWMS setTagFont:kThemeRegularFonts(17.0)];
    
    _tfAttechRiskAssessment.backgroundColor = kThemeGreyValue(249.0);
    _tfAttechSWMS.backgroundColor = kThemeGreyValue(249.0);
    
    [_tfAttechRiskAssessment.layer setBorderWidth:1.0f];
    [_tfAttechRiskAssessment.layer setBorderColor:kThemeGreyValue(197.0).CGColor];
    [_tfAttechRiskAssessment.layer setMasksToBounds:NO];
    
    [_tfAttechSWMS.layer setBorderWidth:1.0f];
    [_tfAttechSWMS.layer setBorderColor:kThemeGreyValue(197.0).CGColor];
    [_tfAttechSWMS.layer setMasksToBounds:NO];
    
    _tfAttechRiskAssessment.layer.cornerRadius = 3.0f;
    _tfAttechRiskAssessment.clipsToBounds=YES;
    
    _tfAttechSWMS.layer.cornerRadius = 3.0f;
    _tfAttechSWMS.clipsToBounds=YES;
    
    _tfAttechRiskAssessment.tagColor=kThemeGreyButtom;
    _tfAttechSWMS.tagColor=kThemeGreyButtom;
    
    _tfAttechRiskAssessment.cornerRadius=3.0f;
    _tfAttechSWMS.cornerRadius=3.0f;
    
    [self handleTagBlocks];
    
//    ((AsyncImageView *)[self.view viewWithTag:3301]).imageURL=[NSURL URLWithString:[[Common SiteData] valueForKey:KEY_LOGO]];
    [Common loadLogo:((AsyncImageView *)[self.view viewWithTag:3301])];
    [Common setBgImage:self.view useDefault:YES];
    [Common applyThemeColorToPowerdBy:self.view];
    [self setWorkDetails];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title = self.navTitle;//@"CONTRACTOR SIGN IN";
    
    if ([Common appDelegate].isIpad)
    {
       self.contentView.frame = CGRectMake(0, 0, self.view.frame.size.width,((self.view.frame.size.height-64)>818?(self.view.frame.size.height-64):818));
        self.tpKeyBoard.contentSize = CGSizeMake(self.view.frame.size.width-10,self.contentView.frame.size.height);
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(upadteTime)
                                                 name:N_UpdateTime
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBackground)
                                                 name:N_UpdateBackgroundImages
                                               object:nil];
    [self upadteTime];
}

-(void)upadteTime
{
    [Common updateTime:self.contentView];
//    UILabel *lableTime=[mainVCView viewWithTag:5214];
//    if (lableTime) {
//        [lableTime setTextColor:kGetHomeLabelColor];
//    }
}

-(void)setWorkDetails
{
//-------here i am set permit line but this require actual coma sepreted array possition
//    self.lbPermit.text= [self.workDetailsDic valueForKey:@"permits"];
    self.txtPermit.text= [self.workDetailsDic valueForKey:@"permits"];
    self.tfContractorName.text = [self.workDetailsDic valueForKey:@"contractorName"];
    self.tfContractorCompany.text = [self.workDetailsDic valueForKey:@"contractorCompany"];
    self.tfContractorNumber.text = [self.workDetailsDic valueForKey:@"contactNumber"];
    self.tfDateOfWork.text = [self.workDetailsDic valueForKey:@"dateOfWork"];
    self.tfLocation.text = [self.workDetailsDic valueForKey:@"location"];
    self.workPermitFormID = [self.workDetailsDic valueForKey:KEY_WORKPERMIT_FORM_ID];
}

-(void)setLabelColor
{
    [_tfContractorName applyFlatTheme];
    [_tfContractorCompany applyFlatTheme];
    [_tfContractorNumber applyFlatTheme];
    [_tfDateOfWork applyFlatTheme];
    [_tfAdditionalContractor applyFlatTheme];
    [_tfLocation applyFlatTheme];
    [_tfDescriptionOfWork applyFlatTheme];
    [_tfEquipmentToBeUsed applyFlatTheme];
    
    UIView *view = [self.view viewWithTag:5501];
    if (!view) {
        return;
    }
    for (id subView in view.subviews) {
        if ([subView isKindOfClass:[UILabel class]] ) {
            UILabel *lblTitle = (UILabel *)subView;
            lblTitle.textColor = kGetHomeLabelColor;
        }
        else if ([subView isKindOfClass:[UITextField class]])
        {
            UITextField *textField = (UITextField *)subView;
            [textField applyGrayBorderTheme];
        }
    }
    
    UIView *innerview=[self.view viewWithTag:5502];
    if (!innerview) {
        return;
    }
    for (id subView in innerview.subviews) {
        if ([subView isKindOfClass:[UILabel class]] ) {
            UILabel *lblTitle = (UILabel *)subView;
            lblTitle.textColor = kGetHomeLabelColor;
        }
        else if ([subView isKindOfClass:[UITextField class]])
        {
            UITextField *textField = (UITextField *)subView;
            [textField applyGrayBorderTheme];
        }
    }
}

-(void)updateBackground
{
    [Common setBgImage:self.view useDefault:YES];
}
-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationItem.title = @"";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateTime object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateBackgroundImages object:nil];
}

#pragma mark - Photo blocks

- (IBAction)onTackPhoto {
    
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Image Option"
                                                             delegate:self
                                                    cancelButtonTitle:[@"Cancel" uppercaseString]
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:[@"Camera" uppercaseString],[@"Gallery" uppercaseString], nil];
    actionSheet.tintColor = kGetThemeColor;
    [actionSheet showInView:self.view];
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:[@"Cancel" uppercaseString]]) {
        return;
    }
    NSLog(@"====%@",[actionSheet buttonTitleAtIndex:buttonIndex]);
    
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:[@"Gallery" uppercaseString]])
    {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    else
    {
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
    }
    [self performSelector:@selector(openPicker:) withObject:picker afterDelay:0.5];
    
}
- (void)openPicker:(UIImagePickerController *)picker
{
    if([Common appDelegate].isIpad)
    {
        picker.modalPresentationStyle = UIModalPresentationPopover;
        
        UIPopoverPresentationController *popPC = picker.popoverPresentationController;
        popPC.permittedArrowDirections = UIPopoverArrowDirectionAny;
        
        if ([documentType intValue]==1)
        {
            popPC.sourceView = _btnAddAttechRiskAssesment;
            popPC.sourceRect = _btnAddAttechRiskAssesment.bounds;
        }
        else
        {
            popPC.sourceView = _btnAddAttechSWMS;
            popPC.sourceRect = _btnAddAttechSWMS.bounds;
        }
        [self showViewController:picker sender:picker];
    }
    else
    {
        [self presentViewController:picker animated:NO completion:NULL];
    }
}
- (IBAction)onSideMenuClick:(id)sender {
    [self.menuContainerViewController toggleRightSideMenuCompletion:^{}];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    
    [picker dismissViewControllerAnimated:YES completion:^{
//        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//
//            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                                  message:@"Device has no camera"
//                                                                 delegate:nil
//                                                        cancelButtonTitle:@"OK"
//                                                        otherButtonTitles: nil];
//
//            [myAlertView show];
//
//
//        }
    }];
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
    
    if (textField==self.tfAdditionalContractor)
    {
        return YES;
    }
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    return [string isEqualToString:filtered];
    
}
- (BOOL)attechmentLimitReach:(long)nextAttachmentLength {
    
    if ([self->documentType intValue]==1)
    {
        long newSize = 0;
//        if (self->attechRisk.count>0) {
//            for (int i=0; i<self->attechRisk.count; i++)
//            {
//                newSize = newSize + [[[self->attechRisk objectAtIndex:i] valueForKey:@"size"] longLongValue];
//            }
//        }
        NSLog(@"risk existing size = %ld  +  %ld",newSize,nextAttachmentLength);
        newSize = newSize + nextAttachmentLength;
//        [Common showAlert:@"" :[NSString stringWithFormat:@"risk attachment : %ld / %ld",newSize,attchmentSizeLimit]];
        if (newSize > attchmentSizeLimit) {
            return true;
        }
    }
    else
    {
        long newSize = 0;
//        if (self->attechSWMS.count>0) {
//            for (int i=0; i<self->attechSWMS.count; i++)
//            {
//                newSize = newSize + [[[self->attechSWMS objectAtIndex:i] valueForKey:@"size"] longLongValue];
//            }
//        }
        NSLog(@"SWMS existing size = %ld  +  %ld",newSize,nextAttachmentLength);
        newSize = newSize + nextAttachmentLength;
//        [Common showAlert:@"" :[NSString stringWithFormat:@"SWMS attachment : %ld / %ld",newSize,attchmentSizeLimit]];
        if (newSize > attchmentSizeLimit) {
            return true;
        }
    }
    return false;
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
        NSString *imgData = [Common encodeToBase64String:picData];
        if ([self attechmentLimitReach:imgData.length])
        {
            [Common showAlert:[NSString stringWithFormat:@"%@ Attachments size limit reached for ",([self->documentType intValue]==1?@"Risk Assessment":@"SWMS")] : @""];
            return;
        }
        NSMutableDictionary *attachmentNsd=[[NSMutableDictionary alloc] init];
        NSString *filename=(([self->documentType intValue]==1)?@"RiskAssessmentImage":@"SWMSImage");
        filename=[NSString stringWithFormat:@"%@%lu.png",filename,(unsigned long)(([self->documentType intValue]==1)?([self->attechRisk count]+1):([self->attechSWMS count]+1))];
        [attachmentNsd setObject:filename forKey:@"filename"];
        [attachmentNsd setObject:imgData forKey:@"fileUri"];
        [attachmentNsd setObject:self.workPermitFormID forKey:KEY_WORKPERMIT_FORM_ID];
        [attachmentNsd setObject:self->documentType forKey:@"documentType"];
        
        [Common callAPI:attachmentNsd Request:REQUEST_AttachWorkPermit ShowProgress:YES WithCompletionHandler:^(id responseObject) {
            
            if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
            {
                NSData *imgData = [[NSString stringWithFormat:@"%@",[attachmentNsd valueForKey:@"fileUri"]] dataUsingEncoding:NSUTF8StringEncoding];
                
                NSMutableDictionary *nsd=[responseObject mutableCopy];
                [nsd setObject:[responseObject valueForKey:@"documentID"] forKey:@"documentID"];
                [nsd setObject:filename forKey:@"filename"];
                [nsd setObject:[NSString stringWithFormat:@"%lu",(unsigned long)imgData.length] forKey:@"size"];
                
                
                if ([self->documentType intValue]==1)
                {
                    [self->attechRisk addObject:nsd];
                    [self.tfAttechRiskAssessment addTag:filename];
                    [self performSelector:@selector(setScrollView) withObject:nil afterDelay:0.3];
                }
                else
                {
                    [self->attechSWMS addObject:nsd];
                    [self.tfAttechSWMS addTag:filename];
                    [self performSelector:@selector(setScrollView) withObject:nil afterDelay:0.3];
                }
            }
            else
            {
                NSString *msg=[responseObject valueForKey:@"errorMessage"];
                [Common showAlert:@"Error" :msg.length>0?msg:@"Please try again."];
                
            }
        }];
    }];
}

-(void)removeAttachDocumentAtIndex:(int)index andDocumentType:(int)fromdocumentType
{
    NSString *docId = ((fromdocumentType==1) ? [[attechRisk objectAtIndex:index] valueForKey:@"documentID"]:[[attechSWMS objectAtIndex:index] valueForKey:@"documentID"]);
    NSMutableDictionary *nsd = [[NSMutableDictionary alloc] init];
    [nsd setObject:self.workPermitFormID forKey:KEY_WORKPERMIT_FORM_ID];
    [nsd setObject:docId forKey:@"documentID"];
    
    [Common callAPI:nsd Request:REQUEST_DeleteWorkPermit ShowProgress:YES WithCompletionHandler:^(id responseObject)
    {
        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
        {
            NSLog(@"success");
            if (fromdocumentType==1)
            {
                [self.tfAttechRiskAssessment deleteTagAtIndex:index];
                [self->attechRisk removeObjectAtIndex:index];
            }
            else
            {
                [self.tfAttechSWMS deleteTagAtIndex:index];
                [self->attechSWMS removeObjectAtIndex:index];
            }
            [self performSelector:@selector(setScrollView) withObject:nil afterDelay:0.3];
        }
        else
        {
            NSString *msg=[responseObject valueForKey:@"errorMessage"];
            [Common showAlert:@"Error" :msg.length>0?msg:@"Please try again."];
            
        }
    }];
}

#pragma mark - Tag blocks

- (void)handleTagBlocks
{
//    __weak typeof(self) weakSelf = self;
    [_tfAttechRiskAssessment setTapBlock:^(NSString *tagText, NSInteger idx)
     {
         NSString *message = [NSString stringWithFormat:@"You tapped: %@", tagText];
         NSLog(@"i am at 1 %@",message);
         
     }];
    
    [_tfAttechRiskAssessment setDeleteBlock:^(NSString *tagText, NSInteger idx)
     {
         [self removeAttachDocumentAtIndex:idx andDocumentType:1];
//         [weakSelf.tfAttechRiskAssessment deleteTagAtIndex:idx];
//         [self performSelector:@selector(setScrollView) withObject:nil afterDelay:0.3];
     }];
    
    
    [_tfAttechSWMS setTapBlock:^(NSString *tagText, NSInteger idx)
     {
         NSString *message = [NSString stringWithFormat:@"You tapped: %@", tagText];
         NSLog(@"i am at 3 %@",message);
     }];
    
    [_tfAttechSWMS setDeleteBlock:^(NSString *tagText, NSInteger idx)
     {
         [self removeAttachDocumentAtIndex:idx andDocumentType:0];
//         [weakSelf.tfAttechSWMS deleteTagAtIndex:idx];
//         [self performSelector:@selector(setScrollView) withObject:nil afterDelay:0.3];
     }];
}

- (IBAction)onAddAttechRisk:(id)sender
{
    [self.view endEditing:YES];
    documentType=[NSNumber numberWithInt:1];
    [self onTackPhoto];
}

- (IBAction)onAddAttechSWMS:(id)sender
{
    [self.view endEditing:YES];
    documentType=[NSNumber numberWithInt:2];
    [self onTackPhoto];
}

- (void)setScrollView
{
    UIView *baseview=[self.view viewWithTag:5501];
    UIView *innerview=[self.view viewWithTag:5502];
    
    int sch = [Common appDelegate].isIpad?45:40;
    
    CGRect rectRisk = _tfAttechRiskAssessment.frame;
    rectRisk.size.height = (_tfAttechRiskAssessment.contentSize.height<sch?sch:_tfAttechRiskAssessment.contentSize.height);
    _tfAttechRiskAssessment.frame = rectRisk;
    
    CGRect rectSWMS = _tfAttechSWMS.frame;
    rectSWMS.size.height =(_tfAttechSWMS.contentSize.height<sch?sch:_tfAttechSWMS.contentSize.height);
    _tfAttechSWMS.frame = rectSWMS;
    
    
    if ([Common appDelegate].isIpad)
    {
        int neededHight = _tfAttechRiskAssessment.frame.origin.y + (_tfAttechSWMS.contentSize.height > _tfAttechRiskAssessment.contentSize.height ? _tfAttechSWMS.contentSize.height : _tfAttechRiskAssessment.contentSize.height) + 10;
        
        CGRect baseviewRect = baseview.frame;
        baseviewRect.size.height = neededHight;
        baseview.frame = baseviewRect;
       
        self.contentView.frame = CGRectMake(0, 0, self.view.frame.size.width,baseview.frame.origin.y + baseview.frame.size.height + 205);
    }
    else
    {
        CGRect innerViewRect=innerview.frame;
        innerViewRect.size.height=_tfAttechSWMS.frame.size.height+25;
        innerViewRect.origin.y=_tfAttechRiskAssessment.frame.origin.y+_tfAttechRiskAssessment.frame.size.height+5;
        innerview.frame=innerViewRect;
        
        CGRect baseviewRect=baseview.frame;
        baseviewRect.size.height=innerview.frame.size.height+innerview.frame.origin.y+20;
        baseview.frame=baseviewRect;
        
        self.contentView.frame = CGRectMake(0, 0, self.view.frame.size.width,baseview.frame.size.height+240);
    }
    self.tpKeyBoard.contentSize = CGSizeMake(self.view.frame.size.width,self.contentView.frame.size.height);
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;
}

#pragma mark - onLogin
- (IBAction)onContinue:(id)sender
{
    [self.view endEditing:YES];
    
    if([self.tfDescriptionOfWork.text length] <=0)
    {
        [Common showAlert:@"Please enter description of work" : @""];
        return;
    }
    else if([self.tfEquipmentToBeUsed.text length] <=0)
    {
        [Common showAlert:@"Please enter equipment to be used" : @""];
        return;
    }
    else if (config.isRiskAssessmentUploadMandatory && [attechRisk count] <= 0)
    {
        [Common showAlert:@"Please attach Risk Assessment" : @""];
        return;
    }
    else if (config.isSwmsUploadMandatory && [attechSWMS count] <= 0)
    {
        [Common showAlert:@"Please attach SWMS" : @""];
        return;
    }

    [self openException:self.workDetailsDic];
}

-(void)openException:(NSMutableDictionary *)workDic
{
    ExceptionVC *exceptionVC = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"ExceptionVC"];
    exceptionVC.workPermitFormID = [workDic valueForKey:KEY_WORKPERMIT_FORM_ID];
    exceptionVC.titlemassage = [[workDic valueForKey:@"WorkObj"] valueForKey:@"displayText"];
    exceptionVC.workPermitTypeID = [[workDic valueForKey:@"WorkObj"] valueForKey:@"workPermitTypeID"];
    exceptionVC.navTitle = self.navTitle;
    exceptionVC.didFinishwithExceptionDetail = ^(NSMutableDictionary *dicPic)
    {
        NSArray *permits=[workDic valueForKey:@"permitTypesRequired"];
        NSMutableDictionary *permitDic=nil;
        for (int i=0;i<[permits count];i++)
        {
            if ([[NSString stringWithFormat:@"%@",[[permits objectAtIndex:i] valueForKey:@"workPermitTypeID"]] isEqualToString:[NSString stringWithFormat:@"%@",[dicPic valueForKey:@"workPermitTypeID"]]])
            {
                [[[workDic valueForKey:@"permitTypesRequired"] objectAtIndex:i] setObject:@"1" forKey:VAL_DONE];
                continue;
            }
            if (![[NSString stringWithFormat:@"%@",[[permits objectAtIndex:i] valueForKey:@"isallfine"]] boolValue])
            {
                permitDic=[[workDic valueForKey:@"permitTypesRequired"] objectAtIndex:i];
            }
        }
        
        if (permitDic==nil)
        {
            [workDic setObject:@"1" forKey:VAL_DONE];
            [workDic removeObjectForKey:@"WorkObj"];
            [self saveWorkPermit];
        }
        else
        {
            [workDic setObject:@"0" forKey:VAL_DONE];
            [workDic setObject:permitDic forKey:@"WorkObj"];
            [self openException:workDic];
        }
    };
    [self.navigationController pushViewController:exceptionVC animated:YES];
}

- (void)saveWorkPermit
{
    NSMutableDictionary *nsd=[[NSMutableDictionary alloc] init];
    [nsd setObject:[[NSNumber alloc] initWithInt:[[NSString stringWithFormat:@"%@",self.workPermitFormID] intValue]] forKey:KEY_WORKPERMIT_FORM_ID];
    [nsd setObject:[[NSNumber alloc] initWithInt:[[NSString stringWithFormat:@"%@",[[_workDetailsDic valueForKey:@"WorkObj"] valueForKey:@"workPermitTypeID"]] intValue]] forKey:@"workPermitTypeID"];
    [nsd setObject:[NSString stringWithFormat:@"%@",self.tfAdditionalContractor.text] forKey:@"additionalContractors"];
    [nsd setObject:[NSString stringWithFormat:@"%@",self.tfDescriptionOfWork.text] forKey:@"workDescription"];
    [nsd setObject:[NSString stringWithFormat:@"%@",self.tfEquipmentToBeUsed.text] forKey:@"equipment"];
    
    [Common callAPI:nsd Request:REQUEST_SAVE_WORK_PERMIT_DETAILS ShowProgress:YES WithCompletionHandler:^(id responseObject) {
        
        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
        {
            [self.navigationController popViewControllerAnimated:NO];
            self.didFinishwithWorkDetail(_workDetailsDic);
        }
        else
        {
            NSString *msg=[responseObject valueForKey:@"errorMessage"];
            [Common showAlert:@"Error" :msg.length>0?msg:@"Please Try Again."];
        }
    }];
}



@end
