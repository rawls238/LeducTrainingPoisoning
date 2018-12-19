Implementation of Training Data Poisoning for Imperfect Information Games, Guy Aridor, Natania Wolansky, Jisha Jacob, Iddo Drori, 2018.

## Libraries:
torch 
lua
luarocks
luasocket

# To Run a Match:

## Environment Setup 
1. Run make in the ACPCServer Directory: 
`cd DeepStack-Leduc/ACPCServer`
`make`
2. Setup the acpc client (Note: Ensure you are using Python 3):
`cd ruleBased-Players/acpc-python-client/`
`python setup.py install`

## Configuring the Game & Players
1. Connect the server by starting the dealer. Run the following command: 
`./DeepStack-Leduc/ACPCServer/dealer <name_of_game> ./DeepStack-Leduc/ACPCServer/leduc.game <#hands> <rngSeed> <p1name> <p2name> -p 20000,20001 <name_of_output_file>`
2. In a separate tab, connect Player 1
3. In a separate tab, connect Player 2

### Players and how to connect them:

#### Simple Control Players:
Three control players were used that modeled the "Always Call", "All In" and "Random" playing profiles.

always_call.py -- always calls
`python ./ruleBased-Players/ESMCCFR-LEDUC/always_call.py ./DeepStack-Leduc/ACPCServer/leduc.game localhost <port>`

allin_net.py -- always raises max amount:
`python ./ruleBased-Players/ESMCCFR-LEDUC/allin_net.py ./DeepStack-Leduc/ACPCServer/leduc.game localhost <port>`

selects random valid action:
`./DeepStack-Leduc/ACPCServer/example_player ./DeepStack-Leduc/ACPCServer/leduc.game localhost <port>`

#### Rule-based irrational players:
Two conservative playing profiles were explore in this project. To run them, use the following commands.

Rocks Player (very conservative):
`python ./ruleBased-Players/ESMCCFR-LEDUC/rocks.py ./DeepStack-Leduc/ACPCServer/leduc.game localhost <port>`

Passive Rocks Player (less conservative):
`python ./ruleBased-Players/ESMCCFR-LEDUC/passiveRocks.py ./DeepStack-Leduc/ACPCServer/leduc.game localhost <port>`

#### "Smart" Irrational Players:
Four semi-rational and irrational playing profiles were built on top of DeepStack. To run them, use the following commands.

Random Bluffer (always plays on port 20001):
`cd ./DeepStack-Leduc/Source`
`th Player_RandomizedBluffer/deepstack.lua`

Semi Bluffer (always plays on port 20001):
`cd ./DeepStack-Leduc/Source`
`th Player_SmartBluffer/deepstack.lua`

Mild Adaptive Rocks (always plays on port 20001):
`cd ./DeepStack-Leduc/Source`
`th Player_MildAdaptiveRocks/deepstack.lua`

Strong Adaptive Rocks (always plays on port 20001):
`cd ./DeepStack-Leduc/Source`
`th Player_StrongAdaptiveRocks/deepstack.lua`

#### Rational Player:
To run a pretrained Deepstack (always plays on port 20000):
`cd ./DeepStack-Leduc/Source`
`th Player_DeepStack/deepstack.lua`






