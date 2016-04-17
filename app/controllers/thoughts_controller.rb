class ThoughtsController < ApplicationController
  before_action :authenticate_user!, except: [:index]

  def index
    render :index, locals: { thoughts: Thought.all }
  end

  def create
    thought = current_user.thoughts.new thought_params

    unless thought.save
      flash[:error] = thought.errors.full_messages.to_sentence
    end

    redirect_to user_path(current_user.handle)
  end

  private

  def thought_params
    params.require(:thought).permit(:message)
  end
end