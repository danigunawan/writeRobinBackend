class AuthenticationController < ApplicationController
  # skip_before_action :verify_authenticity_token, if: :json_request?
   before_action :authorized, except: :login

  # POST /auth/login
  def login
    puts 'LOGGING IN'
    userList = User.where('lower(username) = ?', params[:username].downcase)
    @user



    if userList.length > 0
      @user = userList[0]
    end
    puts 'AUTHENTICATING'

    if @user&.authenticate(params[:password])

      puts "AUTHENTICATED USER #{@user.id}"

      token = JWT.encode({user_id: @user.id},'5KgjiJMXTmi0jvOzwfsp')

      @admin = false
      if !!@user.admin
        @admin = @user.admin
      end

      puts "RENDERING JSON"
      render json: { token: token, username: @user.username, admin: @admin }, status: :ok
    
    else
    # byebug
      puts 'AUTHENTICATION FAILED'
      render json: { error: 'unauthorized' }, status: :unauthorized
    end
  end

  private

  def login_params
    params.permit(:username, :password)
  end

    # protected

    def json_request? 
        return request.format.json?
    end
end
