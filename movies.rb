
# not needed to run the av club file; this is just a side thing

require 'rubygems'
require 'nokogiri' 
require 'open-uri'
require 'mechanize'
   

agent = Mechanize.new

#puts "Enter the name of a film director"
#_searchTerm = gets.chomp
_searchTerm = "Paul Thomas Anderson"

agent.get('http://www.imdb.com/') do |page|
  search_result = page.form_with(:action => '/find') do |search|
    search.q = _searchTerm
  end.submit

  page = Nokogiri::HTML(open(search_result.uri.to_s))
  result = page.css('div table tr td a')[1]
  directorPage = search_result.link_with(text: result.inner_html).click

  page = Nokogiri::HTML(open(directorPage.uri.to_s))
  #puts directorPage.uri.to_s
  movieLinks = page.css('b a')

  # storing the data
  titles = Array.new
  runTimes = Array.new

  for i in 0..movieLinks.length-1
  	#
  	if movieLinks[i].to_s.include? "dr_" # retrieve the movies he/she directed
  		#puts movieLinks[i]

  		title = directorPage.link_with(text: movieLinks[i].inner_html).to_s
  		moviePage = directorPage.link_with(text: title).click
  		page = Nokogiri::HTML(open(moviePage.uri.to_s))
  		runTime = page.css('time').inner_html.to_s
  		#puts title + ": " + runTime
  		#if runTime.includes? "\n"
  		runTime = runTime.delete("min")
  		runTime = runTime.delete(' ')

  		titles.push(title)
  		runTimes.push(runTime.to_i)


  		#if i > 1
  			#
  			#if titles[i].includes? titles[i-1]
  				#puts runTime.to_s
  			#end
  		#end

  	end
  end

puts titles
puts runTimes
  



 end
