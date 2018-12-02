--- Converts between vectors over private hands and vectors over buckets.
-- @classmod bucket_conversion

require 'torch'
require 'math'
require 'Nn.bucketer'
local card_tools = require 'Game.card_tools'
local arguments = require 'Settings.arguments'
local game_settings = require 'Settings.game_settings'

local BucketConversion = torch.class('BucketConversion')

--- Constructor
function BucketConversion:__init()
end

--- Sets the board cards for the bucketer
-- @param board a non-empty vector of board cards
function BucketConversion:set_board(board)
  self.bucketer = Bucketer()

  -- For Leduc, bucket count is 36
  self.bucket_count = self.bucketer:get_bucket_count()

  -- Create a NxK tensor of zeros, where N = 6 and K = 36
  self._range_matrix = arguments.Tensor(game_settings.card_count, self.bucket_count ):zero()

  -- Create a vector mapping private hands to buckets based on a board card
  local buckets = self.bucketer:compute_buckets(board)

  -- Create a 1x36 tensor with values 1 through 36
  local class_ids = torch.range(1, self.bucket_count)

  if arguments.gpu then 
    buckets = buckets:cuda() 
    class_ids = class_ids:cuda()
  else
    -- Convert class tensor values to float values
    class_ids = class_ids:float() 
  end

  -- Resize class and bucket tensors into 6x36 tensors
  class_ids = class_ids:view(1, self.bucket_count):expand(game_settings.card_count, self.bucket_count)
  local card_buckets = buckets:view(game_settings.card_count, 1):expand(game_settings.card_count, self.bucket_count)

  -- Compute element-wise equality of class tensor and bucket tensor
  -- Set Range Matrix as transformation from card ranges to class strength ranges 
  self._range_matrix[torch.eq(class_ids, card_buckets)] = 1

  --matrix for transformation from class values to card values
  self._reverse_value_matrix = self._range_matrix:t():clone()
end

--- Converts a range vector over private hands to a range vector over buckets.
-- 
-- @{set_board} must be called first. Used to create inputs to the neural net.
-- @param card_range a probability vector over private hands
-- @param bucket_range a vector in which to save the resulting probability 
-- vector over buckets
function BucketConversion:card_range_to_bucket_range(card_range, bucket_range)

  -- Matrix Multiply card range and board range matrix
  bucket_range:mm(card_range, self._range_matrix)
end

--- Converts a value vector over buckets to a value vector over private hands.
-- 
-- @{set_board} must be called first. Used to process neural net outputs.
-- @param bucket_value a vector of values over buckets
-- @param card_value a vector in which to save the resulting vector of values
-- over private hands
function BucketConversion:bucket_value_to_card_value(bucket_value, card_value)
  card_value:mm(bucket_value, self._reverse_value_matrix)
end

--- Gives a vector of possible buckets on the the board.
-- 
-- @{set_board} must be called first.
-- @return a mask vector over buckets where each entry is 1 if the bucket is
-- valid, 0 if not
function BucketConversion:get_possible_bucket_mask()
  local mask = arguments.Tensor(1, self.bucket_count)
  local card_indicator = arguments.Tensor(1, game_settings.card_count):fill(1)
  mask:mm(card_indicator, self._range_matrix)
  return mask
end