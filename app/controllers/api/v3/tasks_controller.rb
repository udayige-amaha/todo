class Api::V3::TasksController < ApplicationController
  before_action :set_task, only: [ :show, :update, :destroy ]

  def index
    tasks = current_user.tasks
    tasks = tasks.by_priority_level(params[:priority]) if params[:priority].present?
    tasks = tasks.by_due_date if params[:sort] == "due_date"
    tasks = tasks.by_priority if params[:sort] == "priority"
    tasks = tasks.completed(params[:completed]) if params[:completed].present?
    tasks = tasks.overdue if params[:overdue] == "true"

    pagination_data = pagination(tasks, 4)

    render json: {
      tasks: pagination_data[:records],
      meta: pagination_data[:meta]
    }
  end

  def show
    render json: @task
  end

  def create
    result = TaskCreatorService.call(task_params, current_user)
    if result.success?
      render json: result.task, status: :created
    else
      render json: { errors: result.errors }, status: :unprocessable_entity
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

  def set_task
    @task = current_user.tasks.find(params[:id])
  end
  def task_params
    params.require(:task).permit(:title, :completed, :due_date, :priority)
  end
end
