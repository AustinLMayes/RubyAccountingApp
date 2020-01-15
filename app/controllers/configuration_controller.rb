class ConfigurationController < ApplicationController

  def index
    @categories = Category.all
    @new = Category.new
  end

  def create_category
    Category.create(params.require(:category).permit!)
    redirect_to main_app.configuration_path
  end

  def update_category
    c = Category.find(id: params['id'])
    c.update(params.require(:category).permit!)
    redirect_to main_app.configuration_path
  end

  def destroy_category
    Category.find(id: params['id']).destroy
    redirect_to main_app.configuration_path
  end

end
