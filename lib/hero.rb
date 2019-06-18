require_relative '../config/environment'
# include InputValidation

class Hero
  extend Resources::InputValidation
  extend Resources::Findable
  include Resources::InputValidation
  include Resources::Listify

  attr_accessor :hero_name, :secret_identity, :pos_traits, :neg_traits, :alignment, :table, :hero_villain
  attr_reader :powers

  @@all = []
  def self.all
      @@all
  end

  def self.list_all
    self.all.map.with_index { |hero, i| "#{i + 1}. #{hero.hero_name}" }
  end

  # def self.all_heroes
  #   self.all.map { |super| super if super.hero_villain == "hero" }.compact!
  # end
  #
  # def self.all_villains
  #   self.all.map { |super| super if super.hero_villain == "villain" }.compact!
  # end

  def list_powers
      self.powers.map.with_index { |pwr, i| "#{i + 1}. #{pwr.name}" }
  end

  def power_names
      self.powers.map { |pwr| pwr.name }
  end

  def initialize
      @powers = []
  end

  def self.generate_hero
    nameless_hero = self.new
    3.times do
      random_power = PowerScraper.new.scrape_power("https://powerlisting.fandom.com/wiki/Special:Random")
      nameless_hero.powers << Power.find_or_create_power_given_attributes(random_power)
    end

    nameless_hero.pos_traits = PersonalityScraper.positives.sample(3)
    nameless_hero.neg_traits = PersonalityScraper.negatives.sample(3)
    nameless_hero.alignment = ALIGNMENTS.sample

    # CHOOSE DESCRIPTORS BASED ON ALIGNMENT
    if ["Lawful Good", "Neutral Good", "Chaotic Good"].include?(nameless_hero.alignment)
      call_trait = nameless_hero.pos_traits.sample.downcase
      nameless_hero.hero_villain = "hero"
    elsif ["Lawful Evil", "Neutral Evil", "Chaotic Evil"].include?(nameless_hero.alignment)
      call_trait = nameless_hero.neg_traits.sample.downcase
      nameless_hero.hero_villain = "villain"
    else
      call_trait = [nameless_hero.pos_traits, nameless_hero.neg_traits].flatten!.sample.downcase
      nameless_hero.hero_villain = ["hero", "villain"].sample
    end

    ## DISPLAY ABBREVIATED POWER PROFILE - POWERS AND TRAITS ONLY
    puts "\nHere are the new #{nameless_hero.hero_villain}'s starter stats:"
    nameless_hero.generate_hero_table
    nameless_hero.display_hero

    puts "\nWhat should we call this #{call_trait} soul?"
    selection = gets.chomp!
    nameless_hero.hero_name = selection
    puts "\nThis #{nameless_hero.hero_villain} will henceforth be known as " + Rainbow("#{nameless_hero.hero_name}").bright + "!"

    puts "\nWhy not give " + Rainbow("#{nameless_hero.hero_name}").bright + " a secret identity?"
    selection = gets.chomp!
    nameless_hero.secret_identity = selection
    puts "\nYour #{nameless_hero.hero_villain} has been created and added to the database!"
    self.all << nameless_hero
    nameless_hero.display_hero
  end

  def generate_hero_table
    self.table = TTY::Table.new [
      [Rainbow("           Alignment: ").bg(:silver), "#{self.hero_villain.capitalize} - #{self.alignment}"],
      [Rainbow("              Powers: ").bg(:silver), "#{self.listify(self.power_names)}"],
      [Rainbow("         Good Traits: ").bg(:silver), "#{self.listify(self.pos_traits)}"],
      [Rainbow("  Not-so-good Traits: ").bg(:silver), "#{self.listify(self.neg_traits)}"],
    ]
  end

  def display_hero
    puts Rainbow("\n- - - - - #{self.hero_name}").magenta.bright if self.hero_name
    puts Rainbow("- - - - - AKA: #{self.redact}").magenta if self.secret_identity
    puts self.table.render(:ascii, multiline: true, column_widths: [25, 50], padding: [0, 0, 1, 0], alignments: [:center, :left])
  end

  def redact
    "REDACTED"
  end

  ### HERO POWER METHODS (ADD / REPLACE IN BULK / REMOVE)
  def add_power_prompt
      puts Rainbow("\nDo you want to:").bright
      puts "1. Add a random power?"
      puts "2. Select a power from the powers bank?"
      puts "Or, to exit without adding a power, enter 'exit'."
      selection = gets.chomp!

      if selection == "1" # ADD RANDOM POWER
          self.add_random_power

      elsif selection == "2" #SELECT FROM BANK
          self.add_power_from_library

      elsif selection == "exit" # USER WISHES TO EXIT WITHOUT ADDING A POWER.
          puts Rainbow("\nNo powers have been added.").bright

      else # DID NOT RECEIVE A VALID INPUT OF 1, 2, OR 'EXIT'
          puts "Please enter a valid response."
          puts "Enter (1) for a random power, or (2) to select one from the power bank."
          puts "Or, enter 'exit' to exit without adding a power."
          selection = gets.chomp! until self.basic_y_n_e_validation
      end
  end

  def replace_powers_prompt
      # WARNING NOTICE
      puts Rainbow("WARNING: ").red.bright + Rainbow("You are about to erase all of this #{self.hero_villain}'s powers.").bright
      puts Rainbow("This change will be permanent.").bright

      puts "\nWould you like to view this #{self.hero_villain}'s powers before continuing?"
      selection = gets.chomp!
      selection = gets.chomp! until self.basic_y_n_validation(selection)
      puts self.list_powers if YES_ARRAY.include?(selection)

      # DOUBLE CHECK
      puts "\nWould you like to delete all of this #{self.hero_villain}'s powers and generate new ones?"
      selection = gets.chomp!
      selection = gets.chomp! until self.basic_y_n_validation(selection)

      # Clear powers, ask for num of new powers
      if YES_ARRAY.include?(selection)
          self.powers.clear
          puts "\nYou may add up to five powers at a time."
          puts "How many powers would you like to add?"
          selection = gets.chomp!
          selection = gets.chomp! until basic_range_validation(5, "generate", "Replace Powers", selection)
          selection.to_i.times { self.add_power_prompt } if selection != "exit"
      else
          puts Rainbow("\nNo powers have been deleted or added.").bright
      end
  end

  def remove_power_prompt
      if self.powers.length > 0
          puts Rainbow("\nThe current powers are:\n").bright
          puts self.list_powers
          puts Rainbow("\nRead more about the powers before choosing? (y/n)").bright
          selection = gets.chomp!
          selection = gets.chomp! until self.basic_y_n_validation(selection)

          self.class.learn_more_loop(self.powers, selection) if YES_ARRAY.include?(selection)

          puts Rainbow("\nWhich power would you like to delete from your #{self.hero_villain}?").bright
          puts "Enter the number that corresponds to the power you would like to delete."
          puts "Or to exit without deleting a power, enter 'exit'."
          selection = gets.chomp!
          selection = gets.chomp! until self.basic_range_validation(self.powers.length, "delete", "Power Removal", selection)

          if (1..self.powers.length).include?(selection.to_i)
            puts "\nYou have deleted the " + Rainbow("#{self.powers[selection.to_i - 1].name}").underline + " superpower."
            self.powers.delete_at(selection.to_i - 1) if (1..self.powers.length).include?(selection.to_i)
          else puts Rainbow("\nNo powers have been deleted.").bright
          end
          puts Rainbow("\nHere are the #{self.hero_villain}'s current powers:").bright
          puts self.list_powers
      else
        puts "\nThere are no powers to delete."
      end
  end



  ### POWER METHOD HELPER METHODS
  def self.learn_more_loop(domain, selection)
      while YES_ARRAY.include?(selection)
          puts "Which power would you like to read more about?"
          selection = gets.chomp!
          selection = gets.chomp! until self.basic_range_validation(domain.length, "learn about", "'Learn More'", selection )

          if selection != 'exit'
            view_power = domain[selection.to_i - 1]
            view_power.display_attributes
            puts "Would you like to read about another power? (y/n)"
            selection = gets.chomp!
            selection = gets.chomp! until self.basic_y_n_validation(selection)
          end
      end
  end




  ### POWER ADDING OPTIONS
  def add_random_power
      # Generate a random power.
      # If it exists in the master Powers array, do not duplicate object.
      # If it does not exist, create it (and add it to the master array).
      # Add new power to the powers array.
      random_power = PowerScraper.new.scrape_power("https://powerlisting.fandom.com/wiki/Special:Random")
      self.powers << Power.find_or_create_power_given_attributes(random_power)

      # Announce new power.
      puts "You have added the " + Rainbow("#{random_power[:name]}").underline + " superpower."

      # Learn more option.
      puts "Would you like to learn more about your new power? (y/n)"
      selection = gets.chomp!
      selection = gets.chomp! until self.basic_y_n_validation(selection)
      Power.find_by_name(random_power[:name]).display_attributes if YES_ARRAY.include?(selection)

      # List all of the hero's powers.
      puts "\nHere are the #{self.hero_villain}'s current powers:"
      puts self.list_powers
  end

  def add_power_from_library
      # List all powers in Power.all library
      puts Rainbow("Here are the powers you can choose from:").bright
      puts Power.list_all

      # Option to learn more about any power in library.
      puts Rainbow("\nWould you like to learn more about a power before adding? (y/n)").bright
      selection = gets.chomp!
      selection = gets.chomp! until self.basic_y_n_validation(selection)
      self.class.learn_more_loop(Power.all, selection)

      # Power selection
      puts Rainbow("\nWhich power would you like to add?").bright
      puts "(To exit without adding a power, enter 'exit'.)"
      selection = gets.chomp!
      selection = gets.chomp until basic_range_validation(Power.all.length, "add", "'Add Power'", selection)

      # If valid number selection, find that power (by name) in the Power.all array.
      if (1..Power.all.length).include?(selection.to_i)
          new_power = Power.find_by_name(Power.all[selection.to_i - 1].name)

          # Check to see if the hero already has that power.
          # If no, add it, if yes, deny request.
          if !self.powers.include?(new_power)
              self.powers << new_power
              puts "\nYou have added the " + Rainbow("#{new_power.name}").underline + " superpower."
          else
              puts "\nYour #{self.hero_villain} already has that power."
          end
      end

      # List the hero's powers only if they have powers to list.
      if self.list_powers.length > 0
          puts Rainbow("\nHere are the #{self.hero_villain}'s current powers:\n").bright
          puts self.list_powers
      else
          puts "\nYour #{self.hero_villain} currently has no powers."
      end
  end
end

# hero = Hero.new
# hero.add_random_power
# hero.add_random_power
# hero.add_random_power
# hero.remove_power_prompt
