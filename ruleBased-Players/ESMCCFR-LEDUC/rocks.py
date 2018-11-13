import random
import sys


import acpc_python_client as acpc
from rules.Leduc import Leduc
import acpc_python_client.game_utils as utils

class Rocks(acpc.Agent):
    def __init__(self):
        super().__init__()
        self.actions = [acpc.ActionType.FOLD, acpc.ActionType.CALL, acpc.ActionType.RAISE]

    def on_game_start(self, game):
        pass
        
    def on_next_turn(self, game, match_state, is_acting_player):
        vp = match_state.get_viewing_player()
        gameround = match_state.get_state().get_round()

        handcard = match_state.get_state().get_hole_card(vp, 0)
        
        #ranks -- 10,11, or 12 (12 is highest)
        if is_acting_player:
            print("Possible actions: Fold", self.is_fold_valid(), " Call: ", self.is_call_valid(), " Raise: ", self.is_raise_valid())
            if utils.card_rank(handcard) == 12:
                if self.is_raise_valid():
                    self.set_next_action(self.actions[2], game.get_stack(vp))
                elif self.is_call_valid():
                    self.set_next_action(self.actions[1])
                print('my card is a king so i am confident')
            else:
                if self.is_fold_valid():
                    self.set_next_action(self.actions[0])
                    print('i am folding because i am not confident')
                else:
                    self.set_next_action(self.actions[1])


    def on_game_finished(self, game, match_state):
        pass
        
if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage {game_file_path} {dealer_hostname} {dealer_port}")
        sys.exit(1)

    client = acpc.Client(sys.argv[1], sys.argv[2], sys.argv[3])
    client.play(Rocks())
