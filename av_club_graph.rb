

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







# Put these lines back in afterwards
#puts "Enter the name of a television show"
#_show = gets.chomp
_show = 'breaking bad'

agent.get('http://www.avclub.com/tv/') do |page|
  search_result = page.form_with(:action => '/search/') do |search|
    search.q = _show
  end.submit

  reviews = search_result.link_with(text: _show)
  puts reviews

  #search_result.links.with(:href => '/tv/breaking-bad/').each do |link|
    #puts link.text
  #end


end
