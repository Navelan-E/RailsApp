class ProfileController < ApplicationController
  def show
    if customer_signed_in?
      @user = current_customer
    elsif mechanic_signed_in?
      @user = current_mechanic
    else
      redirect_to root_path, alert: "Please sign in to view your profile."
    end
  end

  def edit
    @customer = current_customer
  end

end
