# Assignment 1 - Part 4
# Ruby webscraper
# Jack Christiansen

require 'rubygems'
require 'nokogiri' 
require 'open-uri'
require 'mechanize'
   
page = Nokogiri::HTML(open('http://www.avclub.com/tv/'))   
agent = Mechanize.new


#array = Hash.new # stores 2 dimensional array in hash, uses coordinates as hash function

class Graph
	@show 
	@url
	@grades = Array.new

	def initialize
		#@url = "http://www.avclub.com/tvclub/breaking-bad-pilot-17025"
		#puts "Enter the name of a television show"
		#@show = gets.chomp
	end

	def print
		puts "blah"
	end
end

tvGraph = Graph.new

#tvGraph.print

page.css('div#search-flyout').each do |el|
   #puts el.text
end

#avHomePage = agent.get('http://www.avclub.com/tv/')
#pp avHomePage
#searchBox = avHomePage.form('search-flyout')

agent.get('http://www.avclub.com/tv/') do |page|
  search_result = page.form_with(:action => '/search/') do |search|
    search.q = 'breaking bad'
  end.submit

  search_result.links.each do |link|
    puts link.text
  end
end
