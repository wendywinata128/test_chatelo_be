class Message
  include Mongoid::Document
  include Mongoid::Timestamps

  field :message, type: String
  field :date_created, type: DateTime
  field :type, type: String, default: "message"


  belongs_to :chat_room
  belongs_to :author, class_name: "User"
end
