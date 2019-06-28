require_relative '../config/environment'

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
    self.all.map.with_index { |pwr, i| Rainbow("    #{i + 1}.").bright + " #{pwr.name}" }
  end

  ### Scrapes a batch of random pages, & returns an array of new Power objects.
  def self.populate_library(selection)
      new_powers = []
      until new_powers.length == selection.to_i
        # Scrape a random power page
        temp_attr = PowerScraper.new.scrape_power(BASE_URL + "/wiki/Special:Random")
        # Create power from scrape IF IT DOES NOT EXIST IN LIBRARY ALREADY
        new_powers << Power.new(temp_attr) if !self.find_by_name(temp_attr[:name])
      end
      new_powers
  end

  ### Method to add starter powers to the library
  def self.startup_populate_lib
      15.times { Power.new(PowerScraper.new.scrape_power(BASE_URL + "/wiki/Special:Random")) }
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
end
