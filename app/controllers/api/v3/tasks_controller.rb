class Api::V3::TasksController < ApplicationController
  before_action :set_task, only: [ :show, :update, :destroy, :restore, :hard_destroy ]

  CACHE_TTL = 10.minutes

  def index
    fetch_with_cache(task_cache_key, expires_in: CACHE_TTL) do
      tasks = current_user.tasks
      tasks = tasks.by_priority_level(params[:priority]) if params[:priority].present?
      tasks = tasks.by_due_date if params[:sort] == "due_date"
      tasks = tasks.by_priority if params[:sort] == "priority"
      tasks = tasks.completed(params[:completed]) if params[:completed].present?
      tasks = tasks.overdue if params[:overdue] == "true"

      pagination_data = pagination(tasks, 4)

      {
        tasks: pagination_data[:records].as_json,
        meta: pagination_data[:meta]
      }
    end
  end

  def show
    render json: @task
  end

  def create
    result = TaskCreatorService.call(task_params, current_user)
    if result.success?
      invalidate_task_cache
      render json: result.task, status: :created
    else
      render json: { errors: result.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @task.update(task_params)
      invalidate_task_cache
      render json: @task
    else
      render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @task.discard
    invalidate_task_cache
    head :no_content
  end

  def restore
    @task.undiscard
    invalidate_task_cache
    render json: @task
  end

  def hard_destroy
    @task.destroy
    invalidate_task_cache
    head :no_content
  end

  def trashed
    tasks = current_user.tasks.discarded
    pagination_data = pagination(tasks, 4)

    render json: {
      tasks: pagination_data[:records],
      meta: pagination_data[:meta]
    }
  end

  private

  def set_task
    @task = current_user.tasks.with_discarded.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :completed, :due_date, :priority)
  end

  def task_cache_key
    page = params.fetch(:page, 1)
    "user:#{current_user.id}/tasks/page:#{page}/priority:#{params[:priority]}/sort:#{params[:sort]}/completed:#{params[:completed]}/overdue:#{params[:overdue]}"
  end

  def fetch_with_cache(key, expires_in: CACHE_TTL)
    cached_data = Rails.cache.read(key)
    if cached_data
      render json: cached_data
      return
    end

    result = yield

    Rails.cache.write(key, result, expires_in: expires_in)
    render json: result
  end

  def invalidate_task_cache
    Rails.cache.delete_matched("user:#{current_user.id}/tasks/*")
  end
end
