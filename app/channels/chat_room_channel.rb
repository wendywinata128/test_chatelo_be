class ChatRoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def send_message(data)
    chat_room = ChatRoom.find(params[:room])

    message = Message.new(message: data["message"], author: current_user, chat_room: chat_room, created_at: Time.now())

    if message.save
      ActionCable.server.broadcast "chat_#{params[:room]}", message.to_json(include: { author: { only: [ :id, :name, :color ] } })
    end
  end
end
