require_relative 'mode'
require_relative 'constants'

class DrumEditMode < Mode

  def initialize(clock, sequencer, launch_pad, launch_control)
    @clock = clock
    @clock.register_observer(self)
    
    @sequencer = sequencer
    
    @launch_control = launch_control
    @launch_control.register_number_pad_observer(self)

    @launch_pad = launch_pad
    @launch_pad.register_grid_pad_observer(self)
    @launch_pad.register_number_pad_observer(self)

    select_part(0)
    
    @current_step = 0
  end

  def redraw
    select_part(@selected_part_index)
  end

  def selected_part
    @sequencer.drum_parts[@selected_part_index]
  end

  def draw_launch_pad_number_pad(i)
    if (@sequencer.drum_parts[i].empty?)
      color = (@selected_part_index == i) ? Color::GREEN : Color::OFF
    else
      color = (i == @selected_part_index) ? Color::GREEN : Color::YELLOW
      color = color + (@sequencer.drum_parts[i].muted? ? 0 : Color::FLASH_MODIFIER)
    end

    @launch_pad.set_number_pad(LaunchPad::PAD_1 + i, color)
  end

  def draw_launch_control_number_pad(i)
    color = (@sequencer.drum_parts[i].empty?) ? Color::OFF : Color::YELLOW
    color = color + (@sequencer.drum_parts[i].muted? ? 0 : Color::FLASH_MODIFIER)

    @launch_control.set_number_pad(LaunchControl::PAD_1 + i, color)
  end

  def draw_number_pads
    (0..7).each do |i|
      if (active?)
        draw_launch_pad_number_pad(i)
      end
      draw_launch_control_number_pad(i)
    end
  end

  def draw_grid_pads
    (0..63).each do |i|
      color = (selected_part.steps[i] ? Color::GREEN : Color::YELLOW)
      @launch_pad.set_grid_pad(i, color)
    end
  end

  def select_part(i)
    @selected_part_index = i

    draw_number_pads
    draw_grid_pads
  end

  def next_pulse(i)
    if (active?)
      if (@current_step != selected_part.current_step)
        color = (selected_part.steps[@current_step] ? Color::GREEN : Color::YELLOW)
        @launch_pad.set_grid_pad(@current_step, color)

        @current_step = selected_part.current_step
        @launch_pad.set_grid_pad(@current_step, Color::RED)
      end
    end
  end

  def launch_pad_number_pad_down(pad)
    if (active?)
      select_part(pad - LaunchPad::PAD_1)
    end
  end

  def launch_pad_number_pad_up(pad)
    # nopi
  end

  def launch_pad_grid_pad_down(i)
    if (active?)
      selected_part.toggle_step(i)
      color = selected_part.steps[i] ? Color::GREEN : Color::YELLOW
      @launch_pad.set_grid_pad(i, color)
      draw_number_pads

      @launch_pad.set_letter_pad(LaunchPad::PAD_G, Color::RED)
    end
  end

  def launch_pad_grid_pad_up(i)
    # nopi
  end

  def launch_control_number_pad_down(pad)
    if (active?)
      @sequencer.drum_parts[pad - LaunchControl::PAD_1].toggle_muted
      draw_number_pads
    end
  end

  def launch_control_number_pad_up(pad)
    # nopi
  end
end