require 'active_record'
require 'push/version'
require 'push/configuration'
require 'push/message'
require 'push/feedback'

module Push
  @@ext_id_tag = 'Ext-ID:'

  def self.ext_id_tag=(string)
    @@ext_id_tag = string
  end

  def self.ext_id_tag
    @@ext_id_tag
  end
end
