# require 'nokogiri'
# require 'open-uri'
# require 'pry'
require_relative '../config/environment'

class PowerScraper
  def scrape_power(url)
    doc = Nokogiri::HTML(open(url))
    # name: doc.css("#PageHeader.page-header .page-header__main h1.page-header__title").text
    # short_descrip: & capabilities: doc.css("#mw-content-text p").text
    power_profile = {
      name: doc.css("#PageHeader.page-header .page-header__main h1.page-header__title").text
    }

    # Parse first paragraph to extract :short_descrip, :variation_of, :version_of, :pinnacle_of, :sub_power_of, and :opposite_of.
    # Isolate first paragraph.
    descriptions = doc.css("#mw-content-text p")[0].text.split(".")

    # :short_descrip = first sentence
    power_profile[:short_descrip] = "#{descriptions[0]}."

    # Check for :variation_of, :version_of, :pinnacle_of, :sub_power_of, and :opposite_of, and assign if found.
    descriptions.each do |line|
      case
      when line =~ /variation/i
          power_profile[:variation_of] = "#{line.strip}."
        when line =~ /version/i
          power_profile[:version_of] = "#{line.strip}."
        when line =~ /pinnacle/i
          power_profile[:pinnacle_of] = "#{line.strip}."
        when line =~ /sub-power/i
          power_profile[:sub_power_of] = "#{line.strip}."
        when line =~ /opposite/i
          power_profile[:opposite_of] = "#{line.strip}."
      end
    end

    # Parse lists
    pull_these = ["Capabilities", "Also Called", "Applications", "Associations", "Limitations", "Techniques"]
    doc.css("h2").each do |heading|
      if pull_these.include?(heading.text)
        # Normalize symbol name.
        sym = heading.text.gsub(/"/, "").downcase.split(" ").join("_").to_sym


        if sym == :capabilities # pull Capabilities
          power_profile[sym] = ""
          jump = heading
          until jump.next_element.name != "p"
            power_profile[sym] << jump.next_element.text + "\n"
            jump = jump.next_element
          end
        else # Collect and format ordinary list items.
          # Create category in hash
          power_profile[sym] = heading.next_element.children.map  do |child|
            list_item = {}
            sub_list = []

            # List item contains source material (which is included in parenthesis)
            if child.children[0] && child.children[0].text[-1] == '('
              list_item[:display] = child.text.split(" (").join(" from \'").gsub(/\)\n/, "'").strip
            else # List item is a single element (no source).
              if child.children.css('ul li').length > 0 # List item contains a sublist.
                # binding.pry
                list_item[:display] = child.text.split(/\n/)[0].strip
              else #List item is a simple string.
                list_item[:display] = child.text.gsub(/\n/, "").strip
              end
            end

            # Collect url for list item, if one exists
            if child.css('a').attribute('href')
              list_item[:name] = child.css("a").attribute("title").value if child.css("a").attribute("title")
              list_item[:url] = child.css("a").attribute("href").value if child.css("a").attribute("href")
            end

            # Parse a sublist, if one exists
            if child.children.css('ul li').length > 0
              child.children.css('ul li').map do |child|
                sub_list_item = {}
                # Sub-list item contains source material (which is included in parenthesis)
                if child.children[0] && child.children[0].text[-1] == '('
                  sub_list_item[:display] = child.text.split(" (").join(" from \'").gsub(/\)\n/, "'").strip
                else # Sub-list item is a simple string.
                  sub_list_item[:display] = child.text.gsub(/\n/, "").strip
                end
                # Collect url for sublist item if one exists
                if child.css('a').attribute('href')
                  sub_list_item[:name] = child.css("a").attribute("title").value
                  sub_list_item[:url] = child.css("a").attribute("href").value
                end

                # Add sublist item to sub_list
                sub_list << sub_list_item
              end

              # Add sublist to list_item
              list_item[:sublist] = sub_list
            end

            list_item
          end
        end
      end
    end


    power_profile
    # binding.pry
  end
end

class PersonalityScraper
  # attr_accessor :positives, :negatives
  @@positives = []
  def self.positives
    @@positives
  end

  @@negatives = []
  def self.negatives
    @@negatives
  end

  def scrape_traits(url = "https://teachingmadepractical.com/character-traits-list/")
    doc = Nokogiri::HTML(open(url))
    # binding.pry
    self.class.positives << doc.css("div#x-section-8 p").text.split("\n")
    self.class.positives.flatten!
    self.class.negatives << doc.css("div#x-section-10 p").text.split("\n")
    self.class.negatives.flatten!
  end

end
# traits = PersonalityScraper.new.scrape_traits
# scraper.scrape_traits
# scraper.scrape_power("https://powerlisting.fandom.com/wiki/Special:Random")
