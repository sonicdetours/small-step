require_relative 'mode'
require_relative 'constants'

class PerformanceMode < Mode

  def initialize(clock, launch_pad, midi_output)
    @clock = clock 
    @clock.register_observer(self)
    
    @launch_pad = launch_pad
    @launch_pad.register_grid_pad_observer(self)

    @midi_output = midi_output

    @scale = Scale::CHROMATIC
    @scale_name = "Chromatic"    
    @root_note = 0
    @channel = 0
    @active = false
  end

  def deserialize(json)
    @scale_name = json["keyboard"]["scale"]
    @scale = Scale::TABLE[@scale_name]
    @root_note = json["keyboard"]["root"]
    @channel = json["keyboard"]["channel"]
  end    

  def serialize
    { "scale" => @scale_name, "root" => @root_note, "channel" => @channel }
  end    

  def next_pulse(i)
    if (active?)
      relative_pulse = i % 768
      lit_steps = relative_pulse / 96

      (0..7).each do |j|
        if (j < lit_steps)
          color = Color::YELLOW
        elsif (j == lit_steps)
          color = Color::YELLOW_FLASH
        else
          color = Color::OFF
        end
        @launch_pad.set_number_pad(LaunchPad::PAD_1 + j,color)
      end
    end
  end

  def redraw
    (0..7).each do |i|
      @launch_pad.set_number_pad(LaunchPad::PAD_1 + i, Color::OFF)
    end

    (0..7).each do |i|
      (0..7).each do |j|
        color = (i % 2 == 0) ? Color::YELLOW : Color::GREEN
        @launch_pad.set_grid_pad(i * 8 + j, color)
      end
    end
  end

  def get_note(pad)
    note = @root_note
    # find note in scale
    note = note + @scale[pad % @scale.length]
    # add octaves
    note = note + (pad / @scale.length) * 12
    (note > 127) ? 127 : note
  end

  def launch_pad_grid_pad_down(pad)
    if (active?)
      @midi_output.puts(0b10010000 + @channel, get_note(pad), 127)
    end
  end

  def launch_pad_grid_pad_up(pad)
    @midi_output.puts(0b10000000 + @channel, get_note(pad), 0)
  end
end