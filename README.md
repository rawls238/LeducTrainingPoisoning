# deep_learning_project
Fall 2018 Deep Learning Project Repo


libraries:
torch 
lua
luarocks
luasocket

to run a match:

1. connect the server.  
./DeepStack-Leduc/ACPCServer/dealer <name_of_game> ./DeepStack-Leduc/ACPCServer/leduc.game <#hands> <rngSeed> <p1name> <p2name> -p 20000,20001 > <name_of_output_file>

2. in separate tab, connect player 1
3. in separate tab, connect player 2


examples of how to connect a player:

pretrained deepstack:
cd ./DeepStack-Leduc/Source
th Player/deepstack.lua


allin_net.py (from previous year's project) -- always raises max amount:
python ./code/ESMCCFR-LEDUC/allin_net.py ./DeepStack-Leduc/ACPCServer/leduc.game localhost <port>

example_player.c (from DeepStack code) -- selects random action:
./DeepStack-Leduc/ACPCServer/example_player ./DeepStack-Leduc/ACPCServer/leduc.game localhost <port>


always_call.py (written by us) -- always calls -- just wants to see what everyone has
python ./code/ESMCCFR-LEDUC/always_call.py ./DeepStack-Leduc/ACPCServer/leduc.game localhost <port>

