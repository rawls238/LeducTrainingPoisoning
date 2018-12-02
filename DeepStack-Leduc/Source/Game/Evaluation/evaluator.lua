--- Evaluates hand strength in Leduc Hold'em and variants.
-- 
-- Works with hands which contain two or three cards, but assumes that
-- the deck contains no more than two cards of each rank (so three-of-a-kind
-- is not a possible hand).
-- 
-- Hand strength is given as a numerical value, where a lower strength means
-- a stronger hand: high pair < low pair < high card < low card
-- @module evaluator

require 'torch'
require 'math'
local game_settings = require 'Settings.game_settings'
local card_to_string = require 'Game.card_to_string_conversion'
local card_tools = require 'Game.card_tools'
local arguments = require 'Settings.arguments'

local M = {}

--- Gives a strength representation for a hand containing two cards.
-- @param hand_ranks the rank of each card in the hand
-- @return the strength value of the hand
-- @local
function M:evaluate_two_card_hand(hand_ranks)
  -- Check for the pair 
  local hand_value = nil 
  if hand_ranks[1] == hand_ranks[2] then
    --hand is a pair
    hand_value = hand_ranks[1]
  else
    --hand is a high card    
    hand_value = hand_ranks[1] * game_settings.rank_count + hand_ranks[2]    
  end
  return hand_value
end

--- Gives a strength representation for a hand containing two cards.
-- @param hand_ranks the rank of each card in the hand
-- @return the strength value of the hand
-- @local
function M:rocks_evaluate_two_card_hand(hand_ranks)
  -- Check for the pair 
  local hand_value = nil 
  if hand_ranks[1] == hand_ranks[2] then
    --hand is a pair
    hand_value = hand_ranks[1]
  elseif hand_ranks[1] == 1 then
    -- Highest Card is an A
    hand_value = hand_ranks[1] * game_settings.rank_count
  elseif hand_ranks[1] == 2 then
    -- Highest Card is an K
    hand_value = hand_ranks[1] * game_settings.rank_count * 5
  else
    -- Highest Card is an Q
    hand_value = hand_ranks[1] * game_settings.rank_count * 10
  end
  return hand_value
end

--- Gives a strength representation for a two or three card hand.
-- @param hand a vector of two or three cards
-- @param[opt] impossible_hand_value the value to return if the hand is invalid
-- @return the strength value of the hand, or `impossible_hand_value` if the 
-- hand is invalid
function M:evaluate(hand, player, impossible_hand_value)
  -- Check if valid hand for game
  assert(hand:max() <= game_settings.card_count and hand:min() > 0, 'hand does not correspond to any cards' )
  impossible_hand_value = impossible_hand_value or -1
  if not card_tools:hand_is_possible(hand) then
    return impossible_hand_value
  end

  -- For each card in whole hand (private + board) find card rank
  --    Note: For Leduc, discard the card suit
  local hand_ranks = hand:clone()
  for i = 1, hand_ranks:size(1) do 
    hand_ranks[i] = card_to_string:card_to_rank(hand_ranks[i])
  end

  -- Sort hand by card ranks (highest to lowest rank)
  hand_ranks = hand_ranks:sort()

  -- In Leduc, evaluate the hand by rank
  if hand:size(1) == 2 and player == 1 then

    -- Return Normal Evaluation for Current Player
    return self:evaluate_two_card_hand(hand_ranks)
  elseif hand:size(1) == 2 and player == 2 then

    -- Return Rocks Evaluation for Opponent
    return self:rocks_evaluate_two_card_hand(hand_ranks)
  else
    assert(false, 'unsupported size of hand!' )
  end
end

--- Gives strength representations for all private hands on the given board.
-- @param board a possibly empty vector of board cards
-- @param impossible_hand_value the value to assign to hands which are invalid 
-- on the board
-- @return a vector containing a strength value or `impossible_hand_value` for
-- every private hand
function M:batch_eval(board, player, impossible_hand_value)
  local hand_values = arguments.Tensor(game_settings.card_count):fill(-1)

  -- If empty board, then assign hand values relative to suit count
  if board:dim() == 0 then 
    for hand = 1, game_settings.card_count do 
      hand_values[hand] = math.floor((hand -1 ) / game_settings.suit_count ) + 1
    end

  else
    local board_size = board:size(1)
    assert(board_size == 1 or board_size == 2, 'Incorrect board size for Leduc' )

    -- Create whole hand 1x2 Tensor
    local whole_hand = arguments.Tensor(board_size + 1)

    -- Set the first value of the whole hand 1x2 Tensor to the board
    whole_hand[{{1, -2}}]:copy(board)

    for card = 1, game_settings.card_count do 
      -- Set the second value of the whole hand Tensor to the private card
      whole_hand[-1] = card; 

      -- Calculate the hand_value based on the whole hand 
      hand_values[card] = self:evaluate(whole_hand, player, impossible_hand_value)
    end 
  end
  return hand_values
end

return M