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
