require 'nokogiri'
require 'open-uri'
require 'fileutils'

class Wikipedia
  BUFFER_LOCATION = "tmp/wikipedia_buffer"
  SWP_LOCATION = "tmp/wikipedia_swp"

  class BufferLockedException < StandardError; end

  def initialize
    FileUtils.rm_rf("tmp")
    FileUtils.mkdir("tmp")

    3.times { Thread.new { push_line } }
  end

  def random_line
    line = pop_line

    Thread.new { push_line }

    line
  end

  private

  def random_text
    url = "https://en.wikipedia.org/wiki/Special:Random"
    html = Nokogiri::HTML(open(url))

    paragraphs = html.css("p").map { |x| x }.join("\n")
    result = paragraphs.gsub!(/\[.*\]/, "").split(/\n/).sample

    raise unless result
    raise if result == ""
    raise if result.length < 150

    result
  rescue
    retries ||= 0

    retry if (retries += 1) < 10

    return "Warning: check your Internet connection"
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
    lock_buffer do
      lines = File.read(BUFFER_LOCATION).lines

      line = lines.shift

      File.open(BUFFER_LOCATION, "w") do |file|
        lines.each { |line| file.puts(line) }
      end

      line.gsub!(/\n/, "")
    end
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
