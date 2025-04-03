# frozen_string_literal: true

require_relative "lib/hangman"

file_path = "google-10000-english-no-swears.txt"

# :: is used to access a CONSTANT inside the Class
if File.exist?(Hangman::SAVE_FILE)
  puts "Do you want to load your saved game? (yes/no)"
  choice = gets.chomp.downcase
  game = (choice == "yes" ? Hangman.load_game : Hangman.new(file_path))
else
  game = Hangman.new(file_path)
end

until game.victory? || game.defeat?
  game.display_game
  letter = game.guess
  game.letters_guessed.push(letter)
  game.mistakes += 1 unless game.chosen_word.include?(letter)
end

game.display_game

if game.victory?
  puts "Congratulations! You won!"
elsif game.defeat?
  puts "Game over! The word was '#{game.chosen_word}'. Better luck next time!"
end

if File.exist?(Hangman::SAVE_FILE)
  File.delete(Hangman::SAVE_FILE)
  puts "Saved game deleted."
end
