class Admin::AchievementsController < ApplicationController
  before_action :set_achievement, only: [ :edit, :update, :destroy ]

  def index
    @achievements = Achievement.includes(:user)
                               .order(created_at: :desc)
                               .page(params[:page]).per(10)
  end

  def edit
    render partial: "form", locals: { achievement: @achievement }
  end

  def update
    if @achievement.update(achievement_params)
      redirect_to admin_achievements_path, notice: "Achievement updated successfully."
    else
      # Re-render the partial so the modal shows validation errors
      render partial: "form", locals: { achievement: @achievement },
             status: :unprocessable_entity
    end
  end

  def destroy
    @achievement.destroy
    redirect_to admin_achievements_path, notice: "Achievement removed."
  end

  private

  def set_achievement
    @achievement = Achievement.find(params[:id])
  end

  def achievement_params
    params.require(:achievement).permit(:title, :description, :year, :ielts_overall_band, :result)
  end
end
