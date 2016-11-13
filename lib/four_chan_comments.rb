require 'nokogiri'
require 'open-uri'
require 'fileutils'

class FourChanComments
  BUFFER_LOCATION = "assets/four_chan_buffer"
  SWP_LOCATION = "assets/four_chan_swp"
  BASE_URL = "http://boards.4chan.org"
  SFW_BOARDS = ["x"]
  NSFW_BOARDS = ["b", "pol", "soc", "s4s", "a"]

  class BufferLockedException < StandardError; end

  def initialize
    clean_up

    @sfw = true

    8.times { Thread.new { push_line } }
  end

  def random_line(sfw)
    @sfw = sfw

    line = pop_line

    Thread.new { push_line }

    line
  end

  def clean_up
    FileUtils.rm_rf BUFFER_LOCATION
    FileUtils.rm_rf SWP_LOCATION
  end

  private

  def random_page_url
    boards = SFW_BOARDS
    boards += NSFW_BOARDS unless @sfw
    board = boards.sample
    page = Random.rand(10)

    url = "#{BASE_URL}/#{board}/#{page}"
  end

  def random_text
    url = random_page_url
    html = Nokogiri::HTML(open(url))

    paragraphs = html.css("blockquote").map { |x| x }.join("\n")
    result = paragraphs.split(/\n/).sample

    raise unless result

    result = clean_string(result)

    raise if result == ""
    raise if result.length < 60

    result
  rescue
    retries ||= 0

    retry if (retries += 1) < 10

    return "Warning: check your Internet connection"
  end

  def clean_string(string)
    string = string.split(">").last

    (20).downto(5) do |i|
      if string =~ /[0-9]{#{i}}/
        string.gsub!(/[0-9]{#{i}}/, "")
        break
      end
    end

    string
  end

  def push_line
    text = random_text

    lock_buffer do
      File.open(BUFFER_LOCATION, "a") do |file|
        file.puts(text)
      end
    end
  end

  def pop_line
    lines = File.read(BUFFER_LOCATION).lines
    line = lines.shift

    Thread.new do
      lock_buffer do
        File.open(BUFFER_LOCATION, "w") do |file|
          lines.each { |line| file.puts(line) }
        end
      end
    end

    line.to_s.gsub!(/\n/, "")
  rescue Errno::ENOENT
    retries ||= 0

    sleep(0.1)

    retry if (retries += 1) < 80

    return ""
  end

  def lock_buffer
    raise BufferLockedException if File.exist?(SWP_LOCATION)

    FileUtils.touch(SWP_LOCATION)

    output = yield

    FileUtils.rm_rf(SWP_LOCATION)

    output
  rescue BufferLockedException
    retries ||= 0

    sleep(0.1)

    retry if (retries += 1) < 40

    return nil
  rescue Exception => e
    FileUtils.rm_rf(SWP_LOCATION)

    raise e
  end
end
