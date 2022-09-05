# frozen_string_literal: false

require 'io/console'
require_relative 'string_colorizer'

# The Board class is used to print the board and display the guesser's former suggestions as they play.
class Board
  LIMITS = '|---------------------|'.freeze
  EMPTY_SPACE = '|                     |'.freeze
  SECRET_CODE_SIDE = '||--||--||--||--|     |'.freeze
  SUGGESTIONS_SIDE = '||--||--||--||--||----|'.freeze
  EMPTY_SUGGESTION = '||  ||  ||  ||  ||    |'.freeze

  def initialize(secret_code)
    @current_turn = 1
    @secret_code = secret_code
    @current_suggestion = {}
    @previous_suggestions = []
    @game_over = false
  end

  attr_reader :current_turn, :secret_code, :current_suggestion, :previous_suggestions, :game_over

  def print_board
    print_secret_code_side
    print_buffer
    print_suggestion_side
  end

  def retrieve_suggestion(suggestion)
    @current_suggestion["suggestion n°#{@current_turn}"] = suggestion
  end

  def retrieve_feedback(feedback)
    @current_suggestion['feedback'] = feedback
    @game_over = @current_suggestion["suggestion n°#{@current_turn}"] == @secret_code
  end

  def reset_board_for_next_suggestion
    @previous_suggestions.push(@current_suggestion.dup)
    @current_suggestion.clear
    @current_turn += 1
  end

  private

  def print_secret_code_side
    puts LIMITS
    if @game_over == false
      3.times { puts EMPTY_SPACE }
    else
      puts SECRET_CODE_SIDE
      print_secret_code
      puts SECRET_CODE_SIDE
    end
    puts LIMITS
  end

  def print_buffer
    2.times { puts EMPTY_SPACE }
    puts LIMITS
  end

  def print_suggestion_side
    print_former_suggestions if @current_turn > 1
    puts SUGGESTIONS_SIDE
    puts EMPTY_SUGGESTION if @current_suggestion == {}
    print_filled_line if @current_suggestion != {}
    puts SUGGESTIONS_SIDE
    puts LIMITS
  end

  def print_former_suggestions
    turn_considered = @current_turn - 1
    @previous_suggestions.reverse.each do |suggestion|
      puts SUGGESTIONS_SIDE
      print_individual_former_suggestion(suggestion, turn_considered)
      puts SUGGESTIONS_SIDE
      turn_considered -= 1
    end
    puts LIMITS
  end

  def print_filled_line
    suggestion_index = 0
    ['||', '  ', '||', '  ', '||', '  ', '||', '  ', '||', '    ', '|'].each do |item|
      print item if ['||', '|'].include?(item)
      if item == '  '
        print item.colorize_background(@current_suggestion["suggestion n°#{@current_turn}"][suggestion_index])
        suggestion_index += 1
      end
      @current_suggestion['feedback'].each { |symbol| print symbol } if item == '    '
    end
    print "\n"
  end

  def print_individual_former_suggestion(suggestion, turn_considered)
    suggestion_index = 0
    ['||', '  ', '||', '  ', '||', '  ', '||', '  ', '||', '    ', '|'].each do |item|
      print item if ['||', '|'].include?(item)
      if item == '  '
        print item.colorize_background(suggestion["suggestion n°#{turn_considered}"][suggestion_index])
        suggestion_index += 1
      end
      suggestion['feedback'].each { |symbol| print symbol } if item == '    '
    end
    print "\n"
  end

  def print_secret_code
    suggestion_index = 0
    ['||', '  ', '||', '  ', '||', '  ', '||', '  ', '|', '     ', '|'].each do |item|
      print item if ['||', '|', '     '].include?(item)
      if item == '  '
        print item.colorize_background(@current_suggestion["suggestion n°#{@current_turn}"][suggestion_index])
        suggestion_index += 1
      end
    end
    print "\n"
  end
end

# The Rules class is used to determine the basic rules followed by the game and to check for victory conditions.
class Rules
  def initialize(creator, turn_limit = 12)
    @creator = creator
    @turn_limit = turn_limit
  end

  def compare_current_suggestion(current_suggestion, board)
    1 if current_suggestion == board.secret_code
    perfect_matches = check_for_exact_matches(current_suggestion, board)
    partial_matches = check_for_partial_matches(current_suggestion, board)
    assign_matching_symbols(perfect_matches, partial_matches)
  end

  def print_text_feedback(board)
    feedback = board.current_suggestion['feedback']
    puts 'None of your guesses matches the secret code!' if feedback.all?('x')
    print_text_perfect_matches(feedback)
    print_text_partial_matches(feedback)
  end

  private

  def check_for_exact_matches(current_suggestion, board)
    matches = 0
    current_suggestion.each_index do |index|
      matches += 1 if current_suggestion[index] == board.secret_code[index]
    end
    matches
  end

  def check_for_partial_matches(current_suggestion, board)
    temp_secret_code = board.secret_code.dup
    matches = 0
    place_dummy_colors_for_exact_matches(current_suggestion, temp_secret_code)
    current_suggestion.each_index do |index|
      if current_suggestion[index] != board.secret_code[index] && temp_secret_code.include?(current_suggestion[index])
        matches += 1
        temp_secret_code.delete_at(temp_secret_code.index(current_suggestion[index]))
      end
    end
    matches
  end

  def place_dummy_colors_for_exact_matches(current_suggestion, temp_secret_code)
    current_suggestion.each_index do |index|
      temp_secret_code[index] = 'exact' if current_suggestion[index] == temp_secret_code[index]
    end
  end

  def assign_matching_symbols(perfect_matches, partial_matches)
    symbol_array = []
    perfect_matches.times { symbol_array.push('o'.colorize('red')) }
    partial_matches.times { symbol_array.push('o') }
    symbol_array.push('x') until symbol_array.length == 4
    symbol_array
  end

  def print_text_perfect_matches(feedback)
    if feedback.count('o'.colorize('red')).zero? && feedback.all?('x') == false
      puts 'None of your guesses perfectly matches the secret code!'
    elsif feedback.count('o'.colorize('red')) == 1
      puts 'One of your guesses perfectly matches the secret code!'
    elsif feedback.all?('o'.colorize('red'))
      puts 'Congratulations, you guessed the secret code!'
    else
      puts "#{feedback.count('o'.colorize('red'))} of your guesses perfectly match the secret code!"
    end
  end

  def print_text_partial_matches(feedback)
    if feedback.count('o') == 1
      puts 'One of your guesses is in the secret code, but in a different place.'
    elsif feedback.count('o') > 1
      puts "#{feedback.count('o')} of your guesses are in the secret code, but in different places."
    end
  end
end

# The Player class is used to query for each player's data, and to initialize them.
class Player
  @taken_role = ''

  class << self
    attr_accessor :taken_role
  end

  def initialize(human, name, role)
    @human = human
    @name = name
    @role = role
    @score = 0
  end

  attr_reader :role

  def self.initialize_players
    player_one = initialize_player_one
    player_two = initialize_player_two
    [player_one, player_two]
  end

  def calculate_score(board)
    @score += 1 if board.game_over == false
  end

  class << self
    private

    def initialize_player_one
      player1_human = player_human?(0)
      player1_name = define_player_name(0, player1_human)
      player1_role = define_player_role(0)
      if player1_human == true
        HumanPlayer.new(player1_human, player1_name, player1_role)
      else
        ComputerPlayer.new(player1_human, player1_name, player1_role)
      end
    end

    def initialize_player_two
      player2_human = player_human?(1)
      player2_name = define_player_name(1, player2_human)
      player2_role = define_player_role(1)
      if player2_human == true
        HumanPlayer.new(player2_human, player2_name, player2_role)
      else
        ComputerPlayer.new(player2_human, player2_name, player2_role)
      end
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
      until %w[y n].include?(player_input)
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
    @guesses_set = generate_guesses_list
    @was_creator = 2
    @last_move = []
  end

  attr_reader :name, :score
  attr_accessor :guesses_set, :was_creator, :role, :last_move

  def interrogate_creator
    secret_code = []
    4.times { secret_code.push(color_generator) }
    secret_code
  end

  def request_suggestion_from_player(board)
    move = if board.current_turn == 1
             perform_move1
           else
             perform_move2(board)
           end
    @last_move = move
  end

  private

  def color_generator
    case rand(6)
    when 0 then 'white'
    when 1 then 'blue'
    when 2 then 'red'
    when 3 then 'yellow'
    when 4 then 'green'
    when 5 then 'cyan'
    end
  end

  def generate_guesses_list
    combinations_enumerator = %w[white blue red yellow green cyan].repeated_permutation(4)
    combinations_enumerator.map { |element| element }
  end

  def perform_move1
    openers_list = @guesses_set.select do |element|
      element[0] == element[1] && element[2] == element[3] && element[0] != element[2]
    end
    openers_list.sample
  end

  def perform_move2(board)
    evaluate_remaining_guesses(board)
    @last_move = @guesses_set.sample
  end

  def evaluate_remaining_guesses(board)
    @guesses_set.delete(@last_move)
    partial_matches = board.previous_suggestions.last['feedback'].count('o')
    perfect_matches = board.previous_suggestions.last['feedback'].count("\e[31mo\e[0m")
    move_deletion(partial_matches, perfect_matches)
  end

  def move_deletion(partial_matches, perfect_matches)
    zero_match_check if partial_matches.zero? && perfect_matches.zero?
    color_presence_check(partial_matches, perfect_matches) if (partial_matches + perfect_matches).positive?
    perfect_position_check(perfect_matches) if perfect_matches.zero? == false
  end

  def zero_match_check
    @guesses_set.delete_if { |potential_solution| potential_solution.intersect?(@last_move) == true }
  end

  def color_presence_check(partial_matches, perfect_matches)
    @guesses_set.delete_if do |potential_solution|
      enough_colors?(potential_solution, partial_matches, perfect_matches) == false
    end
  end

  def enough_colors?(potential_solution, partial_matches, perfect_matches)
    editable_solution = potential_solution.dup
    matches = 0
    @last_move.each do |color|
      if editable_solution.include?(color)
        editable_solution.delete_at(editable_solution.index(color))
        matches += 1
      end
    end
    partial_matches + perfect_matches == matches
  end

  def perfect_position_check(perfect_matches)
    @guesses_set.delete_if { |potential_solution| exact_color_matching?(potential_solution, perfect_matches) == false }
  end

  def exact_color_matching?(potential_solution, perfect_matches)
    matches = 0
    @last_move.each_index do |index|
      matches += 1 if @last_move[index] == potential_solution[index]
    end
    matches == perfect_matches
  end
end

# The HumanPlayer class saves date about potential human players.
class HumanPlayer < Player
  def initialize(human, name, role)
    super
    @was_creator = 2
  end

  attr_reader :name, :score
  attr_accessor :was_creator, :role

  def interrogate_creator
    puts "\e[H\e[2J"
    instruct_creator
    secret_input = gets.chomp.downcase.split.delete_if do |element|
      %w[white blue red yellow green cyan].include?(element) == false
    end
    secret_input = reject_input(secret_input)
    puts "\e[H\e[2J"
    secret_input
  end

  def request_suggestion_from_player(_board)
    puts "Type your guess, #{@name}!"
    instruct_about_colors
    input = gets.chomp.downcase.split.delete_if do |element|
      %w[white blue red yellow green cyan].include?(element) == false
    end
    reject_input(input)
  end

  private

  def instruct_creator
    puts "Your turn to create a code, #{@name}!" if @was_creator.zero?
    puts "What will the secret code be, #{@name}?"
    instruct_about_colors
  end

  def instruct_about_colors
    puts 'Write four colors from the following list, separated with spaces:'
    print_colorized_colors
    puts 'You can select the same color several times.'
  end

  def print_colorized_colors
    print 'White '.colorize('white')
    print 'Blue '.colorize('blue')
    print 'Red '.colorize('red')
    print 'Yellow '.colorize('yellow')
    print 'Green '.colorize('green')
    print 'Cyan'.colorize('cyan')
    print "\n"
  end

  def reject_input(input)
    until input.length == 4
      puts 'Invalid answer!'
      input = gets.chomp.downcase.split.delete_if do |element|
        %w[white blue red yellow green cyan].include?(element) == false
      end
    end
    input
  end
end

def mastermind_wrapper
  play_game
  ask_for_retry
end

def play_game
  components_array = initialize_components
  play_turn(*components_array) until components_array[0].game_over == true || components_array[0].current_turn == 13
  components_array = reinitialize_for_role_inversion(components_array)
  play_turn(*components_array) until components_array[0].game_over == true || components_array[0].current_turn == 13
  compare_scores(components_array[1])
end

def initialize_components
  player_array = Player.initialize_players
  creator_index = player_array.index { |player| player.role == 'creator' }
  secret_code = player_array[creator_index].interrogate_creator
  ruleset = Rules.new(player_array[creator_index])
  board = Board.new(secret_code)
  [board, player_array, ruleset]
end

def reinitialize_for_role_inversion(components_array)
  components_array[1] = exchange_roles(components_array[1])
  creator_index = components_array[1].index { |player| player.role == 'creator' }
  secret_code = components_array[1][creator_index].interrogate_creator
  components_array[0] = Board.new(secret_code)
  components_array
end

def play_turn(board, players, ruleset)
  guesser_index = players.index { |player| player.role == 'guesser' }
  creator_index = players.index { |player| player.role == 'creator' }
  print_screen(board, players, ruleset)
  process_suggestion(board, players, ruleset, guesser_index, creator_index)
  print_screen(board, players, ruleset)
  wait_for_enter
  board.reset_board_for_next_suggestion
end

def print_screen(board, players, ruleset)
  puts "\e[H\e[2J"
  board.print_board
  players.each do |player|
    print "#{player.name}: #{player.score}   "
  end
  print "\n"
  ruleset.print_text_feedback(board) if board.current_suggestion != {}
end

def process_suggestion(board, players, ruleset, guesser_index, creator_index)
  current_suggestion = players[guesser_index].request_suggestion_from_player(board)
  board.retrieve_suggestion(current_suggestion)
  current_feedback = ruleset.compare_current_suggestion(current_suggestion, board)
  board.retrieve_feedback(current_feedback)
  players[creator_index].calculate_score(board)
end

def wait_for_enter
  puts 'Press the Enter key to continue.'
  $stdin.gets(1)
end

def exchange_roles(player_array)
  current_guesser_index = player_array.index { |player| player.role == 'guesser' }
  current_creator_index = player_array.index { |player| player.role == 'creator' }
  player_array[current_guesser_index].was_creator = 0
  player_array[current_creator_index].was_creator = 1
  player_array[current_guesser_index].role = 'creator'
  player_array[current_creator_index].role = 'guesser'
  player_array
end

def compare_scores(players)
  if players[0].score == players[1].score
    puts "It's a draw!"
  else
    winner = players.max { |player1, player2| player1.score <=> player2.score }
    puts "#{winner.name} wins!"
  end
end

def ask_for_retry
  puts 'Retry? (y/n)'
  answer = gets.chomp.downcase
  mastermind_wrapper if answer == 'y'
  while %w[y n].include?(answer) == false
    if answer != 'n'
      puts 'Invalid answer!'
      answer = gets.chomp.downcase
    end
  end
end

mastermind_wrapper
