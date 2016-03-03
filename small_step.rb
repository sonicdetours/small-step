require_relative 'constants'
require_relative 'internal_clock'
require_relative 'sequencer'
require_relative 'launch_pad'
require_relative 'launch_control'
require_relative 'drum_edit_mode'
require_relative 'performance_mode'

require 'json'
require 'unimidi'

class SmallStep

  def initialize(midi_output_port_name)
    @midi_output = UniMIDI::Output.find { |device| device.name.match(midi_output_port_name) } 
    
    @clock = InternalClock.new

    @sequencer = Sequencer.new(@clock, @midi_output)    
    
    @launch_pad = LaunchPad.new
    @launch_pad.start

    @launch_control = LaunchControl.new
    @launch_control.start    

    @drum_edit_mode = DrumEditMode.new(@clock, @sequencer, @launch_pad, @launch_control)
    @performance_mode = PerformanceMode.new(@clock, @launch_pad, @midi_output)

    @launch_pad.register_letter_pad_observer(self)
    @launch_control.register_knob_observer(self)    
    @clock.register_observer(self)

    select_drum_edit_mode

    @launch_pad.set_letter_pad(LaunchPad::PAD_F, Color::YELLOW)
    @launch_pad.set_letter_pad(LaunchPad::PAD_H, Color::RED)

    load_song
  end

  def next_pulse(i)
    if (i % 24 == 0)
      @launch_pad.flash_on
      @launch_control.flash_on
    elsif (i % 12 == 0)
      @launch_pad.flash_off
      @launch_control.flash_off
    end
  end

  def load_song
    if (File.exists?('pattern.json'))
      json = File.read('pattern.json')
      json = JSON.parse(json)
      @sequencer.deserialize(json)
      @performance_mode.deserialize(json)

      @launch_pad.set_letter_pad(LaunchPad::PAD_G, Color::GREEN)

      select_drum_edit_mode
    end
  end

  def save_song
    pattern = @sequencer.serialize
    pattern["keyboard"] = @performance_mode.serialize
    json = JSON.pretty_generate(pattern)
    File.write('pattern.json', json)
    @launch_pad.set_letter_pad(LaunchPad::PAD_G, Color::GREEN)
  end

  def select_drum_edit_mode
    @drum_edit_mode.activate
    @performance_mode.deactivate

    @launch_pad.set_letter_pad(LaunchPad::PAD_A, Color::GREEN)
    @launch_pad.set_letter_pad(LaunchPad::PAD_B, Color::YELLOW)
  end

  def select_performance_mode
    @drum_edit_mode.deactivate
    @performance_mode.activate

    @launch_pad.set_letter_pad(LaunchPad::PAD_A, Color::YELLOW)
    @launch_pad.set_letter_pad(LaunchPad::PAD_B, Color::GREEN)
  end

  def launch_pad_letter_pad_down(pad)
    case pad
      when LaunchPad::PAD_A
        select_drum_edit_mode
      when LaunchPad::PAD_B
        select_performance_mode
      when LaunchPad::PAD_F
        load_song
      when LaunchPad::PAD_G
        save_song
      when LaunchPad::PAD_H
        if @clock.running?
          @launch_pad.set_letter_pad(LaunchPad::PAD_H, Color::RED)
          @clock.stop
        else
          @launch_pad.set_letter_pad(LaunchPad::PAD_H, Color::GREEN_FLASH)
          @clock.start
        end
    end
  end

  def launch_pad_letter_pad_up(pad)
    #nopi
  end

  def launch_control_knob_change(knob, value)
    if (knob < LaunchControl::KNOB_9)
      @sequencer.drum_parts[knob - LaunchControl::KNOB_1].change_pan(value)
    else
      @sequencer.drum_parts[knob - LaunchControl::KNOB_9].change_volume(value)
    end
    @launch_pad.set_letter_pad(LaunchPad::PAD_G, Color::RED)
  end

  def run
    while true
      sleep(1)
    end
  end
end

SmallStep.new("XMidi").run