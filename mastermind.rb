require 'string_colorizer'

# The Board class is used to print the board and display the guesser's former suggestions as they play.
class Board
  LIMITS = '|---------------------|'.freeze
  EMPTY_SPACE = '|                     |'.freeze
  SECRET_CODE_SIDE = '||--||--||--||--|     |'.freeze
  SUGGESTIONS_SIDE = '||--||--||--||--||----|'.freeze
  EMPTY_SUGGESTION = '||  ||  ||  ||  ||    |'.freeze

  def initialize
    @current_turn = 0
    @secret_code = ''
    @current_suggestion = ''
    @previous_suggestions = []
    @game_over = false
  end

  def print_board
    print_secret_code_side
    print_buffer
    print_suggestions
  end

  private

  def print_secret_code_side
    puts LIMITS
    if @game_over == false
      3.times { puts EMPTY_SPACE }
    else
      puts SECRET_CODE_SIDE
      puts @secret_code
      puts SECRET_CODE_SIDE
    end
    puts LIMITS
  end

  def print_buffer
    2.times { puts EMPTY_SPACE }
    puts LIMITS
  end

  def print_suggestions
    print_former_suggestions if @current_turn.positive?
    puts SUGGESTIONS_SIDE
    puts EMPTY_SUGGESTION
    puts SUGGESTIONS_SIDE
    puts LIMITS
  end

  def print_former_suggestions
    @previous_suggestions.each do |suggestion|
      puts SUGGESTIONS_SIDE
      puts suggestion
      puts SUGGESTIONS_SIDE
    end
  end
end

# The Rules class is used to determine the basic rules followed by the game and to check for victory conditions.
class Rules
  def initialize(creator, secret_code, turn_limit = 12)
    @creator = creator
    @secret_code = secret_code
    @turn_limit = turn_limit
  end
end

# The Player class is used to identify players and determine their IA if they're computer.
class Player
  @taken_role = ''

  class << self
    attr_accessor :taken_role
  end

  def initialize(human, name, role)
    @human = human
    @name = name
    @role = role
  end

  attr_reader :role

  def self.initialize_players
    player_one = initialize_player_one
    player_two = initialize_player_two
    [player_one, player_two]
  end

  class << self
    private

    def initialize_player_one
      player1_human = player_human?(0)
      player1_name = define_player_name(0, player1_human)
      player1_role = define_player_role(0)
      player1_human == true ? HumanPlayer.new(player1_human, player1_name, player1_role) : ComputerPlayer.new(player1_human, player1_name, player1_role)
    end

    def initialize_player_two
      player2_human = player_human?(1)
      player2_name = define_player_name(1, player2_human)
      player2_role = define_player_role(1)
      player2_human == true ? HumanPlayer.new(player2_human, player2_name, player2_role) : ComputerPlayer.new(player2_human, player2_name, player2_role)
    end

    def player_human?(id)
      case id
      when 0 then id = 'player 1'
      when 1 then id = 'player 2'
      end
      puts "Will #{id} be human? (y/n)"
      player_input = gets.chomp.downcase
      reject_player_input(player_input)
      player_input == 'y'
    end

    def define_player_name(id, human)
      if human == false
        'CPU'
      else
        case id
        when 0 then id = 'player 1'
        when 1 then id = 'player 2'
        end
        puts "What is your name, #{id}?"
        gets.chomp
      end
    end

    def define_player_role(id)
      if id.zero?
        puts 'Should player 1 be the code creator? (y/n)'
        player_input = gets.chomp.downcase
        reject_player_input(player_input)
        Player.taken_role =  player_input == 'y' ? 'creator' : 'guesser'
      else
        Player.taken_role == 'creator' ? 'guesser' : 'creator'
      end
    end

    def reject_player_input(player_input)
      until player_input == 'y' || player_input == 'n'
        puts 'Invalid answer!'
        player_input = gets.chomp.downcase
      end
    end
  end
end

# The ComputerPlayer class saves data about potential computer players and define their AI.
class ComputerPlayer < Player
  @computers_number = 1

  class << self
    attr_accessor :computers_number
  end

  def initialize(human, name, role)
    super
    @name += " #{ComputerPlayer.computers_number}"
    ComputerPlayer.computers_number += 1
  end

  def interrogate_creator
    secret_code = []
    4.times { secret_code.push(color_generator) }
    secret_code
  end

  private

  def color_generator
    case rand(6)
    when 0 then 'white'
    when 1 then 'black'
    when 2 then 'red'
    when 3 then 'yellow'
    when 4 then 'green'
    when 5 then 'cyan'
    end
  end
end

# The HumanPlayer class saves date about potential human players.
class HumanPlayer < Player
  def interrogate_creator
    instruct_creator
    secret_input = gets.chomp.downcase.split.delete_if { |element| %w[white black red yellow green cyan].include?(element) == false }
    secret_input = reject_secret_input(secret_input)
    puts "\e[H\e[2J"
    secret_input
  end

  private

  def instruct_creator
    puts "What will the secret code be, #{@name}?"
    puts 'Write four colors from the following list, separated with spaces:'
    print 'White '.colorize('white') + 'Black '.colorize('dark gray') + 'Red '.colorize('red') + 'Yellow '.colorize('yellow') + 'Green '.colorize('green') + 'Cyan'.colorize('cyan') + "\n"
    puts 'You can select the same color several times.'
  end

  def reject_secret_input(secret_input)
    until secret_input.length == 4
      puts 'Invalid answer!'
      secret_input = gets.chomp.downcase.split.delete_if { |element| %w[white black red yellow green cyan].include?(element) == false }
    end
    secret_input
  end
end

def play_game
  components_array = initialize_components
end

def initialize_components
  board = Board.new
  player_array = Player.initialize_players
  creator_index = player_array.index { |player| player.role == 'creator' }
  secret_code = player_array[creator_index].interrogate_creator
  ruleset = Rules.new(player_array[creator_index], secret_code)
  [board, player_array, ruleset]
end

play_game
