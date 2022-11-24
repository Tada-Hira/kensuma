module Users::Orders
  class FieldSolventsController < Users::Base
    before_action :set_order
    before_action :set_field_solvent, only: %i[show edit update destroy]

    def show; end

    def new
      if @order.field_solvents.present?
        redirect_to users_order_field_solvent_path(@order, @order.field_solvents.first)
      else
        @field_solvent = @order.field_solvents.new
      end
    end

    def create
      @field_solvent = @order.field_solvents.build(field_solvent_params)
      if @field_solvent.save
        flash[:success] = '溶剤情報を登録しました。'
        redirect_to users_order_field_solvent_url(@order, @field_solvent)
      else
        render :new
      end
    end

    def destroy
      @field_solvent.destroy!
      flash[:danger] = "#{@field_solvent.solvent_name}を削除しました"
      redirect_to users_order_url(@order)
    end

    def edit; end

    def update
      if @field_solvent.update(field_solvent_params)
        flash[:success] = '溶剤情報を更新しました'
        redirect_to users_order_field_solvent_url(@order, @field_solvent)
      else
        render 'edit'
      end
    end

    private

    def set_order
      @order = current_business.orders.find_by(site_uu_id: params[:order_site_uu_id])
    end

    def set_field_solvent
      @field_solvent = @order.field_solvents.find_by(uuid: params[:uuid])
    end

    def set_field_solvents
      @field_solvents = @order.field_solvents
    end

    def field_solvent_params
      params.require(:field_solvent).permit(
          :solvent_name, :carried_quantity, :solvent_classification, :solvent_ingredients, :using_location, :storing_place,
          :using_tool, :usage_period_start, :usage_period_end, :working_process, :sds, :ventilation_control
      )
    end
  end
end
