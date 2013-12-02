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
      puts @board
      begin
        start_piece = @board[*get_start_piece_input]
        if start_piece.nil? || start_piece.color != @current_player
          raise InvalidPieceSelectionError.new("must select a #{curr_player_name} piece") 
        end
      rescue InvalidPieceSelectionError => e
        puts e.message
        retry
      end

      begin
        move_sequence = get_move_sequence_input
        start_piece.perform_moves(move_sequence)
      rescue InvalidMoveError => e
        puts "invalid move!"
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
    unless coordinate =~ /^[0-7],?\s*[0-7]$/
      raise InvalidPieceSelectionError.new("must select a coordinate (e.g. 0, 0 )") 
    end
  end

  def get_move_sequence_input
    puts "enter your move sequence as a series of coordinates, one per line (e.g. 2, 3 )"
    puts "end your selection by pressing 'e'"
    coords_arr = []
    while true
      input = gets.chomp.map(&:to_i)
      return coords_arr if input.downcase == "e"
      check_valid_coordinate(input)
      coords_arr << input.split(/,?\s*/)
    end
    coords_arr
  end
end

g = Game.new
g.play