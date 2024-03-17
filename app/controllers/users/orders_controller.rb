# rubocop:disable all
module Users
  class OrdersController < Users::Base
    before_action :prime_contractor_access, except: :index
    before_action :set_business_workers_name, only: %i[new create edit update]
    before_action :set_order, except: %i[index new create]
    before_action :set_business_construction_licenses, only: %i[new create edit update]
    before_action :check_system_chart_status, only: :system_chart_status

    def index
      @orders = current_business.orders
      @received_orders = @current_business.request_orders.reject { |request_order|
        request_order.order.business_id == @current_business.id
      }.sort.reverse
    end

    def show; end

    def new
      if Rails.env.development?
        @order = current_business.orders.new(
          # テスト用デフォルト値 ==========================
          site_career_up_id:                   '12345678910000',
          site_name:                           'サイト株式会社',
          site_address:                        '東京都サイト区1-2-1',

          order_name:                          'オーダー株式会社',
          order_post_code:                     '0123456',
          order_address:                       '東京都オーダー区1-2-1',
          order_supervisor_name:               'テストスーパーバイザー',
          order_supervisor_company:            'テストスーパーバイザー株式会社',
          order_supervisor_apply:              %w[基本契約約款の通り 契約書に準拠する 口頭及び文書による].sample,

          construction_name:                   '工事名',
          construction_details:                '工事内容',
          start_date:                          Date.today,
          end_date:                            Date.today.next_month,
          contract_date:                       Date.today.prev_month,
          submission_destination:              'テスト作業員1',
          supervisor_name:                     'テスト作業員1',
          supervisor_apply:                    %w[基本契約約款の通り 契約書に準拠する 口頭及び文書による].sample,
          site_agent_name:                     'テスト作業員1',
          site_agent_apply:                    %w[基本契約約款の通り 契約書に準拠する 口頭及び文書による].sample,
          #supervising_engineer_name:           'テスト作業員1',
          supervising_engineer_check:          0,
          #supervising_engineer_assistant_name: 'テスト作業員1'
          # =============================================
        )
      else
        @order = current_business.orders.new
      end
        @professional_engineer_qualification_1st = License.all.order(:id)
        @professional_engineer_qualification_2nd = License.all.order(:id)
        @supervising_engineer_qualification = License.all.order(:id)
        @supervising_engineer_assistant_qualification = License.all.order(:id)
    end

    def create
      @order = current_business.orders.build(order_params_with_converted)
      request_order = @order.request_orders.build(business: current_business)

      24.times do |n|
        request_order.documents.build(
          document_type: n + 1,
          created_on:    Date.current,
          submitted_on:  Date.current,
          business:      current_business
        )
      end

      if @order.save
        redirect_to users_order_url(@order)
      else
        render :new
      end
    end

    def edit
      # orderの技術者名1から作業員テーブルのレコードを特定する
      worker = Worker.find_by(name: @order.professional_engineer_name_1st, business_id: current_business.id)
      # 作業員のidで作業員と技能検定マスターの中間テーブル(worker_license)を特定する
      worker_license = WorkerLicense.where(worker_id: worker&.id)
      array = []
      worker_license.each do |record|
        array << record.license_id
      end
      if worker.nil?
        @professional_engineer_qualification_1st = License.all.order(:id)
      else
        @professional_engineer_qualification_1st = License.where("id IN (?)", array)
      end

      # orderの技術者名2から作業員テーブルのレコードを特定する
      worker = Worker.find_by(name: @order.professional_engineer_name_2nd, business_id: current_business.id)
      # 作業員のidで作業員と技能検定マスターの中間テーブル(worker_license)を特定する
      worker_license = WorkerLicense.where(worker_id: worker&.id)
      array = []
      worker_license.each do |record|
        array << record.license_id
      end
      if worker.nil?
        @professional_engineer_qualification_2nd = License.all.order(:id)
      else
        @professional_engineer_qualification_2nd = License.where("id IN (?)", array)
      end

      # orderの監督技術者･主任技術者から作業員テーブルのレコードを特定する
      worker = Worker.find_by(name: @order.supervising_engineer_name, business_id: current_business.id)
      # 作業員のidで作業員と技能技能検定マスターの中間テーブル(worker_license)を特定する
      worker_license = WorkerLicense.where(worker_id: worker&.id)
      array = []
      worker_license.each do |record|
        array << record.license_id
      end
      if worker.nil?
        @supervising_engineer_qualification = License.all.order(:id)
      else
        @supervising_engineer_qualification = License.where("id IN (?)", array)
      end

      # orderの監督技術者補佐から作業員テーブルのレコードを特定する
      worker = Worker.find_by(name: @order.supervising_engineer_assistant_name, business_id: current_business.id)
      # 作業員のidで作業員と技能検定マスターの中間テーブル(worker_license)を特定する
      worker_license = WorkerLicense.where(worker_id: worker&.id)
      array = []
      worker_license.each do |record|
        array << record.license.id
      end
      if worker.nil?
        @supervising_engineer_assistant_qualification = License.all.order(:id)
      else
        @supervising_engineer_assistant_qualification = License.where("id IN (?)", array)
      end
    end

    def update
      if @order.update(order_params_with_converted)
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

    def system_chart_status; end

    # 専門技術者1
    def professional_engineer_1st_license_options
      professional_engineer_name_1st = params[:professional_engineer_name_1st]
      worker = Worker.find_by(name: professional_engineer_name_1st)
      options = worker&.licenses
      render json: options
    end

    # 専門技術者2
    def professional_engineer_2nd_license_options
      professional_engineer_name_2nd = params[:professional_engineer_name_2nd]
      worker = Worker.find_by(name: professional_engineer_name_2nd)
      options = worker&.licenses
      render json: options
    end

    # 監督技術者・主任技術者
    def supervising_engineer_license_options
      supervising_engineer_name = params[:supervising_engineer_name]
      worker = Worker.find_by(name: supervising_engineer_name)
      options = worker&.licenses
      render json: options
    end

    # 監督技術者補佐
    def supervising_engineer_assistant_license_options
      supervising_engineer_assistant_name = params[:supervising_engineer_assistant_name]
      worker = Worker.find_by(name: supervising_engineer_assistant_name)
      options = worker&.licenses
      render json: options
    end

    private

    def set_order
      @order = current_business.orders.find_by(site_uu_id: params[:site_uu_id])
    end

    def order_params_with_converted
      converted_params = order_params.dup
      # ハイフンを除外
      converted_params[:order_post_code] = order_params[:order_post_code].gsub(/[-ー]/, '')

      converted_params
    end

    # 提出済みの場合は現場情報の編集を不可にする
    def check_status_order
      if @order.request_orders.where(parent_id: nil).approved
        flash[:danger] = '提出済のため、編集できません。'
        redirect_to users_order_path(@order)
      end
    end

    # 有料、無料ユーザーの切り分け(無料ユーザーは元請機能の使用を制限する)
    def prime_contractor_access
      redirect_to users_orders_path, flash: { danger: '現場情報作成機能は有料サービスとなります' } if current_user.is_prime_contractor == false
    end

    # 工事作業所災害防止協議会兼施工体系図,作業間連絡調整書の公開の有無の切り替え
    def check_system_chart_status
      request_order = RequestOrder.find_by(params[:uuid])
      order = request_order.order
      order.update_attribute(:system_chart_status, !order.system_chart_status)

      if order.system_chart_status
        flash[:success] = '工事作業所災害防止協議会兼施工体系図と作業間連絡調整書を公開しました'
      else
        flash[:danger] = '工事作業所災害防止協議会兼施工体系図と作業間連絡調整書を非公開にしました'
      end
      redirect_to users_request_order_path(uuid: request_order)
    end

    # 業種1(建設許可証番号)がbusiness_industryにない時も取得する
    def occupation_1st
      occupation_info_1st = params.dig(:order, :content, :construction_license_number)&.slice(0)
      if occupation_info_1st.present?
        business_industry_occupation_1st = BusinessIndustry.find_by(id: occupation_info_1st)
        industry_id_1st = BusinessIndustry.find_by(id: params.dig(:order, :content, :construction_license_number)&.slice(0))&.industry_id
        if business_industry_occupation_1st.nil? && (occupation_info_1st == @order.content&.[]('genecon_construction_license_id_1st'))
          @order.content&.[]('genecon_occupation_1st')
        elsif business_industry_occupation_1st.nil? && (occupation_info_1st == @order.content&.[]('genecon_construction_license_id_2nd'))
          @order.content&.[]('genecon_occupation_2nd')
        else
          Industry.find_by(id: industry_id_1st)&.name
        end
      end
    end

    # 業種2(建設許可証番号)がbusiness_industryにない時も取得する
    def occupation_2nd
      occupation_info_2nd = params.dig(:order, :content, :construction_license_number)&.slice(1)
      if occupation_info_2nd.present?
        business_industry_occupation_2nd = BusinessIndustry.find_by(id: occupation_info_2nd)
        industry_id_2nd = BusinessIndustry.find_by(id: params.dig(:order, :content, :construction_license_number)&.slice(1))&.industry_id
        if business_industry_occupation_2nd.nil? && (occupation_info_2nd == @order.content&.[]('genecon_construction_license_id_1st'))
          @order.content&.[]('genecon_occupation_1st')
        elsif business_industry_occupation_2nd.nil? && (occupation_info_2nd == @order.content&.[]('genecon_construction_license_id_2nd'))
          @order.content&.[]('genecon_occupation_2nd')
        else
          Industry.find_by(id: industry_id_2nd)&.name
        end
      end
    end

    # 建設業許可種別(大臣,知事)1(建設許可証番号)がbusiness_industryにない時も取得する
    def construction_license_permission_type_minister_governor_1st
      construction_license_permission_type_minister_governor_info_1st = params.dig(:order, :content, :construction_license_number)&.slice(0)
      if construction_license_permission_type_minister_governor_info_1st.present?
        business_industry_minister_governor_1st = BusinessIndustry.find_by(id: construction_license_permission_type_minister_governor_info_1st)
        if business_industry_minister_governor_1st.nil? && (construction_license_permission_type_minister_governor_info_1st == @order.content&.[]('genecon_construction_license_id_1st'))
          @order.content&.[]('genecon_construction_license_permission_type_minister_governor_1st')
        elsif business_industry_minister_governor_1st.nil? && (construction_license_permission_type_minister_governor_info_1st == @order.content&.[]('genecon_construction_license_id_2nd'))
          @order.content&.[]('genecon_construction_license_permission_type_minister_governor_2nd')
        else
          BusinessIndustry.find_by(id: params.dig(:order, :content, :construction_license_number)&.slice(0))&.construction_license_permission_type_minister_governor_i18n
        end
      end
    end

    # 建設業許可種別(大臣,知事)2(建設許可証番号)がbusiness_industryにない時も取得する
    def construction_license_permission_type_minister_governor_2nd
      construction_license_permission_type_minister_governor_info_2nd = params.dig(:order, :content, :construction_license_number)&.slice(1)
      if construction_license_permission_type_minister_governor_info_2nd.present?
        business_industry_minister_governor_2nd = BusinessIndustry.find_by(id: construction_license_permission_type_minister_governor_info_2nd)
        if business_industry_minister_governor_2nd.nil? && (construction_license_permission_type_minister_governor_info_2nd == @order.content&.[]('genecon_construction_license_id_1st'))
          @order.content&.[]('genecon_construction_license_permission_type_minister_governor_1st')
        elsif business_industry_minister_governor_2nd.nil? && (construction_license_permission_type_minister_governor_info_2nd == @order.content&.[]('genecon_construction_license_id_2nd'))
          @order.content&.[]('genecon_construction_license_permission_type_minister_governor_2nd')
        else
          BusinessIndustry.find_by(id: params.dig(:order, :content, :construction_license_number)&.slice(1))&.construction_license_permission_type_minister_governor_i18n
        end
      end
    end

    # 建設業許可種別(特定,一般)1(建設許可証番号)がbusiness_industryにない時も取得する
    def construction_license_permission_type_identification_general_1st
      construction_license_permission_type_identification_general_info_1st = params.dig(:order, :content, :construction_license_number)&.slice(0)
      if construction_license_permission_type_identification_general_info_1st.present?
        business_industry_identification_general_1st = BusinessIndustry.find_by(id: construction_license_permission_type_identification_general_info_1st)
        if business_industry_identification_general_1st.nil? && (construction_license_permission_type_identification_general_info_1st == @order.content&.[]('genecon_construction_license_id_1st'))
          @order.content&.[]('genecon_construction_license_permission_type_identification_general_1st')
        elsif business_industry_identification_general_1st.nil? && (construction_license_permission_type_identification_general_info_1st == @order.content&.[]('genecon_construction_license_id_2nd'))
          @order.content&.[]('genecon_construction_license_permission_type_identification_general_2nd')
        else
          BusinessIndustry.find_by(id: params.dig(:order, :content, :construction_license_number)&.slice(0))&.construction_license_permission_type_identification_general_i18n
        end
      end
    end

    # 建設業許可種別(特定,一般)2(建設許可証番号)がbusiness_industryにない時も取得する
    def construction_license_permission_type_identification_general_2nd
      construction_license_permission_type_identification_general_info_2nd = params.dig(:order, :content, :construction_license_number)&.slice(1)
      if construction_license_permission_type_identification_general_info_2nd.present?
        business_industry_identification_general_2nd = BusinessIndustry.find_by(id: construction_license_permission_type_identification_general_info_2nd)
        if business_industry_identification_general_2nd.nil? && (construction_license_permission_type_identification_general_info_2nd == @order.content&.[]('genecon_construction_license_id_1st'))
          @order.content&.[]('genecon_construction_license_permission_type_identification_general_1st')
        elsif business_industry_identification_general_2nd.nil? && (construction_license_permission_type_identification_general_info_2nd == @order.content&.[]('genecon_construction_license_id_2nd'))
          @order.content&.[]('genecon_construction_license_permission_type_identification_general_2nd')
        else
          BusinessIndustry.find_by(id: params.dig(:order, :content, :construction_license_number)&.slice(1))&.construction_license_permission_type_identification_general_i18n
        end
      end
    end

    # 建設業許可番号(2桁)1(建設許可証番号)がbusiness_industryにない時も取得する
    def construction_license_number_double_digit_1st
      construction_license_number_double_digit_info_1st = params.dig(:order, :content, :construction_license_number)&.slice(0)
      if construction_license_number_double_digit_info_1st.present?
        business_industry_double_digit_1st = BusinessIndustry.find_by(id: construction_license_number_double_digit_info_1st)
        if business_industry_double_digit_1st.nil? && (construction_license_number_double_digit_info_1st == @order.content&.[]('genecon_construction_license_id_1st'))
          @order.content&.[]('genecon_construction_license_number_double_digit_1st')
        elsif business_industry_double_digit_1st.nil? && (construction_license_number_double_digit_info_1st == @order.content&.[]('genecon_construction_license_id_2nd'))
          @order.content&.[]('genecon_construction_license_number_double_digit_2nd')
        else
          BusinessIndustry.find_by(id: params.dig(:order, :content, :construction_license_number)&.slice(0))&.construction_license_number_double_digit
        end
      end
    end

    # 建設業許可番号(2桁)2(建設許可証番号)がbusiness_industryにない時も取得する
    def construction_license_number_double_digit_2nd
      construction_license_number_double_digit_info_2nd = params.dig(:order, :content, :construction_license_number)&.slice(1)
      if construction_license_number_double_digit_info_2nd.present?
        business_industry_double_digit_2nd = BusinessIndustry.find_by(id: construction_license_number_double_digit_info_2nd)
        if business_industry_double_digit_2nd.nil? && (construction_license_number_double_digit_info_2nd == @order.content&.[]('genecon_construction_license_id_1st'))
          @order.content&.[]('genecon_construction_license_number_double_digit_1st')
        elsif business_industry_double_digit_2nd.nil? && (construction_license_number_double_digit_info_2nd == @order.content&.[]('genecon_construction_license_id_2nd'))
          @order.content&.[]('genecon_construction_license_number_double_digit_2nd')
        else
          BusinessIndustry.find_by(id: params.dig(:order, :content, :construction_license_number)&.slice(1))&.construction_license_number_double_digit
        end
      end
    end

    # 建設業許可番号(6桁)1(建設許可証番号)がbusiness_industryにない時も取得する
    def construction_license_number_six_digits_1st
      construction_license_number_six_digits_info_1st = params.dig(:order, :content, :construction_license_number)&.slice(0)
      if construction_license_number_six_digits_info_1st.present?
        business_industry_six_digits_1st = BusinessIndustry.find_by(id: construction_license_number_six_digits_info_1st)
        if business_industry_six_digits_1st.nil? && (construction_license_number_six_digits_info_1st == @order.content&.[]('genecon_construction_license_id_1st'))
          @order.content&.[]('genecon_construction_license_number_six_digits_1st')
        elsif business_industry_six_digits_1st.nil? && (construction_license_number_six_digits_info_1st == @order.content&.[]('genecon_construction_license_id_2nd'))
          @order.content&.[]('genecon_construction_license_number_six_digits_2nd')
        else
          BusinessIndustry.find_by(id: params.dig(:order, :content, :construction_license_number)&.slice(0))&.construction_license_number_six_digits
        end
      end
    end

    # 建設業許可番号(6桁)2(建設許可証番号)がbusiness_industryにない時も取得する
    def construction_license_number_six_digits_2nd
      construction_license_number_six_digits_info_2nd = params.dig(:order, :content, :construction_license_number)&.slice(1)
      if construction_license_number_six_digits_info_2nd.present?
        business_industry_six_digits_2nd = BusinessIndustry.find_by(id: construction_license_number_six_digits_info_2nd)
        if business_industry_six_digits_2nd.nil? && (construction_license_number_six_digits_info_2nd == @order.content&.[]('genecon_construction_license_id_1st'))
          @order.content&.[]('genecon_construction_license_number_six_digits_1st')
        elsif business_industry_six_digits_2nd.nil? && (construction_license_number_six_digits_info_2nd == @order.content&.[]('genecon_construction_license_id_2nd'))
          @order.content&.[]('genecon_construction_license_number_six_digits_2nd')
        else
          BusinessIndustry.find_by(id: params.dig(:order, :content, :construction_license_number)&.slice(1))&.construction_license_number_six_digits
        end
      end
    end

    # 建設許可証(更新日)1(建設許可証番号)がbusiness_industryにない時も取得する
    def construction_license_updated_at_1st
      construction_license_updated_at_info_1st = params.dig(:order, :content, :construction_license_number)&.slice(0)
      if construction_license_updated_at_info_1st.present?
        business_industry_updated_at_1st = BusinessIndustry.find_by(id: construction_license_updated_at_info_1st)
        if business_industry_updated_at_1st.nil? && (construction_license_updated_at_info_1st == @order.content&.[]('genecon_construction_license_id_1st'))
          @order.content&.[]('genecon_construction_license_updated_at_1st')
        elsif business_industry_updated_at_1st.nil? && (construction_license_updated_at_info_1st == @order.content&.[]('genecon_construction_license_id_2nd'))
          @order.content&.[]('genecon_construction_license_updated_at_2nd')
        else
          BusinessIndustry.find_by(id: params.dig(:order, :content, :construction_license_number)&.slice(0))&.construction_license_updated_at
        end
      end
    end

    # 建設許可証(更新日)2(建設許可証番号)がbusiness_industryにない時も取得する
    def construction_license_updated_at_2nd
      construction_license_updated_at_info_2nd = params.dig(:order, :content, :construction_license_number)&.slice(1)
      if construction_license_updated_at_info_2nd.present?
        business_industry_updated_at_2nd = BusinessIndustry.find_by(id: construction_license_updated_at_info_2nd)
        if business_industry_updated_at_2nd.nil? && (construction_license_updated_at_info_2nd == @order.content&.[]('genecon_construction_license_id_1st'))
          @order.content&.[]('genecon_construction_license_updated_at_1st')
        elsif business_industry_updated_at_2nd.nil? && (construction_license_updated_at_info_2nd == @order.content&.[]('genecon_construction_license_id_2nd'))
          @order.content&.[]('genecon_construction_license_updated_at_2nd')
        else
          BusinessIndustry.find_by(id: params.dig(:order, :content, :construction_license_number)&.slice(1))&.construction_license_updated_at
        end
      end
    end

    # 建設許可証番号1がbusiness_industryにない時も取得する
    def construction_license_number_1st
      construction_license_number_info_1st = params.dig(:order, :content, :construction_license_number)&.slice(0)
      if construction_license_number_info_1st.present?
        business_industry_construction_license_1st = BusinessIndustry.find_by(id: construction_license_number_info_1st)
        if business_industry_construction_license_1st.nil? && (construction_license_number_info_1st == @order.content&.[]('genecon_construction_license_id_1st'))
          @order.content&.[]('genecon_construction_license_number_1st')
        elsif business_industry_construction_license_1st.nil? && (construction_license_number_info_1st == @order.content&.[]('genecon_construction_license_id_2nd'))
          @order.content&.[]('genecon_construction_license_number_2nd')
        else
          BusinessIndustry.find_by(id: params.dig(:order, :content, :construction_license_number)&.slice(0))&.construction_license_number
        end
      end
    end

    # 建設許可証番号2がbusiness_industryにない時も取得する
    def construction_license_number_2nd
      construction_license_number_info_2nd = params.dig(:order, :content, :construction_license_number)&.slice(1)
      if construction_license_number_info_2nd.present?
        business_industry_construction_license_2nd = BusinessIndustry.find_by(id: construction_license_number_info_2nd)
        if business_industry_construction_license_2nd.nil? && (construction_license_number_info_2nd == @order.content&.[]('genecon_construction_license_id_1st'))
          @order.content&.[]('genecon_construction_license_number_1st')
        elsif business_industry_construction_license_2nd.nil? && (construction_license_number_info_2nd == @order.content&.[]('genecon_construction_license_id_2nd'))
          @order.content&.[]('genecon_construction_license_number_2nd')
        else
          BusinessIndustry.find_by(id: params.dig(:order, :content, :construction_license_number)&.slice(1))&.construction_license_number
        end
      end
    end

    def order_params
      params.require(:order).permit(
        :site_career_up_id,
        :site_name,
        :site_address,
        :order_name,
        :order_post_code,
        :order_address,
        :order_supervisor_name,
        :order_supervisor_company,
        :order_supervisor_apply,
        :construction_name,
        :construction_details,
        :start_date, :end_date,
        :contract_date,
        :site_agent_name,
        :site_agent_apply,
        :supervisor_name,
        :supervisor_apply,
        :professional_engineer_name_1st,
        :professional_engineer_details_1st,
        :professional_engineer_qualification_1st,
        :professional_engineer_name_2nd,
        :professional_engineer_details_2nd,
        :professional_engineer_qualification_2nd,
        :general_safety_responsible_person_name,
        :general_safety_agent_name,
        :supervising_engineer_name,
        :supervising_engineer_check,
        :supervising_engineer_qualification,
        :supervising_engineer_assistant_name,
        :supervising_engineer_assistant_qualification,
        :health_and_safety_manager_name,
        :submission_destination,
        construction_license: []
      ).merge(
        content: {
          genecon_name:                                                            current_business.name,                                             # 会社名
          genecon_branch_name:                                                     current_business.branch_name,                                      # 支店･営業所名
          genecon_address:                                                         current_business.address,                                          # 会社住所
          genecon_branch_address:                                                  current_business.branch_address,                                   # 支店･営業所住所
          genecon_career_up_id:                                                    current_business.career_up_id,                                     # 事業所ID(キャリアアップ)
          genecon_health_insurance_status:                                         current_business.business_health_insurance_status,                 # 健康保険加入状況
          genecon_health_insurance_association:                                    current_business.business_health_insurance_association,            # 健康保険会社
          genecon_health_insurance_office_number:                                  current_business.business_health_insurance_office_number,          # 健康保険番号
          genecon_welfare_pension_insurance_join_status:                           current_business.business_welfare_pension_insurance_join_status,   # 厚生年金加入状況
          genecon_welfare_pension_insurance_office_number:                         current_business.business_welfare_pension_insurance_office_number, # 厚生年金番号
          genecon_employment_insurance_join_status:                                current_business.business_employment_insurance_join_status,        # 雇用保険加入状況
          genecon_employment_insurance_number:                                     current_business.business_employment_insurance_number, # 雇用保険番号
          # 建設許可証関連
          genecon_construction_license_id_1st:                                     params.dig(:order, :content, :construction_license_number)&.slice(0),    # 建設許可証番号のid1
          genecon_occupation_1st:                                                  occupation_1st,                                                          # 業種1
          genecon_construction_license_permission_type_minister_governor_1st:      construction_license_permission_type_minister_governor_1st,              # 建設業許可種別(大臣,知事)1
          genecon_construction_license_permission_type_identification_general_1st: construction_license_permission_type_identification_general_1st,         # 建設業許可種別(特定,一般)1
          genecon_construction_license_number_double_digit_1st:                    construction_license_number_double_digit_1st,                            # 建設業許可番号(2桁)1
          genecon_construction_license_number_six_digits_1st:                      construction_license_number_six_digits_1st,                              # 建設業許可番号(6桁)1
          genecon_construction_license_updated_at_1st:                             construction_license_updated_at_1st,                                     # 建設許可証(更新日)1
          genecon_construction_license_number_1st:                                 construction_license_number_1st,                                         # 建設許可証番号1
          genecon_construction_license_id_2nd:                                     params.dig(:order, :content, :construction_license_number)&.slice(1),    # 建設許可証番号のid2
          genecon_occupation_2nd:                                                  occupation_2nd,                                                          # 業種2
          genecon_construction_license_permission_type_minister_governor_2nd:      construction_license_permission_type_minister_governor_2nd,              # 建設業許可種別(大臣,知事)2
          genecon_construction_license_permission_type_identification_general_2nd: construction_license_permission_type_identification_general_2nd,         # 建設業許可種別(特定,一般)2
          genecon_construction_license_number_double_digit_2nd:                    construction_license_number_double_digit_2nd,                            # 建設業許可番号(2桁)2
          genecon_construction_license_number_six_digits_2nd:                      construction_license_number_six_digits_2nd,                              # 建設業許可番号(6桁)2
          genecon_construction_license_updated_at_2nd:                             construction_license_updated_at_2nd,                                     # 建設許可証(更新日)2
          genecon_construction_license_number_2nd:                                 construction_license_number_2nd,                                         # 建設許可証番号2
          genecon_specific_skilled_foreigners_exist:                               current_business.specific_skilled_foreigners_exist_i18n,                 # 一号特定技能外国人の従事の状況(有無)
          genecon_foreign_construction_workers_exist:                              current_business.foreign_construction_workers_exist_i18n,                # 外国人建設就労者の従事の状況(有無)
          genecon_foreign_technical_intern_trainees_exist:                         current_business.foreign_technical_intern_trainees_exist_i18n            # 外国人技能実習生の従事の状況(有無)
        }
      )
    end
  end
end
# rubocop:enable all
