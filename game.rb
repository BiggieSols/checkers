require_relative 'board'



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
        start_piece = @board[*get_start_piece_input]
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
end

g = Game.new
g.play