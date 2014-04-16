
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
require 'fuzzystringmatch'
require_relative 'chart.rb'

agent = Mechanize.new

## check command line arguments
#  accepts only a single argument: either "jarow" or "reg"
#  this tells the program which string matching technique to use when selecting the show to chart

def asciiGraph(graphY, episodesPerSeason)
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
		puts "" # I forget why, but taking this line out makes the graph look horrible.
	end
end

if ARGV.count != 1 then 
  puts "No command line arguments specified. Assuming jarow."
  command = "jarow"
  #exit
else 
  command = ARGV[0]
end
ARGV.clear

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
    #puts "Which one is it? Enter the corresponding number."
  	#userChoice = gets.chomp
  	#userChoice = userChoice.gsub! '&amp;','&'
  	#reviews = search_result.link_with(text: results[userChoice.to_i-1].inner_html).click
    
    ## create _showProper which is just the search term with the first letter of each word capitalized to match av club's style.
    #  a found boolean is used to determine when the search is successful. this is needed because the (experts) part of the reg exp is optional, so it will match
    #  any search term that has (experts) or (newbies) or nothing. i am counting on the user always desiring the expert rating (if it exists) and for that rating to
    #  always come first.
    
    ## i also noticed that, for example, if i searched for "family gu", the search function would indeed return Family Guy as a valid result, which i assume is because 
    #  of the fuzzy search, but the regexp below selected "Family Guy" correctly. This is because the regular expression matched as many characters as it could from 
    #  the broken search term and got the right answer.
    
    _showProper = _show.split.map(&:capitalize).join(' ')
    if command.eql?("jarow") then
      puts "jarow match"
      # choice 2: compare the string and make a guess on which one is most likely the one the user intended.
      jarow = FuzzyStringMatch::JaroWinkler.create( :pure )
      bestDistance = 0
      current = 0
      matchIndex = 0

      for i in 0..results.length-1
        choice = results[i].inner_html

        current = jarow.getDistance(_show.downcase,choice.downcase)
        print choice + ": \t" + (current*100).to_s + "% match"
        puts ""

        if current > bestDistance
          bestDistance = current
          matchIndex = i
        else
          # do nothing
        end
      end

      reviews = search_result.link_with(text: results[matchIndex.to_i].inner_html).click
      _show = results[matchIndex.to_i].inner_html
      _showProper = _show.split.map(&:capitalize).join('_')
      #puts _showProper

    elsif command.eql?("reg") 
      puts "regular expression match"
      reviews = nil
      found = false
      results.each do |i|
        if !i.inner_html[/#{_showProper}(\s\(experts\))?/].nil? and !found then
          reviews = search_result.link_with(text: i.inner_html).click
          found = true
        end
      end
    end
  elsif results.length == 1
  	reviews = search_result.link_with(text: results[0].inner_html).click
  	_show = results[0].inner_html
    _showProper = _show.split.map(&:capitalize).join('_')
    #puts _showProper

  else ## added additional error checking in case there are no search results
    puts "No results matched your search term."
    exit
  end

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

  	#season.pop

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
  writeContents(graphY, episodesPerSeason, validSeasons, _showProper)
  	# writes a text file containing the numbers corresponding to each grade
#  	 begin
#       file = File.open("numberList.txt", "w")
#       for i in 0..graphY.length-1
#         file.write(graphY[graphY.length-1 - i].to_s + "\n")
#       end 
#     rescue IOError => e
#     #some error occur, dir not writable etc.
#   ensure
#     file.close unless file == nil
#   end

	puts ""
  	puts "" # make it easier on the eyes
  	puts ""

  	asciiGraph(graphY, episodesPerSeason)


end
