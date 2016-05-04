 //
//  ViewController.m
//  FoosballCameraController
//
//  Created by Michael Ozeryansky on 4/27/16.
//  Copyright © 2016 Michael Ozeryansky. All rights reserved.
//

#import "ViewController.h"

#import <opencv2/opencv.hpp>
#import <opencv2/core.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/videoio/cap_ios.h>
#import <opencv2/xfeatures2d.hpp>
#import <opencv2/features2d.hpp>

using namespace std;
using namespace cv;
using namespace cv::xfeatures2d;

@interface ViewController ()
@property (nonatomic, retain) CvVideoCamera* videoCamera;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.imageView];
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetHigh;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.videoCamera start];
    
    /*
    Ptr<FastFeatureDetector> detector = FastFeatureDetector::create(5);
    
    UIImage *patternImage = [UIImage imageNamed:@"pattern.png"];
    Mat pattern;
    UIImageToMat(patternImage, pattern);
    cvtColor(pattern, pattern, CV_BGRA2GRAY);
    
    std::vector<KeyPoint> keypoints_1;
    
    detector->detect(pattern, keypoints_1);
    
    Mat img_keypoints_1;
    
    drawKeypoints(pattern, keypoints_1, img_keypoints_1, Scalar::all(-1), DrawMatchesFlags::DEFAULT);
    
    patternImage = MatToUIImage(img_keypoints_1);
    
    [self.imageView setImage:patternImage];
    //*/
}

#pragma mark - Protocol CvVideoCameraDelegate


- (void)processImage:(Mat&)image;
{
    // Do some OpenCV stuff with the image
    //*
    Mat image_copy;
    cvtColor(image, image_copy, CV_BGRA2BGR);
    
    Ptr<FastFeatureDetector> detector = FastFeatureDetector::create(50);
    Ptr<FastFeatureDetector> detector5 = detector;//FastFeatureDetector::create(30);
     //-Ptr<SiftFeatureDetector> detector = SIFT::create();
     //-Ptr<SurfFeatureDetector> detector = SURF::create();
    //Ptr<ORB> detector = ORB::create();
     //Ptr<BRISK> detector = BRISK::create();
     //-Ptr<MSER> detector = MSER::create();
     //Ptr<SimpleBlobDetector> detector = SimpleBlobDetector::create();
    UIImage *patternImage = [UIImage imageNamed:@"pattern.png"];
    Mat pattern;
    UIImageToMat(patternImage, pattern);
    cvtColor(pattern, pattern, CV_BGRA2BGR);
    
    std::vector<KeyPoint> keypoints_1, keypoints_2;
    
    detector5->detect(pattern, keypoints_1);
    detector->detect(image_copy, keypoints_2);
    
    Mat img_keypoints_1, img_keypoints_2;
    
    drawKeypoints(image_copy, keypoints_1, img_keypoints_1, Scalar::all(-1), DrawMatchesFlags::DEFAULT);
    image_copy = img_keypoints_1;
    
    cvtColor(image_copy, image, CV_BGR2BGRA);
    
    
    // computing descriptors
    Ptr<BriefDescriptorExtractor> extractor = BriefDescriptorExtractor::create();
    Mat descriptors1, descriptors2;
    extractor->compute(pattern, keypoints_1, descriptors1);
    extractor->compute(image_copy, keypoints_2, descriptors2);
    
    // matching descriptors
    BFMatcher matcher = BFMatcher::BFMatcher();
    vector<DMatch> matches;
    matcher.match(descriptors1, descriptors2, matches);
    
    // drawing the results
    Mat img_matches;
    drawMatches(pattern, keypoints_1, image_copy, keypoints_2, matches, img_matches);
    
    cvtColor(img_matches, image, CV_BGR2BGRA);
    
    // invert image
    //bitwise_not(image_copy, image_copy);
    //cvtColor(image_copy, image, CV_BGR2BGRA);
}

@end
