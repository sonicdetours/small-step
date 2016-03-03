
class InternalClock

  attr_accessor :bpm
  
  def initialize(bpm = 120, thread_priority = 1)
    @thread_priority = thread_priority
    @bpm = bpm
    @pulse_length = 60.0 / bpm / 24.0
    @observers = Array.new
  end

  def running?
    @running
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
    end
  end

  def stop
    Thread.kill(@thread)
    @thread = nil
  end

  def run
    while true
      loop_time = Time::now + @pulse_length

      @observers.each do |observer| 
        observer.next_pulse(@pulse_count)
      end
      @pulse_count = @pulse_count + 1

      sleep(loop_time - Time::now)
    end
  end
end