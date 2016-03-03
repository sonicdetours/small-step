require 'unimidi'

class Controller

  def initialize(thread_priority = 1, midi_port_name)
    @midi_output = UniMIDI::Output.find { |device| device.name.match(midi_port_name) } 
    @midi_input = UniMIDI::Input.find { |device| device.name.match(midi_port_name) } 
    @observers = Array.new
    @thread_priority = thread_priority
  end

  def send_midi_message(a, b, c)
    if (@midi_output)
      @midi_output.puts(a, b, c)
    end
  end

  def register_observer(observer)
    @observers << observer
  end

  def deregister_observer(observer)
    @observers.delete(observer) 
  end

  def start
    if (!@thread)
      @thread = Thread.new() { run }
      @thread.abort_on_exception = true
      @thread.priority = @thread_priority
    end
  end

  def stop 
    Thread.kill(@thread)
    @thread = nil
  end

  def run
    while true
      message = @midi_input.gets
      notify_observers(message)
    end
  end
end