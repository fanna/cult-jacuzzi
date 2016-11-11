require 'nokogiri'
require 'open-uri'

class Wikipedia
  def self.random_article
    url = "https://en.wikipedia.org/wiki/Special:Random"
    html = Nokogiri::HTML(open(url))
    text = html.css("p").map { |x| x }.join("\n")

    puts "---"
    puts text
    puts "---"

    text.gsub!(/\[.*\]/, "").split(/[\n,\.]/)
  end
end
