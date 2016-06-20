//
//  FISBlackjackViewController.m
//  objc-BlackJackViews
//
//  Created by Matt Amerige on 6/20/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#import "FISBlackjackViewController.h"

#define kMaxturns 3

@interface FISBlackjackViewController ()

@property (weak, nonatomic) IBOutlet UILabel *winnerLabel;

@property (weak, nonatomic) IBOutlet UILabel *houseLabel;
@property (weak, nonatomic) IBOutlet UILabel *houseScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *houseStayedLabel;

@property (weak, nonatomic) IBOutlet UILabel *houseCard1Label;
@property (weak, nonatomic) IBOutlet UILabel *houseCard2Label;
@property (weak, nonatomic) IBOutlet UILabel *houseCard3Label;
@property (weak, nonatomic) IBOutlet UILabel *houseCard4Label;
@property (weak, nonatomic) IBOutlet UILabel *houseCard5Label;

@property (weak, nonatomic) IBOutlet UILabel *houseBustLabel;
@property (weak, nonatomic) IBOutlet UILabel *houseBlackjackLabel;
@property (weak, nonatomic) IBOutlet UILabel *houseWinsLabel;
@property (weak, nonatomic) IBOutlet UILabel *houseLossesLabel;

@property (weak, nonatomic) IBOutlet UILabel *playerLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerStayedLabel;

@property (weak, nonatomic) IBOutlet UILabel *playerCard1Label;
@property (weak, nonatomic) IBOutlet UILabel *playerCard2Label;
@property (weak, nonatomic) IBOutlet UILabel *playerCard3Label;
@property (weak, nonatomic) IBOutlet UILabel *playerCard4Label;
@property (weak, nonatomic) IBOutlet UILabel *playerCard5Label;

@property (weak, nonatomic) IBOutlet UILabel *playerBustLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerBlackjackLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerWinsLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerLossesLabel;


@property (weak, nonatomic) IBOutlet UIButton *hitButton;
@property (weak, nonatomic) IBOutlet UIButton *stayButton;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *houseCardLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *playerCardLabels;

@property (nonatomic) NSUInteger turns;

@end

@implementation FISBlackjackViewController

typedef enum {
    FISPlayer,
    FISHouse
    
} FISPlayerType;

- (FISBlackjackGame *)game
{
    if (!_game) {
        _game = [[FISBlackjackGame alloc] init];
    }
    return _game;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _setupNewGame];
}

- (void)_hideViews
{
    self.winnerLabel.hidden = YES;
    
    self.houseStayedLabel.hidden = YES;
    self.houseScoreLabel.hidden = YES;
    
    self.houseCard1Label.hidden = YES;
    self.houseCard2Label.hidden = YES;
    self.houseCard3Label.hidden = YES;
    self.houseCard4Label.hidden = YES;
    self.houseCard5Label.hidden = YES;
    
    self.houseBustLabel.hidden = YES;
    self.houseBlackjackLabel.hidden = YES;

    
    self.playerStayedLabel.hidden = YES;
    
    self.playerCard1Label.hidden = YES;
    self.playerCard2Label.hidden = YES;
    self.playerCard3Label.hidden = YES;
    self.playerCard4Label.hidden = YES;
    self.playerCard5Label.hidden = YES;
    
    self.playerBustLabel.hidden = YES;
    self.playerBlackjackLabel.hidden = YES;

}

/**
 Sets up a new game, dealing two cards to the house and two card to the player

 */
- (IBAction)_dealButtonTapped:(id)sender
{
    [self _startNewGame];
}

- (IBAction)_hitButtonTapped:(id)sender
{
    [self.game dealCardToPlayer];
    [self _updateCardUIForPlayer:FISPlayer];
    [self _updateScoreUI];
    if (self.game.player.busted) {
        self.playerBustLabel.hidden = NO;
        [self _processGameResults];
    }
    else {
        [self.game processHouseTurn];
        [self _updateCardUIForPlayer:FISHouse];
        [self _updateScoreUI];
        if (self.game.house.busted) {
            self.houseBustLabel.hidden = NO;
            [self _processGameResults];
        }
    }
    self.turns++;
}

- (IBAction)_stayButtonTapped:(id)sender
{
	self.stayButton.enabled = NO;
	self.hitButton.enabled = NO;
	self.playerStayedLabel.hidden = NO;
	
	
	NSUInteger houseRemainingTurns = 5 - self.game.house.cardsInHand.count;
	
	for (NSUInteger i = 0; i < houseRemainingTurns; i++) {
		[self.game processHouseTurn];
		[self _updateCardUIForPlayer:FISHouse];
		[self _updateScoreUI];
		if (self.game.house.busted) {
            self.houseBustLabel.hidden = NO;
			break;
		}
	}
    [self _processGameResults];
}

- (void)_processGameResults
{
	self.winnerLabel.hidden = NO;
	BOOL housewins = [self.game houseWins];
	
	if (housewins) {
		self.winnerLabel.text = @"YOU LOSE";
	}
	else {
		self.winnerLabel.text = @"YOU WIN";
	}
    
    if (self.game.house.blackjack) {
        self.houseBlackjackLabel.hidden = NO;
    }
    else if (self.game.player.blackjack) {
        self.playerBlackjackLabel.hidden = NO;
    }
    
    

	[self.game incrementWinsAndLossesForHouseWins:housewins];
	
	// Update score UI
	[self _updateScoreUI];
	
	[self _updateWinLossUI];
	
	// Disable Hit and Stay
	self.hitButton.enabled = NO;
	self.stayButton.enabled = NO;
}

#pragma mark - Helper Methods

- (void)_setupNewGame
{
    [self _hideViews];
    [self _updateScoreUI];
}

/**
 Sets up a new game. Deals the first round (two cards to each player and house. 
 Unhides the two cards, and enables the hit/stay buttons
 */
- (void)_startNewGame
{
	[self.game.deck resetDeck];
	[self.game.player resetForNewGame];
	[self.game.house resetForNewGame];
	[self _hideViews];
	
	[self.game dealNewRound];
	[self _unhideFirstTwoCards];
	_hitButton.enabled = YES;
	_stayButton.enabled = YES;
	self.houseScoreLabel.hidden = NO;
	[self _updateScoreUI];
}

/**
 Unhides the first two cards for the start of a new game for both the
 player and the house
 
 */
- (void)_unhideFirstTwoCards
{
	for (NSUInteger i = 0; i < 2; i++) {
		[self _updateCardUIForPlayer:FISPlayer];
		
		[self _updateCardUIForPlayer:FISHouse];
	}
}

/**
 Applies the card.cardLabel property for all card in hand to the cardLabels
 */
- (void)_updateCardUIForPlayer:(FISPlayerType)playerType
{
	NSArray *cards = nil;
	NSArray *cardLabels = nil;
	if (playerType == FISPlayer) {
		
		cards = self.game.player.cardsInHand;
		cardLabels = self.playerCardLabels;
		
	}
	else if (playerType == FISHouse) {
		cards = self.game.house.cardsInHand;
		cardLabels = self.houseCardLabels;
	}
	else {
		NSLog(@"Invalid Player Type");
		return;
	}
	
	// Updates all cards that are currently in hand
	NSUInteger index = 0;
	for (FISCard *card in cards) {
		UILabel *label = cardLabels[index];
        label.hidden = NO;
		label.text = card.cardLabel;
		
		index++;
	}
}

- (void)_updateScoreUI
{
    self.playerScoreLabel.text = [NSString stringWithFormat:@"Score: %ld", self.game.player.handscore];
    self.houseScoreLabel.text = [NSString stringWithFormat:@"Score: %ld", self.game.house.handscore];
}

- (void)_updateWinLossUI
{
    self.playerLossesLabel.text = [NSString stringWithFormat:@"Losses: %ld", self.game.player.losses];
    self.playerWinsLabel.text = [NSString stringWithFormat:@"Wins: %ld", self.game.player.wins];
    
    self.houseLossesLabel.text = [NSString stringWithFormat:@"Losses: %ld", self.game.house.losses];
    self.houseWinsLabel.text = [NSString stringWithFormat:@"Wins: %ld", self.game.house.wins];
}


@end


















