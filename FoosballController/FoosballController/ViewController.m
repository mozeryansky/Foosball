//
//  ViewController.m
//  FoosballController
//
//  Created by Michael Ozeryansky on 4/21/16.
//  Copyright © 2016 Michael Ozeryansky. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic) double rotation;
@property (nonatomic) double position;
@property (strong, nonatomic) ORSSerialPortManager *serialManager;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.position = 50;
    self.rotation = 0;
    
    [self.positionTextField setDoubleValue:self.position];
    [self.rotationTextField setDoubleValue:self.rotation];
    
    self.serialManager = [ORSSerialPortManager sharedSerialPortManager];
    if ([[self.serialManager availablePorts] count] == 0){
        NSLog(@"No connected serial ports found!");
    } else {
        // print available serial ports
        NSLog(@"Available serial ports:");
        NSArray *availablePorts = self.serialManager.availablePorts;
        [availablePorts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ORSSerialPort *port = (ORSSerialPort *)obj;
            NSLog(@"%lu. %@\n", (unsigned long)idx, port.name);
        }];
        
        // open usb port: 0
        ORSSerialPort *port = [availablePorts objectAtIndex:0];
        self.serialPort = port;
        self.serialPort.baudRate = @9600;
        self.serialPort.delegate = self;
        [self.serialPort open];
    }
}

- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark - Position

- (void)setPosition:(double)position
{
    if(position < 0){
        position = 0;
    } else if(position > 100){
        position = 100;
    }
    
    _position = position;
    
    [self.positionTextField setDoubleValue:_position];
    
    [self sendPosition];
}

- (void)sendPosition
{
    static int prevSent = -1;
    int value = (int)round(self.position);
    
    if(value == prevSent){
        return;
    }
    prevSent = value;
    
    // send
    NSString *dataStr = [NSString stringWithFormat:@"p%03d", value];
    [self sendString:dataStr];
}

- (IBAction)positionTextFieldChanged:(NSTextField *)textField
{
    [self setPosition:textField.doubleValue];
    [textField setDoubleValue:self.position];
}

#pragma mark - Rotation

- (void)setRotation:(double)rotation
{
    if(rotation < -90){
        rotation = -90;
    } else if(rotation > 90){
        rotation = 90;
    }
    
    _rotation = rotation;
    
    [self.rotationTextField setDoubleValue:_rotation];
    
    [self sendRotation];
}

- (void)sendRotation
{
    static int prevSent = -1;
    int value = (int)round(self.rotation);
    
    if(value == prevSent){
        return;
    }
    prevSent = value;
    
    // send
    NSString *dataStr = [NSString stringWithFormat:@"r%03d", value];
    [self sendString:dataStr];
}

- (IBAction)rotationTextFieldChanged:(NSTextField *)textField
{
    [self setRotation:textField.doubleValue];
    [textField setDoubleValue:self.rotation];
}

#pragma mark - Mouse

- (void)mouseDragged:(NSEvent *)theEvent
{
    [self.view.window makeFirstResponder:nil];
    
    double pos_scale = 0.2;
    double pos_power = 1.1;
    
    double rot_scale = 0.5;
    double rot_power = 1.1;
    
    self.position += -(theEvent.deltaX>0?1:-1) * pow(fabs(theEvent.deltaX), pos_power) * pos_scale;
    self.rotation += (theEvent.deltaY>0?1:-1) * pow(fabs(theEvent.deltaY), rot_power) * rot_scale;
    
    [self.positionTextField setDoubleValue:self.position];
    [self.rotationTextField setDoubleValue:self.rotation];
}

#pragma mark - Custom Actions

- (void)doPositionLoopStep:(NSTimer *)timer
{
    static int direction = 1;
    
    if(self.position == 100){
        direction = -1;
    } else if(self.position == 0){
        direction = 1;
    }
    
    double slider = self.positionSlider.doubleValue;
    
    int maxStep = 5;
    int step = ceil((slider/100.0)*maxStep);
    self.position += direction * step;
}

- (IBAction)positionLoopButtonPressed:(NSButton *)button
{
    static NSTimer *timer;
    
    if(button.state == NSOnState){
        // on
        timer = [NSTimer scheduledTimerWithTimeInterval:0.1f
                                         target:self
                                       selector:@selector(doPositionLoopStep:)
                                       userInfo:nil
                                        repeats:YES];
        
    } else if(button.state == NSOffState){
        // off
        [timer invalidate];
    }
}

- (void)doRotationLoopStep:(NSTimer *)timer
{
    static int direction = 1;
    
    if(self.rotation == 90){
        direction = -1;
    } else if(self.rotation == -90){
        direction = 1;
    }
    
    double slider = self.rotationSlider.doubleValue;
    
    int maxStep = 6;
    int step = ceil((slider/100.0)*maxStep);
    self.rotation += direction * step;
}

- (IBAction)rotationLoopButtonPressed:(NSButton *)button
{
    static NSTimer *timer;
    
    if(button.state == NSOnState){
        // on
        timer = [NSTimer scheduledTimerWithTimeInterval:0.1f
                                                 target:self
                                               selector:@selector(doRotationLoopStep:)
                                               userInfo:nil
                                                repeats:YES];
        
    } else if(button.state == NSOffState){
        // off
        [timer invalidate];
    }
}

#pragma mark - ORSSerialPort

- (void)sendString:(NSString *)string
{
    // append delimeter
    string = [string stringByAppendingString:@"|"];
    
    // send
    [self.serialPort sendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)serialPort:(ORSSerialPort *)serialPort didReceiveData:(NSData *)data
{
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"\nReceived: \"%@\"", string);
}

- (void)serialPortWasRemovedFromSystem:(ORSSerialPort *)serialPort
{
    self.serialPort = nil;
}

- (void)serialPort:(ORSSerialPort *)serialPort didEncounterError:(NSError *)error
{
    NSLog(@"%s %@ %@", __PRETTY_FUNCTION__, serialPort, error);
}

- (void)serialPortWasOpened:(ORSSerialPort *)serialPort
{
    NSLog(@"Serial port %@ was opened", serialPort.name);
}

@end
