# rubocop:disable all
module Users
  class DocumentsController < Users::Base
    layout 'documents'
    before_action :set_documents # サイドバーに常時表示させるために必要
    before_action :set_document, except: :index # オブジェクトが1つも無い場合、indexで呼び出さないようにする
    before_action :set_workers, only: %i[show edit update] # 2次下請以下の作業員を定義する
    before_action :edit_restriction_after_approved, only: %i[edit update]

    def index; end

    def show
      respond_to do |format|
        format.html
        format.pdf do
          case @document.document_type
          when 'cover_document', 'table_of_contents_document',
                'doc_3rd', 'doc_6th', 'doc_7th', 'doc_9th', 'doc_10th', 'doc_11th', 'doc_12th', 'doc_15th', 'doc_16th',
                'doc_17th', 'doc_19th', 'doc_21st', 'doc_23rd', 'doc_24th'
            render pdf: '書類', layout: 'pdf', encording: 'UTF-8', page_size: 'A4'
          when 'doc_4th'
            render pdf: '書類', layout: 'pdf', encording: 'UTF-8', page_size: 'A3', margin: { bottom: 2 }, orientation: 'Landscape'
          when 'doc_5th', 'doc_13th', 'doc_14th', 'doc_18th', 'doc_22nd'
            render pdf: '書類', layout: 'pdf', encording: 'UTF-8', page_size: 'A3', orientation: 'Landscape'
          when 'doc_8th'
            render pdf: '書類', layout: 'pdf', encording: 'UTF-8', page_size: 'A3', margin: { top: 0 }, orientation: 'Landscape'
          when 'doc_20th'
            render pdf: '書類', layout: 'pdf', encording: 'UTF-8', page_size: 'A3', margin: { bottom: 2 }
          end
        end
      end
    end

    def edit
      @error_msg_for_doc_19th = nil
      @error_msg_for_doc_20th = nil
    end

    def update
      case @document.document_type
      when 'doc_3rd', 'doc_5th', 'doc_6th', 'doc_7th', 'doc_16th', 'doc_17th'
        if @document.update(document_params(@document))
          redirect_to users_request_order_document_url, success: '保存に成功しました'
        else
          flash[:danger] = '更新に失敗しました'
          render :edit
        end
      when 'doc_10th', 'doc_11th' #現場作業員データも更新
        j = 1
        case @document.document_type
        when 'doc_10th'
          focus_workers = document_info.field_workers.where(id: age_border(65))
        when 'doc_11th'
          focus_workers = document_info.field_workers.where(id: age_border(18))
        end
        update_workers = []
        focus_workers.each do |focus_worker|
          focus_worker.content = focus_worker.content
          focus_worker.content["occupation"] = params[:document][:content]["occupation_#{j.ordinalize}".to_sym]
          focus_worker.content["work_notice"] = params[:document][:content]["work_notice_#{j.ordinalize}".to_sym]
          update_workers.push(focus_worker)
          j += 1
        end
        FieldWorker.import update_workers, on_duplicate_key_update: [:content]

        if @document.update(document_params(@document))
          redirect_to users_request_order_document_url, success: '保存に成功しました'
        else
          flash[:danger] = '保存に失敗しました'
          render action: :edit
          flash[:danger] = '更新に失敗しました'
          render :edit
        end
      when 'doc_14th'
        @error_msg_for_doc_14th = @document.error_msg_for_doc_14th(document_params(@document))
        if @error_msg_for_doc_14th.blank?
          if @document.update(document_params(@document))
            redirect_to users_request_order_document_url, success: "保存に成功しました"
          else
            flash[:danger] = '保存に失敗しました'
            render action: :edit
          end
        else
          flash[:danger] = @error_msg_for_doc_14th.first
          render action: :edit
        end
      when 'doc_19th'
        @error_msg_for_doc_19th = @document.error_msg_for_doc_19th(document_params(@document))
        if @error_msg_for_doc_19th.blank?
          if @document.update(document_params(@document))
            redirect_to users_request_order_document_url, success: '保存に成功しました'
          else
            flash[:danger] = '保存に失敗しました'
            render action: :edit
          end
        else
          flash[:danger] = '保存に失敗しました'
          render action: :edit
        end
      when 'doc_20th'
        # date_selectのデータ取得形式に合わせるため年月を結合
        params[:document][:content][:term] = term_join
        params[:document][:content][:planning_period_beginning] = planning_period_beginning_join
        params[:document][:content][:planning_period_final_stage] = planning_period_final_stage_join
        # 現場人数取得のバリデーションのため
        @error_msg_for_doc_20th = @document.error_msg_for_doc_20th(document_params(@document), params[:request_order_uuid], params[:sub_request_order_uuid])
        if @error_msg_for_doc_20th.blank?
          if @document.update(document_params(@document))
            redirect_to users_request_order_document_url, success: '保存に成功しました'
          else
            flash[:danger] = '保存に失敗しました'
            render action: :edit
          end
        else
          flash[:danger] = '保存に失敗しました'
          render action: :edit
        end
      when 'doc_22nd'
        # time_selectのデータ取得形式に合わせるため時分を結合
        params[:document][:content][:delegation_time_from] = delegation_time_from_join
        params[:document][:content][:delegation_time_to] = delegation_time_to_join
        params[:document][:content][:patrol_record_time_1st] = patrol_record_time_1st_join
        params[:document][:content][:patrol_record_time_2nd] = patrol_record_time_2nd_join
        params[:document][:content][:patrol_record_time_3rd] = patrol_record_time_3rd_join
        params[:document][:content][:patrol_record_time_4th] = patrol_record_time_4th_join
        params[:document][:content][:patrol_record_time_5th] = patrol_record_time_5th_join
        params[:document][:content][:patrol_record_time_6th] = patrol_record_time_6th_join
        params[:document][:content][:patrol_record_time_7th] = patrol_record_time_7th_join
        @error_msg_for_doc_22nd = @document.error_msg_for_doc_22nd(document_params(@document), params[:request_order_uuid])
        if @error_msg_for_doc_22nd.blank?
          if @document.update(document_params(@document))
            redirect_to users_request_order_document_url, success: '保存に成功しました'
          else
            flash[:danger] = '保存に失敗しました'
            render action: :edit
          end
        else
          flash[:danger] = '保存に失敗しました'
          render action: :edit
        end
      end
    end

    #安全衛生役員の役職取得のため(doc_20th)
    def set_safety_officer_name
      if params[:safety_officer_name].present?
        @safety_officer_post = Worker.find_by(name: params[:safety_officer_name]).job_title
      else
        @safety_officer_post = ''
      end
      respond_to do |format|
        format.js do
          render 'users/documents/doc_20th/set_safety_officer_name'
        end
      end
    end

    #総括安全衛生管理者の役職取得のため(doc_20th)
    def set_general_manager_name
      if params[:general_manager_name].present?
        @general_manager_post = Worker.find_by(name: params[:general_manager_name]).job_title
      else
        @general_manager_post = ''
      end
      respond_to do |format|
        format.js do
          render 'users/documents/doc_20th/set_general_manager_name'
        end
      end
    end

    #安全管理者の役職取得のため(doc_20th)
    def set_safety_manager_name
      if params[:safety_manager_name].present?
        @safety_manager_post = Worker.find_by(name: params[:safety_manager_name]).job_title
      else
        @safety_manager_post = ''
      end
      respond_to do |format|
        format.js do
          render 'users/documents/doc_20th/set_safety_manager_name'
        end
      end
    end

    #衛生管理者の役職取得のため(doc_20th)
    def set_hygiene_manager_name
      if params[:hygiene_manager_name].present?
        @hygiene_manager_post = Worker.find_by(name: params[:hygiene_manager_name]).job_title
      else
        @hygiene_manager_post = ''
      end
      respond_to do |format|
        format.js do
          render 'users/documents/doc_20th/set_hygiene_manager_name'
        end
      end
    end

    #安全衛生推進者の役職取得のため(doc_20th)
    def set_health_and_safety_promoter_name
      if params[:health_and_safety_promoter_name].present?
        @health_and_safety_promoter_post = Worker.find_by(name: params[:health_and_safety_promoter_name]).job_title
      else
        @health_and_safety_promoter_post = ''
      end
      respond_to do |format|
        format.js do
          render 'users/documents/doc_20th/set_health_and_safety_promoter_name'
        end
      end
    end

    private

    def set_documents
      @documents = current_business.request_orders.find_by(uuid: params[:request_order_uuid]).documents.order(id: :asc)
    end

    def set_document
      @document = current_business.request_orders.find_by(uuid: params[:request_order_uuid]).documents.find_by(uuid: params[:uuid])
    end

    #年度パラメータを再セット(doc_20th)
    def term_join
      if params[:document][:content][:term]['(1i)'].present?
        Date.new(
          params[:document][:content][:term]['(1i)'].to_i,
          params[:document][:content][:term]['(2i)'].to_i,
          params[:document][:content][:term]['(3i)'].to_i
        )
      end
    end

    #始期パラメータを再セット(doc_20th)
    def planning_period_beginning_join
      if params[:document][:content][:planning_period_beginning]['(1i)'].present? && params[:document][:content][:planning_period_beginning]['(2i)'].present?
        Date.new(
          params[:document][:content][:planning_period_beginning]['(1i)'].to_i,
          params[:document][:content][:planning_period_beginning]['(2i)'].to_i,
          params[:document][:content][:planning_period_beginning]['(3i)'].to_i
        )
      end
    end

    #終期パラメータを再セット(doc_20th)
    def planning_period_final_stage_join
      if params[:document][:content][:planning_period_final_stage]['(1i)'].present? && params[:document][:content][:planning_period_final_stage]['(2i)'].present?
        Date.new(
          params[:document][:content][:planning_period_final_stage]['(1i)'].to_i,
          params[:document][:content][:planning_period_final_stage]['(2i)'].to_i,
          params[:document][:content][:planning_period_final_stage]['(3i)'].to_i
        )
      end
    end

    #委任期間(自)時間パラメータを再セット(doc_22nd)
    def delegation_time_from_join
      if params[:document][:content][:delegation_time_from]['(4i)'].present? && params[:document][:content][:delegation_time_from]['(5i)'].present?
        DateTime.new(
          params[:document][:content][:delegation_time_from]['(1i)'].to_i,
          params[:document][:content][:delegation_time_from]['(2i)'].to_i,
          params[:document][:content][:delegation_time_from]['(3i)'].to_i,
          params[:document][:content][:delegation_time_from]['(4i)'].to_i,
          params[:document][:content][:delegation_time_from]['(5i)'].to_i
        )
      end
    end

     #委任期間(至)時間パラメータを再セット(doc_22nd)
    def delegation_time_to_join
      if params[:document][:content][:delegation_time_to]['(4i)'].present? && params[:document][:content][:delegation_time_to]['(5i)'].present?
        DateTime.new(
          params[:document][:content][:delegation_time_to]['(1i)'].to_i,
          params[:document][:content][:delegation_time_to]['(2i)'].to_i,
          params[:document][:content][:delegation_time_to]['(3i)'].to_i,
          params[:document][:content][:delegation_time_to]['(4i)'].to_i,
          params[:document][:content][:delegation_time_to]['(5i)'].to_i
        )
      end
    end

    #統責者・巡視記録時刻1パラメータを再セット(doc_22nd)
    def patrol_record_time_1st_join
      if params[:document][:content][:patrol_record_time_1st]['(4i)'].present? && params[:document][:content][:patrol_record_time_1st]['(5i)'].present?
        DateTime.new(
          params[:document][:content][:patrol_record_time_1st]['(1i)'].to_i,
          params[:document][:content][:patrol_record_time_1st]['(2i)'].to_i,
          params[:document][:content][:patrol_record_time_1st]['(3i)'].to_i,
          params[:document][:content][:patrol_record_time_1st]['(4i)'].to_i,
          params[:document][:content][:patrol_record_time_1st]['(5i)'].to_i
        )
      end
    end

    #統責者・巡視記録時刻2パラメータを再セット(doc_22nd)
    def patrol_record_time_2nd_join
      if params[:document][:content][:patrol_record_time_2nd]['(4i)'].present? && params[:document][:content][:patrol_record_time_2nd]['(5i)'].present?
        DateTime.new(
          params[:document][:content][:patrol_record_time_2nd]['(1i)'].to_i,
          params[:document][:content][:patrol_record_time_2nd]['(2i)'].to_i,
          params[:document][:content][:patrol_record_time_2nd]['(3i)'].to_i,
          params[:document][:content][:patrol_record_time_2nd]['(4i)'].to_i,
          params[:document][:content][:patrol_record_time_2nd]['(5i)'].to_i
        )
      end
    end

    #統責者・巡視記録時刻3パラメータを再セット(doc_22nd)
    def patrol_record_time_3rd_join
      if params[:document][:content][:patrol_record_time_3rd]['(4i)'].present? && params[:document][:content][:patrol_record_time_3rd]['(5i)'].present?
        DateTime.new(
          params[:document][:content][:patrol_record_time_3rd]['(1i)'].to_i,
          params[:document][:content][:patrol_record_time_3rd]['(2i)'].to_i,
          params[:document][:content][:patrol_record_time_3rd]['(3i)'].to_i,
          params[:document][:content][:patrol_record_time_3rd]['(4i)'].to_i,
          params[:document][:content][:patrol_record_time_3rd]['(5i)'].to_i
        )
      end
    end

    #統責者・巡視記録時刻4パラメータを再セット(doc_22nd)
    def patrol_record_time_4th_join
      if params[:document][:content][:patrol_record_time_4th]['(4i)'].present? && params[:document][:content][:patrol_record_time_4th]['(5i)'].present?
        DateTime.new(
          params[:document][:content][:patrol_record_time_4th]['(1i)'].to_i,
          params[:document][:content][:patrol_record_time_4th]['(2i)'].to_i,
          params[:document][:content][:patrol_record_time_4th]['(3i)'].to_i,
          params[:document][:content][:patrol_record_time_4th]['(4i)'].to_i,
          params[:document][:content][:patrol_record_time_4th]['(5i)'].to_i
        )
      end
    end

    #統責者・巡視記録時刻5パラメータを再セット(doc_22nd)
    def patrol_record_time_5th_join
      if params[:document][:content][:patrol_record_time_5th]['(4i)'].present? && params[:document][:content][:patrol_record_time_5th]['(5i)'].present?
        DateTime.new(
          params[:document][:content][:patrol_record_time_5th]['(1i)'].to_i,
          params[:document][:content][:patrol_record_time_5th]['(2i)'].to_i,
          params[:document][:content][:patrol_record_time_5th]['(3i)'].to_i,
          params[:document][:content][:patrol_record_time_5th]['(4i)'].to_i,
          params[:document][:content][:patrol_record_time_5th]['(5i)'].to_i
        )
      end
    end

    #統責者・巡視記録時刻６パラメータ6を再セット(doc_22nd)
    def patrol_record_time_6th_join
      if params[:document][:content][:patrol_record_time_6th]['(4i)'].present? && params[:document][:content][:patrol_record_time_6th]['(5i)'].present?
        DateTime.new(
          params[:document][:content][:patrol_record_time_6th]['(1i)'].to_i,
          params[:document][:content][:patrol_record_time_6th]['(2i)'].to_i,
          params[:document][:content][:patrol_record_time_6th]['(3i)'].to_i,
          params[:document][:content][:patrol_record_time_6th]['(4i)'].to_i,
          params[:document][:content][:patrol_record_time_6th]['(5i)'].to_i
        )
      end
    end

    #統責者・巡視記録時刻７パラメータを再セット(doc_22nd)
    def patrol_record_time_7th_join
      if params[:document][:content][:patrol_record_time_7th]['(4i)'].present? && params[:document][:content][:patrol_record_time_7th]['(5i)'].present?
        DateTime.new(
          params[:document][:content][:patrol_record_time_7th]['(1i)'].to_i,
          params[:document][:content][:patrol_record_time_7th]['(2i)'].to_i,
          params[:document][:content][:patrol_record_time_7th]['(3i)'].to_i,
          params[:document][:content][:patrol_record_time_7th]['(4i)'].to_i,
          params[:document][:content][:patrol_record_time_7th]['(5i)'].to_i
        )
      end
    end

    def set_workers
      case current_business.request_orders.find_by(uuid: params[:request_order_uuid]).documents.find_by(uuid: params[:uuid]).document_type
      when 'doc_19th'
        request_order = RequestOrder.find_by(uuid: params[:request_order_uuid])
        workers = []
        # 元請が資料を確認、作成するとき
        if request_order.parent_id.nil?
          request_order.children.each do |first_request_order|
            @second_workers = first_request_order.children.map { |second_request_order|
              Business.find_by(id: second_request_order.business_id).workers
            }.flatten!
            workers.push(@second_workers).flatten!
            first_request_order.children.each do |second_request_order|
              @third_workers = second_request_order.children.map { |third_request_order|
                Business.find_by(id: third_request_order.business_id).workers
              }.flatten!
              workers.push(@third_workers).flatten!
              second_request_order.children.each do |third_request_order|
                @forth_workers = third_request_order.children.map { |forth_request_order|
                  Business.find_by(id: forth_request_order.business_id).workers
                }.flatten!
                workers.push(@forth_workers).flatten!
              end
            end
          end
        # 1次下請けが資料を確認、作成するとき
        else
          request_order.children.each do |second_request_order|
            @second_workers = request_order.children.map { |second_request_order_sub|
              Business.find_by(id: second_request_order_sub.business_id).workers
            }.flatten!
            workers.push(@second_workers).flatten!
            second_request_order.children.each do |third_request_order|
              @third_workers = second_request_order.children.map { |third_request_order_sub|
                Business.find_by(id: third_request_order_sub.business_id).workers
              }.flatten!
              @forth_workers = third_request_order.children.map { |forth_request_order_sub|
                Business.find_by(id: forth_request_order_sub.business_id).workers
              }.flatten!
              workers.push(@third_workers).flatten!
              workers.push(@forth_workers).flatten!
            end
          end
        end
        merge_workers = workers&.map { |sub_worker| { sub_worker&.name => sub_worker&.uuid } }
        @workers_name_uuid = {}.merge(*merge_workers)
      end
    end

    def edit_restriction_after_approved
      request_order = RequestOrder.find_by(uuid: params[:request_order_uuid])
      if request_order.status == 'approved'
        flash[:danger] = '承認されているため編集できません'
        redirect_to users_request_order_document_url
      end
    end

    def document_params(document)
      case document.document_type
      when 'doc_3rd', 'doc_6th', 'doc_7th', 'doc_10th', 'doc_11th', 'doc_16th', 'doc_17th'
        params.require(:document).permit(content:
          [
            :date_submitted
          ]
        )
      when 'doc_14th'
        params.require(:document).permit(content:
        %i[
            date_submitted
            reception_number1
            reception_number2
            reception_number3
            reception_number4
            reception_number5
            reception_number6
            reception_number7
            reception_number8
            reception_number9
            reception_number10
            precautions
            prime_contractor_confirmation
            reception_confirmation_date
            inspection_date
          ]
        )
      when 'doc_19th'
        params.require(:document).permit(content:
          %i[
            prime_contractor_confirmation
            company_name
            date_created
            safety_and_health_construction_policy
            safety_and_health_construction_objective
            construction_type_1st_period_month_1st
            construction_type_1st_period_month_2st
            construction_type_1st_period_month_3rd
            carry_on_machine
            construction_type_period_month_1st
            construction_type_period_week_one_1st
            construction_type_period_week_two_1st
            construction_type_period_week_three_1st
            construction_type_period_week_four_1st
            construction_type_period_week_five_1st
            construction_type_period_month_2nd
            construction_type_period_week_one_2nd
            construction_type_period_week_two_2nd
            construction_type_period_week_three_2nd
            construction_type_period_week_four_2nd
            construction_type_period_week_five_2nd
            construction_type_period_month_3rd
            construction_type_period_week_one_3rd
            construction_type_period_week_two_3rd
            construction_type_period_week_three_3rd
            construction_type_period_week_four_3rd
            construction_type_period_week_five_3rd
            construction_type_1st
            construction_type_1st_period_1st
            construction_type_1st_period_2nd
            construction_type_1st_period_3rd
            daily_safety_and_health_activity
            construction_type_2nd
            construction_type_2nd_period_1st
            construction_type_2nd_period_2nd
            construction_type_2nd_period_3rd
            construction_type_3rd
            construction_type_3rd_period_1st
            construction_type_3rd_period_2nd
            construction_type_3rd_period_3rd
            construction_type_4th
            construction_type_4th_period_1st
            construction_type_4th_period_2nd
            construction_type_4th_period_3rd
            construction_type_5th
            construction_type_5th_period_1st
            construction_type_5th_period_2nd
            construction_type_5th_period_3rd
            main_machine_equipment
            main_tool
            main_material
            protective_equipment
            qualified_staff
            work_classification_1st
            predicted_disaster_1st
            risk_reduction_measures_1st
            predicted_disaster_2nd
            risk_reduction_measures_2nd
            work_classification_2nd
            predicted_disaster_3rd
            risk_reduction_measures_3rd
            work_classification_3rd
            risk_reduction_measures_4th
            predicted_disaster_4th
            risk_reduction_measures_5th
            predicted_disaster_5th
            predicted_disaster_6th
            risk_reduction_measures_6th
            predicted_disaster_7th
            risk_reduction_measures_7th
            predicted_disaster_8th
            risk_reduction_measures_8th
            construction_manager
            subcontractor_construction_workers_position_1st
            subcontractor_construction_workers_name_1st
            subcontractor_company_name_1st
            subcontractor_construction_workers_position_2nd
            subcontractor_construction_workers_name_2nd
            subcontractor_company_name_2nd
            subcontractor_construction_workers_position_3rd
            subcontractor_construction_workers_name_3rd
            subcontractor_company_name_3rd
            subcontractor_construction_workers_position_4th
            subcontractor_construction_workers_name_4th
            subcontractor_company_name_4th
            safety_and_health_manager
            subcontractor_construction_workers_position_5th
            subcontractor_construction_workers_name_5th
            subcontractor_company_name_5th
            subcontractor_construction_workers_position_6th
            subcontractor_construction_workers_name_6th
            subcontractor_company_name_6th
            subcontracting_notice
            subcontractor_organization_chart
            worker_list
            use_notification
            use_notification_for_mobile_crane
            use_notification_for_vehicle_construction_machine
            use_notification_for_use_notification_for_electric_tool
            use_notification_for_electric_welder
            use_notification_for_construction_vehicle
            use_notification_for_organic_solvent_and_specific_chemical_substance
            use_notification_for_fire
            use_notification_for_others_1st
            use_notification_name_for_others_1st
            sending_education_report
            new_entry_education_report
            use_notification_for_others_2nd
            use_notification_name_for_others_2nd
            use_notification_for_others_3rd
            use_notification_name_for_others_3rd
            work_plan_1st
            work_plan_name_1st
            work_plan_2nd
            work_plan_name_2nd
            work_plan_3rd
            work_plan_name_3rd
            work_plan_4th
            work_plan_name_4th
            safety_and_health_plan
            use_notification_for_others_4th
            use_notification_name_for_others_4th
            use_notification_for_others_5th
            use_notification_name_for_others_5th
            use_notification_for_others_6th
            use_notification_name_for_others_6th
            risk_possibility_1st
            risk_possibility_2nd
            risk_possibility_3rd
            risk_possibility_4th
            risk_possibility_5th
            risk_possibility_6th
            risk_possibility_7th
            risk_possibility_8th
            risk_seriousness_1st
            risk_seriousness_2nd
            risk_seriousness_3rd
            risk_seriousness_4th
            risk_seriousness_5th
            risk_seriousness_6th
            risk_seriousness_7th
            risk_seriousness_8th
          ]
                                        )
      when 'doc_20th'
        params.require(:document).permit(content:
          %i[
            date_created
            term
            planning_period_beginning
            planning_period_final_stage
            health_and_safety_policy
            health_and_safety_goals
            health_and_safety_issues
            plan_priority_measures_1st
            plan_items_to_be_implemented_1st
            plan_management_goals_1st
            plan_responsible_for_implementation_1st
            schedules_april_june_1st
            schedules_july_september_1st
            schedules_october_december_1st
            schedules_january_march_1st
            schedules_points_to_note_1st
            schedules_remarks_1st
            plan_priority_measures_2nd
            plan_items_to_be_implemented_2nd
            plan_management_goals_2nd
            plan_responsible_for_implementation_2nd
            schedules_april_june_2nd
            schedules_july_september_2nd
            schedules_october_december_2nd
            schedules_january_march_2nd
            schedules_points_to_note_2nd
            schedules_remarks_2nd
            plan_priority_measures_3rd
            plan_items_to_be_implemented_3rd
            plan_management_goals_3rd
            plan_responsible_for_implementation_3rd
            schedules_april_june_3rd
            schedules_july_september_3rd
            schedules_october_december_3rd
            schedules_january_march_3rd
            schedules_points_to_note_3rd
            schedules_remarks_3rd
            plan_priority_measures_4th
            plan_items_to_be_implemented_4th
            plan_management_goals_4th
            plan_responsible_for_implementation_4th
            schedules_april_june_4th
            schedules_july_september_4th
            schedules_october_december_4th
            schedules_january_march_4th
            schedules_points_to_note_4th
            schedules_remarks_4th
            common_to_work_sitespriority_measures_1st
            common_items_to_be_implemented_1st_1st
            common_items_to_be_implemented_1st_2nd
            common_items_to_be_implemented_1st_3rd
            common_to_work_sitespriority_measures_2nd
            common_items_to_be_implemented_2nd_1st
            common_items_to_be_implemented_2nd_2nd
            common_items_to_be_implemented_2nd_3rd
            common_to_work_sitespriority_measures_3rd
            common_items_to_be_implemented_3rd_1st
            common_items_to_be_implemented_3rd_2nd
            common_items_to_be_implemented_3rd_3rd
            common_to_work_sitespriority_measures_4th
            common_items_to_be_implemented_4th_1st
            common_items_to_be_implemented_4th_2nd
            common_items_to_be_implemented_4th_3rd
            events_april
            events_may
            events_jun
            events_july
            events_august
            events_september
            events_october
            events_november
            events_december
            events_january
            events_february
            events_march
            safety_officer_post
            safety_officer_name
            employment_manager_post
            general_manager_post
            general_manager_name
            safety_manager_post
            safety_manager_name
            hygiene_manager_post
            hygiene_manager_name
            health_and_safety_promoter_post
            health_and_safety_promoter_name
            construction_manager_post
            remarks
          ]
                                        )
      when 'doc_22nd'
        params.require(:document).permit(content:
          %i[
            recorder
            safety_duty_person
            meeting_date
            actual_work_date
            occupation_1st
            required_qualification_1st
            work_content_1st
            risk_prediction_1st
            foreman_confirmation_1st
            implementation_confirmation_1st
            implementation_confirmation_person_1st
            corrective_action_1st
            corrective_action_confirmation_date_1st
            corrective_action_reviewer_1st
            occupation_2nd
            required_qualification_2nd
            work_content_2nd
            risk_prediction_2nd
            foreman_confirmation_2nd
            implementation_confirmation_2nd
            implementation_confirmation_person_2nd
            corrective_action_2nd
            corrective_action_confirmation_date_2nd
            corrective_action_reviewer_2nd
            occupation_3rd
            required_qualification_3rd
            work_content_3rd
            risk_prediction_3rd
            foreman_confirmation_3rd
            implementation_confirmation_3rd
            implementation_confirmation_person_3rd
            corrective_action_3rd
            corrective_action_confirmation_date_3rd
            corrective_action_reviewer_3rd
            occupation_4th
            required_qualification_4th
            work_content_4th
            risk_prediction_4th
            foreman_confirmation_4th
            implementation_confirmation_4th
            implementation_confirmation_person_4th
            corrective_action_4th
            corrective_action_confirmation_date_4th
            corrective_action_reviewer_4th
            occupation_5th
            required_qualification_5th
            work_content_5th
            risk_prediction_5th
            foreman_confirmation_5th
            implementation_confirmation_5th
            implementation_confirmation_person_5th
            corrective_action_5th
            corrective_action_confirmation_date_5th
            corrective_action_reviewer_5th
            occupation_6th
            required_qualification_6th
            work_content_6th
            risk_prediction_6th
            foreman_confirmation_6th
            implementation_confirmation_6th
            implementation_confirmation_person_6th
            corrective_action_6th
            corrective_action_confirmation_date_6th
            corrective_action_reviewer_6th
            occupation_7th
            required_qualification_7th
            work_content_7th
            risk_prediction_7th
            foreman_confirmation_7th
            implementation_confirmation_7th
            implementation_confirmation_person_7th
            corrective_action_7th
            corrective_action_confirmation_date_7th
            corrective_action_reviewer_7th
            occupation_8th
            required_qualification_8th
            work_content_8th
            risk_prediction_8th
            foreman_confirmation_8th
            implementation_confirmation_8th
            implementation_confirmation_person_8th
            corrective_action_8th
            corrective_action_confirmation_date_8th
            corrective_action_reviewer_8th
            occupation_9th
            required_qualification_9th
            work_content_9th
            risk_prediction_9th
            foreman_confirmation_9th
            implementation_confirmation_9th
            implementation_confirmation_person_9th
            corrective_action_9th
            corrective_action_confirmation_date_9th
            corrective_action_reviewer_9th
            occupation_10th
            required_qualification_10th
            work_content_10th
            risk_prediction_10th
            foreman_confirmation_10th
            implementation_confirmation_10th
            implementation_confirmation_person_10th
            corrective_action_10th
            corrective_action_confirmation_date_10th
            corrective_action_reviewer_10th
            occupation_11th
            required_qualification_11th
            work_content_11th
            risk_prediction_11th
            foreman_confirmation_11th
            implementation_confirmation_11th
            implementation_confirmation_person_11th
            corrective_action_11th
            corrective_action_confirmation_date_11th
            corrective_action_reviewer_11th
            occupation_12th
            required_qualification_12th
            work_content_12th
            risk_prediction_12th
            foreman_confirmation_12th
            implementation_confirmation_12th
            implementation_confirmation_person_12th
            corrective_action_12th
            corrective_action_confirmation_date_12th
            corrective_action_reviewer_12th
            occupation_13th
            required_qualification_13th
            work_content_13th
            risk_prediction_13th
            foreman_confirmation_13th
            implementation_confirmation_13th
            implementation_confirmation_person_13th
            corrective_action_13th
            corrective_action_confirmation_date_13th
            corrective_action_reviewer_13th
            occupation_14th
            required_qualification_14th
            work_content_14th
            risk_prediction_14th
            foreman_confirmation_14th
            implementation_confirmation_14th
            implementation_confirmation_person_14th
            corrective_action_14th
            corrective_action_confirmation_date_14th
            corrective_action_reviewer_14th
            occupation_15th
            required_qualification_15th
            work_content_15th
            risk_prediction_15th
            foreman_confirmation_15th
            implementation_confirmation_15th
            implementation_confirmation_person_15th
            corrective_action_15th
            corrective_action_confirmation_date_15th
            corrective_action_reviewer_15th
            occupation_16th
            required_qualification_16th
            work_content_16th
            risk_prediction_16th
            foreman_confirmation_16th
            implementation_confirmation_16th
            implementation_confirmation_person_16th
            corrective_action_16th
            corrective_action_confirmation_date_16th
            corrective_action_reviewer_16th
            occupation_17th
            required_qualification_17th
            work_content_17th
            risk_prediction_17th
            foreman_confirmation_17th
            implementation_confirmation_17th
            implementation_confirmation_person_17th
            corrective_action_17th
            corrective_action_confirmation_date_17th
            corrective_action_reviewer_17th
            notifications_and_instructions_1st
            events_and_patrols_1st
            patrol_record_time_1st
            patrol_record_content_1st
            corrective_action_report_1st
            corrective_action_report_confirmer_1st
            notifications_and_instructions_2nd
            events_and_patrols_2nd
            patrol_record_time_2nd
            patrol_record_content_2nd
            corrective_action_report_2nd
            corrective_action_report_confirmer_2nd
            notifications_and_instructions_3rd
            events_and_patrols_3rd
            patrol_record_time_3rd
            patrol_record_content_3rd
            corrective_action_report_3rd
            corrective_action_report_confirmer_3rd
            notifications_and_instructions_4th
            events_and_patrols_4th
            patrol_record_time_4th
            patrol_record_content_4th
            corrective_action_report_4th
            corrective_action_report_confirmer_4th
            notifications_and_instructions_5th
            events_and_patrols_5th
            patrol_record_time_5th
            patrol_record_content_5th
            corrective_action_report_5th
            corrective_action_report_confirmer_5th
            notifications_and_instructions_6th
            events_and_patrols_6th
            patrol_record_time_6th
            patrol_record_content_6th
            corrective_action_report_6th
            corrective_action_report_confirmer_6th
            notifications_and_instructions_7th
            events_and_patrols_7th
            patrol_record_time_7th
            patrol_record_content_7th
            corrective_action_report_7th
            corrective_action_report_confirmer_7th
            delegation_date_from
            delegation_time_from
            delegation_date_to
            delegation_time_to
            officer_signature_date
            officer_substitute_signature_date
          ]
                                        )
      end
    end
  end
  # rubocop:enable all
end
