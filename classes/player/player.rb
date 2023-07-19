# The Player class is used to query for each player's data, and to initialize them.
class Player
  @taken_role = ''

  class << self
    attr_accessor :taken_role
  end

  def initialize(name, role)
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
        HumanPlayer.new(player1_name, player1_role)
      else
        ComputerPlayer.new(player1_name, player1_role)
      end
    end

    def initialize_player_two
      player2_human = player_human?(1)
      player2_name = define_player_name(1, player2_human)
      player2_role = define_player_role(1)
      if player2_human == true
        HumanPlayer.new(player2_name, player2_role)
      else
        ComputerPlayer.new(player2_name, player2_role)
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
