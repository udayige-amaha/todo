class Api::V2::TasksController < ApplicationController
  before_action :set_user
  before_action :set_task, only: [ :show, :update, :destroy ]

  def index
    tasks = @user.tasks

    tasks = tasks.by_priority_level(params[:priority]) if params[:priority].present?
    tasks = tasks.by_due_date if params[:sort] == "due_date"
    tasks = tasks.by_priority if params[:sort] == "priority"
    tasks = tasks.completed(params[:completed])
    tasks = tasks.overdue if params[:overdue] == "true"

    pagination_data = pagination(tasks, 4)
    task_count = pagination_data[:records].count

    render json: {
      tasks: pagination_data[:records],
      meta: pagination_data[:meta]
      # **(task_count > 3 ? pagination_data[:meta] : {}) # conditionally include metadata
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
    params.require(:task).permit(:title, :completed, :priority, :due_date)
  end
end
