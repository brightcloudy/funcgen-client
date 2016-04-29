class FuncgenMessage
  def initialize(message, fromcomponent)
    @message = message
    @component = fromcomponent
  end

  def message
    @message
  end

  def sender
    @component
  end

  def is_from?(sender)
    return @component.eql?(sender)
  end
end
