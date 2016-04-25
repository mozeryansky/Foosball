//
//  ViewController.h
//  FoosballController
//
//  Created by Michael Ozeryansky on 4/21/16.
//  Copyright © 2016 Michael Ozeryansky. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ORSSerialPort.h"
#import "ORSSerialPortManager.h"

@interface ViewController : NSViewController <ORSSerialPortDelegate>

@property (nonatomic, strong) ORSSerialPort *serialPort;

@property (weak) IBOutlet NSTextField *rotationTextField;
@property (weak) IBOutlet NSTextField *positionTextField;
@property (weak) IBOutlet NSSlider *positionSlider;
@property (weak) IBOutlet NSSlider *rotationSlider;
@property (weak) IBOutlet NSButton *connectButton;

- (IBAction)rotationTextFieldChanged:(NSTextField *)sender;
- (IBAction)positionTextFieldChanged:(NSTextField *)sender;

- (IBAction)positionLoopButtonPressed:(NSButton *)sender;
- (IBAction)rotationLoopButtonPressed:(NSButton *)sender;

- (IBAction)minPositionButtonPressed:(NSButton *)sender;
- (IBAction)maxPositionButtonPressed:(NSButton *)sender;
- (IBAction)minRotationButtonPressed:(NSButton *)sender;
- (IBAction)maxRotationButtonPressed:(NSButton *)sender;

- (IBAction)decreasePositionButtonPressed:(NSButton *)sender;
- (IBAction)increasePositionButtonPressed:(NSButton *)sender;
- (IBAction)decreaseRotationButtonPressed:(NSButton *)sender;
- (IBAction)increaseRotationButtonPressed:(NSButton *)sender;

- (IBAction)setZeroPositionButtonPressed:(NSButton *)sender;
- (IBAction)setZeroRotationButtonPressed:(NSButton *)sender;

- (IBAction)connectButtonPressed:(id)sender;

@end

