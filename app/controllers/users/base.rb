# frozen_string_literal: true

module Users
  class Base < ApplicationController
    before_action :authenticate_user!
    before_action :business_nil_access
    before_action :unread_news_count
    layout 'users'

    # 会社情報が登録してあればダッシュボードへ
    def business_present_access
      redirect_to users_dash_boards_path if current_user.business.present?
    end

    # 会社情報が登録してなければ会社情報登録画面へ
    def business_nil_access
      redirect_to new_users_business_path, flash: { danger: '会社情報を登録して下さい' } if current_user.business.nil?
    end

    def unread_news_count
      @unread_news_count = News.unread(current_user).count
    end

    # 現在のユーザーの会社情報を取得
    def current_business
      if current_user.admin_user_id.nil?
        @current_business ||= current_user&.business
      elsif current_user.admin_user_id.present?
        @current_business ||= current_user&.admin_user&.business
      end
    end

    # 提出済みの場合は下請けの現場情報の編集を不可にする
    def check_status_request_order
      if @request_order&.submitted? || @request_order&.approved?
        flash[:danger] = '提出済のため、編集できません。'
        redirect_to users_request_order_path(@request_order)
      end
    end

    # 自社(事業所)の作業員名を取得
    def set_business_workers_name
      @business_workers_name = current_business.workers.pluck(:name)
      @business_workers_name_id = current_business.workers
    end

    # 自社(事業所)の職種を取得
    def set_business_occupations
      @business_occupations = current_business.business_occupations.includes(:occupation).map { |bo| bo.occupation.short_name }
    end

    # 自社(事業所)および現場で取得している建設許可証番号を取得
    def set_business_construction_licenses
      # 元請の建設許可証番号
      @industry = @current_business.business_industries.map { |industry| Industry.find(industry.industry_id).name }
      @order_construction_licenses = current_business&.business_industries&.distinct&.pluck(:id, :construction_license_number)&.to_h
      order_content = @order&.content || {}
      if order_content['genecon_construction_license_number_1st'].present? && !@order_construction_licenses.value?(order_content['genecon_construction_license_number_1st'])
        if @order_construction_licenses.key?(:genecon_construction_license_id_1st)
          @order_construction_licenses[@order_construction_licenses[:genecon_construction_license_id_1st]] = @order_construction_licenses[:genecon_construction_license_number_1st]
          @order_construction_licenses.delete(:genecon_construction_license_id_1st)
        end
        @order_construction_licenses[order_content['genecon_construction_license_id_1st']] = order_content['genecon_construction_license_number_1st']
      end
      if order_content['genecon_construction_license_number_2nd'].present? && !@order_construction_licenses.value?(order_content['genecon_construction_license_number_2nd'])
        if @order_construction_licenses.key?(:genecon_construction_license_id_2nd)
          @order_construction_licenses[@order_construction_licenses[:genecon_construction_license_id_2nd]] = @order_construction_licenses[:genecon_construction_license_number_2nd]
          @order_construction_licenses.delete(:genecon_construction_license_id_2nd)
        end
        @order_construction_licenses[order_content['genecon_construction_license_id_2nd']] = order_content['genecon_construction_license_number_2nd']
      end
      # 下請けの建設許可証番号
      @request_order_construction_licenses = current_business&.business_industries&.distinct&.pluck(:id, :construction_license_number)&.to_h
      request_order_content = @request_order&.content || {}
      if request_order_content['subcon_construction_license_number_1st'].present? && !@request_order_construction_licenses.value?(request_order_content['subcon_construction_license_number_1st'])
        if @request_order_construction_licenses.key?(:subcon_construction_license_id_1st)
          @request_order_construction_licenses[@request_order_construction_licenses[:subcon_construction_license_id_1st]] =
            @request_order_construction_licenses[:subcon_construction_license_number_1st]
          @request_order_construction_licenses.delete(:subcon_construction_license_id_1st)
        end
        @request_order_construction_licenses[request_order_content['subcon_construction_license_id_1st']] = request_order_content['subcon_construction_license_number_1st']
      end
      if request_order_content['subcon_construction_license_number_2nd'].present? && !@request_order_construction_licenses.value?(request_order_content['subcon_construction_license_number_2nd'])
        if @request_order_construction_licenses.key?(:subcon_construction_license_id_2nd)
          @request_order_construction_licenses[@request_order_construction_licenses[:genecon_construction_license_id_2nd]] =
            @request_order_construction_licenses[:subcon_construction_license_number_2nd]
          @request_order_construction_licenses.delete(:subcon_construction_license_id_2nd)
        end
        @request_order_construction_licenses[request_order_content['subcon_construction_license_id_2nd']] = request_order_content['subcon_construction_license_number_2nd']
      end
    end

    # 書類に反映させる作業員情報
    def worker_info(worker)
      json =
        JSON.parse(
          worker.to_json(
            except:  %i[uuid created_at updated_at], # 作業員情報
            include: {
              worker_medical:                  {
                except: %i[id worker_id created_at updated_at] # 作業員の健康情報
              },
              worker_insurance:                {
                except: %i[id worker_id created_at updated_at] # 保険情報
              },
              worker_skill_trainings:          {
                only: %i[skill_training_id images] # 中間テーブル(技能講習マスタ)
              },
              worker_special_educations:       {
                only: %i[special_education_id images] # 中間テーブル(特別教育マスタ)
              },
              worker_safety_health_educations: {
                only: %i[safety_health_education_id images] # 中間テーブル(安全教育マスタ)
              },
              worker_licenses:                 {
                only: %i[license_id images] # 中間テーブル(免許マスタ)
              }
            }
          )
        )

      country = { country: I18n.t("countries.#{worker.country}") }
      experience_days = (Date.today - worker.hiring_on).to_i + ((worker.experience_term_before_hiring - worker.blank_term) * 365)
      experience_years = { experience_years: (experience_days / 365).to_i }
      json.merge(country, experience_years)
    end

    # 書類に反映させる車両情報
    def car_info(car)
      json =
        JSON.parse(
          car.to_json(
            except:  %i[uuid images created_at updated_at], # 車両
            include: {
              car_voluntary_insurances: {
                except: %i[id created_at updated_at] # 任意保険
              }
            }
          )
        )

      insurance_company = { car_insurance_company: CarInsuranceCompany.find(json['car_insurance_company_id']).name }
      voluntary_insurance_company = { voluntary_insurance_company: CarInsuranceCompany.find(json['car_voluntary_insurances'][0]['car_voluntary_id']).name }

      json.merge(insurance_company, voluntary_insurance_company)
    end

    # 書類に反映させる特殊車両情報
    def special_vehicle_info(special_vehicle)
      json =
        JSON.parse(
          special_vehicle.to_json(
            except: %i[uuid created_at updated_at] # 特殊車両情報
          )
        )

      %w[personal_insurance objective_insurance passenger_insurance other_insurance].each do |attr|
        json[attr] = '無制限' if special_vehicle.send("#{attr}_unlimited") == 'unlimited'
      end

      json
    end

    # 書類に反映させる機械情報
    def machine_info(machine)
      JSON.parse(
        machine.to_json(
          except:  %i[uuid created_at updated_at], # 機械情報
          include: {
            machine_tags: {
              only: [:tag_id] # 中間テーブル(機械名マスタ)
            }
          }
        )
      )
    end

    # 書類に反映させる溶剤情報
    def solvent_info(solvent)
      JSON.parse(
        solvent.to_json(
          except: %i[uuid created_at updated_at] # 溶剤情報
        )
      )
    end
  end
end
