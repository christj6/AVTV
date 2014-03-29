
# not needed to run the av club file; this is just a side thing

require 'rubygems'
require 'nokogiri' 
require 'open-uri'
require 'mechanize'
   

agent = Mechanize.new

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

  puts directorPage.uri.to_s

  movies = Array.new

  puts page.css('div div div div div div div div div b a')
  



  end
