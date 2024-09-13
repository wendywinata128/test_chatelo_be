class ApplicationController < ActionController::API
    def current_user
        authorization_header = request.headers["Authorization"]

        user = $redis.hget("user:#{authorization_header}", "data")

        if user == nil
            raise UserNotAuthorizedError, "Authorization header is missing"
        end

        User.new(JSON.parse(user))
    end

    def return_json(status: 200, message: "Success", data: nil)
        render json:
            {
                status: status,
                message: message,
                data: data
            }
    end

    def respond_error(status: 400, message: "Failed", error: nil)
        render json:
            {
                status: status,
                message: message,
                error: error
            }, status: status
    end
end
