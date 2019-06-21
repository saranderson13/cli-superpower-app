require_relative '../config/environment'

class Hero
  extend Resources::InputValidation
  extend Resources::Findable
  include Resources::InputValidation
  include Resources::Listify

  attr_accessor :hero_name, :secret_identity, :pos_traits, :neg_traits, :alignment, :table, :hero_villain, :temp_hero
  attr_reader :powers

  def self.temp
    @@temp
  end

  def self.temp=(temporary_hero)
    @@temp = temporary_hero
  end

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

  def self.generate_temp_hero
    self.temp = self.new
    3.times do
      # binding.pry
      Hero.temp.powers << Power.find_or_create_power_given_attributes(PowerScraper.new.scrape_power(BASE_URL + "/wiki/Special:Random"))
    end

    self.temp.pos_traits = PersonalityScraper.positives.sample(3)
    self.temp.neg_traits = PersonalityScraper.negatives.sample(3)
    self.temp.alignment = ALIGNMENTS.sample
  end

  def self.alignment_and_descriptor
    # CHOOSE DESCRIPTORS BASED ON ALIGNMENT
    if ["Lawful Good", "Neutral Good", "Chaotic Good"].include?(self.temp.alignment)
      call_trait = self.temp.pos_traits.sample.downcase
      self.temp.hero_villain = "hero"
    elsif ["Lawful Evil", "Neutral Evil", "Chaotic Evil"].include?(self.temp.alignment)
      call_trait = self.temp.neg_traits.sample.downcase
      self.temp.hero_villain = "villain"
    else
      call_trait = [self.temp.pos_traits, self.temp.neg_traits].flatten!.sample.downcase
      self.temp.hero_villain = ["hero", "villain"].sample
    end
    call_trait
  end
  ## DISPLAY ABBREVIATED POWER PROFILE - POWERS AND TRAITS ONLY
  def self.display_starter_table
    self.temp.generate_hero_table
    self.temp.display_hero
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
end
