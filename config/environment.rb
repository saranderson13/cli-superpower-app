require 'bundler/setup'
Bundler.require(:default, :development, :test)

require 'pry'
require 'nokogiri'
require 'open-uri'
require 'rainbow'
require 'tty-table'

require './lib/resources.rb'
require './lib/power_profile.rb'
require './lib/scrapers.rb'
require './lib/hero.rb'
require './lib/command_prompt.rb'
