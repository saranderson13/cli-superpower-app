
#CONSTANTS
BASE_URL = "https://powerlisting.fandom.com"
YES_ARRAY = ["y", "Y", "Yes", "yes", "YES"]
NO_ARRAY = ["n", "N", "No", "no", "NO"]
ALIGNMENTS = ["Lawful Good", "Lawful Neutral", "Lawful Evil", "Neutral Good", "True Neutral", "Neutral Evil", "Chaotic Good", "Chaotic Neutral", "Chaotic Evil"]

module Resources
  module InputValidation
    ### INPUT VALIDATION METHODS
    def basic_range_validation(upper_limiter, action_verb, interface, selection)
        if (1..upper_limiter).include?(selection.to_i) || selection == 'exit'
            true
        else
            puts  Rainbow("\n #{10022.chr("UTF-8")} ERROR: Input out of range. Please enter a valid input.").bright.bg("FF7575")
            if action_verb == "add" || action_verb == "remove" || action_verb == "view"
              puts "\n   Enter the number that corresponds to the option you would like to #{action_verb}."
            elsif action_verb == "generate" # USED FOR POWER GENERATION ONLY
              puts "\n   Enter the number of powers you would like to #{action_verb}"
              puts "   You can #{action_verb} a maximum of #{upper_limiter} powers at a time."
            end
            puts "   Or to exit the '#{interface}' interface, enter 'exit'."
            puts "\n- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
            false
        end
    end

    def super_basic_range_validation(upper_limiter, selection)
        if (1..upper_limiter).include?(selection.to_i) || selection == 'exit'
            true
        else
          puts Rainbow("\n #{10022.chr("UTF-8")} ERROR: Input out of range. Please enter a valid input.").bright.bg("FF7575")
          puts "\n- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
            false
        end
    end

    def basic_y_n_validation(selection)
        if YES_ARRAY.include?(selection) || NO_ARRAY.include?(selection)
            true
        else
            puts Rainbow("\n #{10022.chr("UTF-8")} ERROR: Input out of range. Please enter a valid input.").bright.bg("FF7575")
            puts "\n   Enter 'y' for yes, or 'n' for no"
            puts "\n- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
            false
        end
    end

    def basic_y_n_e_validation(selection)
      if YES_ARRAY.include?(selection) || NO_ARRAY.include?(selection) || selection == 'exit'
          true
      else
          puts Rainbow("\n #{10022.chr("UTF-8")} ERROR: Input out of range. Please enter a valid input.").bright.bg("FF7575")
          puts "\n   Enter 'y' for yes, 'n' for no, or 'exit' to return to the root menu."
          puts "\n- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
          false
      end
    end

    def basic_cli_validation
      if (1..4).include?(self.selection)
        true
      else
        puts Rainbow("\n #{10022.chr("UTF-8")} ERROR: Input out of range. Please enter a valid input.").bright.bg("FF7575")
        puts "\n   Enter a number that corresponds to a menu option, or 'exit' to exit the program."
        puts Rainbow("   WARNING:").bright.red + " Exiting the program will erase your character and power libraries."
        puts "\n- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
        false
      end
    end
  end


  module Findable
    def find_by_name(name)
      self.all.detect { |object| object if object.name == name }
    end
  end

  module Listify
    def listify(array)
      string = ""
      array.map.with_index { |item, i| string << Rainbow("#{i + 1}.").bright + "#{item}\n" }
      string
    end
  end
end
