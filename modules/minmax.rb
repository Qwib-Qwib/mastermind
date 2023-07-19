require_relative "move_processing"

# Tasked with performing Knuth's 5-moves-max algorithm by calculating which unused guess is more likely to trim down
# the set of possible solutions.
module Minmax
  include MoveProcessing

  module_function

  def check_most_destructive_guess
    @unused_guesses_set.delete(@last_move)
    scores_per_guess = create_scores_list
    scores_per_guess = scores_per_guess.sort_by { |_unused_guess, min_score| min_score }.reverse!
    scores_per_guess.select! { |_unused_guess, min_score| min_score == scores_per_guess.first[1] }
    scores_per_guess.flatten!(1).keep_if { |element| element.instance_of?(Array) }
    if scores_per_guess.intersect?(@possible_solutions)
      scores_per_guess.intersection(@possible_solutions).sample
    else
      scores_per_guess.sample
    end
  end

  def create_scores_list
    @unused_guesses_set.reduce({}) do |scores_list, unused_guess|
      scores_list[unused_guess] = calculate_scores_for_one_guess(unused_guess)
      scores_list[unused_guess].sort!
      scores_list[unused_guess] = scores_list[unused_guess][0]
      scores_list
    end
  end

  def calculate_scores_for_one_guess(unused_guess)
    possible_feedbacks = calculate_possible_feedbacks
    scores_for_one_guess = []
    possible_feedbacks.each_with_object(unused_guess) do |specific_feedback, guess|
      dup_guesses_set = @possible_solutions.dup
      scores_for_one_guess.push(minmax_check(specific_feedback, guess, dup_guesses_set))
    end
    scores_for_one_guess
  end

  def calculate_possible_feedbacks
    possible_feedbacks_array = []
    (0..4).to_a.repeated_permutation(2) do |possible_feedback|
      possible_feedbacks_array.push(possible_feedback) if possible_feedback.sum <= 4 && possible_feedback[1] != 4
    end
    possible_feedbacks_array
  end

  def minmax_check(feedback, unused_guess, dup_guesses_set)
    feedback_scores = []
    compute_destruction_scores_for_unused_guess(feedback_scores, feedback, unused_guess, dup_guesses_set)
    feedback_scores.sum
  end

  def compute_destruction_scores_for_unused_guess(feedback_scores, feedback, guess, guesses_set)
    if feedback == [0, 0]
      feedback_scores, guesses_set = get_zero_match_score(feedback_scores, guesses_set, guess,
                                                          &MoveProcessing.zero_match_block)
    end
    if feedback.sum.positive?
      feedback_scores = compute_destruction_scores_positive_feedback(feedback_scores, feedback, guess, guesses_set)
    end
    feedback_scores
  end

  def compute_destruction_scores_positive_feedback(feedback_scores, feedback, guess, guesses_set)
    feedback_scores, guesses_set = get_color_presence_score(feedback_scores, guesses_set, guess, *feedback,
                                                            &MoveProcessing.color_presence_block)
    compute_destruction_scores_either_positive(feedback_scores, feedback, guess, guesses_set)
  end

  def compute_destruction_scores_either_positive(feedback_scores, feedback, guess, guesses_set)
    if feedback[0].positive? && feedback[1].zero?
      feedback_scores, guesses_set = get_incorrect_position_score(feedback_scores, guesses_set, guess,
                                                                  &MoveProcessing.incorrect_position_block)
    end
    if feedback[1].positive?
      feedback_scores = get_perfect_position_score(feedback_scores, guesses_set, guess, feedback[1],
                                                   &MoveProcessing.perfect_position_block)
    end
    feedback_scores
  end

  def get_zero_match_score(feedback_scores, dup_guesses_set, unused_guess, &block)
    feedback_scores.push(zero_match_count(dup_guesses_set, unused_guess, &block))
    zero_match_delete(dup_guesses_set, unused_guess, &block)
    [feedback_scores, dup_guesses_set]
  end

  def get_incorrect_position_score(feedback_scores, dup_guesses_set, unused_guess, &block)
    feedback_scores.push(incorrect_position_count(dup_guesses_set, unused_guess, &block))
    incorrect_position_delete(dup_guesses_set, unused_guess, &block)
    [feedback_scores, dup_guesses_set]
  end

  def get_color_presence_score(feedback_scores, dup_guesses_set, unused_guess, *feedback, &block)
    feedback_scores.push(color_presence_count(dup_guesses_set, unused_guess, *feedback, &block))
    color_presence_delete(dup_guesses_set, unused_guess, *feedback, &block)
    [feedback_scores, dup_guesses_set]
  end

  def get_perfect_position_score(feedback_scores, dup_guesses_set, unused_guess, perfect_matches, &block)
    feedback_scores.push(perfect_position_count(dup_guesses_set, unused_guess, perfect_matches, &block))
    perfect_position_delete(dup_guesses_set, unused_guess, perfect_matches, &block)
    feedback_scores
  end
end
