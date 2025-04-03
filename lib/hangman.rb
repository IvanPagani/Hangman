# frozen_string_literal: true

require "yaml"

class Hangman
  attr_accessor :dictionary_path, :letters_guessed, :mistakes, :chosen_word

  SAVE_FILE = "saved_game.yml"

  def initialize(dictionary_path, letters_guessed = [], mistakes = 0, chosen_word = nil)
    @dictionary_path = dictionary_path
    @letters_guessed = letters_guessed
    @mistakes = mistakes

    # If a word was provided (from a saved game), use it.
    # Otherwise, randomly choose a new word from the dictionary.
    @chosen_word = chosen_word || choose_word
  end

  def choose_word
    words = File.readlines(@dictionary_path, chomp: true)
                .filter { |word| word.length.between?(5, 12) }
    words.sample
  end

  def display_game
    system("clear") || system("cls")
    display_hangman(@mistakes)
    display_word(@chosen_word, @letters_guessed)
    display_letters(@letters_guessed)
  end

  def display_hangman(mistakes)
    hangman = [
      " H A N G M A N",
      "         ",
      " ------  ",
      " |    |  ",
      " |       ",
      " |       ",
      " |       ",
      " |       ",
      " ========="
    ]

    hangman[4] = " |    O  " if mistakes >= 1
    hangman[5] = " |    |  " if mistakes >= 2
    hangman[5] = " |   /|  " if mistakes >= 3
    hangman[5] = " |   /|\\" if mistakes >= 4
    hangman[6] = " |   /   " if mistakes >= 5
    hangman[6] = " |   / \\" if mistakes >= 6

    puts hangman.join("\n")
  end

  def display_word(chosen_word, letters_guessed)
    puts "\n#{chosen_word.chars.map do |letter|
      letters_guessed.include?(letter) ? letter : '_'
    end.join(' ')}\n\n"
  end

  def display_letters(letters_guessed)
    puts "Letters guessed: #{letters_guessed.join(', ')}"
  end

  def guess
    loop do
      print "Enter a letter or type 'save' to save the game: "
      input = gets.chomp.downcase

      if input == "save"
        save_game
        puts "Game saved! Exiting..."
        exit
      elsif input.match?(/^[a-z]$/) && !@letters_guessed.include?(input)
        return input
      else
        puts "Invalid input."
      end
    end
  end

  def victory?
    @chosen_word.chars.all? { |letter| @letters_guessed.include?(letter) }
  end

  def defeat?
    @mistakes >= 6
  end

  def save_game
    data = YAML.dump({
                       dictionary_path: @dictionary_path,
                       letters_guessed: @letters_guessed,
                       mistakes: @mistakes,
                       chosen_word: @chosen_word
                     })
    File.write(SAVE_FILE, data)
  end

  def self.load_game
    return unless File.exist?(SAVE_FILE)

    data = YAML.load_file(SAVE_FILE)
    new(data[:dictionary_path],
        data[:letters_guessed],
        data[:mistakes],
        data[:chosen_word])
  end
end
