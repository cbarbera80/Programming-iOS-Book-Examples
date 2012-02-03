

#import "ViewController.h"
#import <EventKit/EventKit.h>

@interface ViewController ()
@property (nonatomic, strong) UIPopoverController* currentPop;
@end

@implementation ViewController
@synthesize currentPop;

// run on device

// look in Calendar app afterwards to find your new events

- (IBAction)doButton:(id)sender {
    EKRecurrenceRule* recur = 
    [[EKRecurrenceRule alloc] 
     initRecurrenceWithFrequency:EKRecurrenceFrequencyYearly 
     interval:1 
     daysOfTheWeek:nil 
     daysOfTheMonth:nil
     monthsOfTheYear:[NSArray arrayWithObjects:
                      [NSNumber numberWithInt: 1],
                      [NSNumber numberWithInt: 4],
                      [NSNumber numberWithInt: 6],
                      [NSNumber numberWithInt: 9],
                      nil] 
     weeksOfTheYear:nil 
     daysOfTheYear:nil 
     setPositions: nil
     end:nil];
    EKEventStore* database = [[EKEventStore alloc] init];
    EKEvent* taxes = [EKEvent eventWithEventStore:database];
    taxes.title = @"[Testing] Estimated tax payment due";
    [taxes addRecurrenceRule: recur];
    NSCalendar* greg = 
    [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* comp = [[NSDateComponents alloc] init];
    [comp setYear:2011];
    [comp setMonth:4];
    [comp setDay:15];
    NSDate* date = [greg dateFromComponents:comp];
    taxes.calendar = [database defaultCalendarForNewEvents];
    taxes.startDate = date; 
    taxes.endDate = date;
    taxes.allDay = YES;
    NSError* err = nil;
    BOOL ok = [database saveEvent:taxes span: EKSpanFutureEvents error:&err];
    if (ok)
        NSLog(@"ok!");
    else
        NSLog(@"error: %@", [err localizedDescription]);
}

// modify example so you'll get some results
// look in console for results

- (IBAction)doButton2:(id)sender {
    EKEventStore* database = [[EKEventStore alloc] init];
    NSDate* d1 = [NSDate date];
    NSDate* d2 = [NSDate dateWithTimeInterval:60*60*24*365 sinceDate:d1];
    NSPredicate* pred = 
    [database predicateForEventsWithStartDate:d1 endDate:d2 
                                    calendars:database.calendars];
    NSMutableArray* marr = [NSMutableArray array];
    [database enumerateEventsMatchingPredicate:pred usingBlock:
     ^(EKEvent *event, BOOL *stop) {
         NSRange r = [event.title rangeOfString:@"insurance" 
                                        options:NSCaseInsensitiveSearch];
         if (r.location != NSNotFound)
             [marr addObject: event];
     }];
    [marr sortUsingSelector:@selector(compareStartDateWithEvent:)];
    NSLog(@"%@", marr);
}

// universal, works on iPhone or iPad

- (IBAction)doButton3:(id)sender {
    EKEventViewController* evc = [[EKEventViewController alloc] init];
    evc.delegate = self;
    EKEventStore* database = [[EKEventStore alloc] init];
    EKEvent* anEvent = [EKEvent eventWithEventStore:database];
    anEvent.title = @"Asteroid due to strike earth";
    anEvent.notes = @"Look out! Here it comes!";
    evc.event = anEvent;
    evc.allowsEditing = NO;
    // on iPhone, push onto existing navigation interface
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        [self.navigationController pushViewController:evc animated:YES];
    // on iPad, create navigation interface in popover
    else {
        UINavigationController* nc = 
        [[UINavigationController alloc] initWithRootViewController:evc];
        evc.modalInPopover = NO;
        UIPopoverController* pop = 
        [[UIPopoverController alloc] initWithContentViewController:nc];
        self.currentPop = pop;
        [pop presentPopoverFromRect:[sender bounds] inView:sender
           permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

-(void)eventViewController:(EKEventViewController *)controller didCompleteWithAction:(EKEventViewAction)action {
    
}


@end
