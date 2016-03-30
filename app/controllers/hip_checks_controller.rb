class HipChecksController < ApplicationController
  def new
    hip_check = HipCheck.new

    hip_check.user = user

    render :new, locals: { hip_check: hip_check }
  end

  def create
    hip_check = HipCheck.new(hip_check_attributes)

    hip_check.user = user

    if hip_check.valid?
      render :show, locals: { hip_check: hip_check }
    else
      flash[:error] = hip_check.errors.full_messages.to_sentence

      render :new, locals: { hip_check: hip_check }
    end
  end

  private

  def hip_check_attributes
    params.require(:hip_check).permit(:time, :topic)
  end

  def user
    @user ||= User.find_by!(handle: params[:handle])
  end
end
