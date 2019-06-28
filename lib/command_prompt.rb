require_relative '../config/environment'

class CommandPrompt
    include Resources::InputValidation
    extend Resources::InputValidation

    attr_accessor :selection, :selected_hero

    def prompt
        # INTRODUCTION - Root menu
        puts Rainbow("\n #{8269.chr("UTF-8")} Welcome to the superpower index! What would you like to do?").bright.bg("96E0CC")
        puts Rainbow("    1. ").bright + "Populate the superpower library"
        puts Rainbow("    2. ").bright + "Explore the superpower library"
        puts Rainbow("    3. ").bright + "Generate a superhero"
        puts Rainbow("    4. ").bright + "Browse or edit the hero profiles"
        self.selection = gets.chomp

        # LOOP UNTIL 'exit' IS SUBMITTED AS INPUT
        while self.selection != 'exit'

          # POPULATE SUPERPOWER LIBRARY
          if self.selection.to_i == 1
              puts Rainbow("\n #{10687.chr("UTF-8")} POWER LIBRARY - POPULATION INTERFACE").bright.bg("91B0F2")
              puts "    You can randomly generate 10 superpowers at a time."
              puts Rainbow(" ? ").bright.bg("91B0F2") + Rainbow(" How many powers would you like to send to the library?").bright

              self.selection = gets.chomp!
              self.selection = gets.chomp! until self.basic_range_validation(10, "generate", "Populate Library", self.selection)

              if self.selection != 'exit'
                added_powers = Power.populate_library(self.selection)
              end

              if added_powers
                puts Rainbow("\n #{10687.chr("UTF-8")} The following powers have been added to your library: ").bright.bg("91B0F2")
                puts "\n"
                added_powers.each_with_index { |pwr, i| puts Rainbow("    #{i + 1}.").bright + " #{pwr.name}" }
                puts "\n- - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
              end

          # BROWSE LIBRARY
          elsif self.selection.to_i == 2
              puts Rainbow("\n #{10687.chr("UTF-8")} WELCOME TO THE SUPERPOWER LIBRARY").bright.bg("CFAEE2")
              puts "    You are about to see the full list of every power that has been saved to the library."
              puts "    There are currently #{Power.all.length} powers in your library."
              puts Rainbow(" i ").bright.bg("CFAEE2") + Rainbow(" Press 'enter' when you are ready to see the library.").bright
              gets.chomp!
              puts Power.list_all

              puts "\n" + Rainbow(" ? ").bright.bg("CFAEE2") + Rainbow(" Would you like to learn more about a power from the library? (y/n)").bright
              self.selection = gets.chomp!
              self.selection = gets.chomp! until self.basic_y_n_validation(self.selection)

              self.learn_more_loop(Power.all) if YES_ARRAY.include?(self.selection)

          # CREATE A NEW SUPERHERO
          elsif self.selection.to_i == 3
              puts Rainbow("\n #{128165.chr("UTF-8")}  CHARACTER CREATION INTERFACE").bright.bg("CEF77D")
              puts "    In a moment a new superperson will be generated."
              puts "    They may be a hero, or a villain - fate will decide."
              puts "    They'll be generated with 3 powers to start off,"
              puts "    as well as 3 positive traits, 3 negative traits, and an alignment."
              puts "    You'll give them a name, and even a secret identity."
              puts Rainbow(" ? ").bright.bg("CEF77D") +  Rainbow(" Are you ready? (y/n)").bright
              self.selection = gets.chomp!
              puts "No time like the present!" if !YES_ARRAY.include?(self.selection)
              Hero.generate_temp_hero
              call_trait = Hero.alignment_and_descriptor

              # Display starter card
              puts Rainbow("\n #{128165.chr("UTF-8")}  Here are the new #{Hero.temp.hero_villain}'s starter stats:").bright.bg("CEF77D")
              puts "\n"
              Hero.display_starter_table

              # Determine name
              puts Rainbow(" ? ").bright.bg("CEF77D") +  Rainbow(" What should we call this #{call_trait} soul?").bright
              self.selection = gets.chomp!
              Hero.temp.hero_name = self.selection
              puts "\n" + Rainbow(" i ").bright.bg("CEF77D") + " This #{Hero.temp.hero_villain} will henceforth be known as " + Rainbow("#{Hero.temp.hero_name}").bright + "!"

              puts "\n" + Rainbow(" ? ").bright.bg("CEF77D") + " Why not give " + Rainbow("#{Hero.temp.hero_name}").bright + " a secret identity?"
              self.selection = gets.chomp!
              Hero.temp.secret_identity = selection

              puts "\n" + Rainbow(" ? ").bright.bg("CEF77D") + Rainbow(" Your #{Hero.temp.hero_villain} has been created and added to the database!\n").bright
              Hero.all << Hero.temp
              Hero.temp.display_hero

          # BROWSE HEROES, EDIT HERO PROFILES
          elsif self.selection.to_i == 4
            if Hero.all.length > 0
                puts Rainbow("\n #{128171.chr("UTF-8")}  Welcome to the Character Browser").bright.bg("F7AC7E")
                puts "    You are about to see the full list of every"
                puts "    Hero and Villain that has been saved to the database."
                puts "    There is currently 1 superperson in the database." if Hero.all.length == 1
                puts "    There are currently #{Hero.all.length} superpeople in the database." if Hero.all.length > 1
                puts Rainbow(" i ").bright.bg("F7AC7E") + Rainbow(" Press 'enter' when you are ready to see the library.").bright
                gets.chomp!
                puts Hero.list_all

                puts "\n" + Rainbow(" ? ").bright.bg("F7AC7E") + Rainbow(" Select a superperson to view or edit their profile:").bright
                self.selection = gets.chomp!
                self.selection = gets.chomp! until self.basic_range_validation(Hero.list_all.length, "view", "Character Database", self.selection)

                if self.selection != "exit"
                  self.selected_hero = Hero.all[self.selection.to_i - 1]
                  self.selected_hero.generate_hero_table
                  self.selected_hero.display_hero

                    until self.selection == "exit"
                        puts "\n" + Rainbow(" ? ").bright.bg("F7AC7E") + Rainbow(" What would you like to do?").bright
                        puts Rainbow("    1.").bright + " Learn more about the #{self.selected_hero.hero_villain}'s powers'"
                        puts Rainbow("    2.").bright + " Edit power set"
                        puts Rainbow("    3.").bright + " Change superhero name"
                        puts Rainbow("    4.").bright + " Reveal secret identity"
                        self.selection = gets.chomp!
                        self.selection = gets.chomp! until self.super_basic_range_validation(4, self.selection)

                        # EXPLORE HERO'S POWERS
                        if self.selection.to_i == 1
                          self.selection = 'y'
                          self.learn_more_loop(self.selected_hero.powers)

                        # EDIT POWERS
                        elsif self.selection.to_i == 2
                          puts "\n" + Rainbow(" ? ").bright.bg("F7AC7E") + Rainbow(" What would you like to do?").bright
                          puts Rainbow("    1.").bright + " Add a power, either from the library or at random"
                          puts Rainbow("    2.").bright + " Remove a power"
                          puts Rainbow("    3.").bright + " Remove all powers and generate new powers in bulk"
                          self.selection = gets.chomp!
                          self.selection = gets.chomp! until self.super_basic_range_validation(3, self.selection)

                          # ADD A POWER
                          if self.selection.to_i == 1
                            self.add_power_prompt

                          # REMOVE A POWER
                          elsif self.selection.to_i == 2
                            if self.selected_hero.powers.length > 0
                                puts Rainbow("\nThe current powers are:\n").bright
                                puts self.selected_hero.list_powers

                                puts Rainbow("\nRead more about the powers before choosing? (y/n)").bright
                                self.selection = gets.chomp!
                                self.selection = gets.chomp! until self.basic_y_n_validation(self.selection)

                                self.learn_more_loop(self.selected_hero.powers) if YES_ARRAY.include?(self.selection)

                                puts Rainbow("\nWhich power would you like to delete from your #{self.selected_hero.hero_villain}?").bright
                                puts "Enter the number that corresponds to the power you would like to delete."
                                puts "Or to exit without deleting a power, enter 'exit'."
                                self.selection = gets.chomp!
                                self.selection = gets.chomp! until self.basic_range_validation(self.selected_hero.powers.length, "delete", "Power Removal", self.selection)

                                if (1..self.selected_hero.powers.length).include?(self.selection.to_i)
                                  puts "\nYou have deleted the " + Rainbow("#{self.selected_hero.powers[self.selection.to_i - 1].name}").underline + " superpower."
                                  self.selected_hero.powers.delete_at(self.selection.to_i - 1) if (1..self.selected_hero.powers.length).include?(self.selection.to_i)
                                else puts Rainbow("\nNo powers have been deleted.").bright
                                end
                                puts Rainbow("\nHere are the #{self.selected_hero.hero_villain}'s current powers:").bright
                                puts self.selected_hero.list_powers
                            else
                              puts "\nThere are no powers to delete."
                            end

                          # CLEAR POWERS AND ADD IN BULK
                          elsif self.selection.to_i == 3
                            # WARNING NOTICE
                            puts Rainbow("WARNING: ").red.bright + Rainbow("You are about to erase all of this #{self.selected_hero.hero_villain}'s powers.").bright
                            puts Rainbow("This change will be permanent.").bright

                            puts "\nWould you like to view this #{self.selected_hero.hero_villain}'s powers before continuing?"
                            self.selection = gets.chomp!
                            self.selection = gets.chomp! until self.basic_y_n_validation(self.selection)
                            puts self.selected_hero.list_powers if YES_ARRAY.include?(self.selection)

                            puts "\nWould you like to delete all of this #{self.selected_hero.hero_villain}'s powers and generate new ones?"
                            self.selection = gets.chomp!
                            self.selection = gets.chomp! until self.basic_y_n_validation(self.selection)

                            if YES_ARRAY.include?(self.selection)
                                self.selected_hero.powers.clear
                                puts "\nYou may add up to five powers at a time."
                                puts "How many powers would you like to add?"
                                self.selection = gets.chomp!
                                self.selection = gets.chomp! until self.basic_range_validation(5, "generate", "Replace Powers", self.selection)
                                self.selection.to_i.times { self.add_power_prompt } if self.selection != "exit"
                            else
                                puts Rainbow("\nNo powers have been deleted or added.").bright
                            end
                          end

                        # RENAME HERO
                        elsif self.selection.to_i == 3
                          former_name = self.selected_hero.hero_name

                          puts "\nWhat would you like the #{self.selected_hero.hero_villain}'s new name to be?"
                          self.selected_hero.hero_name = gets.chomp!

                          puts "\nThe #{self.selected_hero.hero_villain} will no longer be known as #{former_name}."
                          puts "From this point forth, this #{self.selected_hero.hero_villain} shall be called " + Rainbow("#{self.selected_hero.hero_name}").bright + "!"

                        # REVEAL SECRET IDENTITY
                        elsif self.selection.to_i == 4
                          puts Rainbow("\nWARNING: ").red.bright + "You do not have the necessary security clearance."

                        end
                    end
                end
            else
              puts Rainbow("\n    No heroes or villains have been created yet.").bright.bg("F7AC7E")
            end

          #INVALID SELECTION
          else
              self.basic_cli_validation
          end

          # LOOPING PROMPT - User returned to root menu
          puts Rainbow("\n #{8269.chr("UTF-8")} What would you like to do next?").bright.bg("96E0CC")
          puts Rainbow("   1. ").bright + "Populate the superpower library"
          puts Rainbow("   2. ").bright + "Explore the superpower library"
          puts Rainbow("   3. ").bright + "Generate a superhero"
          puts Rainbow("   4. ").bright + "Browse or edit the hero profiles"
          self.selection = gets.chomp!
        end
    end

    def loop
      Power.startup_populate_lib
      PersonalityScraper.new.scrape_traits
      self.prompt until self.selection == 'exit'
    end



    ### REPEATING PROMPTS
    def add_power_prompt
      puts "\n" + Rainbow(" ? ").bright.bg("F7AC7E") + Rainbow(" Do you want to:").bright
      puts Rainbow("    1. ").bright + "Add a random power?"
      puts Rainbow("    2. ").bright + "Select a power from the powers bank?"
      puts "    (To exit without adding a power, enter 'exit'.)"

      self.selection = gets.chomp!

      if self.selection == "1" # ADD RANDOM POWER
          self.add_random_power

      elsif self.selection == "2" #SELECT FROM BANK
          self.add_power_from_library

      elsif self.selection == "exit" # USER WISHES TO EXIT WITHOUT ADDING A POWER.
          puts "\n" + Rainbow(" i ").bright.bg("F7AC7E") + Rainbow(" No powers have been added.").bright

      else # DID NOT RECEIVE A VALID INPUT OF 1, 2, OR 'EXIT'
          puts "Please enter a valid response."
          puts "Enter (1) for a random power, or (2) to select one from the power bank."
          puts "Or, enter 'exit' to exit without adding a power."
          self.selection = gets.chomp! until self.basic_y_n_e_validation
      end
    end

    def learn_more_loop(domain)
        while YES_ARRAY.include?(self.selection)
            puts "\n" + Rainbow(" ? ").bright.bg("CFAEE2") + Rainbow(" Which power would you like to read more about?").bright
            self.selection = gets.chomp!
            self.selection = gets.chomp! until self.basic_range_validation(domain.length, "learn about", "'Learn More'", self.selection )

            if self.selection != 'exit'
              view_power = domain[self.selection.to_i - 1]
              view_power.display_attributes
              puts "\n" + Rainbow(" ? ").bright.bg("CFAEE2") + Rainbow(" Would you like to read about another power? (y/n)").bright
              self.selection = gets.chomp!
              self.selection = gets.chomp! until self.basic_y_n_validation(self.selection)
            end
        end
    end

    def add_random_power
        # Generate a random power.
        # If it exists in the master Powers array, do not duplicate object.
        # If it does not exist, create it (and add it to the master array).
        # Add new power to the powers array.
        random_power = PowerScraper.new.scrape_power("https://powerlisting.fandom.com/wiki/Special:Random")
        self.selected_hero.powers << Power.find_or_create_power_given_attributes(random_power)

        # Announce new power.
        puts "\n" + Rainbow(" i ").bright.bg("F7AC7E") + "You have added the " + Rainbow("#{random_power[:name]}").underline + " superpower."

        # Learn more option.
        puts Rainbow(" ? ").bright.bg("F7AC7E") + Rainbow(" Would you like to learn more about your new power? (y/n)").bright
        self.selection = gets.chomp!
        self.selection = gets.chomp! until self.basic_y_n_validation(self.selection)
        Power.find_by_name(random_power[:name]).display_attributes if YES_ARRAY.include?(self.selection)

        # List all of the hero's powers.
        puts "\n" + Rainbow(" i ").bright.bg("F7AC7E") + Rainbow(" Here are the #{self.selected_hero.hero_villain}'s current powers:\n").bright
        puts self.selected_hero.list_powers
        puts "\n- - - - - - - - - - - - - - - - - - - - - - - - - - - -\n"
    end

    def add_power_from_library
        # List all powers in Power.all library
        puts "\n" + Rainbow(" i ").bright.bg("F7AC7E") + Rainbow(" Here are the powers you can choose from:\n").bright
        puts Power.list_all

        # Option to learn more about any power in library.
        puts "\n" + Rainbow(" ? ").bright.bg("F7AC7E") + Rainbow(" Would you like to learn more about a power before adding? (y/n)").bright
        self.selection = gets.chomp!
        self.selection = gets.chomp! until self.basic_y_n_validation(self.selection)
        self.learn_more_loop(Power.all)

        # Power selection
        puts "\n" + Rainbow(" ? ").bright.bg("F7AC7E") + Rainbow(" Which power would you like to add?").bright
        puts "    (To exit without adding a power, enter 'exit'.)"
        self.selection = gets.chomp!
        self.selection = gets.chomp until self.basic_range_validation(Power.all.length, "add", "'Add Power'", self.selection)

        # If valid number selection, find that power (by name) in the Power.all array.
        if (1..Power.all.length).include?(self.selection.to_i)
            new_power = Power.find_by_name(Power.all[self.selection.to_i - 1].name)

            # Check to see if the hero already has that power.
            # If no, add it, if yes, deny request.
            if !self.selected_hero.powers.include?(new_power)
                self.selected_hero.powers << new_power
                puts "\n" + Rainbow(" i ").bright.bg("F7AC7E") + " You have added the " + Rainbow("#{new_power.name}").underline + " superpower."
            else
                puts "\n" + Rainbow(" ! ").bright.bg("F7AC7E") + Rainbow(" Your #{self.selected_hero.hero_villain} already has that power.").bright
            end
        end

        # List the hero's powers only if they have powers to list.
        if self.selected_hero.list_powers.length > 0
            puts "\n" + Rainbow(" i ").bright.bg("F7AC7E") + Rainbow(" Here are the #{self.selected_hero.hero_villain}'s current powers:\n").bright
            puts self.selected_hero.list_powers
            puts "\n- - - - - - - - - - - - - - - - - - - - - - - - - - - -\n"
        else
            puts "\n" + Rainbow(" ! ").bright.bg("F7AC7E") + Rainbow(" Your #{self.selected_hero.hero_villain} currently has no powers.").bright
        end
    end
end
