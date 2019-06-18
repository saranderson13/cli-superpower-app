require_relative '../config/environment'

class CommandPrompt
    include Resources::InputValidation
    extend Resources::InputValidation

    attr_accessor :selection

    def prompt
        # INTRODUCTION
        puts Rainbow("\nWelcome to the superpower index! What would you like to do?").bright
        puts "1. Populate the superpower library"
        puts "2. Explore the superpower library"
        puts "3. Generate a superhero"
        puts "4. Browse or edit the hero profiles"
        self.selection = gets.chomp

        # LOOPABLE OPTIONS
        while self.selection != 'exit'

          # POPULATE SUPERPOWER LIBRARY
          if self.selection.to_i == 1
              Power.populate_library

          # BROWSE LIBRARY
          elsif self.selection.to_i == 2
              puts "\nWelcome to the superpower library."
              puts "You are about to see the full list of every"
              puts "power that has been saved to the library."
              puts "There are currently #{Power.all.length} powers in your library."
              puts "Press 'enter' when you are ready to see the library."
              gets.chomp!
              puts Power.list_all

              puts "\n\nWould you like to learn more about a power from the library? (y/n)"
              self.selection = gets.chomp!
              self.selection = gets.chomp! until self.basic_y_n_validation(self.selection)

              Hero.learn_more_loop(Power.all, selection) if YES_ARRAY.include?(self.selection)

          # CREATE A NEW SUPERHERO
          elsif self.selection.to_i == 3
              puts Rainbow("\nWelcome to the superperson generator!").bright
              puts "In a moment a new superperson will be generated."
              puts "They may be a hero, or a villain - fate will decide."
              puts "They'll be generated with 3 powers to start off,"
              puts "as well as 3 positive traits, 3 negative traits, and an alignment."
              puts "You'll give them a name, and even a secret identity."
              puts "Are you ready? (y/n)"
              self.selection = gets.chomp!
              puts "No time like the present!" if !YES_ARRAY.include?(self.selection)
              Hero.generate_hero

          # BROWSE HEROES, EDIT HERO PROFILES
          elsif self.selection.to_i == 4
            if Hero.all.length > 0
                puts Rainbow("\nWelcome to the superperson browser!").bright
                puts "You are about to see the full list of every"
                puts "Hero and Villain that has been saved to the database."
                puts "There is currently 1 superperson in the database." if Hero.all.length == 1
                puts "There are currently #{Hero.all.length} superpeople in the database." if Hero.all.length > 1
                puts "Press 'enter' when you are ready to see the database."
                gets.chomp!
                puts Hero.list_all

                puts "\nSelect a superperson to view or edit their profile:"
                self.selection = gets.chomp!
                self.selection = gets.chomp! until self.basic_range_validation(Hero.list_all.length, "view", "Hero Database", self.selection)

                selected_hero = Hero.all[self.selection.to_i - 1]
                selected_hero.generate_hero_table
                selected_hero.display_hero

                puts Rainbow("\nWhat would you like to do?").bright
                puts "1. Learn more about the #{selected_hero.hero_villain}'s powers'"
                puts "2. Edit power set"
                puts "3. Change superhero name"
                puts "4. Reveal secret identity"
                self.selection = gets.chomp!
                self.selection = gets.chomp! until self.super_basic_range_validation(4, self.selection)

                # EXPLORE HERO'S POWERS
                if self.selection.to_i == 1
                  selection = 'y'
                  Hero.learn_more_loop(selected_hero.powers, selection)

                # EDIT POWERS
                elsif self.selection.to_i == 2
                  puts "\n1. Add a power, either from the library or at random"
                  puts "2. Remove a power"
                  puts "3. Remove all powers and generate new powers in bulk"
                  self.selection = gets.chomp!
                  self.selection = gets.chomp! until self.super_basic_range_validation(3, self.selection)

                  # ADD A POWER
                  if self.selection.to_i == 1
                    selected_hero.add_power_prompt

                  # REMOVE A POWER
                  elsif self.selection.to_i == 2
                    selected_hero.remove_power_prompt

                  # CLEAR POWERS AND ADD IN BULK
                  elsif self.selection.to_i == 3
                    selected_hero.replace_powers_prompt


                  end

                # RENAME HERO
                elsif self.selection.to_i == 3
                  puts "\nWhat would you like the #{selected_hero.hero_villain}'s new name to be?"
                  former_name = selected_hero.hero_name
                  selected_hero.hero_name = gets.chomp!
                  puts "\nThe #{selected_hero.hero_villain} will no longer be known as #{former_name}."
                  puts "From this point forth, this #{selected_hero.hero_villain} shall be called " + Rainbow("#{selected_hero.hero_name}").bright + "!"

                # REVEAL SECRET IDENTITY
                elsif self.selection.to_i == 4
                  puts Rainbow("\nWARNING: ").red.bright + "You do not have the necessary security clearance."
                end

            else
              puts Rainbow("\nNo heroes or villains have been created yet.").bright
            end

          #INVALID SELECTION
          else
              self.basic_cli_validation(self.selection)
          end

          # LOOPING PROMPT
          puts Rainbow("\nWhat would you like to do next?").bright
          puts "1. Populate the superpower library"
          puts "2. Explore the superpower library"
          puts "3. Generate a superhero"
          puts "4. Browse or edit the hero profiles"
          self.selection = gets.chomp!
        end
    end

    def loop
      Power.startup_populate_lib
      PersonalityScraper.new.scrape_traits
      self.prompt until self.selection == 'exit'
    end
end
