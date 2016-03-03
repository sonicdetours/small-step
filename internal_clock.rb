
class InternalClock

  attr_accessor :bpm
  
  def initialize(bpm = 120, thread_priority = 1)
    @thread_priority = thread_priority
    @bpm = bpm
    @pulse_length = 60.0 / bpm / 24.0
    @observers = Array.new

    @clock_outputs = Array.new
  end

  def register_clock_output(midi_port_name)
    @clock_outputs << UniMIDI::Output.find { |device| device.name.match(midi_port_name) }
  end

  def send_clock_message(message)
    @clock_outputs.each { |output| output.puts(message)
}
  end

  def register_observer(observer)
    @observers << observer
  end

  def deregister_observer(observer)
    @observers.delete(observer) 
  end

  def running?
    if (@thread)
      return true
    else
      return false
    end
  end

  def start
    if (!@thread)
      @pulse_count = 0
      @thread = Thread.new() { run }
      @thread.abort_on_exception = true
      @thread.priority = @thread_priority

      @observers.each do |observer| 
        observer.clock_started
      end
      send_clock_message(250)
    end
  end

  def stop
    Thread.kill(@thread)
    @thread = nil

    @observers.each do |observer| 
      observer.clock_stopped
    end
    send_clock_message(252)
  end

  def run
    while true
      loop_time = Time::now + @pulse_length

      @observers.each do |observer| 
        observer.clock_pulse(@pulse_count)
      end

      send_clock_message(248)

      @pulse_count = @pulse_count + 1

      sleep(loop_time - Time::now)
    end
  end
end