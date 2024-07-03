# rubocop:disable all
module Users::SubRequestOrders
  class DocumentsController < Users::Base
    before_action :set_documents, only: %i[index show edit update]
    before_action :set_document, only: %i[show edit update]

    layout 'documents'

    def index
      render 'users/documents/index'
    end

    def show
      respond_to do |format|
        format.html do
          case @document.document_type
          when 'doc_4th'
            request_order = RequestOrder.find_by(uuid: params[:request_order_uuid]).root
            @prime_contractor_business = Business.find(request_order.business_id)
            @business = Business.find(@document.business_id)
          end
        end
        format.pdf do
          case @document.document_type
          # when 'cover_document', 'table_of_contents_document',
          #       'doc_3rd', 'doc_6th', 'doc_7th', 'doc_9th', 'doc_10th', 'doc_11th', 'doc_12th', 'doc_15th',
          #       'doc_16th', 'doc_17th', 'doc_19th', 'doc_20th', 'doc_21st', 'doc_22nd', 'doc_23rd', 'doc_24th'
          #   return render template: 'users/documents/show', pdf: '書類', layout: 'pdf', encording: 'UTF-8', page_size: 'A4'
          # when 'doc_4th'
          #   return render template: 'users/documents/show', pdf: '書類', layout: 'pdf', encording: 'UTF-8', page_size: 'A3', margin: { bottom: 2 }, orientation: 'Landscape'
          # when 'doc_5th', 'doc_13th', 'doc_14th', 'doc_18th'
          #   return render template: 'users/documents/show', pdf: '書類', layout: 'pdf', encording: 'UTF-8', page_size: 'A3', orientation: 'Landscape'
          # when 'doc_8th'
          #   return render template: 'users/documents/show', pdf: '書類', layout: 'pdf', encording: 'UTF-8', page_size: 'A3', margin: { top: 5 }, orientation: 'Landscape'
          # end
          when 'doc_8th'
            @document_site_info = document_site_info
            @document_info = document_info
            pdf = Doc8thPdf.new(@document_site_info, @document_info)

            # PDFをレンダリングし、ブラウザに表示またはダウンロードさせる
            send_data pdf.render, filename: "doc_8th.pdf", type: "application/pdf", disposition: "inline"
            return
          else
            render_params = { pdf: '書類', layout: 'pdf', encoding: 'UTF-8', page_size: 'A4' }
            render_params[:page_size] = 'A3'
            render_params[:margin] = { bottom: 2 } if @document.document_type == 'doc_4th'
            render_params[:orientation] = 'Landscape' if ['doc_4th', 'doc_5th', 'doc_13th', 'doc_14th', 'doc_18th', 'doc_8th'].include?(@document.document_type)
            render_params[:margin] = { top: 5 } if @document.document_type == 'doc_8th'
            
            render template: 'users/documents/show', **render_params
            return
          end
        end
      end
      render 'users/documents/show'
    end

    def edit
      render 'users/documents/edit'
    end

    def update
      if @document.request_order.order.business_id == current_business.id # 元請けのみが編集できる
        case @document.document_type
        when 'doc_13th', 'doc_15th', 'doc_16th'
          if @document.update(document_params(@document))
            redirect_to users_request_order_sub_request_order_document_url, success: '保存に成功しました'
          else
            flash[:danger] = '更新に失敗しました'
            render :edit
          end
        when 'doc_14th'
          error_msg_for_approval_doc_14th = @document.error_msg_for_approval_doc_14th(document_params(@document)).join("<br>").html_safe

          if error_msg_for_approval_doc_14th.present?
            flash[:danger] = error_msg_for_approval_doc_14th
            render template: 'users/documents/doc_14th/_subcon_edit'
          else
            if @document.update(document_params(@document))
              flash[:success] = '保存に成功しました'
              redirect_to users_request_order_sub_request_order_document_url
            else
              flash[:danger] = '保存に失敗しました'
              render template: 'users/documents/doc_14th/_subcon_edit'
            end
          end
        end
      else
        redirect_to root_url
      end
    end

    private

    def validate_request_order!
      request_order = current_business.request_orders.find_by!(uuid: params[:request_order_uuid])
      sub_request_order = RequestOrder.find_by!(uuid: params[:sub_request_order_uuid])
      unless sub_request_order.child_of?(request_order) || sub_request_order.descendant_of?(request_order)
        raise 'だめ'
      end

      sub_request_order
    end

    def document_params(document)
      case document.document_type
      when 'doc_13th'
        field_special_vehicle_ids = @document.request_order.field_special_vehicles.ids
        field_special_vehicle_keys = field_special_vehicle_ids.map { |field_special_vehicle_id| "field_special_vehicle_#{field_special_vehicle_id}" }

        params.require(:document).permit(approval_content:
          [
            date_submitted:                field_special_vehicle_keys, # 13-001 提出日(西暦)
            prime_contractor_confirmation: field_special_vehicle_keys, # 13-037 元請確認欄･担当者
            receipt_number:                field_special_vehicle_keys, # 13-038 受付番号
            reception_confirmation_date:   field_special_vehicle_keys, # 13-039 受付確認年月日
            person_confirming_receipt:     field_special_vehicle_keys, # 13-040 受付確認者
            a_over_winding_prevention:     field_special_vehicle_keys, # 13-111 (a)Aクレーン部 安全装置         巻過防止装置
            a_overload_protector:          field_special_vehicle_keys, # 13-112 (a)Aクレーン部 安全装置         過負荷防止装置
            a_anti_slip_hook:              field_special_vehicle_keys, # 13-113 (a)Aクレーン部 安全装置         フックのはずれ
            a_control_of_hoisting_device:  field_special_vehicle_keys, # 13-114 (a)Aクレーン部 安全装置         起伏装置制御
            a_swivel_warning_device:       field_special_vehicle_keys, # 13-115 (a)Aクレーン部 安全装置         旋回警報装置
            a_main_supplemental:           field_special_vehicle_keys, # 13-116 (a)Aクレーン部 制御装置･作業装置 主巻･補巻
            a_up_down_turning:             field_special_vehicle_keys, # 13-117 (a)Aクレーン部 制御装置･作業装置 起伏･旋回
            a_clutch:                      field_special_vehicle_keys, # 13-118 (a)Aクレーン部 制御装置･作業装置 クラッチ
            a_brake_lock:                  field_special_vehicle_keys, # 13-119 (a)Aクレーン部 制御装置･作業装置 ブレーキ･ロック
            a_jib:                         field_special_vehicle_keys, # 13-120 (a)Aクレーン部 制御装置･作業装置 ジブ
            a_pulley:                      field_special_vehicle_keys, # 13-121 (a)Aクレーン部 制御装置･作業装置 滑車
            a_hook_bucket:                 field_special_vehicle_keys, # 13-122 (a)Aクレーン部 制御装置･作業装置 フック･バケット
            a_wire_rope_chain:             field_special_vehicle_keys, # 13-123 (a)Aクレーン部 制御装置･作業装置 ワイヤロープ･チェーン
            a_slinging_tool:               field_special_vehicle_keys, # 13-124 (a)Aクレーン部 制御装置･作業装置 玉掛用具
            a_control_unit:                field_special_vehicle_keys, # 13-125 (a)Aクレーン部 その他           操作装置
            a_performance_indication:      field_special_vehicle_keys, # 13-126 (a)Aクレーン部 その他           性能表示
            a_lighting:                    field_special_vehicle_keys, # 13-127 (a)Aクレーン部 その他           照明
            b_brake:                       field_special_vehicle_keys, # 13-128 (a)B車両部　　 走行部　　       ブレーキ
            b_clutch:                      field_special_vehicle_keys, # 13-129 (a)B車両部　　 走行部　　       クラッチ
            b_handle:                      field_special_vehicle_keys, # 13-130 (a)B車両部　　 走行部　　       ハンドル
            b_tire:                        field_special_vehicle_keys, # 13-131 (a)B車両部　　 走行部　　       タイヤ
            b_crawler:                     field_special_vehicle_keys, # 13-132 (a)B車両部　　 走行部　　       クローラ
            b_alarm_device:                field_special_vehicle_keys, # 13-133 (a)B車両部　　 安全装置等       警報装置
            b_various_mirrors:             field_special_vehicle_keys, # 13-134 (a)B車両部　　 安全装置等       各種ミラー
            b_direction_indicator:         field_special_vehicle_keys, # 13-135 (a)B車両部　　 安全装置等       方向指示器
            b_headlights:                  field_special_vehicle_keys, # 13-136 (a)B車両部　　 安全装置等       前後照灯
            b_left_turn_protector:         field_special_vehicle_keys, # 13-137 (a)B車両部　　 安全装置等       左折プロテクター
            b_outrigger:                   field_special_vehicle_keys, # 13-138 (a)B車両部　　 安全装置等       アウトリガー
            b_elevator:                    field_special_vehicle_keys, # 13-139 (a)B車両部　　 安全装置等       昇降装置
            b_vessel:                      field_special_vehicle_keys, # 13-140 (a)B車両部　　 安全装置等       ベッセル
            b_rearward_monitoring_devices: field_special_vehicle_keys, # 13-141 (a)B車両部　　 安全装置等       後方監視装置
            c_piercing:                    field_special_vehicle_keys, # 13-142 (a)Cゴンドラ　                 突りょう
            c_workbench:                   field_special_vehicle_keys, # 13-143 (a)Cゴンドラ　                 作業床
            c_elevator:                    field_special_vehicle_keys, # 13-144 (a)Cゴンドラ　                 昇降装置
            c_electrical_equipment:        field_special_vehicle_keys, # 13-145 (a)Cゴンドラ　                 電気装置
            c_wire_lifeline:               field_special_vehicle_keys, # 13-146 (a)Cゴンドラ　                 ワイヤ･ライフライン
            d_turning:                     field_special_vehicle_keys, # 13-147 (a)D安全装置　 各種ロック       旋回
            d_bucket:                      field_special_vehicle_keys, # 13-148 (a)D安全装置　 各種ロック       バケット
            d_boom_arm:                    field_special_vehicle_keys, # 13-149 (a)D安全装置　 各種ロック       ブーム･アーム
            d_add_item_check_1st:          field_special_vehicle_keys, # 13-150 (a)D安全装置　 各種ロック       追加項目1(13-103)
            d_add_item_check_2nd:          field_special_vehicle_keys, # 13-151 (a)D安全装置　 各種ロック       追加項目2(13-104)
            d_add_item_check_3rd:          field_special_vehicle_keys, # 13-152 (a)D安全装置　 各種ロック       追加項目3(13-105)
            d_alarm_device:                field_special_vehicle_keys, # 13-153 (a)D安全装置　                 警報装置
            d_outrigger:                   field_special_vehicle_keys, # 13-154 (a)D安全装置　                 アウトリガー
            d_head_guard:                  field_special_vehicle_keys, # 13-155 (a)D安全装置　                 ヘッドガード
            d_lighting:                    field_special_vehicle_keys, # 13-156 (a)D安全装置　                 照明
            e_control_unit:                field_special_vehicle_keys, # 13-157 (a)E作業装置　                 操作装置
            e_bucket_blade:                field_special_vehicle_keys, # 13-158 (a)E作業装置　                 バケット･ブレード
            e_boom_arm:                    field_special_vehicle_keys, # 13-159 (a)E作業装置　                 ブーム･アーム
            e_jib:                         field_special_vehicle_keys, # 13-160 (a)E作業装置　                 ジブ
            e_reader:                      field_special_vehicle_keys, # 13-161 (a)E作業装置　                 リーダ
            e_hammer_auger_vibro:          field_special_vehicle_keys, # 13-162 (a)E作業装置　                 ハンマ･オーガ･バイブロ
            e_hydraulic_drive_unit:        field_special_vehicle_keys, # 13-163 (a)E作業装置　                 油圧駆動装置
            e_wire_rope_chain:             field_special_vehicle_keys, # 13-164 (a)E作業装置　                 ワイヤロープ･チェーン
            e_hanger:                      field_special_vehicle_keys, # 13-165 (a)E作業装置　                 吊り具等
            e_pulley:                      field_special_vehicle_keys, # 13-166 (a)E作業装置　                 滑車
            f_brake:                       field_special_vehicle_keys, # 13-167 (a)F走行部　                   ブレーキ
            f_parking_brake:               field_special_vehicle_keys, # 13-168 (a)F走行部　                   駐車ブレーキ
            f_brake_lock:                  field_special_vehicle_keys, # 13-169 (a)F走行部　                   ブレーキロック
            f_clutch:                      field_special_vehicle_keys, # 13-170 (a)F走行部　                   クラッチ
            f_control_unit:                field_special_vehicle_keys, # 13-171 (a)F走行部　                   操縦装置
            f_tires_iron_wheel:            field_special_vehicle_keys, # 13-172 (a)F走行部　                   タイヤ･鉄輪
            f_crawler:                     field_special_vehicle_keys, # 13-173 (a)F走行部　                   クローラ
            g_switchboard:                 field_special_vehicle_keys, # 13-174 (a)G電気装置　                 配電盤
            g_wiring:                      field_special_vehicle_keys, # 13-175 (a)G電気装置　                 配線
            g_isolation:                   field_special_vehicle_keys, # 13-176 (a)G電気装置　                 絶縁
            g_earth:                       field_special_vehicle_keys, # 13-177 (a)G電気装置　                 アース
            h_add_item_check_4th:          field_special_vehicle_keys, # 13-178 (a)Hその他　                   追加項目4(13-106)
            h_add_item_check_5th:          field_special_vehicle_keys, # 13-179 (a)Hその他　                   追加項目5(13-107)
            h_add_item_check_6th:          field_special_vehicle_keys, # 13-180 (a)Hその他　                   追加項目6(13-108)
            h_add_item_check_7th:          field_special_vehicle_keys, # 13-181 (a)Hその他　                   追加項目7(13-109)
            h_add_item_check_8th:          field_special_vehicle_keys, # 13-182 (a)Hその他　                   追加項目8(13-110)
            inspection_date:               field_special_vehicle_keys, # 13-255 (a)点検年月日
            inspector:                     field_special_vehicle_keys  # 13-256 (a)点検者
          ]
                                        )
      when 'doc_14th'
        params.require(:document).permit(approval_content:
          %i[
            prime_contractor_confirmation
            reception_confirmation_date
          ]
                                        )
      when 'doc_15th'
        params.require(:document).permit(approval_content:
          %i[
            prime_contractor_confirmation
          ]
                                        )
      when 'doc_16th'
        params.require(:document).permit(approval_content:
          %i[
            prime_contractor_confirmation
            fire_permit_number
            fire_permit_date
            fire_prevention_manager
            manager
            permit_criteria
          ]
                                        )
      end
    end

    def set_documents
      sub_request_order = validate_request_order!
      @documents = sub_request_order.documents
    end

    def set_document
      @document = @documents.find_by!(uuid: params[:uuid])
    end
  end
end
