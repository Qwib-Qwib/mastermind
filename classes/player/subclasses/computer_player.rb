require File.expand_path('../../player.rb', __FILE__)
require_relative "../../../modules/move_processing"
require_relative "../../../modules/minmax"

# The ComputerPlayer class saves data about potential computer players and define their AI.
class ComputerPlayer < Player
  include Minmax
  include MoveProcessing
  @computers_number = 1

  class << self
    attr_accessor :computers_number
  end

  def initialize(name, role)
    super
    @name += " #{ComputerPlayer.computers_number}"
    ComputerPlayer.computers_number += 1
    @unused_guesses_set = generate_guesses_list
    @possible_solutions = generate_guesses_list
    @was_creator = 2
    @last_move = []
  end

  attr_reader :name, :score
  attr_accessor :possible_solutions, :was_creator, :role, :last_move

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
    openers_list = @possible_solutions.select do |element|
      element[0] == element[1] && element[2] == element[3] && element[0] != element[2]
    end
    openers_list.sample
  end

  def perform_move2(board)
    evaluate_remaining_guesses(board)
    @last_move = check_most_destructive_guess
  end

  def evaluate_remaining_guesses(board)
    @possible_solutions.delete(@last_move)
    partial_matches = board.previous_suggestions.last['feedback'].count('o')
    perfect_matches = board.previous_suggestions.last['feedback'].count("\e[31mo\e[0m")
    MoveProcessing.move_deletion(@possible_solutions, @last_move, partial_matches, perfect_matches)
  end
end
