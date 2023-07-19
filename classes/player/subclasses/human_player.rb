require File.expand_path('../../player.rb', __FILE__)
require_relative "../../../string_colorizer"

# The HumanPlayer class saves date about potential human players.
class HumanPlayer < Player
  def initialize(name, role)
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
