class HipChecksController < ApplicationController
  before_action :authenticate_user!

  def new
    hip_check = HipCheck.new(user: current_user)

    render :new, locals: { hip_check: hip_check }
  end

  def create
    hip_check = HipCheck.new(hip_check_attributes)
    hipness = hip_check.hipness
    topic = hip_check.topic

    render :show, locals: { hip_check: hip_check, hipness: hipness, topic: topic }
  end

  private

  def hip_check_attributes
    params.require(:hip_check).permit(:user_id, :time, :topic)
  end
end
