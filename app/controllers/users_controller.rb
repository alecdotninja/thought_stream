class UsersController < ApplicationController
  def index
    render :index, locals: { users: users }
  end

  def show
    render :show, locals: { user: user }
  end

  def followers
    render :followers, locals: { user: user, users: user.followers }
  end

  def following
    render :following, locals: { user: user, users: user.followees }
  end

  def friends
    render :friends, locals: { user: user, users: user.friends }
  end

  private

  def user
    @user ||= User.find_by!(handle: params[:handle])
  end

  def users
    @users ||= User.all
  end
end