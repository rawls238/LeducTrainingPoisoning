import random
import sys


import acpc_python_client as acpc
from rules.Leduc import Leduc
import acpc_python_client.game_utils as utils

class PassiveRocks(acpc.Agent):
    def __init__(self):
        super().__init__()
        self.actions = [acpc.ActionType.FOLD, acpc.ActionType.CALL, acpc.ActionType.RAISE]

    def on_game_start(self, game):
        pass
        
    def on_next_turn(self, game, match_state, is_acting_player):
        vp = match_state.get_viewing_player()
        gameround = match_state.get_state().get_round()
        
        if gameround == 0:
            print("round 0")
            #first round, so handcards but no table cards
            handcard = match_state.get_state().get_hole_card(vp, 0)
            #ranks -- 10,11, or 12 (12 is highest)
            if is_acting_player:
                print("Possible actions: Fold", self.is_fold_valid(), " Call: ", self.is_call_valid(), " Raise: ", self.is_raise_valid())
                if utils.card_rank(handcard) > 10 :
                    #if we have higher than a bottom card, play on
                    if self.is_raise_valid() and utils.card_rank(handcard) == 12:
                        #if we have top card, raise
                        self.set_next_action(self.actions[2], game.get_stack(vp))
                    #if we don't have top card, call
                    elif self.is_call_valid():
                        self.set_next_action(self.actions[1])
                    print('my card is a king so i am confident')
                else:
                    if self.is_fold_valid():
                        self.set_next_action(self.actions[0])
                        print('i am folding because i am not confident')
                    else:
                        self.set_next_action(self.actions[1])
        elif gameround == 1:
            print("round 1")


            #board card and hand card
            handcard = match_state.get_state().get_hole_card(vp, 0)
            tablecard = match_state.get_state().get_board_card(0)

            #strategy.  default is call.  if have the tablecard, raise.  if have lower than tablecard, fold
            if is_acting_player:
                if self.is_raise_valid() and utils.card_rank(handcard) == utils.card_rank(tablecard):
                    print("have a match so raise")
                    self.set_next_action(self.actions[2], game.get_stack(vp))
                elif self.is_fold_valid() and utils.card_rank(handcard) < utils.card_rank(tablecard):
                    print("have bad cards so fold")
                    self.set_next_action(self.actions[0])

                print("dunno, so calling")
                self.set_next_action(self.actions[1])




    def on_game_finished(self, game, match_state):
        pass
        
if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage {game_file_path} {dealer_hostname} {dealer_port}")
        sys.exit(1)

    client = acpc.Client(sys.argv[1], sys.argv[2], sys.argv[3])
    client.play(PassiveRocks())
