require_relative 'board'

class InvalidPieceSelectionError < StandardError
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
    # don't forget to add begin/rescue with InvalidMoveError
    until @board.won?
      begin
        start_piece = @board[*get_start_piece_input]
        raise InvalidPieceSelectionError.new("must select a #{curr_player_name} piece")
      rescue InvalidPieceSelectionError => e
        puts e.message
        retry
      end

      begin
        move_sequence = get_move_sequence_input
        start_piece.perform_moves(move_sequence)
      rescue InvalidMoveError => e
        puts e.message
        retry
      end
    end

    puts "winner is #{@board.winner}!"
  end

  def get_start_piece_input
    puts "enter your starting piece as a coordinate (e.g. 0, 0)"
    start_coords = gets.chomp.split(/,?\s*/)
  end

  def get_move_sequence_input
    puts "enter your move sequence as a series of coordinates, one per line (e.g. 2, 3 )"
    puts "end your selection by pressing 'e'"
    coords_arr = []
    while true
      input = gets.chomp
      return coords_arr if input.downcase == "e"
      coords_arr << input.split(/,?\s*/)
    end
  end
end

g = Game.new