# deep_learning_project
# Fall 2018 Deep Learning Project Repo


## libraries:
torch 
lua
luarocks
luasocket

# to run a match:


## SETTING UP ENVIRONMENT
1. Run make in the ACPCServer Directory: 
`cd DeepStack-Leduc/ACPCServer`
`make`

2. Setup the acpc client:
`cd code/acpc-python-client/`
`python setup.py install`


## CONFIGURING GAME/PLAYERS
1. connect the server.  
`./DeepStack-Leduc/ACPCServer/dealer <name_of_game> ./DeepStack-Leduc/ACPCServer/leduc.game <#hands> <rngSeed> <p1name> <p2name> -p 20000,20001 > <name_of_output_file>`

2. in separate tab, connect player 1
3. in separate tab, connect player 2


### Players and how to connect them:

#### testing players:

always_call.py -- always calls
`python ./ruleBased-Players/ESMCCFR-LEDUC/always_call.py ./DeepStack-Leduc/ACPCServer/leduc.game localhost <port>`

allin_net.py -- always raises max amount:
`python ./ruleBased-Players/ESMCCFR-LEDUC/allin_net.py ./DeepStack-Leduc/ACPCServer/leduc.game localhost <port>`

selects random valid action:
`./DeepStack-Leduc/ACPCServer/example_player ./DeepStack-Leduc/ACPCServer/leduc.game localhost <port>`

#### rule-based irrational players:

Rocks Player (very conservative):
`python ./ruleBased-Players/ESMCCFR-LEDUC/rocks.py ./DeepStack-Leduc/ACPCServer/leduc.game localhost <port>`

Passive Rocks Player (less conservative):
`python ./ruleBased-Players/ESMCCFR-LEDUC/passiveRocks.py ./DeepStack-Leduc/ACPCServer/leduc.game localhost <port>`

#### "Smart" Irrational Players:

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

pretrained deepstack (always plays on port 20000):
`cd ./DeepStack-Leduc/Source`
`th Player_DeepStack/deepstack.lua`






