require 'rspec/core/formatters/base_text_formatter'
require 'ruby-progressbar'
require 'rspec/instafail'

class Fuubar < RSpec::Core::Formatters::BaseTextFormatter

  attr_reader :example_count, :finished_count

  def start(example_count)
    @example_count = example_count
    @finished_count = 0
    @progress_bar   = ProgressBar.create(:title => "  #{example_count} examples", :total => example_count, :output => output)
    @progress_bar.bar_mark = '='
  end

  def increment
    with_color do
      @finished_count += 1
      @progress_bar.title = "  #{finished_count}/#{example_count}"
      @progress_bar.increment
    end
  end

  def example_passed(example)
    super
    increment
  end

  def example_pending(example)
    super
    @state = :yellow unless @state == :red
    increment
  end

  def example_failed(example)
    super
    @state = :red

    output.print "\e[K"
    instafail.example_failed(example)
    output.puts

    increment
  end

  def start_dump
    with_color { @progress_bar.finish }
  end

  def dump_failures
    # don't!
  end

  def instafail
    @instafail ||= RSpec::Instafail.new(output)
  end

  def with_color
    output.print "\e[#{colors[state]}m" if color_enabled?
    yield
    output.print "\e[0m"
  end

  def state
    @state ||= :green
  end

  def colors
    { :red => 31, :green => 32, :yellow => 33 }
  end

end
