//
//  ViewController.m
//  sendM
//
//  Created by john goodstadt on 31/08/2015.
//  Copyright © 2015 john goodstadt. All rights reserved.
//

#import "ViewController.h"
#import <WatchConnectivity/WatchConnectivity.h>

@interface ViewController () <WCSessionDelegate>
@property (weak, nonatomic) IBOutlet UILabel *replyLabel;
@property (weak, nonatomic) IBOutlet UILabel *counterLabel;
@property (assign) int counter;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    if(WCSession.isSupported){
        WCSession* session = WCSession.defaultSession;
        session.delegate = self;
        [session activateSession];
        
    }
    
    
    self.counter = 1;
    self.counterLabel.text = [NSString stringWithFormat:@"%i",_counter];
}


/*
 Discussion
 This method is called in response to a message sent by the counterpart process using the sendMessage:replyHandler:errorHandler: method. This specific method is called when the counterpart specifies a valid reply handler, indicating that it wants a response. Use this method to process the message data and provide an appropriate reply. You must execute the reply block as part of your implementation.
 
 Use messages to communicate quickly with the counterpart process. Messages can be sent and received only while both processes are active and running.
 
 The delivery of multiple messages occurs serially, so your implementation of this method does not need to be reentrant. This method is called on a background thread of your app.
 */
- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message replyHandler:(void(^)(NSDictionary<NSString *, id> *replyMessage))replyHandler
{
    NSLog(@"didReceiveMessage with replyHandler");
    
    if(message){
        
        NSString* command = [message objectForKey:@"request"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.replyLabel setText:command];
        });
        
        
        
        NSString* otherCounter = [message objectForKey:@"counter"];
        
        
        NSDictionary* response = @{@"response" : [NSString stringWithFormat:@"Message %@ received.",otherCounter]} ;
        
        
        if (replyHandler != nil) replyHandler(response);
        
        
        
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
        
        
        if(session.reachable){
            NSLog(@"session.reachable");
        }
        
        if(session.paired){
            if(session.isWatchAppInstalled){
                
                if(session.watchDirectoryURL != nil){
                    
                    
                }
                
            }
        }
        
        
    }
}

/**
 Uses given Dictionary to send and handle its reply and any errors.
 
 @param request message that is sent to the counterpart device - keyword, value.
 
 @return void
 */
-(void)packageAndSendMessage:(NSDictionary*)request
{
    
    
    
    /*
     Discussion
     Before retrieving the default session object, call this method to verify that the current device supports watch connectivity. Session objects are always available on Apple Watch. They are also available on iPhones that support pairing with an Apple Watch. For all other devices, this method returns NO to indicate that you cannot use the classes and methods of this framework.
     */
    if(WCSession.isSupported){
        
        WCSession* session = WCSession.defaultSession;
        session.delegate = self;
        [session activateSession];
        
        /*
         Discussion
         In your WatchKit extension, the value of this property is YES when a matching session is active on the user’s iPhone and the device is within range so that communication may occur. On iOS, the value is YES when the paired Apple Watch is in range and the associated Watch app is running in the foreground. In all other cases, the value is NO.
         
         The counterpart must be reachable in order for you to send messages using the sendMessage:replyHandler:errorHandler: and sendMessageData:replyHandler:errorHandler: methods. Sending messages to a counterpart that is not reachable results in an error.
         
         The session must be configured and activated before accessing this property.
         */
        if(session.reachable)
        {
            
            
            
            /*
             Discussion
             Use this message to send a dictionary of data to the counterpart as soon as possible. Messages are queued serially and delivered in the order in which you sent them. Delivery of the messages happens asynchronously, so this method returns immediately.
             
             If you specify a reply handler block, your handler block is executed asynchronously on a background thread. The block is executed serially with respect to other incoming delegate messages.
             
             Calling this method from your WatchKit extension while it is active and running wakes up the corresponding iOS app in the background and makes it reachable. Calling this method from your iOS app does not wake up the corresponding WatchKit extension. If you call this method and the counterpart is unreachable (or becomes unreachable before the message is delivered), the errorHandler block is executed with an appropriate error. The errorHandler block may also be called if the message parameter contains non property list data types.
             */
            
            
            [session sendMessage:request replyHandler: ^(NSDictionary<NSString *,id> * __nonnull replyMessage)
             {
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     NSLog(@".....replyHandler called --- %@",replyMessage);
                     
                     NSDictionary* message = replyMessage;
                     
                     NSString* response = message[@"response"];
                     
                     if(response)
                         [self.replyLabel setText:response];
                     else
                         [self.replyLabel setText:@"nil"];
                     
                     
                     
                     
                 });
                 
                 
                 
                 
             }
             
                    errorHandler:^(NSError * __nonnull error) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"%@",error.localizedDescription);
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
#pragma mark Button Actions
- (IBAction)SendMessageButtonPressed:(id)sender {
    
    [self.replyLabel setText:@"Sending..."];
    
    
    
    NSDictionary* message = @{@"request":[NSString stringWithFormat:@"Message %d from the Phone",self.counter] ,@"counter":[NSString stringWithFormat:@"%d",self.counter]};
    
    self.counter++;
    self.counterLabel.text = [NSString stringWithFormat:@"%i",_counter];
    
     //Send message
    [self packageAndSendMessage:message];
    
}
- (IBAction)yesButtonPressed:(id)sender {
    
    [self.replyLabel setText:@"Sending Yes..."];
    
    self.counter++;
    self.counterLabel.text = [NSString stringWithFormat:@"%i",_counter];
    
     //Build message and send
    [self packageAndSendMessage:@{@"request":@"Yes",@"counter":[NSString stringWithFormat:@"%i",_counter]}];
}
- (IBAction)noButtonPressed:(id)sender {
    
    [self.replyLabel setText:@"Sending No..."];
    
    self.counter++;
    self.counterLabel.text = [NSString stringWithFormat:@"%i",_counter];
    
    
    //Build message and send
    [self packageAndSendMessage:@{@"request":@"No",@"counter":[NSString stringWithFormat:@"%i",_counter]}];
}
@end
