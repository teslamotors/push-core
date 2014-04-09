module Push
  class DeliveryError < StandardError
    attr_reader :code, :description, :notify

    def initialize(code, message_id, description, source, notify = true, device = nil, ext_id = nil)
      @code = code
      @message_id = message_id
      @description = description
      @source = source
      @notify = notify
      @device = device
      @ext_id = ext_id
    end

    def message
      device_msg = @device ? "to device #{@device}" : nil
      ext_id_msg = @ext_id ? "#{Push.ext_id_tag} #{@ext_id}" : nil
      [ "Unable to deliver message #{@message_id}", 
         device_msg ,
         ext_id_msg,         
        "received #{@source} error #{@code} (#{@description})" ,
      ].compact.join(', ')
    end
  end
end
