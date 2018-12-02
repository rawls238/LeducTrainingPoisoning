--- Samples random probability vectors for use as player ranges.
-- @classmod range_generator

require "math"
require "torch"
local arguments = require 'Settings.arguments'
local evaluator = require 'Game.Evaluation.evaluator'
local card_toos = require 'Game.card_tools'

local RangeGenerator = torch.class('RangeGenerator')

--- Recursively samples a section of the range vector.
-- @param cards an NxJ section of the range tensor, where N is the batch size
-- and J is the length of the range sub-vector
-- @param mass a vector of remaining probability mass for each batch member
-- @see generate_range
-- @local
function RangeGenerator:_generate_recursion(cards, mass)
  local batch_size = cards:size(1)
  assert(mass:size(1) == batch_size)
  --we terminate recursion at size of 1
  local card_count = cards:size(2)
  if card_count == 1 then
    cards:copy(mass) 
  else
    local rand = torch.rand(batch_size)
    if arguments.gpu then 
      rand = rand:cuda()
    end
    local mass1 = mass:clone():cmul(rand)
    local mass2 = mass -mass1
    local halfSize = card_count/2
    --if the tensor contains an odd number of cards, randomize which way the
  --middle card goes
    if halfSize % 1 ~= 0 then
      halfSize = halfSize - 0.5
      halfSize = halfSize + torch.random(0,1)
    end 
    self:_generate_recursion(cards[{{}, {1, halfSize}}], mass1)
    self:_generate_recursion(cards[ {{}, {halfSize +1, -1}}], mass2)
  end
end

--- Samples a batch of ranges with hands sorted by strength on the board.
-- @param range a NxK tensor in which to store the sampled ranges, where N is
-- the number of ranges to sample and K is the range size
-- @see generate_range
-- @local
function RangeGenerator:_generate_sorted_range(range)
  local batch_size = range:size(1)
  self:_generate_recursion(range, arguments.Tensor(batch_size):fill(1))
end

--- Sets the (possibly empty) board cards to sample ranges with.
-- 
-- The sampled ranges will assign 0 probability to any private hands that
-- share any cards with the board.
--
-- @param board a possibly empty vector of board cards
function RangeGenerator:set_board(board)

  -- Create a ByteTensor of valid possible hands for the bord
  local possible_hand_indexes = card_toos:get_possible_hand_indexes(board)

  -- In Leduc, the possible hands will be 5
  self.possible_hands_count = possible_hand_indexes:sum(1)[1]  

  -- Reshape possible hands ByteTensor to a 1D row vector
  self.possible_hands_mask = possible_hand_indexes:view(1, -1)

  if not arguments.gpu then 
    self.possible_hands_mask = self.possible_hands_mask:byte()
  end

  -- Create a vector of private hand strength values for the board
  local hand_strengths = evaluator:batch_eval(board, 1)

  -- Creates a 1x6 tensor that applies a binary mask to hand strengths
  --    based on the possible hands ByteTensor
  local non_coliding_strengths = arguments.Tensor(self.possible_hands_count)  
  non_coliding_strengths:maskedSelect(hand_strengths, self.possible_hands_mask)

  -- Create a reverse order (asc. hand strength) tensor of possible hands
  local order
  _, order = non_coliding_strengths:sort()
  _, self.reverse_order = order:sort() 
  self.reverse_order = self.reverse_order:view(1, -1):long()

  -- Setup unique hand strengths for opponent and setup reverse order
  --    (asc. hand strength) tensor of possible hands
  local p2_hand_strengths = evaluator:batch_eval(board, 2)
  local p2_non_coliding_strengths = arguments.Tensor(self.possible_hands_count)  
  p2_non_coliding_strengths:maskedSelect(hand_strengths, self.possible_hands_mask)

  local p2_order
  _, p2_order = p2_non_coliding_strengths:sort()
  _, self.p2_reverse_order = p2_order:sort() 
  self.p2_reverse_order = self.p2_reverse_order:view(1, -1):long()

  -- Create empty tensors for re-ordered/sorted ranges
  self.reordered_range = arguments.Tensor()
  self.sorted_range = arguments.Tensor()

  self.p2_reordered_range = arguments.Tensor()
  self.p2_sorted_range = arguments.Tensor()

end

--- Samples a batch of random range vectors.
--
-- Each vector is sampled indepently by randomly splitting the probability
-- mass between the bottom half and the top half of the range, and then
-- recursing on the two halfs.
-- 
-- @{set_board} must be called first.
--
-- @param range a NxK tensor in which to store the sampled ranges, where N is
-- the number of ranges to sample and K is the range size
function RangeGenerator:generate_range(range, player)  

  -- In Leduc, batch size = 10
  local batch_size = range:size(1)

  range:zero()

  -- Original Section -- 
  -- Resize sorted range tensor to be a 10x5 tensor
  -- self.sorted_range:resize(batch_size, self.possible_hands_count)

  -- self:_generate_sorted_range(self.sorted_range, self.possible_hands_count)
  -- local index = self.reverse_order:expandAs(self.sorted_range)

  -- if arguments.gpu and player == 1 then 
  --   index = index:cuda()
  -- end

  -- -- Reorganize sorted range tensor by gathering column-wise elements
  -- self.reordered_range = self.sorted_range:gather(2, index)

  -- range:maskedCopy(self.possible_hands_mask:expandAs(range), self.reordered_range)

  -- Modification: Handle by Player
  if player == 2 then
    -- Resize sorted range tensor to be a 10x5 tensor
    self.p2_sorted_range:resize(batch_size, self.possible_hands_count)

    -- Create sorted 10x6 range tensor
    self:_generate_sorted_range(self.p2_sorted_range, self.possible_hands_count)

    --we have to reorder the the range back to undo the sort by strength

    -- Reshape reverse order tensor to match sorted range tensor dim
    --    In Leduc, index is a 10x5 tensor
    local p2_index = self.p2_reverse_order:expandAs(self.p2_sorted_range)

    if arguments.gpu and player == 1 then 
      p2_index = p2_index:cuda()
    end

    -- Reorganize sorted range tensor by gathering column-wise elements
    self.p2_reordered_range = self.p2_sorted_range:gather(2, p2_index)

    range:maskedCopy(self.possible_hands_mask:expandAs(range), self.p2_reordered_range)
  else
    -- Resize sorted range tensor to be a 10x5 tensor
    self.sorted_range:resize(batch_size, self.possible_hands_count)

    self:_generate_sorted_range(self.sorted_range, self.possible_hands_count)
    local index = self.reverse_order:expandAs(self.sorted_range)

    if arguments.gpu and player == 1 then 
      index = index:cuda()
    end

    -- Reorganize sorted range tensor by gathering column-wise elements
    self.reordered_range = self.sorted_range:gather(2, index)

    range:maskedCopy(self.possible_hands_mask:expandAs(range), self.reordered_range)
  end
end
