class UserController < ApplicationController
    def index
        # @users = User.all
        return_json(status: 200, data: current_user, message: "Retrieve user data")
    end

    def create
        user = User.new(user_params)
        token = SecureRandom.base64(32)
        user.token = token

        chat_room = get_welcome_chat_rooms

        if  user.save
            $redis.hset("user:#{token}", "id", user.id.to_s)
            $redis.hset("user:#{token}", "data", user.to_json)

            chat_room.members << user
            chat_room.save

            message = Message.new(message: "#{user.name} has join the room", author: user, chat_room: chat_room, created_at: Time.now(), type: "information")

            message.save

            ActionCable.server.broadcast "chat_#{chat_room._id}", message.to_json(include: { author: { only: [ :id, :name, :color ] } })

            return_json(data: user)
        end
    end

    def user_params
        params.require(:user).permit(:name, :color)
    end

    def get_welcome_chat_rooms
        chatRoomWelcomeMember = ChatRoom.where(code: "#WELCOMEMEMBER").first

        if !chatRoomWelcomeMember
            chat_room = ChatRoom.new(
                name: "Welcome Member",
                password: "123456",
                color: "#7882EB",
                code: "#WELCOMEMEMBER"
            )

            chat_room.save

            chatRoomWelcomeMember = chat_room
        end

        chatRoomWelcomeMember
    end
end
