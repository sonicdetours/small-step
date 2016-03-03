require_relative 'drum_part'

class Sequencer
  attr_reader :drum_parts
  #attr_reader :current_pulse

  def initialize(clock, midi_output)
    clock.register_observer(self)

    @drum_parts = Array.new(8) do |i|
      part = DrumPart.new(midi_output)
      part.channel = i
      part
    end
    reset
  end

  def next_pulse(i)
    @drum_parts.each { |part| part.next_pulse(i) }
    @current_pulse = i
  end

  def reset
    @current_pulse = 0
    @drum_parts.each { |part| part.reset }
  end

  def deserialize(pattern)
    (0..7).each { |i| @drum_parts[i].deserialize(pattern["drum_parts"][i]) }
  end

  def serialize
    { "drum_parts" => Array.new(8) { |i| @drum_parts[i].serialize } }
  end
end