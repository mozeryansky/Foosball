//
//  ViewController.m
//  FoosballController
//
//  Created by Michael Ozeryansky on 4/21/16.
//  Copyright © 2016 Michael Ozeryansky. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) ORSSerialPortManager *serialManager;
@property (nonatomic) double position;
@property (nonatomic) double rotation;
@property (nonatomic) double minPosition;
@property (nonatomic) double maxPosition;
@property (nonatomic) double minRotation;
@property (nonatomic) double maxRotation;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.minPosition = 0;
    self.maxPosition = 360;
    self.minRotation = -90;
    self.maxRotation = 90;
    
    self.position = 0;
    self.rotation = 0;
    
    [self.positionTextField setDoubleValue:self.position];
    [self.rotationTextField setDoubleValue:self.rotation];
    
    self.serialManager = [ORSSerialPortManager sharedSerialPortManager];
    if ([[self.serialManager availablePorts] count] == 0){
        NSLog(@"No connected serial ports found!");
    } else {
        // print available serial ports
        NSLog(@"Available serial ports:");
        __block NSUInteger bluetoothPort = 0;
        NSArray *availablePorts = self.serialManager.availablePorts;
        [availablePorts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ORSSerialPort *port = (ORSSerialPort *)obj;
            NSLog(@"%lu. %@\n", (unsigned long)idx, port.name);
            if([port.name rangeOfString:@"NBT-8A41"].location != NSNotFound){
                bluetoothPort = idx;
            }
        }];
        
        // open usb port: 0
        ORSSerialPort *port = [availablePorts objectAtIndex:bluetoothPort];
        self.serialPort = port;
        self.serialPort.baudRate = @115200;
        self.serialPort.delegate = self;
    }
}

- (void)viewDidAppear
{
    [super viewDidAppear];
    
    [self.serialPort open];
}

- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark - Position

- (void)setPosition:(double)position
{
    if(position < self.minPosition){
        position = self.minPosition;
    } else if(position > self.maxPosition){
        position = self.maxPosition;
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
    NSString *dataStr = [NSString stringWithFormat:@"p%d", value];
    [self sendString:dataStr];
}

#pragma mark - Rotation

- (void)setRotation:(double)rotation
{
    if(rotation < self.minRotation){
        rotation = self.minRotation;
    } else if(rotation > self.maxRotation){
        rotation = self.maxRotation;
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
    NSString *dataStr = [NSString stringWithFormat:@"r%d", value];
    [self sendString:dataStr];
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
    
    if(self.position >= self.maxPosition){
        direction = -1;
    } else if(self.position <= self.minPosition){
        direction = 1;
    }
    
    double slider = self.positionSlider.doubleValue;
    
    int maxStep = 50;
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
    
    if(self.rotation >= self.maxRotation){
        direction = -1;
    } else if(self.rotation <= self.minRotation){
        direction = 1;
    }
    
    double slider = self.rotationSlider.doubleValue;
    
    int maxStep = 60;
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

#pragma mark - Text Input

- (IBAction)positionTextFieldChanged:(NSTextField *)textField
{
    double val = textField.doubleValue;
    
    if(val > self.maxPosition){
        self.maxPosition = val;
    } else if(val < self.minPosition){
        self.minPosition = val;
    }
    
    [self setPosition:val];
}

- (IBAction)rotationTextFieldChanged:(NSTextField *)textField
{
    double val = textField.doubleValue;
    
    if(val > self.maxRotation){
        self.maxRotation = val;
    } else if(val < self.minRotation){
        self.minRotation = val;
    }
    
    [self setRotation:val];
}

#pragma mark - button actions

- (IBAction)minPositionButtonPressed:(NSButton *)sender
{
    self.minPosition = self.position;
}

- (IBAction)maxPositionButtonPressed:(NSButton *)sender
{
    self.maxPosition = self.position;
}

- (IBAction)minRotationButtonPressed:(NSButton *)sender
{
    self.minRotation = self.rotation;
}

- (IBAction)maxRotationButtonPressed:(NSButton *)sender
{
    self.maxRotation = self.rotation;
}

- (IBAction)decreasePositionButtonPressed:(NSButton *)sender
{
    if(self.position - 1 < self.minPosition){
        self.minPosition--;
    }
    self.position -= 1;
}

- (IBAction)increasePositionButtonPressed:(NSButton *)sender
{
    if(self.position + 1 > self.maxPosition){
        self.maxPosition++;
    }
    self.position += 1;
}

- (IBAction)decreaseRotationButtonPressed:(NSButton *)sender
{
    if(self.rotation - 1 < self.minRotation){
        self.minRotation--;
    }
    self.rotation -= 1;
}

- (IBAction)increaseRotationButtonPressed:(NSButton *)sender
{
    if(self.rotation + 1 > self.maxRotation){
        self.maxRotation++;
    }
    self.rotation += 1;
}

- (IBAction)setZeroPositionButtonPressed:(NSButton *)sender
{
    _position = 0;
    
    [self.positionTextField setDoubleValue:_position];
    
    [self sendString:@"zp"];
}

- (IBAction)setZeroRotationButtonPressed:(NSButton *)sender
{
    _rotation = 0;
    
    [self.rotationTextField setDoubleValue:_rotation];

    [self sendString:@"zr"];
}

- (IBAction)connectButtonPressed:(id)sender
{
    if(self.serialPort.isOpen){
        [self.serialPort close];
    } else {
        [self.serialPort open];
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
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"Serial Port Error"];
    [alert setInformativeText:error.localizedDescription];
    [alert setAlertStyle:NSCriticalAlertStyle];
    [alert runModal];
}

- (void)serialPortWasOpened:(ORSSerialPort *)serialPort
{
    NSLog(@"Serial port %@ was opened", serialPort.name);
    
    [self.connectButton setState:NSOnState];
    [self.connectButton setTitle:@"Disconnect"];
}

- (void)serialPortWasClosed:(ORSSerialPort *)serialPort
{
    NSLog(@"Serial port %@ was closed", serialPort.name);
    
    [self.connectButton setState:NSOffState];
    [self.connectButton setTitle:@"Connect"];
}

@end
