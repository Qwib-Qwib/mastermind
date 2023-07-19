# Tasked with processing feedback from a CPU's moves in order to clean up the CPU's set of possible guesses.
module MoveProcessing
  @zero_match_block = ->(potential_solution, compared_move) { potential_solution.intersect?(compared_move) == true }
  @color_presence_block = lambda do |potential_solution, compared_move, partial_matches, perfect_matches|
    enough_colors_to_match_feedback?(compared_move, potential_solution, partial_matches, perfect_matches) == false
  end
  @incorrect_position_block = lambda do |potential_solution, compared_move|
    same_placement?(compared_move, potential_solution) == true
  end
  @perfect_position_block = lambda do |potential_solution, compared_move, perfect_matches|
    exact_color_matching?(compared_move, potential_solution, perfect_matches) == false
  end

  class << self
    attr_accessor :zero_match_block, :color_presence_block, :incorrect_position_block, :perfect_position_block
  end

  module_function

  def move_deletion(decision_set, compared_move, partial_matches, perfect_matches)
    zero_match_delete(decision_set, compared_move, &@zero_match_block) if partial_matches.zero? && perfect_matches.zero?
    # The following is a guard clause meant to end method prematurely if condition not met.
    return unless (partial_matches + perfect_matches).positive?

    positive_feedback_move_deletion(decision_set, compared_move, partial_matches, perfect_matches)
  end

  def positive_feedback_move_deletion(decision_set, compared_move, partial_matches, perfect_matches)
    if partial_matches.positive? && perfect_matches.zero?
      incorrect_position_delete(decision_set, compared_move, &@incorrect_position_block)
    end
    color_presence_delete(decision_set, compared_move, partial_matches, perfect_matches, &@color_presence_block)
    return unless perfect_matches.positive?

    perfect_position_delete(decision_set, compared_move, perfect_matches, &@perfect_position_block)
  end

  def zero_match_delete(decision_set_used, compared_move, &block)
    decision_set_used.delete_if { |potential_solution| block.call(potential_solution, compared_move) }
  end

  def color_presence_delete(decision_set_used, compared_move, partial_matches, perfect_matches, &block)
    decision_set_used.delete_if do |potential_solution|
      block.call(potential_solution, compared_move, partial_matches, perfect_matches)
    end
  end

  def enough_colors_to_match_feedback?(compared_move, potential_solution, partial_matches, perfect_matches)
    editable_solution = potential_solution.dup
    matches = 0
    compared_move.each do |color|
      if editable_solution.include?(color)
        editable_solution.delete_at(editable_solution.index(color))
        matches += 1
      end
    end
    partial_matches + perfect_matches == matches
  end

  def incorrect_position_delete(decision_set_used, compared_move, &block)
    decision_set_used.delete_if { |potential_solution| block.call(potential_solution, compared_move) }
  end

  def perfect_position_delete(decision_set_used, compared_move, perfect_matches, &block)
    decision_set_used.delete_if { |potential_solution| block.call(potential_solution, compared_move, perfect_matches) }
  end

  def same_placement?(compared_move, potential_solution)
    compared_move.each_index do |index|
      return true if compared_move[index] == potential_solution[index]
    end
    false
  end

  def exact_color_matching?(compared_move, potential_solution, perfect_matches)
    matches = 0
    compared_move.each_index do |index|
      matches += 1 if compared_move[index] == potential_solution[index]
    end
    matches == perfect_matches
  end

  def zero_match_count(decision_set_used, compared_move, &block)
    decision_set_used.count { |potential_solution| block.call(potential_solution, compared_move) }
  end

  def incorrect_position_count(decision_set_used, compared_move, &block)
    decision_set_used.count { |potential_solution| block.call(potential_solution, compared_move) }
  end

  def color_presence_count(decision_set_used, compared_move, partial_matches, perfect_matches, &block)
    decision_set_used.count do |potential_solution|
      block.call(potential_solution, compared_move, partial_matches, perfect_matches)
    end
  end

  def perfect_position_count(decision_set_used, compared_move, perfect_matches, &block)
    decision_set_used.count { |potential_solution| block.call(potential_solution, compared_move, perfect_matches) }
  end
end
