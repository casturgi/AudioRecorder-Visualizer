//
//  RecordingsViewController.m
//  EZAudioRecordVisualizer
//
//  Created by cory Sturgis on 2/19/16.
//  Copyright © 2016 CorySturgis. All rights reserved.
//

#import "RecordingsViewController.h"
#import "AppDelegate.h"
#import "Recording.h"
#import "ViewController.h"

@interface RecordingsViewController () <UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSArray *recordingsArray;
@property NSManagedObjectContext *moc;
@property (nonatomic, strong) EZAudioPlayer *player;
@property (nonatomic, strong) EZAudioFile *audioFile;
@property AVAudioPlayer *audioPlayer;

@end

@implementation RecordingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //Initialize an instance of the the app delegate
    AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
    self.moc = delegate.managedObjectContext;

    //Initialize the audio session and handle any errors that occurr
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];

    NSError *error;
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session category: %@", error.localizedDescription);
    }
    [audioSession setActive:YES error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session active: %@", error.localizedDescription);
    }

    //load saved recordings into the recordings array
    [self load];
}

-(void)viewWillAppear:(BOOL)animated{
    [self load];
}

#pragma mark - Set up notifications

- (void)setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidChangeAudioFile:)
                                                 name:EZAudioPlayerDidChangeAudioFileNotification
                                               object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidChangeOutputDevice:)
                                                 name:EZAudioPlayerDidChangeOutputDeviceNotification
                                               object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidChangePlayState:)
                                                 name:EZAudioPlayerDidChangePlayStateNotification
                                               object:self.player];
}

- (void)audioPlayerDidChangeAudioFile:(NSNotification *)notification
{
    EZAudioPlayer *player = [notification object];
    NSLog(@"Player changed audio file: %@", [player audioFile]);
}

- (void)audioPlayerDidChangeOutputDevice:(NSNotification *)notification
{
    EZAudioPlayer *player = [notification object];
    NSLog(@"Player changed output device: %@", [player device]);
}

- (void)audioPlayerDidChangePlayState:(NSNotification *)notification
{
    EZAudioPlayer *player = [notification object];
    NSLog(@"Player change play state, isPlaying: %i", [player isPlaying]);
}

#pragma Core Data Methods

-(void)load {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Recording"];
    self.recordingsArray = [self.moc executeFetchRequest:request error:nil];
    [self.tableView reloadData];
}

#pragma tableView Delegate Methods


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.recordingsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecCell"];
    Recording *rec = [self.recordingsArray objectAtIndex:indexPath.row];

    UIButton *playPauseButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0, 30, 30)];
    playPauseButton.userInteractionEnabled =YES;
    [playPauseButton setTintColor:[UIColor blueColor]];

    UIImage *play = [UIImage imageNamed:@"play-circle-fill.png"];
    UIImage *stop = [UIImage imageNamed:@"stopButtonIcon.png"];

    [playPauseButton setImage:play forState:UIControlStateNormal];
    [playPauseButton setImage:stop forState:UIControlStateSelected];
    [playPauseButton addTarget:self action:@selector(playPauseBtnPress:) forControlEvents:UIControlEventTouchUpInside];

    cell.accessoryView = playPauseButton;
    cell.textLabel.text = rec.name;
    return cell;
}

-(void)playPauseBtnPress:(UIButton *)sender{

    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    UITableViewCell *cell = (UITableViewCell *)button.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Recording *rec = [self.recordingsArray objectAtIndex:indexPath.row];

    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:rec.url] error:&error];
    self.audioPlayer.delegate = self;
    if (error){
        NSLog(@"could not play audio file. %@", error.localizedDescription);
    }

    if ([button isSelected]) {
        [self.audioPlayer play];
    } else if (![button isSelected]){
        [self.audioPlayer stop];
    }
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self.tableView reloadData];
}

#pragma segue methods



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
