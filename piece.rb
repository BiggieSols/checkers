# encoding: utf-8
require_relative 'board'

class Piece
  attr_accessor :position, :color, :board, :king

  SLIDE_OFFSETS = [ [1, 1], [1, -1] ]
  JUMP_OFFSETS  = [ [2, 2], [2, -1] ] 

  def initialize(position, color, board, king = false)
    @position, @color, @board, @king = position, color, board, king
  end

  def directions
    return [1, -1] if @king
    @color == :b ? [1] : [-1]
  end

  def slide_offsets
    [].tap do |arr|
      SLIDE_OFFSETS.map do |offset|
        directions.map do |direction|
          arr << [ offset[0] * direction, offset[1] ]
        end
      end
    end
  end

  # def jump_offsets
  #   JUMP_OFFSETS.map { |offset| offset[1] *= direction }
  # end
end