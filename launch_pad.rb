require_relative 'controller'

class LaunchPad < Controller
 
  PAD_1 = 104
  PAD_2 = 105
  PAD_3 = 106
  PAD_4 = 107
  PAD_5 = 108
  PAD_6 = 109
  PAD_7 = 110
  PAD_8 = 111

  PAD_A = 8
  PAD_B = 24
  PAD_C = 40
  PAD_D = 56
  PAD_E = 72
  PAD_F = 88
  PAD_G = 104
  PAD_H = 120

  def initialize(thread_priority = 1)
    super(thread_priority, "Launchpad")

    @number_pad_observers = Array.new
    @letter_pad_observers = Array.new
    @grid_pad_observers = Array.new
  end

  def register_number_pad_observer(observer)
    @number_pad_observers << observer
  end

  def register_letter_pad_observer(observer)
    @letter_pad_observers << observer
  end

  def register_grid_pad_observer(observer)
    @grid_pad_observers << observer
  end

  def notify_observers(message)
    data = message[0][:data]
  
    if (data[0] == 176)
      if (data[2] > 0)
        @number_pad_observers.each { |observer| observer.launch_pad_number_pad_down(data[1]) }
      else
        @number_pad_observers.each { |observer| observer.launch_pad_number_pad_up(data[1]) }
      end
    else
      if ((data[1] - 8) % 16 == 0)
        if (data[2] > 0)
          @letter_pad_observers.each { |observer| observer.launch_pad_letter_pad_down(data[1]) }
        else
          @letter_pad_observers.each { |observer| observer.launch_pad_letter_pad_up(data[1]) }
        end
      else
        index = data[1] - (data[1] / 16) * 8
        if (data[2] > 0)
          @grid_pad_observers.each { |observer| observer.launch_pad_grid_pad_down(index) }
        else
          @grid_pad_observers.each { |observer| observer.launch_pad_grid_pad_up(index) }
        end
      end
    end 
  end

  def set_letter_pad(pad, color)
    send_midi_message(144, pad, color)
  end

  def set_number_pad(pad, color)
    send_midi_message(176, pad, color)
  end

  def set_grid_pad(i, color)
    note = i / 8 * 16
    note += i % 8
    send_midi_message(144, note, color)
  end

  def set_grid_pad_at_coordinate(x, y, color)
    note = y * 16 + x
    send_midi_message(144, note, color)
  end

  def flash_on
    send_midi_message(176, 0, 32)
  end

  def flash_off
    send_midi_message(176, 0, 33)
  end

  def clear
    send_midi_message(176, 0, 0)
  end
end