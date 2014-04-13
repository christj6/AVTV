require 'haml'

def writeContents(arr, arr2, arr3, name)
  ratingsHash = Hash.new()
  seasonCount = 0
  episodeCount = 1
  arr.reverse.each do |v|
    key = "S#{arr3[arr2.length - 1 - seasonCount].inner_html}E#{episodeCount}"
    value = v
    ratingsHash.store(key, value)
    episodeCount += 1
    if (episodeCount > arr2[seasonCount]) and (seasonCount < arr2.length) then
      episodeCount = 1
      seasonCount += 1
    end
  end
  writeFile(ratingsHash, name)
end

def writeFile(hash, name)
  ## open the HAML template
  template = File.read('../templates/template.haml')
  
  ## use the HAML engine to add a method to the ratings hash that will render the HAML as HTML and 
  # insert itself into the HTML so we can use its data
  Haml::Engine.new(template).def_method(hash, :render, :title)
  
  ## open the text file to store the results and open the file that will be the output HTML
  #  test for errors and output messages
  begin
    file = File.open("../textFiles/#{name}.txt", "w") 
    ## write the contents of the hash to the text file
    hash.each do |key, value|
      file.write("#{key}-#{value}\n")
    end
    file.close
  rescue IOError => t 
    t.error
  end
  
  begin
    htmlFile = File.open("../html/#{name}.html", "w")
    ## write the rendered HTML to an html file
    htmlFile.write(hash.render(:title => name))
    # close file
    htmlFile.close
  rescue IOError => h 
    h.error
  end
end

