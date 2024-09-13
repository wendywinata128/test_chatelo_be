require "bcrypt"

class ChatRoomController < ApplicationController
    def index
      chat_rooms = ChatRoom.where(:$or => [
        { author: current_user["_id"] },
        { member_ids: current_user["_id"] }
      ]).order_by(updated_at: -1)

      chat_rooms = chat_rooms.map do |chat_room|
        {
          **chat_room.attributes.except("messages"),
          members: chat_room.members,
          messages: chat_room.messages.map do |message|
            {
              **message.attributes,
              author: message.author
            }
          end
        }
      end

      return_json(data:  chat_rooms)
    end


    def create
        chat_room = ChatRoom.new(body_params)

        check_code = ChatRoom.where(code: chat_room.code)

        if check_code.exists?
          return respond_error(message: "Code Already Exists", error: chat_room.code)
        end

        chat_room.author = current_user["_id"]
        chat_room.password = BCrypt::Password.create(chat_room.password)

        chat_room.members << current_user

        message = Message.new(message: "#{current_user.name} has created the room", author: current_user, chat_room: chat_room, created_at: Time.now(), type: "information")

        message.save

        if  chat_room.save
            return_json(data: chat_room)
        end
    end

    def joins
      chat_room = ChatRoom.where(code: "##{params[:code]}".upcase).first

      if chat_room.nil?
        return respond_error(message: "Chat room not found ##{params[:code]}")
      end

      # check password
      if BCrypt::Password.new(chat_room.password) != join_params
        return respond_error(message: "Password not match")
      end

      unless chat_room.members.include?(current_user)
        chat_room.members << User.find(current_user.id)
        chat_room.save
        return_json(data: chat_room)
      else
        respond_error(message: "User is already a member")
      end
    end

    def body_params
        params.require(:room).permit(:name, :password, :color, :code)
    end

    def join_params
      params.require(:password)
    end
end
