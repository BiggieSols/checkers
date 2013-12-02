# encoding: utf-8
require_relative 'piece'
require 'colorize'

class Board
  def initialize
    @grid = Array.new(8) { Array.new(8) }
    set_up_board
  end

  def set_up_board
    8.times do |row|
      if row.even?
        add_piece(Piece.new([1, row], :w, self), [1, row])
        add_piece(Piece.new([5, row], :b, self), [5, row])
        add_piece(Piece.new([7, row], :b, self), [7, row])
      else
        add_piece(Piece.new([0, row], :w, self), [0, row])
        add_piece(Piece.new([2, row], :w, self), [2, row])
        add_piece(Piece.new([6, row], :b, self), [6, row])
      end
    end
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

  # testing for use with current piece identification
  def render(args)
    # puts "\e[H\e[2J" #will clear the screen
    params = {
      piece: nil,
      pointer: nil
    }.merge( args )

    selected_piece = params[:piece].nil? ? [] : params[:piece]

    puts "  0 1 2 3 4 5 6 7"
    8.times do |row_index|
      print "#{row_index} "
      8.times do |col_index|

        background = ((row_index + col_index) % 2 == 0) ? :light_blue : :light_green
        background = :red if selected_piece.has_move?( [row_index, col_index] )
        background = :black if [row_index, col_index] == params[:pointer]

        piece = self[row_index, col_index]
        to_print = piece.nil? ? "  " : piece.to_s
        print to_print.colorize(background: background)
      end
      puts
    end  
    puts
  end

  def [](row, col)
    @grid[row][col]
  end

  def won?
    all_pieces(:w).empty? || all_pieces(:b).empty?
  end

  def winner
    return "Black" if all_pieces(:w).empty?
    return "White" if all_pieces(:b).empty?
    "Incomplete"
  end

  # def draw?
  # end

  def dup
    dup_board = Board.new

    all_pieces.each do |piece|
      new_piece = Piece.new( piece.position, piece.color, dup_board, piece.king )
      dup_board.add_piece(new_piece, new_piece.position)
    end

    dup_board
  end

  # Used with dup method to find equivalent pieces in dup board
  def find_equivalent_piece(equivalent_piece)
    all_pieces.select { |piece| piece == equivalent_piece }.first
  end

  def all_pieces(color = nil)
    return @grid.flatten.compact if color.nil?
    @grid.flatten.compact.select { |piece| piece.color == color }
  end

  def []=(row, col, piece)
    @grid[row][col] = piece
  end

  def empty_pos?(pos)
    self[*pos].nil?
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

# b = Board.new
# puts b
=begin

p1 = Piece.new([2, 2], :w, b, false)
p2 = Piece.new([5, 5], :b, b, true)
p3 = Piece.new([3, 3], :b, b, true)


b.add_piece(p1, p1.position)
b.add_piece(p2, p2.position)
b.add_piece(p3, p3.position)


puts b

# # p1.perform_jump([6, 6])
# # b.render

# p p1.valid_jumps
# p1.perform_slide([5, 3])

p1.perform_moves( [[4, 4], [6, 6]] )#, [6, 5]] )
puts b
# puts p1.king
p1.perform_moves( [[7, 5]])
puts b
# p p1.king

=end
