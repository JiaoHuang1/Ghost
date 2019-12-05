class Player
    attr_reader :name
    attr_accessor :earned_lose

    def initialize
        # puts "Player, please enter your name: "
        @name = gets.chomp.upcase
        @earned_lose = ""
    end

    def guess
        gets.chomp
    end

    def alert_invalid_guess(letter)
        if !("a".."z").to_a.include?(letter)
            puts "invalid_play, enter a lower case alpha letter from 'a' to 'z'"
            return true
        end
        false
    end
end
