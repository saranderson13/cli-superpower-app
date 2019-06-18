require_relative '../config/environment'
# extend InputValidation
# extend Findable

class Power
  extend Resources::InputValidation
  extend Resources::Findable
  include Resources::Listify

  attr_accessor :name, :url, :short_descrip, :variation_of, :version_of, :pinnacle_of, :sub_power_of, :opposite_of, :capabilities, :also_called, :applications, :associations, :limitations, :techniques
  attr_reader :heroes

  # POWER LIBRARY & ASSOCIATED METHODS
  @@all = []
  def self.all ### Class variable reader
    @@all
  end
  def self.clear ### Class variable eraser
    @@all.clear
  end
  def self.list_all ### Formatted list of all powers in library (precede with 'puts' to call)
    self.all.map.with_index { |pwr, i| "#{i + 1}. #{pwr.name}" }
  end

  ### Command Prompt to manually populate the library
  def self.populate_library
      puts "\nYou can randomly generate 10 superpowers at a time."
      puts "How many powers would you like to send to the library?"
      selection = gets.chomp!
      selection = gets.chomp! until self.basic_range_validation(10, "generate", "Populate Library", selection)

      if selection != "exit"
        powers = []
        until powers.length == selection.to_i
          # Scrape a random power page
          temp_attr = PowerScraper.new.scrape_power(BASE_URL + "/wiki/Special:Random")
          # Create power from scrape IF IT DOES NOT EXIST IN LIBRARY ALREADY
          powers << Power.new(temp_attr) if !self.find_by_name(temp_attr[:name])
        end
        # List new powers
        puts "\nThe following powers have been added to your library: "
        powers.each_with_index { |pwr, i| puts "#{i + 1}. #{pwr.name}" }
        puts "- - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
      end
  end

  ### Method to add starter powers to the library
  def self.startup_populate_lib
      15.times { Power.new(PowerScraper.new.scrape_power(BASE_URL + "/wiki/Special:Random")) }
  end

  def self.explorer
    # browse powers
  end




  ### POWER.NEW & ASSOCIATED METHODS
  def initialize(attributes)
    attributes.each { |key, value| self.send("#{key}=", value) }
    @heroes = []
    self.url_maker
    self.class.all << self
  end

  def url_maker
    self.url = BASE_URL + "/wiki/" + self.name.split(" ").join("_")
  end

  # FIND OR CREATE GIVEN ATTRIBUTES
  def self.find_or_create_power_given_attributes(attrs)
    self.find_by_name(attrs[:name]) ? Power.all.select { |pwr| pwr if pwr.name == attrs[:name] } : Power.new(attrs)
  end

  ### SCANS A POWER PROFILE FOR URLS - CREATES NEW POWERS FROM THEM IF THEY DO NOT EXIST.
  def create_all_powers_from_profile
    ### Array of all possible list attributes
    options = [self.also_called, self.applications, self.associations, self.limitations, self.techniques]

    ### Delete any given list attribute that was not generated (does not exist in object)
    options.delete_if { |option| option == nil }

    ### Extract urls from lists
    page_urls = []
    options.each do |list|
      list.each do |new_power|
        ### Extract urls from lists
        page_urls << new_power[:url] if !self.class.find_by_name(new_power[:display])

        ### If a sublist exists, extract all urls from the sublist
        new_power[:sublist].each { |new_power| page_urls << new_power[:url] if new_power[:url] } if new_power[:sublist]
      end
    end

    ### Create a new power from each pulled URL
    page_urls.compact.each { |url| Power.new(PowerScraper.new.scrape_power(BASE_URL + "#{url}")) }
  end




  ### POWER DISPLAY & ASSOCIATED METHODS
  def display_attributes
    table = TTY::Table.new [
      [Rainbow("   Brief Description: ").bg(:silver), "#{self.short_descrip}"]
    ]

    table << [Rainbow("        Variation of: ").bg(:silver), "#{self.variation_of}"] if self.variation_of
    table << [Rainbow("          Version of: ").bg(:silver), "#{self.version_of}"] if self.version_of
    table << [Rainbow("         Pinnacle of: ").bg(:silver), "#{self.pinnacle_of}"] if self.pinnacle_of
    table << [Rainbow("        Sub Power of: ").bg(:silver), "#{self.sub_power_of}"] if self.sub_power_of
    table << [Rainbow("         Opposite of: ").bg(:silver), "#{self.opposite_of}"] if self.opposite_of
    table << [Rainbow("        Capabilities: ").bg(:silver), "#{self.capabilities}"] if self.capabilities
    table << [Rainbow("     Alternate Names: ").bg(:silver), "#{self.listify(self.also_called.map { |pwr| pwr[:display] })}"] if self.also_called
    table << [Rainbow("        Applications: ").bg(:silver), "#{self.listify(self.applications.map { |pwr| pwr[:display] })}"] if self.applications
    table << [Rainbow("        Associations: ").bg(:silver), "#{self.listify(self.associations.map { |pwr| pwr[:display] })}"] if self.associations
    table << [Rainbow("         Limitations: ").bg(:silver), "#{self.listify(self.limitations.map { |pwr| pwr[:display] })}"] if self.limitations
    table << [Rainbow("  Related Techniques: ").bg(:silver), "#{self.listify(self.techniques.map { |pwr| pwr[:display] })}"] if self.techniques

    puts Rainbow("\n- - - - - #{self.name}").magenta.bright
    puts table.render(:ascii, resize: true, multiline: true, column_widths: [15, 80], padding: [0, 0, 1, 0], alignments: [:center, :left])
  end

  # def learn_options
  #   print_options = ["Alternate Names", "Applications", "Associated Powers", "Limitations", "Related Techniques"]
  #   options = [self.also_called, self.applications, self.associations, self.limitations, self.techniques]
  #   print_options.delete_if.with_index {|option, i| options[i] == nil}
  #   print_options << "See all heroes with this power" if self.heroes.length > 0
  #   option_string = Rainbow("What would you like to learn more about?").bright + "\nEnter a number to make your selection:\n"
  #   print_options.each_with_index { |option, i| option_string << "#{i + 1}. #{option}\n" }
  #   option_string
  # end
end

### MANUAL TEST
# test = {name: "Peace Empowerment", short_descrip: "The power to achieve and be empowered by inner peace.", users: ["Hiko Seijuro -- Samurai X", "Guatama Buddha -- Buddhism, Po -- Kung-Fu Panda"]}
# test_power = Power.new(PowerScraper.new.scrape_power("https://powerlisting.fandom.com/wiki/Special:Random"))
# Power.new(PowerScraper.new.scrape_power("https://powerlisting.fandom.com/wiki/Special:Random"))
# Power.new(PowerScraper.new.scrape_power("https://powerlisting.fandom.com/wiki/Special:Random"))
# test_power.url_maker
# test_power.display_attributes
# test_power.learn_options
# Power.populate_library

# test_power.create_all_powers_from_profile
