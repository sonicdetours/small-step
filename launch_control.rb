require_relative 'controller'

class LaunchControl < Controller

  PAD_1 = 9
  PAD_2 = 10
  PAD_3 = 11
  PAD_4 = 12
  PAD_5 = 25
  PAD_6 = 26
  PAD_7 = 27
  PAD_8 = 28

  KNOB_1 = 21
  KNOB_2 = 22
  KNOB_3 = 23
  KNOB_4 = 24
  KNOB_5 = 25
  KNOB_6 = 26
  KNOB_7 = 27
  KNOB_8 = 28

  KNOB_9 = 41
  KNOB_10 = 42
  KNOB_11 = 43
  KNOB_12 = 44
  KNOB_13 = 45
  KNOB_14 = 46
  KNOB_15 = 47
  KNOB_16 = 48

  PAD_UP = 114
  PAD_DOWN = 115
  PAD_LEFT = 116
  PAD_RIGHT = 117

  def initialize(thread_priority = 1)
    super(thread_priority, "Launch Control")

    @number_pad_observers = Array.new()
    @arrow_pad_observers = Array.new()
    @knob_observers = Array.new()
  end

  def register_number_pad_observer(observer)
    @number_pad_observers << observer
  end

  def register_arrow_pad_observer(observer)
    @arrow_pad_observers << observer
  end

  def register_knob_observer(observer)
    @knob_observers << observer
  end

  def clear
    send_midi_message(176, 0, 0)
  end

  def set_number_pad(pad, color)
    send_midi_message(144, pad, color)
  end

  def set_control_pad(pad, color)
    send_midi_message(176, pad, color)
  end

  def flash_on
    send_midi_message(176, 0, 32)
  end

  def flash_off
    send_midi_message(176, 0, 33)
  end

  def notify_observers(message)
    data = message[0][:data]

    case data[0] 
    when 144
      @number_pad_observers.each { |observer| observer.launch_control_number_pad_down(data[1]) }
    when 128
      @number_pad_observers.each { |observer| observer.launch_control_number_pad_up(data[1]) }
    when 176
      if (data[1] < 48)
        @knob_observers.each { |observer| observer.launch_control_knob_change(data[1], data[2]) }
      elsif (data[1] < 118)
        if (data[2] > 0)
          @arrow_pad_observers.each { |observer| observer.launch_control_arrow_pad_down(data[1]) }
        else
          @arrow_pad_observers.each { |observer| observer.launch_control_arrow_pad_up(data[1]) }
        end
      end
    end
  end
end