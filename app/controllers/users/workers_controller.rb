# rubocop:disable Metrics/ClassLength
module Users
  class WorkersController < Users::Base
    before_action :set_worker, only: %i[show edit update destroy]
    before_action :convert_to_full_width, only: %i[create update]

    def index
      @workers = current_business.workers
    end

    def new
      if Rails.env.development?
        # test_data_new
        production_data_new
        worker_add_hyhpen(@worker)
      else
        production_data_new
      end
    end

    def create
      @worker = current_business.workers.build(worker_params_with_converted)
      if @worker.save
        unless @worker.worker_medical.is_special_med_exam == 'y' && @worker.worker_medical.worker_exams.blank?
          @worker.worker_medical.worker_exams.destroy_all
        end
        flash[:success] = '作業員情報を作成しました'
        redirect_to users_worker_path(@worker)
      else
        worker_add_hyhpen(@worker)
        render :new
      end
    end

    def show
      worker_add_hyhpen(@worker)
    end

    def edit
      @worker.worker_licenses.build if @worker.licenses.blank?
      @worker.worker_skill_trainings.build if @worker.skill_trainings.blank?
      @worker.worker_special_educations.build if @worker.special_educations.blank?
      worker_add_hyhpen(@worker)
      if @worker.status_of_residence.blank?
        @worker.status_of_residence = :construction_employment
        @worker.confirmed_check = :checked
      elsif @worker.maturity_date.blank?
        @worker.confirmed_check = :checked
      end
    end

    def update
      if @worker.update(worker_params_with_converted)
        @worker.worker_medical.worker_exams.destroy_all unless @worker.worker_medical.is_special_med_exam == 'y'
        flash[:success] = '更新しました'
        redirect_to users_worker_path(@worker)
      else
        worker_add_hyhpen(@worker)
        render :edit
      end
    end

    def destroy
      @worker.destroy!
      flash[:danger] = "#{@worker.name}を削除しました"
      redirect_to users_workers_url
    end

    def update_workerlicense_images
      worker = current_business.workers.find_by(uuid: params[:worker_id])
      worker_license = worker.worker_licenses.find(params[:worker_license_id])
      remain_images = worker_license.images
      deleted_image = remain_images.delete_at(params[:index].to_i)
      deleted_image.try(:remove!)
      worker_license.update!(images: remain_images)
      flash[:danger] = '証明画像を削除しました'
      redirect_to edit_users_worker_url(worker) and return
    end

    def update_workerskilltraining_images
      worker = current_business.workers.find_by(uuid: params[:worker_id])
      worker_skill_training = worker.worker_skill_trainings.find(params[:worker_skill_training_id])
      remain_images = worker_skill_training.images
      deleted_image = remain_images.delete_at(params[:index].to_i)
      deleted_image.try(:remove!)
      worker_skill_training.update!(images: remain_images)
      flash[:danger] = '証明画像を削除しました'
      redirect_to edit_users_worker_url(worker)
    end

    def update_workerspecialeducation_images
      worker = current_business.workers.find_by(uuid: params[:worker_id])
      worker_special_education = worker.worker_special_educations.find(params[:worker_special_education_id])
      remain_images = worker_special_education.images
      deleted_image = remain_images.delete_at(params[:index].to_i)
      deleted_image.try(:remove!)
      worker_special_education.update!(images: remain_images)
      flash[:danger] = '証明画像を削除しました'
      redirect_to edit_users_worker_url(worker)
    end

    def update_workerexam_images
      worker = current_business.workers.find_by(uuid: params[:worker_id])
      worker_exam = worker.worker_medical.worker_exams.find(params[:worker_exam_id])
      remaining_images = worker_exam.images
      deleting_images = remaining_images.delete_at(params[:index].to_i)
      deleting_images.try(:remove!)
      worker_exam.update!(images: remaining_images)
      flash[:danger] = '証明画像を削除しました'
      redirect_to edit_users_worker_url(worker)
    end

    def update_worker_safety_health_education_images
      worker = current_business.workers.find_by(uuid: params[:worker_id])
      worker_safety_health_education = worker.worker_safety_health_educations.find(params[:safety_health_education_id])
      remaining_images = worker_safety_health_education.images
      deleting_images = remaining_images.delete_at(params[:index].to_i)
      deleting_images.try(:remove!)
      worker_safety_health_education.update!(images: remaining_images)
      flash[:danger] = '証明画像を削除しました'
      redirect_to edit_users_worker_url(worker)
    end

    def update_health_insurance_image
      worker = current_business.workers.find_by(uuid: params[:worker_id])
      worker_insurance = worker.worker_insurance
      remaining_images = worker_insurance.health_insurance_image
      deleting_images = remaining_images.delete_at(params[:index].to_i)
      deleting_images.try(:remove!)
      worker_insurance.update!(health_insurance_image: remaining_images)
      flash[:danger] = '証明画像を削除しました'
      redirect_to edit_users_worker_url(worker)
    end

    def update_career_up_images
      worker = current_business.workers.find_by(uuid: params[:worker_id])
      remaining_images = worker.career_up_images
      deleting_images = remaining_images.delete_at(params[:index].to_i)
      deleting_images.try(:remove!)
      worker.update!(career_up_images: remaining_images)
      flash[:danger] = '証明画像を削除しました'
      redirect_to edit_users_worker_url(worker)
    end

    def delete_seal
      worker = current_business.workers.find_by(uuid: params[:worker_id])
      worker.update(seal: nil)
      flash[:danger] = '証明画像を削除しました'
      redirect_to edit_users_worker_url(worker)
    end

    def update_passports
      worker = current_business.workers.find_by(uuid: params[:worker_id])
      remaining_images = worker.passports
      deleting_images = remaining_images.delete_at(params[:index].to_i)
      deleting_images.try(:remove!)
      worker.update!(passports: remaining_images)
      flash[:danger] = '証明画像を削除しました'
      redirect_to edit_users_worker_url(worker)
    end

    def update_residence_cards
      worker = current_business.workers.find_by(uuid: params[:worker_id])
      remaining_images = worker.residence_cards
      deleting_images = remaining_images.delete_at(params[:index].to_i)
      deleting_images.try(:remove!)
      worker.update!(residence_cards: remaining_images)
      flash[:danger] = '証明画像を削除しました'
      redirect_to edit_users_worker_url(worker)
    end

    def update_employment_conditions
      worker = current_business.workers.find_by(uuid: params[:worker_id])
      remaining_images = worker.employment_conditions
      deleting_images = remaining_images.delete_at(params[:index].to_i)
      deleting_images.try(:remove!)
      worker.update!(employment_conditions: remaining_images)
      flash[:danger] = '証明画像を削除しました'
      redirect_to edit_users_worker_url(worker)
    end

    def update_employee_cards
      worker = current_business.workers.find_by(uuid: params[:worker_id])
      remaining_images = worker.employee_cards
      deleting_images = remaining_images.delete_at(params[:index].to_i)
      deleting_images.try(:remove!)
      worker.update!(employee_cards: remaining_images)
      flash[:danger] = '証明画像を削除しました'
      redirect_to edit_users_worker_url(worker)
    end

    private

    def set_worker
      @worker = current_business.workers.find_by(uuid: params[:uuid])
    end

    # 半角カタカナを全角カタカナに変換する
    def convert_to_full_width
      if params[:worker][:name_kana].present?
        params[:worker][:name_kana] = params[:worker][:name_kana].gsub(/[\uFF61-\uFF9F]+/) { |str| str.unicode_normalize(:nfkc) }
      end
    end

    def worker_params_with_converted
      converted_params = worker_params.dup
      # 全角スペースを半角スペースに変換
      %i[name name_kana].each do |key|
        next unless converted_params[key].present?

        converted_params[key] = space_full_width_to_half_width(converted_params[key])
      end

      # ハイフンを除去する
      %i[my_phone_number family_phone_number post_code career_up_id driver_licence_number].each do |key|
        next unless converted_params[key].present?

        converted_params[key] = reject_hyphen(converted_params[key])
      end

      # スペースを除去する
      %i[career_up_id driver_licence_number].each do |key|
        next unless converted_params[key].present?

        converted_params[key] = reject_space(converted_params[key])
      end

      # 全角数字を半角に変換
      %i[
        my_phone_number
        family_phone_number
        post_code
        career_up_id
        driver_licence_number
        blank_term
        experience_term_before_hiring
      ].each do |key|
        next unless converted_params[key].present?

        converted_params[key] = full_width_to_half_width(converted_params[key])
      end

      # 作業員健康情報のパラメーター整理
      # 健康診断項目の受診の有無が無の時、診断日と血圧をnilにする
      worker_medical_attributes = converted_params[:worker_medical_attributes]
      if worker_medical_attributes[:is_med_exam] == 'n'
        worker_medical_attributes[:med_exam_on] = nil
        worker_medical_attributes[:max_blood_pressure] = nil
        worker_medical_attributes[:min_blood_pressure] = nil
      end

      # 健康診断項目の受診の有無が無の時、診断日と診断種類をnilにする
      if worker_medical_attributes[:is_special_med_exam] == 'n'
        worker_medical_attributes[:special_med_exam_on] = nil
      end

      # 保険名、被保険者番号、建設業退職金共済手帳その他、労働保険特別加入が必須でない場合パラメータを空文字にする
      %i[health_insurance_name employment_insurance_number severance_pay_mutual_aid_name has_labor_insurance].each do |key|
        next unless converted_params[:worker_insurance_attributes][key].present?

        worker_insurance_attributes_params = converted_params[:worker_insurance_attributes]
        unchenge_params = worker_insurance_attributes_params[key]
        worker_insurance_attributes_params[key] = case key
                                                  when :health_insurance_name
                                                    health_insurance_name_nil(worker_insurance_attributes_params[:health_insurance_type], unchenge_params)
                                                  when :employment_insurance_number
                                                    employment_insurance_number_nil(worker_insurance_attributes_params[:employment_insurance_type], unchenge_params)
                                                  when :severance_pay_mutual_aid_name
                                                    severance_pay_mutual_aid_name_nil(worker_insurance_attributes_params[:severance_pay_mutual_aid_type], unchenge_params)
                                                  when :has_labor_insurance
                                                    empty_has_labor_insurance(converted_params[:business_owner_or_master], unchenge_params)
                                                  end
      end

      # 事業主もしくは一人親方であれば、雇用保険に関する項目を空文字にする
      if converted_params[:business_owner_or_master] == '1'
        converted_params[:worker_insurance_attributes][:employment_insurance_type] = ''
        converted_params[:worker_insurance_attributes][:employment_insurance_number] = ''
      end

      # 運転免許証のデータを作成
      if converted_params[:driver_licences].blank?
        converted_params[:driver_licences] = []
        converted_params[:driver_licence_number] = ''
      end

      # 外国人情報の整形
      arg_array = [converted_params[:country], converted_params[:status_of_residence], converted_params[:confirmed_check]]
      %i[status_of_residence maturity_date confirmed_check confirmed_check_date].each do |key|
        if converted_params[key].present?
          if japanese?(arg_array[0])
            converted_params = converted_params.merge(key => '')
          elsif skill_practice_or_permanent_resident?(arg_array[1], key)
            converted_params = converted_params.merge(key => '')
          elsif confirmed_check_unchecked?(arg_array[2], key)
            converted_params = converted_params.merge(key => '')
          else
            converted_params[key]
          end
        else
          converted_params[key]
        end
      end
      %i[passports residence_cards employment_conditions].each do |key|
        if converted_params[key].present?
          if japanese?(arg_array[0])
            converted_params = converted_params.merge(key => [])
          elsif skill_practice_or_permanent_resident?(arg_array[1], key)
            converted_params = converted_params.merge(key => [])
          elsif confirmed_check_unchecked?(arg_array[2], key)
            converted_params = converted_params.merge(key => [])
          else
            converted_params[key]
          end
        else
          converted_params[key]
        end
      end
      converted_params
    end

    # 健康保険が健康保険組合もしくは建設国保でなければ保険名を空文字にする
    def health_insurance_name_nil(health_insurance_type, params)
      health_insurance_name_precenses = %w[health_insurance_association construction_national_health_insurance]
      if health_insurance_name_precenses.exclude?(health_insurance_type)
        ''
      else
        params
      end
    end

    # 雇用保険が被保険者で無ければ被保険者番号を空文字にする
    def employment_insurance_number_nil(employment_insurance_type, params)
      if %w[insured day].exclude?(employment_insurance_type)
        ''
      else
        params
      end
    end

    # 日本人であるか？
    def japanese?(country)
      country == 'JP'
    end

    # 外国人労働者に当たらないか？
    def skill_practice_or_permanent_resident?(status_of_residence, key)
      %w[permanent_resident skill_practice].include?(status_of_residence) && key != :status_of_residence
    end

    # CCUS登録情報が最新でないか？
    def confirmed_check_unchecked?(confirmed_check, key)
      confirmed_check == 'unchecked' && key == :confirmed_check_date
    end

    # 建設業退職金共済手帳がその他で無ければその他（建設業退職金共済手帳）を空文字にする
    def severance_pay_mutual_aid_name_nil(severance_pay_mutual_aid_type, params)
      if severance_pay_mutual_aid_type != 'other'
        ''
      else
        params
      end
    end

    # 事業主もしくは一人親方で無ければ、労働保険特別加入を空文字にする
    def empty_has_labor_insurance(business_owner_or_master, params)
      if business_owner_or_master != '1'
        ''
      else
        params
      end
    end

    # 作業員情報のハイフン差し込み
    def worker_add_hyhpen(worker)
      if worker.present?
        @my_phone_number = phone_number_add_hyphen(worker.my_phone_number)
        @family_phone_number = phone_number_add_hyphen(worker.family_phone_number)
        @post_code = post_code_add_hyphen(worker.post_code)
        @career_up_id = career_up_id_add_hyphen(worker.career_up_id)
        @driver_licence_number = driver_licence_number_add_hyphen(worker.driver_licence_number)
      end
    end

    def worker_params
      params.require(:worker).permit(:name, :name_kana,
        :country, :my_address, :my_phone_number, :family_address, :post_code, { career_up_images: [] },
        :family_phone_number, :birth_day_on, :abo_blood_type, { employee_cards: [] }, { driver_licences: [] },
        :rh_blood_type, :job_title, :hiring_on, :experience_term_before_hiring, :driver_licence_number, :business_owner_or_master,
        :blank_term, :career_up_id, :employment_contract, :family_name, :relationship, :email, :sex, :seal,
        :status_of_residence, :maturity_date, :confirmed_check, :confirmed_check_date,
        { passports: [] }, { residence_cards: [] }, { employment_conditions: [] },
        worker_licenses_attributes:                 [:id, :license_id, { images: [] }, :_destroy],
        worker_safety_health_educations_attributes: [:id, :safety_health_education_id, { images: [] }, :_destroy],
        worker_skill_trainings_attributes:          [:id, :skill_training_id, { images: [] }, :_destroy],
        worker_special_educations_attributes:       [:id, :special_education_id, { images: [] }, :_destroy],
        worker_medical_attributes:                  [
          :id, :med_exam_on, :max_blood_pressure, :min_blood_pressure, :special_med_exam_on, :health_condition, :is_med_exam, :is_special_med_exam,
          { worker_exams_attributes: %i[id worker_medical_id special_med_exam_id others _destroy] }
        ],
        worker_insurance_attributes:
                                                    [
                                                      :id,
                                                      :health_insurance_type,
                                                      :health_insurance_name,
                                                      :pension_insurance_type,
                                                      :employment_insurance_type,
                                                      :employment_insurance_number,
                                                      :severance_pay_mutual_aid_type,
                                                      :severance_pay_mutual_aid_name,
                                                      :has_labor_insurance,
                                                      { health_insurance_image: [] }
                                                    ]
      )
    end
  end
end
# rubocop:enable Metrics/ClassLength
