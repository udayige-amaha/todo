class Api::V2::TasksController < ApplicationController
  before_action :set_user
  before_action :set_task, only: [ :show, :update, :destroy ]

  def index
    pagination_data = pagination(@user.tasks, 4)

    render json: {
      tasks: pagination_data[:records],
      meta: pagination_data[:meta]
    }
  end

  def show
    render json: @task
  end

  def create
    @task = @user.tasks.build(task_params)
    if @task.save
      render json: @task, status: :created
    else
      render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @task.update(task_params)
      render json: @task
    else
      render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    head :no_content
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_task
    @task = @user.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :completed)
  end
end
