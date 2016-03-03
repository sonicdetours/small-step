
class DrumPart

  attr_accessor :steps
  attr_accessor :current_pulse
  attr_accessor :channel
  attr_accessor :note
  attr_accessor :volume
  attr_accessor :pan

  def initialize(midi_output)
    @steps = Array.new(64) { false }
    @muted = false
    @channel = 0
    @note = 0
    @current_pulse = 0
    @volume = 127;
    @pan = 63;
    @midi_output = midi_output
  end

  def empty?
    !@steps.include? true
  end

  def mute
    @muted = true
  end

  def unmute
    @muted = false
  end

  def current_step
    @current_pulse / 6
  end

  def muted?
    @muted
  end

  def toggle_muted
    @muted = !@muted
  end

  def send_control_messages
    @midi_output.puts(0b10110000 + @channel, 7, @volume)
    @midi_output.puts(0b10110000 + @channel, 10, @pan)
  end

  def change_volume(value)
    @volume = value
    send_control_messages
  end

  def change_pan(value)
    @pan = value
    send_control_messages
  end

  def next_pulse(i)
    @current_pulse = i % 384

    if (@note_on)
      @midi_output.puts(0b10000000 + @channel, @note, 100)
      @note_on = false
    end

    if (@current_pulse % 6 == 0)
      if @steps[current_step] && !@muted
        @midi_output.puts(0b10010000 + @channel, @note, 100)
        @note_on = true
       end 
    end
  end

  def reset
    @current_pulse = 0
    send_control_messages
  end

  def current_step
    current_pulse / 6
  end

  def toggle_step(index)
    @steps[index] = !@steps[index]
  end

  def deserialize(json)
    @channel = json["channel"]
    @note = json["note"]
    @pan = json["pan"]
    @volume = json["volume"]
    @muted = false

    for i in 0..63 do
      @steps[i] = json["steps"].chars[i] == "*"
    end
    
    send_control_messages
  end

  def serialize
    steps_string = ""
    @steps.each { |step| steps_string << (step ? "*" : ".") }
    { "channel" => @channel, "note" => @note, "volume" => @volume, "pan" => @pan, "steps" => steps_string }
  end
end