
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
            puts "\nResponse is out of range. Please enter a valid response."
            if action_verb == "add" || action_verb == "remove" || action_verb == "view"
              puts "Enter the number that corresponds to the option you would like to #{action_verb}."
            elsif action_verb == "generate"
              puts "Enter the number of powers you would like to #{action_verb}"
              puts "You can #{action_verb} a maximum of #{upper_limiter} powers at a time."
            end
            puts "Or to exit the #{interface} interface, enter 'exit'."
            false
        end
    end

    def super_basic_range_validation(upper_limiter, selection)
        if (1..upper_limiter).include?(selection.to_i) || selection == 'exit'
            true
        else
            puts "Response is out of range. Please enter a valid response."
            false
        end
    end

    def basic_y_n_validation(selection)
        if YES_ARRAY.include?(selection) || NO_ARRAY.include?(selection)
            true
        else
            puts "Please enter a valid response. (y/n)"
            false
        end
    end

    def basic_y_n_e_validation(selection)
      if YES_ARRAY.include?(selection) || NO_ARRAY.include?(selection) || selection == 'exit'
          true
      else
          puts "Please enter a valid response. (y/n/exit)"
          false
      end
    end

    def basic_cli_validation(selection)
      if (1..4).include?(selection)
        true
      else
        puts "Please enter a valid selection ( 1 / 2 / 3 / 4 )"
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
