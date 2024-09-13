require "uri"

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      token = request.params[:token]

      user = $redis.hget("user:#{token}", "data")

      if user
        self.current_user = User.new(JSON.parse(user))
      else
        reject_unauthorized_connection
      end
    end
  end
end
