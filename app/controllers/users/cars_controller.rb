module Users
  class CarsController < Users::Base
    before_action :set_car, except: %i[index new create update_images]

    def index
      @cars = current_business.cars
    end

    def show; end

    def new
      if Rails.env.development?
        @car = current_business.cars.new(
          # テスト用デフォルト値 ==========================
          usage:                        0,
          owner_name:                   'テストuser1',
          safety_manager:               'anzen taro',
          vehicle_name:                 'ハイエース',
          vehicle_model:                'ZVW30',
          vehicle_number:               '品川111あ1111',
          vehicle_inspection_start_on:  Date.today,
          vehicle_inspection_end_on:    Date.today.since(3.years),
          liability_securities_number:  '7c97466446',
          liability_insurance_start_on: Date.today,
          liability_insurance_end_on:   Date.today.next_year,
          car_insurance_company_id:     1
          # ============================================
        )
        @car.car_voluntary_insurances.build(
          # テスト用デフォルト値 ==========================
          personal_insurance:           1,
          objective_insurance:          2,
          voluntary_securities_number:  '9a87456380',
          voluntary_insurance_start_on: Date.today,
          voluntary_insurance_end_on:   Date.today.next_year,
          company_voluntary_id:         3
          # ============================================
        )
      else
        @car = current_business.cars.new
        @car.car_voluntary_insurances.build
      end
    end

    def create
      @car = current_business.cars.build(car_params_with_converted)
      if @car.save
        redirect_to users_car_url(@car)
      else
        render :new
      end
    end

    def edit; end

    def update
      if @car.update(car_params_with_converted)
        flash[:success] = '更新しました'
        redirect_to users_car_url
      else
        render 'edit'
      end
    end

    def destroy
      @car.destroy!
      flash[:danger] = "#{@car.vehicle_model}を削除しました"
      redirect_to users_cars_url
    end

    def update_images
      car = current_business.cars.find_by(uuid: params[:car_id])
      remain_images = car.images
      deleted_image = remain_images.delete_at(params[:index].to_i)
      deleted_image.try(:remove!)
      car.update!(images: remain_images)
      flash[:danger] = '添付画像を削除しました'
      redirect_to edit_users_car_url(car)
    end

    private

    def set_car
      @car = current_business.cars.find_by(uuid: params[:uuid])
    end

    def car_params_with_converted
      converted_params = car_params.dup
      # ハイフンを除外
      converted_params[:vehicle_number] = car_params[:vehicle_number].gsub(/[-ー]/, '')

      if params[:action] == 'update' && (converted_params[:images])
        # 任意保険証の写し追加処理
        converted_params = converted_params.merge('images' => @car.images.push(converted_params[:images]).flatten)
      end
      converted_params
    end

    def car_params
      params.require(:car).permit(:usage, :owner_name, :safety_manager,
        :vehicle_name, :vehicle_model, :vehicle_number, :vehicle_inspection_start_on, :vehicle_inspection_end_on,
        :liability_securities_number, :liability_insurance_start_on, :liability_insurance_end_on,
        :voluntary_securities_number, :voluntary_insurance_start_on, :voluntary_insurance_end_on,
        :car_insurance_company_id, { images: [] },
        car_voluntary_insurances_attributes: %i[
          id personal_insurance objective_insurance voluntary_securities_number
          voluntary_insurance_start_on voluntary_insurance_end_on company_voluntary_id
        ]
      )
    end
  end
end
