# controllers/admin/charts_controller.rb
class Admin::ChartsController < ApplicationController
    def students
      year = Time.current.year
      data = User
        .where(role: "student", created_at: Time.new(year).all_year)
        .group("EXTRACT(MONTH FROM created_at)")
        .count
      render json: (1..12).map { |m| data[m] || 0 }
    end
end
