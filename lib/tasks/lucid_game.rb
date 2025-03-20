#!/usr/bin/ruby

################################################################################
# CONFIDENTIAL
#
# The contents of this and other files used for interviews are confidential, and
# should not be shared outside of Lucid Software. Discussing or otherwise distributing
# the problems or questions used in your interviews may cause any future interviews
# to be cancelled or any potential offers to be revoked.
################################################################################

# Part 1:
# Sort a list of people by age ascending.  For person's with
# the same age, sort ascending alphabetically by name

# For example:
# Person("Bob", 28)
# Person("Jill", 31)
# Person("Andy", 32)
# Person("Sam", 32)

Person = Struct.new(:name, :age)

PEOPLE = [
  Person.new("Matt", 50),
  Person.new("Lulu", 5),
  Person.new("Laura", 49),
  Person.new("Abby", 50),
  Person.new("Chris", 1),
  Person.new("Jen", 35),
  Person.new("Flavia", 12),
  Person.new("Alicia", 21),
  Person.new("Greg", 78),
  Person.new("Boris", 9)
].freeze

def sorted_people
  PEOPLE.sort do |a, b|
    if a.age < b.age
      -1
    elsif a.age == b.age && [ a.name, b.name ].sort == [ a.name, b.name ]
      0
    else
      1
    end
  end
end

# if __FILE__ == $0
#   puts 'Part 1:'
#   sorted_people.each do |p|
#     puts p
#   end
#   puts
# end

# Part 2:
#   Given a string with a comma separated list of sock colors, determine how
# many pairs of each color sock can be made, output the number of pairs you
# can make that match
#   for example:
#       `red,blue,red,green,green,red`
#   would yield the following in the output:
#   Sock Pairs: 2

def sock_pairs(socks)
  socks.split(",")
       .tally
       .values
       .sum { |count| count / 2 }
end

# Examples of using the pair count function.
# tests = [
#     ([], 0),
#     (["red"], 0),
#     (["red", "red"], 1),
#     (["red", "blue"], 0),
#     (["red", "red", "red"], 1),
#     (["red", "blue", "red", "green", "green", "red"], 2),
#     (
#         [
#             "red",
#             "blue",
#             "purple",
#             "red",
#             "green",
#             "green",
#             "purple",
#             "red",
#             "yellow",
#             "red",
#             "red",
#             "yellow",
#             "red",
#             "purple"
#         ],
#         6
#     ),
# ]

# if __FILE__ == $0
#   puts 'Part 2:'
#   puts 'Sock Pairs: ' + String(sock_pairs("red,blue,purple,red,green,green,purple,red,yellow,red,red,yellow,red,purple"))
#   puts
# end

# Part 3: Implement the board game Othello/Reversi on the following board.
#
#     Othello is a game played on an 8x8 board between two players. There are sixty-four identical game pieces
#     called disks, which are light on one side and dark on the other. Players take turns placing disks on the
#     board with their assigned color facing up. During a play, any disks of the opponent's color that are in a
#     straight line and bounded by the disk just placed and another disk of the current player's color are turned
#     over to the current player's color. The object of the game is to have the majority of disks turned to display
#     your color when the last playable empty square is filled.
#
#     The game begins with four disks placed in a square in the middle of the grid, two facing white-side-up, two
#     dark-side-up, so that the same-colored disks are on a diagonal
#
#       a b c d e f g h
#     1
#     2
#     3
#     4       W B
#     5       B W
#     6
#     7
#     8
#
#     Dark must place a piece (dark-side-up) on the board and so that there exists at least one straight
#     (horizontal, vertical, or diagonal) occupied line between the new piece and another dark piece, with one or
#     more contiguous light pieces between them. For move one, dark has four options shown by Xs below:
#
#       a b c d e f g h
#     1
#     2
#     3       X
#     4     X W B
#     5       B W X
#     6         X
#     7
#     8
#
#     Play always alternates. After placing a dark disk, dark turns over (flips to dark, captures) the single disk
#     (or chain of light disks) on the line between the new piece and an anchoring dark piece. A valid move is one
#     where at least one piece is reversed (flipped over).
#
#     If dark decided to put a piece in the topmost location, one piece gets turned over, so that the board appears thus:
#
#       a b c d e f g h
#     1
#     2
#     3       B
#     4       B B
#     5       B W
#     6
#     7
#     8
#
#     Now light plays. This player operates under the same rules, with the roles reversed: light lays down a light
#     piece, causing a dark piece to flip. Possibilities at this time appear thus (indicated by Ys):
#
#       a b c d e f g h
#     1
#     2
#     3     Y B Y
#     4       B B
#     5     Y B W
#     6
#     7
#     8
#
#     Light takes the bottom left option and reverses one piece:
#
#       a b c d e f g h
#     1
#     2
#     3       B
#     4       B B
#     5     W W W
#     6
#     7
#     8
#
#     Pieces may be captured in more than one direction. For example, if light places a piece at e3, the dark
#     pieces at d4 and e4 are both captured:
#
#       a b c d e f g h               a b c d e f g h
#     1                             1
#     2                             2
#     3       B               ==>   3       B W
#     4       B B                   4       W W
#     5     W W W                   5     W W W
#     6                             6
#     7                             7
#     8                             8
#
#     Players take alternate turns. If one player can not make a valid move, play passes back to the other player.
#     When neither player can move, the game ends. This occurs when the grid has filled up or when neither player
#     can legally place a piece in any of the remaining squares. This means the game may end before the grid is
#     completely filled.
#
#     Game rules:
#       https://en.wikipedia.org/wiki/Reversi#Rules
#     Online game with valid move highlighting:
#       https://www.topster.net/reversi/zweispieler.html

Coordinate = Struct.new(:x, :y)

class Othello
  COLUMNS = "abcdefgh".freeze

  def initialize
    @spaces = Array.new(8) { Array.new(8) }
    @spaces[3][3] = :black
    @spaces[3][4] = :white
    @spaces[4][3] = :white
    @spaces[4][4] = :black

    @current_turn_is_black = true
    @coords = ""
    @endgame_watch = false

    @format = nil
  end

  def render
    print " "
    ("a".."h").each { |x| print " ", x }
    puts
    @spaces.each_with_index do |row, y|
      print y + 1
      row.each do |entry|
        print " "
        print entry.nil? ? " " : entry[0].upcase
      end
      puts
    end
  end

  def choose_format
    puts "Choose a format: 1: human vs human, 2: human vs computer, 3: computer vs computer."
    format_str = gets.strip
    abort if format_str == "exit"

    @format = case format_str
    when "1" then :human_v_human
    when "2" then :human_v_computer
    when "3" then :computer_v_computer
    else
      puts "Invalid format: #{@format_str}."
      choose_format
    end

    puts "You chose #{format_str}: #{@format}."
    puts ""
  end

  def get_move_input
    @coords = gets.strip
    abort if @coords == "exit"

    is_input_valid = @coords.match?(/^[a-hA-H][1-8]$/)

    if is_input_valid
      row, col = @coords.chars
      x = [ 0, [ 7, row.ord - "a".ord ].min ].max
      y = [ 0, [ 7, col.ord - "1".ord ].min ].max
      Coordinate.new(x, y)
    else
      :invalid_input
    end

  rescue => e
    puts e
    retry
  end

  def toggle_player
    @current_turn_is_black = !@current_turn_is_black
  end

  def current_color
    @current_turn_is_black ? :black : :white
  end

  def opponent_color
    @current_turn_is_black ? :white : :black
  end

  def space_occupied?(coordinate)
    !@spaces[coordinate.y][coordinate.x].nil?
  end

  class PotentialPlay
    ANGLES_TO_CHECK = [
      :horiz_left,
      :horiz_right,
      :vert_up,
      :vert_down,
      :diag_pos_up,
      :diag_pos_down,
      :diag_neg_up,
      :diag_neg_down
    ]

    attr_reader :enclosed_opponents_count, :transformed_spaces, :x, :y

    def initialize(spaces, placed_x, placed_y, color)
      @placed_x = placed_x
      @placed_y = placed_y
      @x = placed_x
      @y = placed_y
      @color = color

      @transformed_spaces = ::Marshal.load(::Marshal.dump(spaces))
      @transformed_spaces[@placed_y][@placed_x] = @color

      @is_valid = false
      @enclosed_opponents_count = 0
    end

    def check
      ANGLES_TO_CHECK.each do |angle|
        checker = AngleChecker.new(@transformed_spaces, @placed_x, @placed_y, @color, angle)
        checker.check

        if checker.has_enclosure?
          @is_valid = true
          @transformed_spaces = checker.transformed_spaces
          @enclosed_opponents_count += checker.enclosed_opponents_count
        end
      end
    end

    def valid?
      @is_valid
    end
  end

  class AngleChecker
    attr_reader :farthest_enclosing_x, :farthest_enclosing_y, :enclosed_opponents_count, :transformed_spaces

    def initialize(spaces, idx_x, idx_y, color, movement)
      @transformed_spaces = spaces.dup
      @placed_x = idx_x
      @placed_y = idx_y
      @idx_x = idx_x
      @idx_y = idx_y
      @color = color
      @opponent_color = color == :black ? :white : :black
      @movement = movement

      @has_opponent = false
      @has_enclosure = false
      @farthest_enclosing_x = nil
      @farthest_enclosing_y = nil
      @potentially_enclosed_opponents_count = 0
      @enclosed_opponents_count = 0
      @has_opponent_color = false
      @stopped_by_empty_space = false
    end

    def keep_checking?
      @idx_x >= 0 && @idx_x <= 7 && @idx_y >= 0 && @idx_y <= 7
    end

    def move_one_space
      case @movement
      when :horiz_left
        @idx_x -= 1
      when :horiz_right
        @idx_x += 1
      when :vert_up
        @idx_y -= 1
      when :vert_down
        @idx_y += 1
      when :diag_pos_up
        @idx_x += 1
        @idx_y -= 1
      when :diag_pos_down
        @idx_x -= 1
        @idx_y += 1
      when :diag_neg_up
        @idx_x -= 1
        @idx_y -= 1
      when :diag_neg_down
        @idx_x += 1
        @idx_y += 1
      end
    end

    def has_enclosure?
      @has_enclosure
    end

    def keep_transforming?
      case @movement
      when :horiz_left     then @idx_x >= @farthest_enclosing_x
      when :horiz_right    then @idx_x <= @farthest_enclosing_x
      when :vert_up        then @idx_y >= @farthest_enclosing_y
      when :vert_down      then @idx_y <= @farthest_enclosing_y
      when :diag_pos_up    then @idx_y >= @farthest_enclosing_y && @idx_x <= @farthest_enclosing_x
      when :diag_pos_down  then @idx_y <= @farthest_enclosing_y && @idx_x >= @farthest_enclosing_x
      when :diag_neg_up    then @idx_y >= @farthest_enclosing_y && @idx_x >= @farthest_enclosing_x
      when :diag_neg_down  then @idx_y <= @farthest_enclosing_y && @idx_x <= @farthest_enclosing_x
      end
    end

    def transform
      @idx_x = @placed_x
      @idx_y = @placed_y

      while keep_transforming?
        @transformed_spaces[@idx_y][@idx_x] = @color
        move_one_space
      end
    end

    def check
      while keep_checking?
        color_of_current_space = @transformed_spaces[@idx_y][@idx_x]

        if color_of_current_space.nil?
          @stopped_by_empty_space = true
          break
        end

        if color_of_current_space == @opponent_color
          @has_opponent_color = true
          @potentially_enclosed_opponents_count += 1
        end

        if @has_opponent_color && color_of_current_space == @color
          @has_enclosure = true
          @farthest_enclosing_x = @idx_x
          @farthest_enclosing_y = @idx_y
          @enclosed_opponents_count += @potentially_enclosed_opponents_count
          @potentially_enclosed_opponents_count = 0
          @has_opponent_color = false
        end

        move_one_space
      end

      transform if @has_enclosure
    end
  end

  # +==========+
  # TODO: Implement this function.
  # A fully-working solution must do the following:
  #   1. Alternate turns between WHITE and BLACK.
  #   2. Reverse pieces correctly
  #   3. Only allow valid moves (on empty square and reverses 1+ enemy pieces)
  #   4. Check for no valid moves for game end and declare the winner
  #
  # Extra credit: Have one human play against a computer that always makes a legal move.
  # Extra extra credit: Have the computer make at least somewhat strategic moves rather than just some legal
  # move.
  def play
    choose_format

    loop do
      render()
      puts "#{current_color}'s move:"

      if (@format == :human_v_human) || (@format == :human_v_computer && current_color == :black)
        coordinate = get_move_input()

        if coordinate == :invalid_input
          puts "Invalid input: #{@coords}. Please try again."
          next
        end

        if space_occupied?(coordinate)
          puts "Space #{@coords} is occupied. Please try again."
          next
        end
      end

      possible_plays = []
      @spaces.each_with_index do |row, y|
        row.each_with_index do |entry, x|
          next unless entry.nil?

          potential_play = PotentialPlay.new(@spaces, x, y, current_color)
          potential_play.check

          if potential_play.valid?
            possible_plays << potential_play
          end
        end
      end

      if possible_plays.empty?
        if @endgame_watch == true
          puts "No valid moves for #{current_color}."
          puts ""
          puts "================================"
          puts "Game over!"
          puts "================================"
          puts ""
          puts "Final board:"
          render()
          puts ""
          white_score = @spaces.flatten.count { |space| space == :white }
          black_score = @spaces.flatten.count { |space| space == :black }
          puts "Scores:"
          puts "Black: #{black_score}"
          puts "White: #{white_score}"
          puts ""
          if black_score > white_score
            puts "Black wins!"
          elsif white_score > black_score
            puts "White wins!"
          else
            puts "It's a tie!"
          end
          break
        else
          @endgame_watch = true
          puts "No valid moves for #{current_color}."
          puts ""
          toggle_player
          next
        end
      else
        @endgame_watch = false
      end

      if @format == :computer_v_computer || (@format == :human_v_computer && current_color == :white)
        max_score = possible_plays.max_by(&:enclosed_opponents_count)&.enclosed_opponents_count
        selected_play = possible_plays.select { |valid_potential_play| valid_potential_play.enclosed_opponents_count == max_score }.sample if max_score
      else
        selected_play = PotentialPlay.new(@spaces, coordinate.x, coordinate.y, current_color)
        selected_play.check

        unless selected_play.valid?
          puts "Position #{@coords} is not playable by #{current_color}. Please try again."
          puts ""
          next
        end
      end

      output_coords = COLUMNS[selected_play.x] + (selected_play.y + 1).to_s
      puts output_coords
      @spaces = selected_play.transformed_spaces
      puts ""
      puts "--------------------------------"
      puts "#{current_color} placed at #{output_coords} and flipped #{selected_play.enclosed_opponents_count} #{opponent_color}s."
      puts "Black: #{@spaces.flatten.count { |space| space == :black } }"
      puts "White: #{@spaces.flatten.count { |space| space == :white } }"
      puts ""

      toggle_player
    end
  end
end

if __FILE__ == $0
  puts "Part 3:"
  Othello.new.play
  puts
end
