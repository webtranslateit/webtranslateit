# frozen_string_literal: true

class Spinner

  FRAMES = %w[⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏].freeze
  HIDE_CURSOR = "\e[?25l"
  SHOW_CURSOR = "\e[?25h"
  CLEAR_LINE  = "\r\e[0G"

  def initialize(output: $stdout)
    @output = output
    @thread = nil
    @stop = false
  end

  def start
    @stop = false
    @output.print HIDE_CURSOR
    @thread = Thread.new { animate }
  end

  def stop
    return unless @thread

    @stop = true
    @thread.join
    @output.puts "#{CLEAR_LINE}##{SHOW_CURSOR}"
    @thread = nil
  end

  def run
    start
    yield
  ensure
    stop
  end

  private

  def animate
    frames = FRAMES.dup
    frames.reverse! if rand > 0.5
    i = rand(frames.length)
    until @stop
      @output.print "\r#{frames[i]}"
      i = (i + 1) % frames.length
      sleep 0.1
    end
  end

end
