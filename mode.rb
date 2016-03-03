
class Mode

  def initialize
    @active = false
  end

  def activate
    @active = true
    redraw
  end

  def deactivate
    @active = false
  end

  def active?
    @active
  end
end