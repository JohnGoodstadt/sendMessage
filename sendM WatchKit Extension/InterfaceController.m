//
//  InterfaceController.m
//  tryMessage WatchKit Extension
//
//  Created by john goodstadt on 15/08/2015.
//  Copyright © 2015 john goodstadt. All rights reserved.
//

#import "InterfaceController.h"
#import <WatchConnectivity/WatchConnectivity.h>

@interface InterfaceController()  <WCSessionDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *replyLabel;
@property (assign) int counter;

@end

/**
 Called first when view is loaded
 */
@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    if(WCSession.isSupported){
        WCSession* session = WCSession.defaultSession;
        session.delegate = self;
        [session activateSession];
        
    }
    
    self.counter = 1;
    [self setTitle:[NSString stringWithFormat:@"%i",_counter]];
    
    
    
}

/**
 Called when Phone uses sendMessge with Dictionary of values. Send back dictionary in replyHandler
 
 See phone counter-part for more help info
 
 */
- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message replyHandler:(void(^)(NSDictionary<NSString *, id> *replyMessage))replyHandler
{
    
    if(message){
        
        NSString* command = [message objectForKey:@"request"];
        [self.replyLabel setText:command];
        
        NSString* otherCounter = [message objectForKey:@"counter"];
        
        
        NSDictionary* response = @{@"response" : [NSString stringWithFormat:@"Message %@ received.",otherCounter]} ;
        
        
        if (replyHandler != nil) replyHandler(response);
        
        
    }
    
    
}
/**
 Helper function - accept Dictionary of values to send them to its phone - using sendMessage - including replay from phone
 */
-(void)packageAndSendMessage:(NSDictionary*)request
{
    if(WCSession.isSupported){
        
        
        WCSession* session = WCSession.defaultSession;
        session.delegate = self;
        [session activateSession];
        
        if(session.reachable)
        {
            
            [session sendMessage:request
                    replyHandler:
             ^(NSDictionary<NSString *,id> * __nonnull replyMessage) {
                 
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     NSLog(@".....replyHandler called --- %@",replyMessage);
                     
                     NSDictionary* message = replyMessage;
                     
                     NSString* response = message[@"response"];
                     
                     [[WKInterfaceDevice currentDevice] playHaptic:WKHapticTypeSuccess];
                     
                     if(response)
                         [self.replyLabel setText:response];
                     else
                         [self.replyLabel setText:@"nil"];
                     
                     
                 });
                 
                 
                 
                 
             }
             
                    errorHandler:^(NSError * __nonnull error) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.replyLabel setText:error.localizedDescription];
                        });
                        
                    }
             
             
             ];
        }
        else
        {
            [self.replyLabel setText:@"Session Not reachable"];
        }
        
    }
    else
    {
        [self.replyLabel setText:@"Session Not Supported"];
    }
    
    
    
    
    
}

/**
 Standard WatchKit delegate
 */
-(void)sessionWatchStateDidChange:(nonnull WCSession *)session
{
    if(WCSession.isSupported){
        WCSession* session = WCSession.defaultSession;
        session.delegate = self;
        [session activateSession];
        
    }
}
#pragma mark Button Actions
- (IBAction)sendMessageButtonPressed {
    
    [self.replyLabel setText:@"Sending..."];
    
    self.counter++;
    [self setTitle:[NSString stringWithFormat:@"%i",_counter]];
    
    NSDictionary* message = @{@"request":[NSString stringWithFormat:@"Message %d from the Phone",self.counter] ,@"counter":[NSString stringWithFormat:@"%d",self.counter]};
    
    [self packageAndSendMessage:message];
    
}
- (IBAction)yesButtonPressed {
    
    [self.replyLabel setText:@"Sending Yes..."];
    
    self.counter++;
    [self setTitle:[NSString stringWithFormat:@"%i",_counter]];
    
    [self packageAndSendMessage:@{@"request":@"Yes",@"counter":[NSString stringWithFormat:@"%i",_counter]}];
    
}
- (IBAction)noButtonPressed {
    
    [self.replyLabel setText:@"Sending No..."];
    
    self.counter++;
    [self setTitle:[NSString stringWithFormat:@"%i",_counter]];
    
    [self packageAndSendMessage:@{@"request":@"No",@"counter":[NSString stringWithFormat:@"%i",_counter]}];
}

@end



