module Users
  class OrdersController < Users::Base
    before_action :set_order, except: %i[index new create]

    def index
      @orders = current_business.orders
    end

    def show; end

    def new
      @order = current_business.orders.new(
        # テスト用デフォルト値 ==========================
        site_name:  current_business.name,
        order_name: current_user.name
        # order_post_code: current_business.post_code,
        # order_address:   current_business.address
        # =============================================
      )
    end

    def create
      ActiveRecord::Base.transaction do
        @order = current_business.orders.build(order_params)
        request_order = @order.request_orders.build(business: current_business)
        # 表紙
        request_order.documents.build(
          document_type: 0,
          created_on:    Date.current,
          submitted_on:  Date.current,
          content:       {
            'business_name': '', # 1-1
            'submitted_on':  '' # 1-2
          },
          business:      current_business
        )

        # 目次
        request_order.documents.build(
          document_type: 1,
          created_on:    Date.current,
          submitted_on:  Date.current,
          content:       {},
          business:      current_business
        )

        # 施工体制台帳作成建設工事の通知
        request_order.documents.build(
          document_type: 2,
          created_on:    Date.current,
          submitted_on:  Date.current,
          content:       {
            'submitted_on':           '', # 3-1
            'prime_contractor_name':  '', # 3-2
            'site_name':              '', # 3-3
            'business_name':          '', # 3-4
            'orderer_name':           '', # 3-5
            'construction_name':      '', # 3-6
            'supervisor_name':        '', # 3-7
            'apply':                  '', # 3-8
            'submission_destination': '' # 3-9
          },
          business:      current_business
        )
        request_order.documents.build(
          document_type: 8,
          created_on: Date.current,
          submitted_on: Date.current,
          content: {},
          business: current_business
        )

        if @order.save!
          redirect_to users_order_url(@order)
        end
      end
    rescue ActiveRecord::RecordInvalid
      flash[:danger] = '登録に失敗しました。再度作成してください。'
      redirect_to new_users_order_path
    end

    def edit; end

    def update
      if @order.update(order_params)
        flash[:success] = '更新しました'
        redirect_to users_order_url
      else
        render :edit
      end
    end

    def destroy
      @order.destroy!
      flash[:danger] = "#{@order.site_uu_id}を削除しました"
      redirect_to users_orders_url
    end

    private

    def set_order
      @order = current_business.orders.find_by(site_uu_id: params[:site_uu_id])
    end

    def order_params
      params.require(:order).permit(:status, :site_name, :order_name, :order_post_code, :order_address)
    end
  end
end
