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
