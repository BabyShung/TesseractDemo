//
//  G8ViewController.m
//  Template Framework Project
//
//  Created by Daniele on 14/10/13.
//  Copyright (c) 2013 Daniele Galiotto - www.g8production.com. All rights reserved.
//

#import "G8ViewController.h"

@interface G8ViewController ()
{
    
}

@property(nonatomic,strong) UIImagePickerController *imagePicker;

@end

@implementation G8ViewController

/****README****/
/*
 Follow the readme at https://github.com/gali8/Tesseract-OCR-iOS for first step.
 */



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // language are used for recognition. Ex: eng. Tesseract will search for a eng.traineddata file in the dataPath directory; eng+ita will search for a eng.traineddata and ita.traineddata.
    
    //Like in the Template Framework Project:
    
	// ****Assumed that .traineddata files are in your "tessdata" folder and the folder is in the root of the project.
    
	// ****Assumed, that you added a folder references "tessdata" into your xCode project tree, with the ‘Create folder references for any added folders’ options set up in the «Add files to project» dialog.
    
	// Assumed that any .traineddata files is in the tessdata folder, like in the Template Framework Project
    
    //Create your tesseract using the initWithLanguage method:
	// Tesseract* tesseract = [[Tesseract alloc] initWithLanguage:@"<strong>eng+ita</strong>"];
    
    // set up the delegate to recieve tesseract's callback
    
    // self should respond to TesseractDelegate and implement shouldCancelImageRecognitionForTesseract: method
    
    // to have an ability to recieve callback and interrupt Tesseract before it finishes
    
    
    self.imagePicker = [UIImagePickerController new];
    self.imagePicker.delegate = self;
    self.imagePicker.allowsEditing = YES;
    self.imagePicker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
}

//test demo image
- (IBAction)demoRecognizition:(id)sender {
    [self recognizeImageWithTesseract:[UIImage imageNamed:@"image_sample.jpg"]];
}


//tesseract processing
-(void)recognizeImageWithTesseract:(UIImage *)img
{
    //Threading
    dispatch_async(dispatch_get_main_queue(), ^{
		[self.activityIndicator startAnimating];
	});
    
    Tesseract* tesseract = [[Tesseract alloc] initWithLanguage:@"eng+ita"];//langague package
    tesseract.delegate = self;
    [tesseract setVariableValue:@"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz" forKey:@"tessedit_char_whitelist"]; //limit search
    [tesseract setImage:img]; //image to check
    [tesseract recognize];//processing
    
    NSString *recognizedText = [tesseract recognizedText];
    NSLog(@"Recognized: %@", recognizedText);
    
    //Threading
    dispatch_async(dispatch_get_main_queue(), ^{
		[self.activityIndicator stopAnimating];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tesseract OCR iOS" message:recognizedText delegate:nil cancelButtonTitle:@"Yeah!" otherButtonTitles:nil];
        [alert show];
        
    });
    
    tesseract = nil; //deallocate and free all memory *****
}

- (BOOL)shouldCancelImageRecognitionForTesseract:(Tesseract*)tesseract {
    NSLog(@"progress: %d", tesseract.progress);
    return NO;  // return YES, if you need to interrupt tesseract before it finishes
}


- (IBAction)openCamera:(id)sender
{
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:Nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Take photo", @"Choose Existing", nil];
        [actionSheet showInView:self.view];
    } else {
        [self.imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    }

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != actionSheet.cancelButtonIndex){
        if (buttonIndex == 0)
            [self.imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        else if (buttonIndex == 1)
            [self.imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    } else{
        
    }
    //[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIImagePickerController Delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [self recognizeImageWithTesseract:image];
	});
}
@end
