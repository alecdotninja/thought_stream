class FollowsController < ApplicationController
  before_action :authenticate_user!

  def create
    follow = current_user.follows_as_follower.new follow_params

    unless follow.save
      flash[:error] = follow.errors.full_messages.to_sentence
    end

    if request.xhr?
      render partial: 'button', locals: { user: follow.followee }, change: "follow-button:#{follow.followee_id}"
    else
      redirect_to :back
    end
  end

  def destroy
    follow = current_user.follows_as_follower.find(params[:id])

    follow.destroy

    if request.xhr?
      render partial: 'button', locals: { user: follow.followee }, change: "follow-button:#{follow.followee_id}"
    else
      redirect_to :back
    end
  end

  private

  def follow_params
    params.require(:follow).permit(:followee_id)
  end
end