class UsersController < ApplicationController
    # skip_before_action :verify_authenticity_token, if: :json_request?
    skip_before_action :authorized, only: [:create]

    def create
        @user = User.new(user_params)
        if @user.save
            token = JWT.encode({user_id: @user.id},'5KgjiJMXTmi0jvOzwfsp')
            render json: { token: token, username: @user.username, message:'success'}, status: :ok
        else
            # byebug
            render :json => {message: 'failure'}
        end
    end

    def profile
        puts 'USER PROFILE'
        @user = User.find(params[:id])
        currentUserID = get_user_from_token

        if @user.id == currentUserID
            puts 'CURRENT USER'
            #self
            render :json => {username:@user.username, id:@user.id, friends: User.find(currentUserID).friends}
        else
            puts 'OTHER USER'
            #other user
            isFriends = false
            User.find(currentUserID).friends.each do |friend|
                if friend.id == @user.id
                    isFriends = true
                    break
                end
            end
            puts 'HANDLED FRIENDS'
            render :json => {username:@user.username, id:@user.id , friended: isFriends}
        end

    end

    def friend
        puts 'FRIENDING'
        friender = User.find(get_user_from_token)
        to_friend = User.find(params[:id].to_i)

        if (!friender.is_friends_with(params[:id]))
            Friendship.create(user1: friender.id, user2: to_friend.id)
        end
        render :json => {message: 'done'}
    end

    def unfriend
        friender = User.find(get_user_from_token)
        to_friend = User.find(params[:id].to_i)

        if (friender.is_friends_with(params[:id]))
            Friendship.where('(USER1 = ? or USER2 = ?) and (USER1 = ? or USER2 = ?)',friender.id,friender.id,to_friend.id,to_friend.id)[0].destroy
        end
        render :json => {message: 'done'}

    end

    private

    def user_params 
        params.require(:user).permit(:username,:password)
    end

    # protected

    def json_request? 
        return request.format.json?
    end
end
