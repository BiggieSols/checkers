require_relative 'piece'
require 'colorize'

class Board

  def initialize
    @grid = Array.new(8) { Array.new(8) }
  end

  def render
    puts "  0 1 2 3 4 5 6 7"
    8.times do |row_index|
      print "#{row_index} "
      8.times do |col_index|
        background = ((row_index + col_index) % 2 == 0) ? :light_blue : :light_green
        piece = self[row_index, col_index]
        to_print = piece.nil? ? "  " : piece.to_s
        print to_print.colorize(background: background)
      end
      puts
    end  end

  def [](row, col)
    @grid[row][col]
  end

  def []=(row, col, piece)
    @grid[row][col] = piece
  end
end