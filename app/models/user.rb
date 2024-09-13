class User
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :color, type: String
  field :token, type: String

  has_many :messages, class_name: "Message", inverse_of: :author
  has_and_belongs_to_many :chat_rooms
end
