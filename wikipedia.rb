require 'nokogiri'
require 'open-uri'

class Wikipedia
  def self.random_text
    retries ||= 0

    url = "https://en.wikipedia.org/wiki/Special:Random"
    html = Nokogiri::HTML(open(url))

    paragraphs = html.css("p").map { |x| x }.join("\n")
    result = paragraphs.gsub!(/\[.*\]/, "").split(/\n/).sample

    raise unless result
    raise if result == ""
    raise if result.length < 150

    result
  rescue
    retry if (retries += 1) < 10
  end
end
