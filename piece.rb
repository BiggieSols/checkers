# encoding: utf-8

require 'matrix'

class InvalidMoveError < StandardError
end

class Piece
  attr_accessor :position, :color, :board, :king

  SLIDE_OFFSETS = [ [1, 1], [1, -1] ]
  JUMP_OFFSETS  = [ [2, 2], [2, -2] ] 

  def initialize(position, color, board, king = false)
    @position, @color, @board, @king = position, color, board, king
  end

  def to_s
    color == :b ? "⚫ " : "⚪ "
  end

  def ==(other_piece)
    @position == other_piece.position && 
    @color == other_piece.color && 
    @king == other_piece.king
  end

  def perform_moves!(move_sequence)
    if move_sequence.length == 1
      perform_single_move(move_sequence.first)
    else
      move_sequence.each { |move| perform_jump( move ) }
    end
  end

  def perform_single_move(move)
    if valid_slide?( move )
      perform_slide( move )
    else
      perform_jump( move )
    end
  end

  def perform_moves(move_sequence)
    raise InvalidMoveError.new("not a valid move sequence") unless is_valid_sequence?(move_sequence)
    perform_moves!(move_sequence)
  end

  def is_valid_sequence?(move_sequence)
    dup_board = @board.dup
    dup_piece = dup_board.find_equivalent_piece(self)

    begin
      dup_piece.perform_moves!(move_sequence)
    rescue
      false
    else
      true
    end
  end

  def perform_slide(new_pos)
    raise InvalidMoveError.new("not a valid slide") unless valid_slide?( new_pos )
    @board.move(self, new_pos)
    maybe_promote

  end

  def perform_jump(new_pos)
    raise InvalidMoveError.new("not a valid jump") unless valid_jump?( new_pos )
    remove_middle_piece( new_pos )
    @board.move( self, new_pos )
    maybe_promote
  end

  def valid_moves
    valid_slides + valid_jumps
  end

  def valid_recursive_moves
    valid_slides + valid_recursive_jumps
  end

  def has_move?(coord)
    valid_moves.include?( coord )
  end

  def has_recursive_move?(coord)
    valid_recursive_moves.include?( coord )
  end

  def valid_slides
    potential_slides.select { |new_pos| @board.empty_pos?( new_pos ) }
  end

  def valid_jumps
    potential_jumps.select! { |new_pos| @board.empty_pos?( new_pos ) }

    [].tap do |arr|
      potential_jumps.each do |jump|
        middle_pos = between_pos( @position, jump )
        piece = @board[ middle_pos[0], middle_pos[1] ]
        arr << jump if (!piece.nil? && piece.color != @color)
      end
    end
  end

  def move(new_pos)
    @position = new_pos
  end


  private

  def directions
    return [1, -1] if @king
    @color == :b ? [-1] : [1]
  end

  # black back row is 0, white back row is 7
  def opponent_back_row
    @color == :b ? 0 : 7
  end

  def maybe_promote
    @king = true if @position[0] == opponent_back_row
  end

  def move_offsets_with_direction(move_type_offsets)
    [].tap do |arr|
      move_type_offsets.map do |offset|
        directions.map do |direction|
          arr << [ offset[0] * direction, offset[1] ]
        end
      end
    end
  end

  def between_pos(pos1, pos2)
    ( Vector[ *pos1 ] + Vector[ *pos2 ] ) / 2
  end

  def potential_slides
    potential_moves( slide_offsets )
  end

  def potential_jumps
    potential_moves( jump_offsets )
  end

  def potential_moves(move_type_offsets)
    [].tap do |arr|
      move_type_offsets.each do |slide_offset|
        new_pos = ( Vector[ *@position ] + Vector[ *slide_offset ] ).to_a
        arr << new_pos if in_bounds?(new_pos)
      end
    end
  end

  def in_bounds?(coords)
    coords.all? { |coord| coord.between?( 0, 7 ) }
  end

  def slide_offsets
    move_offsets_with_direction(SLIDE_OFFSETS)
  end

  def jump_offsets
    move_offsets_with_direction(JUMP_OFFSETS)
  end

  def remove_middle_piece(new_pos)
    pos_to_remove =   between_pos( @position, new_pos )
    piece_to_remove = @board[ *pos_to_remove ]
    @board.remove_piece( piece_to_remove )
  end

  def valid_slide?(new_pos)
    valid_slides.include?( new_pos )

  end

  def valid_jump?(new_pos)
    valid_jumps.include?( new_pos )
  end

  def valid_recursive_jumps
    valid_rec_jumps = valid_jumps

    return valid_rec_jumps if valid_jumps.empty?

    valid_jumps.each do |jump|
      board_dup = @board.dup

      self_dup = board_dup[ @position[0], @position[1] ]

      self_dup.perform_jump(jump)

      new_jumps = self_dup.valid_recursive_jumps

      new_jumps.delete(@position)

      valid_rec_jumps += new_jumps
    end

    valid_rec_jumps
  end
end 



