### please enter "ruby game.rb" in terminal to play the game ###

require "set"
require_relative "Player"

class Game
    DICTIONARY = Set.new
    File.open("dictionary.txt").each do |line|
        DICTIONARY.add(line.chomp)
    end
    
    def initialize
        @players = []
        @fragment = ""
        @current_player = @players[0]
    end

    def dictionary                                          ### lazy initialization of a large dictionary
        @dictionary ||= DICTIONARY
    end

    def add_player                                          ### get all player's name and add player instance to @players array
        puts "How many players are joining the game?"
        number = gets.chomp.to_i
        number.times do |n|
            puts "Player #{n + 1}, please enter your name: "
            @players << Player.new
        end
        @current_player = @players[0]
    end

    def current_player
        @current_player
    end

    def previous_player                                     ### the previous player of the 1st player in @players array should be the last player in the array
        current_idx = @players.index(@current_player)
        previous_idx = current_idx - 1
        @previous_player = @players[previous_idx]
    end

    def next_player! 
        @previous_player = @current_player
        current_idx = @players.index(@current_player)
        next_idx = current_idx + 1
        @current_player = @players[next_idx % @players.length]
    end

    def take_turn(player)                                   ### if a player made a valid guess, add the guess letter to the fragment
        puts "#{@current_player.name}, please enter a guess: "
        puts "or admit defeat？(Enter 'yes' to end this round, but you will gain a 'GHOST' symble for this round. Oops!)"
        letter = @current_player.guess

        if letter == "yes"                                  ### player can enter 'yes' on his/her turn to end/lose the round
            return "round_end"                              ### by return the word 'round_end' for #take_turn, we can break #lose_the_round
        end                                                 ### in #play_round

        until valid_play?(letter) do
            letter = @current_player.guess
            if letter == "yes"                              ### after a few guesses (>= 1) of invalid play, player can enter 'yes' to end/lose the round
                return "round_end"
            end
        end

        p @fragment += letter 
    end

    def valid_play?(letter)

        if !("a".."z").to_a.include?(letter)
            puts "invalid_play, enter a lower case alpha letter from 'a' to 'z'"
            return false
        end

        if letter == "yes"                                  ### 'yes' is a valid play but this play will only lead to end the round of the game
            return true
        end
        
        potential_fragment = @fragment + letter
        DICTIONARY.each do |word|
            return true if word.start_with?(potential_fragment)
        end

        puts "Invalid play, must be a valid prefix in the dicionary."
        puts "or admit defeat？(Enter 'yes' to end this round, but you will gain a 'GHOST' symble for this round. Oops!)"
        false
    end

    def lose_the_round?
        DICTIONARY.include?(@fragment)
    end

    def play_around
        lose_the_round = false
        until lose_the_round? do 
            if take_turn(@current_player) == "round_end"
                next_player!
                break
            end
            next_player!
        end
        puts "------------------------------------"
        puts "#{@previous_player.name} lose the round!"
        puts "------------------------------------"
        @fragment = ""
        @previous_player
    end

    def record(player)                                  ### record the "GHOST" symble into the player instance that lost that round of game
        ghost = ["G", "H", "O", "S", "T"]
        previous_earned_char = player.earned_lose[-1]
        if previous_earned_char == nil
            player.earned_lose += "G"
        else  
            previous_earned_char_index = ghost.index(previous_earned_char)
            player.earned_lose += ghost[previous_earned_char_index + 1]
        end
    end

    def game_over?
        @players.each do |player_instance| 
            if player_instance.earned_lose == "GHOST"
                puts "#{player_instance.name} loses the game!"
                return true
            end
        end
        false
    end

    def dispaly_ghost                               
        puts "GHOST earned: "
        @players.each do |player_instance|
            earned_ghost = player_instance.earned_lose
            if earned_ghost == ""
                puts "#{player_instance.name}: None (You are doing great!)"
            else  
                puts "#{player_instance.name}: #{player_instance.earned_lose}"
            end
        end
        puts "------------------------------------"
    end

    def run
        puts "Let's start GHOST game!"       
        self.record(self.play_around)
        self.dispaly_ghost

        until game_over? do
            puts
            puts "Let's play another round!"
            self.record(self.play_around)
            self.dispaly_ghost
        end
    end
end

p game = Game.new
game.add_player
game.run

