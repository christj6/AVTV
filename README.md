AVTV
====

AV Club web scraper: it fetches a TV show's grades and plots a graph with them. Run it (navigate to the directory, enter "ruby av_club_graph.rb"), enter the name of a TV show, and it'll plot a graph: episode # on the x-axis, grade on the y-axis. It also writes an Excel-friendly list of the numbers (A = 11, A- = 10, etc) corresponding to each episode to a text file called "NumberList.txt" so if you have a text file with the same filename in the same directory when you run the program, it will get overwritten.

Inspired by this: http://graphtv.kevinformatics.com/tt0903747
