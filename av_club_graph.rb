
=begin

Given the name of a television show, this program gathers the grades AV Club gave to every episode it reviewed,
and creates a contour/graph where A = 11, A- = 10, B+ = 9 ... F = 0.
This contour is printed to the console in ascii format.

Sample Output:
-------------------------------
Enter the name of a television show.
breaking bad
You searched for:
1: Breaking Bad


season 1
7 episodes
season 2
13 episodes
season 3
13 episodes
season 4
13 episodes
season 5
16 episodes



A |- - - - - O -|- - O - O - - O O O - O O|O - O - O O O - O O - O O|- - - - - - - - - - O O O|- - - - - O - O O - - O O O - O|
A-|O O O - O - -|O - - O - O O - - - - - -|- - - - - - - - - - O - -|- O - O - - O - - O - - -|O O O O O - O - - O O - - - O -|
B+|- - - - - - O|- O - - - - - - - - - - -|- O - - - - - - - - - - -|O - O - O O - O O - - - -|- - - - - - - - - - - - - - - -|
B |- - - - - - -|- - - - - - - - - - O - -|- - - O - - - O - - - - -|- - - - - - - - - - - - -|- - - - - - - - - - - - - - - -|
B-|- - - O - - -|- - - - - - - - - - - - -|- - - - - - - - - - - - -|- - - - - - - - - - - - -|- - - - - - - - - - - - - - - -|
C+|- - - - - - -|- - - - - - - - - - - - -|- - - - - - - - - - - - -|- - - - - - - - - - - - -|- - - - - - - - - - - - - - - -|
C |- - - - - - -|- - - - - - - - - - - - -|- - - - - - - - - - - - -|- - - - - - - - - - - - -|- - - - - - - - - - - - - - - -|
C-|- - - - - - -|- - - - - - - - - - - - -|- - - - - - - - - - - - -|- - - - - - - - - - - - -|- - - - - - - - - - - - - - - -|
D+|- - - - - - -|- - - - - - - - - - - - -|- - - - - - - - - - - - -|- - - - - - - - - - - - -|- - - - - - - - - - - - - - - -|
D |- - - - - - -|- - - - - - - - - - - - -|- - - - - - - - - - - - -|- - - - - - - - - - - - -|- - - - - - - - - - - - - - - -|
D-|- - - - - - -|- - - - - - - - - - - - -|- - - - - - - - - - - - -|- - - - - - - - - - - - -|- - - - - - - - - - - - - - - -|
F |- - - - - - -|- - - - - - - - - - - - -|- - - - - - - - - - - - -|- - - - - - - - - - - - -|- - - - - - - - - - - - - - - -|
  |----------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------
=end

require 'rubygems'
require 'nokogiri' 
require 'open-uri'
require 'mechanize'
require_relative 'test.rb'

agent = Mechanize.new



# AV Club Grades: A, A-, B+, B, B-, C+, C, C-, D+, D, D-, F
# on metacritic, they correspond with: 100, 91, 83, 80, 75, 70, 67, 60, 58, 50, 42, 40 (SKIP), 33, 25, 16, 0

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
  	# choice 1: allow the user to input their choice. Might get complicated later when
  	# we have to create some whole other page for storing the possible options. If we're going with rails.
  	puts "Which one is it? Enter the corresponding number."
  	userChoice = gets.chomp
  	reviews = search_result.link_with(text: results[userChoice.to_i-1].inner_html).click
  	_show = results[userChoice.to_i-1].inner_html

  	# choice 2: compare the string and make a guess on which one is most likely the one the user intended.
=begin

	# this part compares each choice's string length to the user input's string length.
	# if a user types in "the shield", 'the shield' and 'the shield (classic)' both appear,
	# but 'the shield' has a string length closer to the user input, so it would get chosen.
	# in theory, that is what would happen, but the approach has some kinks to work out.
  	smallestDiff = 50
  	diff = 0

  	for i in 0..results.length-1
  		diff = (results[i].inner_html).to_s.length - _show.length

  		if diff.abs < smallestDiff.abs
  			matchIndex = i
  		else
  			# do nothing
  		end
  	end

  	reviews = search_result.link_with(text: results[matchIndex.to_i].inner_html).click
  	_show = results[matchIndex.to_i].inner_html
=end


  else
  	reviews = search_result.link_with(text: results[0].inner_html).click
  	_show = results[0].inner_html
  end

  _show = _show.downcase.tr(" ", "_")
  puts _show # --now "_show" is equal to the actual name of the show, not just whatever the user typed in.

  puts "" # make it easier on the eyes


  grades = Array.new 
  graphY = Array.new
  validSeasons = Array.new # array of integers reflecting the season numbers in the tvSeasonButton elements on each show's reviews page.
  episodesPerSeason = Array.new # index 0 stores # of eps in season 1, etc.

  #fetch the number of TV Season buttons on the show's page
  page = Nokogiri::HTML(open(reviews.uri.to_s))
  validSeasons = page.css('nav a').select{|link| link['data-ct_href'] == "tvSeasonButton"}


  # this function takes a given TV season and pushes it onto the Grades array
  def pushSeason (index, reviews, grades, validSeasons, episodesPerSeason)
  	puts "season " + validSeasons[index].inner_html
  	if index != 0 then
  		season = reviews.link_with(class: "badge season-" + validSeasons[index].inner_html).click.search('.grade.letter.tv').reverse
  	else
  		season = reviews.search('.grade.letter.tv').reverse
  	end
  	topJunk = season[season.size - 1] # grabs top element from array

  	while season[season.size - 1] == topJunk
  		season.pop
  	end

  	season.pop

  	#season.delete(topJunk)
	  #season.pop # the latest episode is at the top of every page, remove it from the list

	  # for some reason, every couple of days I will test this program and this section messes me up.
	  # Some days it needs 3 pops to get the right number of episodes, other days it needs 1 pop.
	  # There's probably a better way of removing duplicates, but I have yet to implement that. Definitely on the to-do list.

	  #season.pop # maybe implement something where you fetch the top episode's ID and make sure the last one isn't that,
	  #season.pop # except in the caes of the final season/latest season of the show where it is.
	  season = season.reverse
	  puts season.length.to_s + " episodes"
	  episodesPerSeason.push(season.length.to_i)
	  while season.length > 0 do
	  	grades.push(season.pop.inner_text())
	  end
	end

	for i in 0..validSeasons.length-1
		pushSeason(validSeasons.length-1 - i, reviews, grades, validSeasons, episodesPerSeason)
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
  #calls a function that outputs an html file for displaying the chart of the show
  writeContents(graphY, episodesPerSeason, validSeasons, _show)
  	# writes a text file containing the numbers corresponding to each grade
  	begin
  		file = File.open("numberList.txt", "w")
  		for i in 0..graphY.length-1
  			file.write(graphY[graphY.length-1 - i].to_s + "\n")
  		end 
  	rescue IOError => e
	  #some error occur, dir not writable etc.
	ensure
		file.close unless file == nil
	end

	puts ""
  	puts "" # make it easier on the eyes
  	puts ""

tickMarks = Array.new # stores the sum of the previous seasons (used to drop tick marks at season divisions)
# for example, breaking bad has 5 seasons, each containing: 7, 13, 13, 13, and 16 episdoes, respectively.
# In this case, tickMarks would store numbers: 7, 20, 33, 46, 62 in indexes 0, 1, 2, 3, 4.

for i in 0..episodesPerSeason.length-1
	for j in 0..i
		#
		tickMarks[i] = tickMarks[i].to_i + episodesPerSeason[j].to_i
	end
end

for i in 0..12
	for j in 0..(graphY.length-1 + 2)

		if i == 12 && j > 1
			print "--"
		else
			if j == 0
				# fill the left edge of the graph with grades corresponding to each row.
				case i
				when 0
					print "A "
				when 1
					print "A-"
				when 2
					print "B+"
				when 3
					print "B "
				when 4
					print "B-"
				when 5
					print "C+"
				when 6
					print "C "
				when 7
					print "C-"
				when 8
					print "D+"
				when 9
					print "D "
				when 10
					print "D-"
				when 11
					print "F "
				else
					print "  "
				end
			else
				if j == 1
					print "|" # drop a vertical line down to separate the grades from the start of the graph proper.
				else
					_yFlip = 11 - i; # flips the value, since the graph counts upside down

					if graphY[graphY.length-1 - j + 2] == _yFlip then
						print "O" # the episode's grade is right here
					else
						print "-" # blank space
					end

					# put down the vertical bars to separate seasons
					if tickMarks.include? j-1
						print "|"
					else
						print " " # no need to drop a bar here
					end
					# end vertical bar loop
				end
			end
		end
		
		STDOUT.flush
	end
	puts ""
	#puts ""
end


end
