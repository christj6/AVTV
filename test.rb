def writeContents(arr, arr2, arr3, name)
  resArr = Array.new()
  ratingsHash = Hash.new()
  result = String.new("<html>
	<head>
		<script src=\"//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js\"></script>
		<script src=\"Chart.js\"></script>
	</head>
	<body>
		<h1>Ratings for #{name}</h1>
		<h2>Seasons Over Time</h2>
		<canvas id=\"line\" data-type=\"Line\" width=\"600\" height=\"400\"></canvas>
		<script type=\"text/javascript\">
		var ctx = document.getElementById(\"line\").getContext(\"2d\");
		var data = {
			labels : [")
  seasonCount = 0
  episodeCount = 1
  arr.reverse.each do |v|
    resArr.push(v)
    key = "S#{arr3[arr2.length - 1 - seasonCount].inner_html}E#{episodeCount}"
    value = v
    ratingsHash.store(key, value)
    #puts "S#{arr3[arr2.length - 1 - seasonCount].inner_html}E#{episodeCount}: #{v}"
    result += "\"S#{arr3[arr2.length - 1 - seasonCount].inner_html}E#{episodeCount}\"," 
    episodeCount += 1
    if (episodeCount > arr2[seasonCount]) and (seasonCount < arr2.length) then
      episodeCount = 1
      seasonCount += 1
    end
  end
  result = result.chop
  result = result + "],
			datasets : [
				{
					fillColor : \"rgba(220,220,220,0.5)\",
					strokeColor : \"rgba(220,220,220,1)\",
					pointColor : \"rgba(220,220,220,1)\",
					pointStrokeColor : \"#fff\",
					data : ["
            resArr.each do |val|
              result += val.to_s + ","
            end
            result = result.chop
            result += "]
				}
			]
		}
		var myNewChart = new Chart(ctx).Line(data);
		</script>
	</body>
</html>"
#puts result
writeFile(ratingsHash, result, name)
end

def writeFile(hash, str, name)
  file = File.open("#{name}.txt", "w")
  htmlFile = File.open("#{name}.html", "w")
  hash.each do |key, value|
    file.write("#{key}-#{value}\n")
  end
  htmlFile.write(str)
end

