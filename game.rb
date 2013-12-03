require_relative 'board'
require 'io/console'



class InvalidPieceSelectionError < StandardError
end

# mix this in as a module later
class InvalidMoveError < StandardError
end

# NOTE TO SELF: add to module later

class Game

  def initialize
    @board = Board.new
    @current_player = :b
    @last_move = nil
  end

  def curr_player_name
    @current_player == :b ? "Black" : "White"
  end

  def switch_player
    @current_player = @current_player == :b ? :w : :b
  end

  def play
    until @board.won?
      puts @board
      begin
        start_piece = @board[*get_arrow_input_for_start_piece]
        if start_piece.nil? || start_piece.color != @current_player
          raise InvalidPieceSelectionError.new("must select a #{curr_player_name} piece") 
        end
      rescue InvalidPieceSelectionError, InvalidMoveError => e
        puts e.message
        retry
      end

      @board.render(piece: start_piece)

      begin
        move_sequence = get_move_sequence_input

        start_piece.perform_moves(move_sequence)
        raise InvalidMoveError.new("must enter at least one move") if move_sequence.empty?
      rescue InvalidMoveError, InvalidPieceSelectionError => e
        puts e.message
        retry
      end
      switch_player
    end

    puts "winner is #{@board.winner}!"
  end

  def get_start_piece_input
    puts "enter your starting piece as a coordinate (e.g. 0, 0)"
    start_coords = gets.chomp.split(/,?\s*/).map(&:to_i)
    check_valid_coordinate(start_coords)
    start_coords
  end

  def check_valid_coordinate(coordinate)
    unless coordinate.join(" ") =~ /^[0-7],?\s*[0-7]$/
      raise InvalidPieceSelectionError.new("must select a coordinate (e.g. 0, 0 )") 
    end
  end

  def get_move_sequence_input
    puts "enter your move sequence as a series of coordinates, one per line (e.g. 2, 3 )"
    puts "end your selection by pressing 'e'"
    coords_arr = []
    while true
      input = gets.chomp #.split(/,?\s*/).map(&:to_i)
      return coords_arr if input.downcase == "e"
      input = input.split(/\s*,?\s*/).map(&:to_i)
      check_valid_coordinate(input)
      coords_arr << input
    end
  end

  def get_arrow_input_for_start_piece
    pointer_pos = @last_move || [0, 0]
    puts @board.render(pointer: pointer_pos)
    
    while true
      char = STDIN.getch.to_s
      puts char
      
      case char
      when "D"
        pointer_pos = move_pointer(pointer_pos, :left)
      when "C"
        pointer_pos = move_pointer(pointer_pos, :right)
      when "A"
        pointer_pos = move_pointer(pointer_pos, :up)
      when "B"
        pointer_pos = move_pointer(pointer_pos, :down)
      when "\r"
        @last_move = pointer_pos.dup
        return pointer_pos
      when "q"
        return "exit"
      end
    end
  end

  def move_pointer(pointer, direction)
    directions = {
      up:     [-1,  0],
      down:   [ 1,  0],
      left:   [ 0, -1],
      right:  [ 0,  1]
    }

    dir_to_move = directions[direction]

    new_pos = [ pointer[0] + dir_to_move[0], pointer[1] + dir_to_move[1] ]

    return pointer unless in_bounds(new_pos)


    @board.render(pointer: new_pos)

    new_pos
  end

  # replace with module later
  def in_bounds(pos)
    pos.all? { |coord| coord.between?(0, 7) }
  end
end

if __FILE__ == $PROGRAM_NAME
  g = Game.new
  g.play
end

