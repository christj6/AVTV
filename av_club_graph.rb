
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
#puts "Enter the name of a television show (be sure to capitalize)"
#_show = gets.chomp
_show = 'Breaking Bad'

agent.get('http://www.avclub.com/tv/') do |page|
  search_result = page.form_with(:action => '/search/') do |search|
    search.q = _show
  end.submit

  reviews = search_result.link_with(text: _show).click


  grades = Array.new
  graphX = Array.new
  graphY = Array.new

  puts "season 1"
  season = reviews.link_with(class: "badge season-1").click.search('.grade.letter.tv').reverse
  season.pop # the latest episode is at the top of every page, remove it from the list
  season.pop
  season = season.reverse
  puts season.length
  while season.length > 0 do
  	grades.push(season.pop.inner_text())
  end

  puts "season 2"
  season = reviews.link_with(class: "badge season-2").click.search('.grade.letter.tv').reverse
  season.pop # the latest episode is at the top of every page, remove it from the list
  season.pop
  season = season.reverse
  puts season.length
  while season.length > 0 do
  	grades.push(season.pop.inner_text())
  end

  puts "season 3"
  season = reviews.link_with(class: "badge season-3").click.search('.grade.letter.tv').reverse
  season.pop # the latest episode is at the top of every page, remove it from the list
  season.pop
  season = season.reverse
  puts season.length
  while season.length > 0 do
  	grades.push(season.pop.inner_text())
  end

  puts "season 4"
  season = reviews.link_with(class: "badge season-4").click.search('.grade.letter.tv').reverse
  season.pop # the latest episode is at the top of every page, remove it from the list
  season.pop
  season = season.reverse
  puts season.length
  while season.length > 0 do
  	grades.push(season.pop.inner_text())
  end

  puts "season 5"
  season = reviews.search('.grade.letter.tv').reverse
  season.pop # the latest episode is at the top of every page, remove it from the list
  season.pop
  season = season.reverse
  puts season.length
  while season.length > 0 do
  	grades.push(season.pop.inner_text())
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
  		puts "error"
  	end
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
