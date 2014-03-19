module Push
  class DeliveryError < StandardError
    attr_reader :code, :description, :notify

    def initialize(code, message_id, description, source, notify = true, device = nil)
      @code = code
      @message_id = message_id
      @description = description
      @source = source
      @notify = notify
      @device = device
    end

    def message
      device_msg = @device ? "to device #{@device}" : nil
      [ "Unable to deliver message #{@message_id}", 
         device_msg ,
        "received #{@source} error #{@code} (#{@description})" ,
      ].compact.join(', ')
    end
  end
end
