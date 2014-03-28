
=begin

Given the name of a television show, this program gathers the grades AV Club gave to every episode it reviewed,
and creates a contour/graph where A = 11, A- = 10, B+ = 9 ... F = 0.
This contour is printed to the console in ascii format.

Sample Output:
-------------------------------
Breaking Bad:
season 1
7
season 2
13
season 3
13
season 4
13
season 5
16
          X       X   X     X X X   X X X   X   X X X   X X   X X                     X X X           X   X X     X X X   X
X X X   X     X     X   X X                                 X       X   X     X     X       X X X X X   X     X X       X
            X   X                         X                       X   X   X X   X X
                                  X           X       X
      X

----------------------------------------------------------------
=end

require 'rubygems'
require 'nokogiri' 
require 'open-uri'
require 'mechanize'
   

agent = Mechanize.new



# AV Club Grades: A, A-, B+, B, B-, C+, C, C-, D+, D, D-, F
# on metacritic, they correspond with: 100, 91, 83, 80, 75, 70, 67, 60, 58, 50, 42, 40 (SKIP), 33, 25, 16, 0

# Put these lines back in afterwards
puts "Enter the name of a television show."
_show = gets.chomp

agent.get('http://www.avclub.com/tv/') do |page|
  search_result = page.form_with(:action => '/search/') do |search|
    search.q = _show
  end.submit

  # grab exact spelling of show so the user doesn't have to capitalize it exactly
  page = Nokogiri::HTML(open(search_result.uri.to_s))
  results = page.css('section ul li a')

  puts "You searched for: "

  for i in 0..results.length-1
  	puts (i+1).to_s + ": " + results[i].inner_html
  end

  puts "" # make it easier on the eyes

  if results.length > 1
  	puts "Which one is it? Enter the corresponding number."
  	userChoice = gets.chomp
  	reviews = search_result.link_with(text: results[userChoice.to_i-1].inner_html).click
  else
  	reviews = search_result.link_with(text: results[0].inner_html).click
  end

  puts "" # make it easier on the eyes


  grades = Array.new
  graphY = Array.new
  validSeasons = Array.new

  #fetch the number of TV Season buttons on the show's page
  page = Nokogiri::HTML(open(reviews.uri.to_s))
  validSeasons = page.css('nav a').select{|link| link['data-ct_href'] == "tvSeasonButton"}


  # this function takes a given TV season and pushes it onto the Grades array
  def pushSeason (index, reviews, grades, validSeasons)
  	  puts "season " + validSeasons[index].inner_html
	  if index != 0 then
	  	season = reviews.link_with(class: "badge season-" + validSeasons[index].inner_html).click.search('.grade.letter.tv').reverse
	  else
	  	season = reviews.search('.grade.letter.tv').reverse
	  end
	  season.pop # the latest episode is at the top of every page, remove it from the list
	  season.pop # maybe implement something where you fetch the top episode's ID and make sure the last one isn't that,
	  season.pop # except in the caes of the final season/latest season of the show where it is.
	  season = season.reverse
	  puts season.length.to_s + " episodes"
	  while season.length > 0 do
	  	grades.push(season.pop.inner_text())
	  end
  end

  for i in 0..validSeasons.length-1
  	pushSeason(validSeasons.length-1 - i, reviews, grades, validSeasons)
  end

  while grades.length > 0 do
  	case grades.pop
  	when "A"
  		graphY.push(11)
  	when "A-"
  		graphY.push(10)
  	when "B+"
  		graphY.push(9)
  	when "B"
  		graphY.push(8)
  	when "B-"
  		graphY.push(7)
  	when "C+"
  		graphY.push(6)
  	when "C"
  		graphY.push(5)
  	when "C-"
  		graphY.push(4)
  	when "D+"
  		graphY.push(3)
  	when "D"
  		graphY.push(2)
  	when "D-"
  		graphY.push(1)
  	when "F"
  		graphY.push(0)
  	else
  		graphY.push(-1) # Sopranos Season 5 has no reviews. This allows the contour to skip over season 5, but still present the gap.
  	end
  end

  	# writes a text file containing the numbers corresponding to each grade
    begin
	  file = File.open("numberList.txt", "w")
	  for i in 0..graphY.length-1
	  	file.write(graphY[i].to_s + "\n")
	  end 
	rescue IOError => e
	  #some error occur, dir not writable etc.
	ensure
	  file.close unless file == nil
	end



  # this prints the values corresponding with each AV Club grade in ascii format
for i in 0..11
	for j in 0..graphY.length-1
		_yFlip = 11 - i; # flips the value, since the graph counts upside down

		if graphY[graphY.length-1 - j] == _yFlip then
			print "X "
		else
			print "  "
		end
		STDOUT.flush
	end
	puts ""
end
  
  




end
