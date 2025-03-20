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
  def initialize
    @spaces = Array.new(8) { Array.new(8) }
    @spaces[3][3] = :black
    @spaces[3][4] = :white
    @spaces[4][3] = :white
    @spaces[4][4] = :black

    # @spaces[0][0] = :a
    # @spaces[0][1] = :b
    # @spaces[0][2] = :c
    # @spaces[0][3] = :d
    # @spaces[0][4] = :e
    # @spaces[0][5] = :f
    # @spaces[0][6] = :g
    # @spaces[0][7] = :h

    # @spaces[7][0] = :a
    # @spaces[7][1] = :b
    # @spaces[7][2] = :c
    # @spaces[7][3] = :d
    # @spaces[7][4] = :e
    # @spaces[7][5] = :f
    # @spaces[7][6] = :g
    # @spaces[7][7] = :h

    @current_turn_is_black = true
    @coords = ""
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

  def get_move_input
    @coords = gets.strip
    abort if @coords == "exit"

    row, col = @coords.chars
    x = [ 0, [ 7, row.ord - "a".ord ].min ].max
    y = [ 0, [ 7, col.ord - "1".ord ].min ].max
    Coordinate.new(x, y)
  rescue => e
    puts e
    retry
  end

  def toggle_current_player
    @current_turn_is_black = !@current_turn_is_black
  end

  def current_player_color
    @current_turn_is_black ? :black : :white
  end

  def non_current_player_color
    @current_turn_is_black ? :white : :black
  end

  def move_does_not_reverse_any_tokens?(coordinate)
    @spaces[coordinate.y][coordinate.x] = current_player_color

    # horizontal
    # horizontal_pattern = @spaces[coordinate.y].join("")
    # puts horizontal_pattern
    # aaa = horizontal_pattern =~ /#{current_player_color}.*#{current_player_color}/
    # aaa = horizontal_pattern =~ /black.*white/
    # puts "aaa: #{aaa}"

    # puts @spaces[coordinate.y][coordinate.x]

    # vertical
    # Diagonal positive
    # Diagonal negative

    @spaces[coordinate.y][coordinate.x] = nil
  end

  def space_occupied?(coordinate)
    !@spaces[coordinate.y][coordinate.x].nil?
  end

  # PossiblePlay class evaluates all the possibilities for a single placement.
  # It has methods to determine if a move is valid and how many opponents will flip.
  # It instantiates 8 Checkers, one for each direction.
  class PossiblePlay
    def initialize(spaces, idx_x, idx_y)
      @spaces = spaces.dup
      @idx_x = idx_x
      @idx_y = idx_y
      @checkers = [
        Checker.new(spaces, idx_x, idx_y),
        Checker.new(spaces, idx_x, idx_y),
        Checker.new(spaces, idx_x, idx_y),
        Checker.new(spaces, idx_x, idx_y),
        Checker.new(spaces, idx_x, idx_y),
        Checker.new(spaces, idx_x, idx_y),
        Checker.new(spaces, idx_x, idx_y),
        Checker.new(spaces, idx_x, idx_y)
      ]
    end
  end

  # Checker class evaluates a play in one direction, eg, horiz_left, horiz_right, vert_up,
  # vert_down, diag_pos_up, diag_pos_down, diag_neg_up, and diag_neg_down. It has methods
  # to determine if the move is valid (for this direction), how many opponents will flip,
  # and which coordinates should flip (but something else does the flipping).
  class Checker
    attr_reader :farthest_enclosing_x, :farthest_enclosing_y, :enclosed_opponents_count

    def initialize(spaces, idx_x, idx_y, color, movement)
      @spaces = spaces.dup
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

    def transform
      @idx_x = @placed_x
      @idx_y = @placed_y

      # while horiz_left_edit_idx > farthest_left_enclosing_x
      # while horiz_right_edit_idx <= farthest_right_enclosing_x
      # while vert_up_edit_idx >= farthest_up_enclosing_y
      # while vert_down_edit_idx <= farthest_down_enclosing_y
      # while diag_pos_up_y_edit_idx >= farthest_up_enclosing_y

      # while horiz_left_edit_idx > farthest_left_enclosing_x
      # while horiz_right_edit_idx <= farthest_right_enclosing_x
      # while vert_up_edit_idx >= farthest_up_enclosing_y
      # while vert_down_edit_idx <= farthest_down_enclosing_y
      # while diag_pos_up_y_edit_idx >= farthest_up_enclosing_y

      while @idx_x > @farthest_enclosing_x && @idx_y > @farthest_enclosing_y
        @transformed_spaces[@idx_y][@idx_x] = @color
        move_one_space
      end
    end

    def check
      while keep_checking?
        color_of_current_space = @spaces[@idx_y][@idx_x]

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
    loop do
      render()
      puts "#{current_player_color}'s move:"
      coordinate = get_move_input()

      if space_occupied?(coordinate)
        puts "Space #{@coords} is occupied. Please try again."
        next
      end

      # if move_does_not_reverse_any_tokens?(coordinate)
      #   puts "Move does not reverse any opponent tokens. Please try again."
      #   next
      # end

      @spaces[coordinate.y][coordinate.x] = current_player_color

      puts "---------"
      puts "position: #{@coords}"
      puts "current player: #{current_player_color}"

      is_valid_move = false

      # # horiz left
      # horiz_left_idx = coordinate.x
      # has_non_current_color = false
      # has_enclosing_current_color = false
      # farthest_left_enclosing_x = nil
      # potentially_enclosed_opponents_count = 0
      # enclosed_opponents_count = 0

      # while horiz_left_idx >= 0
      #   val = @spaces[coordinate.y][horiz_left_idx]
      #   break if val.nil?

      #   if val == non_current_player_color
      #     has_non_current_color = true
      #     potentially_enclosed_opponents_count += 1
      #   end

      #   if has_non_current_color && val == current_player_color
      #     has_enclosing_current_color = true
      #     farthest_left_enclosing_x = horiz_left_idx
      #     enclosed_opponents_count += potentially_enclosed_opponents_count
      #     potentially_enclosed_opponents_count = 0
      #   end

      #   horiz_left_idx -= 1
      # end

      # if has_enclosing_current_color
      #   is_valid_move = true
      #   horiz_left_edit_idx = coordinate.x

      #   while horiz_left_edit_idx > farthest_left_enclosing_x
      #     @spaces[coordinate.y][horiz_left_edit_idx] = current_player_color
      #     horiz_left_edit_idx -= 1
      #   end
      # end

      horiz_left = Checker.new(@spaces, coordinate.x, coordinate.y, current_player_color, :horiz_left)
      horiz_left.check

      if horiz_left.has_enclosure?
        is_valid_move = true
        horiz_left_edit_idx = coordinate.x

        while horiz_left_edit_idx > horiz_left.farthest_enclosing_x
          @spaces[coordinate.y][horiz_left_edit_idx] = current_player_color
          horiz_left_edit_idx -= 1
        end
      end

      # horiz right
      horiz_right_idx = coordinate.x
      has_non_current_color = false
      has_enclosing_current_color = false
      farthest_right_enclosing_x = nil
      potentially_enclosed_opponents_count = 0
      enclosed_opponents_count = 0

      while horiz_right_idx <= 7
        val = @spaces[coordinate.y][horiz_right_idx]
        break if val.nil?

        if val == non_current_player_color
          has_non_current_color = true
          potentially_enclosed_opponents_count += 1
        end

        if has_non_current_color && val == current_player_color
          has_enclosing_current_color = true
          farthest_right_enclosing_x = horiz_right_idx
          enclosed_opponents_count += potentially_enclosed_opponents_count
          potentially_enclosed_opponents_count = 0
        end

        horiz_right_idx += 1
      end

      if has_enclosing_current_color
        is_valid_move = true
        horiz_right_edit_idx = coordinate.x

        while horiz_right_edit_idx <= farthest_right_enclosing_x
          @spaces[coordinate.y][horiz_right_edit_idx] = current_player_color
          horiz_right_edit_idx += 1
        end
      end

      # vert up
      vert_up_idx = coordinate.y
      has_non_current_color = false
      has_enclosing_current_color = false
      farthest_up_enclosing_y = nil
      potentially_enclosed_opponents_count = 0
      enclosed_opponents_count = 0

      while vert_up_idx >= 0
        val = @spaces[vert_up_idx][coordinate.x]
        break if val.nil?

        if val == non_current_player_color
          has_non_current_color = true
          potentially_enclosed_opponents_count += 1
        end

        if has_non_current_color && val == current_player_color
          has_enclosing_current_color = true
          farthest_up_enclosing_y = vert_up_idx
          enclosed_opponents_count += potentially_enclosed_opponents_count
          potentially_enclosed_opponents_count = 0
        end

        vert_up_idx -= 1
      end

      if has_enclosing_current_color
        is_valid_move = true
        vert_up_edit_idx = coordinate.y

        while vert_up_edit_idx >= farthest_up_enclosing_y
          @spaces[vert_up_edit_idx][coordinate.x] = current_player_color
          vert_up_edit_idx -= 1
        end
      end

      # vert down
      vert_down_idx = coordinate.y
      has_non_current_color = false
      has_enclosing_current_color = false
      farthest_down_enclosing_y = nil
      potentially_enclosed_opponents_count = 0
      enclosed_opponents_count = 0

      while vert_down_idx <= 7
        val = @spaces[vert_down_idx][coordinate.x]
        break if val.nil?

        if val == non_current_player_color
          has_non_current_color = true
          potentially_enclosed_opponents_count += 1
        end

        if has_non_current_color && val == current_player_color
          has_enclosing_current_color = true
          farthest_down_enclosing_y = vert_down_idx
          enclosed_opponents_count += potentially_enclosed_opponents_count
          potentially_enclosed_opponents_count = 0
        end

        vert_down_idx += 1
      end

      if has_enclosing_current_color
        is_valid_move = true
        vert_down_edit_idx = coordinate.y

        while vert_down_edit_idx <= farthest_down_enclosing_y
          @spaces[vert_down_edit_idx][coordinate.x] = current_player_color
          vert_down_edit_idx += 1
        end
      end

      # diag pos up
      diag_pos_up_y_idx = coordinate.y
      diag_pos_up_x_idx = coordinate.x

      has_non_current_color = false
      has_enclosing_current_color = false
      farthest_up_enclosing_y = nil
      potentially_enclosed_opponents_count = 0
      enclosed_opponents_count = 0

      while diag_pos_up_y_idx >= 0 && diag_pos_up_x_idx <= 7
        val = @spaces[diag_pos_up_y_idx][diag_pos_up_x_idx]
        break if val.nil?

        if val == non_current_player_color
          has_non_current_color = true
          potentially_enclosed_opponents_count += 1
        end

        if has_non_current_color && val == current_player_color
          has_enclosing_current_color = true
          farthest_up_enclosing_y = diag_pos_up_y_idx
          enclosed_opponents_count += potentially_enclosed_opponents_count
          potentially_enclosed_opponents_count = 0
        end

        diag_pos_up_y_idx -= 1
        diag_pos_up_x_idx += 1
      end

      if has_enclosing_current_color
        is_valid_move = true
        diag_pos_up_y_edit_idx = coordinate.y
        diag_pos_up_x_edit_idx = coordinate.x

        while diag_pos_up_y_edit_idx >= farthest_up_enclosing_y
          @spaces[diag_pos_up_y_edit_idx][diag_pos_up_x_edit_idx] = current_player_color
          diag_pos_up_y_edit_idx -= 1
          diag_pos_up_x_edit_idx += 1
        end
      end

      # diag pos down
      # diag neg up
      # diag neg down

      @spaces[coordinate.y][coordinate.x] = nil unless is_valid_move


      # vertical = @spaces.map { |row| row[coordinate.x] }
      # puts "vertical: #{vertical}"

      # diag_neg_d = [ 0, coordinate.y - coordinate.x ].max
      # diag_neg_h = [ 0, coordinate.x - coordinate.y ].max
      # diag_neg = []
      # diag_neg_coords = []

      # while diag_neg_d < 8 && diag_neg_h < 8
      #   diag_neg << @spaces[diag_neg_d][diag_neg_h]
      #   diag_neg_coords << [ diag_neg_d, diag_neg_h ]
      #   diag_neg_d += 1
      #   diag_neg_h += 1
      # end
      # puts "diag neg: #{diag_neg}"
      # puts diag_neg.join(",")

      # diag_pos_d = [ 7, coordinate.y + coordinate.x ].min
      # diag_pos_h = [ 0, coordinate.x - (7 - coordinate.y) ].max
      # diag_pos = []
      # diag_pos_coords = []

      # while diag_pos_d >= 0 && diag_pos_h < 8
      #   diag_pos << @spaces[diag_pos_d][diag_pos_h]
      #   diag_pos_coords << [ diag_pos_d, diag_pos_h ]
      #   diag_pos_d -= 1
      #   diag_pos_h += 1
      # end
      # puts "diag pos: #{diag_pos}"
      # puts "========="

      # # TODO: gotta handle BWB --> WBWB --> WWWB
      # # Currently we see WBWB and reject it because it doesn't start and end with W

      # horizontal_str = horizontal.join(",")
      # vertical_str = vertical.join(",")
      # diag_neg_str = diag_neg.join(",")
      # diag_pos_str = diag_pos.join(",")

      # cpc = current_player_color
      # ncc = non_current_player_color

      # aaa = /^,*#{cpc},+#{ncc}(?:,+#{cpc}|,+#{ncc})*,+#{cpc},*$/

      # # puts horizontal_str
      # @valid_horizontal = horizontal_str =~ aaa
      # # puts vertical_str
      # @valid_vertical = vertical_str =~ aaa
      # # puts diag_neg_str
      # @valid_diag_neg = diag_neg_str =~ aaa
      # # puts diag_pos_str
      # @valid_diag_pos = diag_pos_str =~ aaa

      # puts @valid_horizontal
      # puts @valid_vertical
      # puts @valid_diag_neg
      # puts @valid_diag_pos

      # if @valid_horizontal || @valid_vertical || @valid_diag_neg || @valid_diag_pos
      #   puts "Valid move"

      #   if @valid_horizontal
      #     @spaces[coordinate.y].each_with_index do |space_color, i|
      #       next if space_color.nil?

      #       @spaces[coordinate.y][i] = current_player_color
      #     end
      #   end

      #   if @valid_diag_pos
      #     diag_pos_coords.each do |coord|
      #       if @spaces[coord[0]][coord[1]] == non_current_player_color
      #         @spaces[coord[0]][coord[1]] = current_player_color
      #       end
      #     end
      #   end

      #   if @valid_diag_neg
      #     diag_neg_coords.each do |coord|
      #       @spaces[coord[0]][coord[1]] = current_player_color
      #     end
      #   end
      # else
      #   puts "Invalid move"
      #   @spaces[coordinate.y][coordinate.x] = nil
      #   next
      # end

      toggle_current_player
    end
  end
end

if __FILE__ == $0
  puts "Part 3:"
  Othello.new.play
  puts
end
