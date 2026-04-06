module PaginationHelper
  extend ActiveSupport::Concern

  def pagination(scope, items_per_page = 4)
    page = params.fetch(:page, 1).to_i
    page = 1 if page < 1

    offset = (page - 1) * items_per_page

    records = scope.limit(items_per_page).offset(offset)

    total_count = scope.count
    total_pages = (total_count.to_f / items_per_page).ceil

    {
      records: records,
      meta: {
        current_page: page,
        next_page: page < total_pages ? page + 1 : nil,
        prev_page: page > 1 ? page - 1: nil,
        total_count: total_count,
        total_pages: total_pages
      }
    }
  end
end
