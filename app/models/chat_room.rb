class ChatRoom
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :password, type: String
  field :color, type: String
  field :author, type: String
  field :code, type: String

  has_and_belongs_to_many :members, class_name: User
  has_many :messages
end
