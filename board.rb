# encoding: utf-8
require_relative 'piece'
require 'colorize'

class Board
  def initialize
    @grid = Array.new(8) { Array.new(8) }
  end

  def to_s
    board_render = "  0 1 2 3 4 5 6 7\n"
    8.times do |row_index|
      board_render += "#{row_index} "
      8.times do |col_index|
        background = ((row_index + col_index) % 2 == 0) ? :light_blue : :light_green
        piece = self[row_index, col_index]
        to_print = piece.nil? ? "  " : piece.to_s
        board_render += to_print.colorize(background: background)
      end
      board_render += "\n"
    end  
    board_render + "\n"
  end

  def [](row, col)
    @grid[row][col]
  end

  def dup
    dup_board = Board.new

    all_pieces.each do |piece|
      new_piece = Piece.new( piece.position, piece.color, dup_board, piece.king )
      dup_board.add_piece(new_piece, new_piece.position)
    end

    dup_board
  end

  def all_pieces(color = nil)
    return @grid.flatten.compact if color == nil
    @grid.flatten.compact.select { |piece| piece.color == color }
  end

  def []=(row, col, piece)
    @grid[row][col] = piece
  end

  def empty_pos?(pos)
    self[*pos] == nil
  end

  def move(piece, new_pos)
    remove_piece(piece)
    add_piece(piece, new_pos)
  end

  def add_piece(piece, new_pos)
    self[ new_pos[0], new_pos[1] ] = piece
    piece.move( new_pos )
  end

  def remove_piece(piece)
    old_pos = piece.position
    self[ *old_pos ] = nil
    piece.position = nil
  end
end

b = Board.new
p1 = Piece.new([2, 2], :b, b, true)
p2 = Piece.new([5, 5], :w, b, true)
p3 = Piece.new([3, 3], :w, b, true)


b.add_piece(p1, p1.position)
b.add_piece(p2, p2.position)
b.add_piece(p3, p3.position)


puts b

# b.render

# # p1.perform_jump([6, 6])
# # b.render

# p p1.valid_slides
# p1.perform_slide([5, 3])

p1.perform_moves!( [[4, 4], [6, 6]] )
puts b