require 'unimidi'

class ExternalClock

  def initialize(midi_input_port_name)
    @midi_input = UniMIDI::Input.find { |device| device.name.match(midi_input_port_name) } 
    @observers = Array.new
    @running = false

    Thread.new { run }
  end

  def register_observer(observer)
    @observers << observer
  end

  def deregister_observer(observer)
    @observers.delete(observer) 
  end

  def running?
    @running
  end

  def start
  end

  def stop
  end

  def run
    while true
      message = @midi_input.gets
      case message[0][:data][0]
      when 248
        if @running 
          @observers.each do |observer| 
            observer.clock_pulse(@pulse_count)
          end
          @pulse_count = @pulse_count + 1
        end
      when 250
        @running = true
        @pulse_count = 0

        @observers.each do |observer| 
          observer.clock_started
        end
      when 252
        @running = false

        @observers.each do |observer| 
          observer.clock_stopped
        end
      end
    end
  end

end
