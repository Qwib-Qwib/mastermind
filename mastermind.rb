# frozen_string_literal: false

require 'io/console'
require_relative 'string_colorizer'
require_relative 'classes/board'
require_relative 'classes/rules'
require_relative 'classes/player/player_main'
require_relative 'modules/minmax'
require_relative 'modules/move_processing'

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
  while %w[y n].include?(answer) == false
    if answer != 'n'
      puts 'Invalid answer!'
      answer = gets.chomp.downcase
    end
  end
  reset_game if answer == 'y'
end

def reset_game
  ComputerPlayer.computers_number = 1
  mastermind_wrapper
end

mastermind_wrapper
