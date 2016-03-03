require_relative 'constants'
require_relative 'internal_clock'
require_relative 'external_clock'
require_relative 'sequencer'
require_relative 'launch_pad'
require_relative 'launch_control'
require_relative 'drum_edit_mode'
require_relative 'performance_mode'

require 'json'
require 'unimidi'

class SmallStep

  def initialize(clock, sequencer_output_port_name, performance_output_port_name)
    @clock = clock

    @sequencer_output = UniMIDI::Output.find { |device| device.name.match(sequencer_output_port_name) } 
    @performance_output = UniMIDI::Output.find { |device| device.name.match(performance_output_port_name) } 

    @sequencer = Sequencer.new(@clock, @sequencer_output)    
    
    @launch_pad = LaunchPad.new
    @launch_pad.start

    @launch_control = LaunchControl.new
    @launch_control.start    

    @drum_edit_mode = DrumEditMode.new(@clock, @sequencer, @launch_pad, @launch_control)
    @performance_mode = PerformanceMode.new(@clock, @launch_pad, @performance_output)

    @launch_pad.register_letter_pad_observer(self)
    @launch_control.register_knob_observer(self)    
    @clock.register_observer(self)

    select_drum_edit_mode

    @launch_pad.set_letter_pad(LaunchPad::PAD_F, Color::YELLOW)
    @launch_pad.set_letter_pad(LaunchPad::PAD_H, Color::RED)

    load_song
  end

  def clock_started
    @launch_pad.set_letter_pad(LaunchPad::PAD_H, Color::GREEN_FLASH)
  end

  def clock_stopped
    @launch_pad.set_letter_pad(LaunchPad::PAD_H, Color::RED)
  end

  def clock_pulse(i)
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
          @clock.stop
        else
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

clock = InternalClock.new(115)
clock.register_clock_output("IAC")
clock.register_clock_output("Scarlett")

smallstep = SmallStep.new(clock, "Scarlet", "IAC")
smallstep.run
