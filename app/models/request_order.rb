class RequestOrder < ApplicationRecord
  attribute :professional_engineer_skill_training_id, :integer

  belongs_to :order
  belongs_to :business
  has_many :documents, dependent: :destroy
  has_many :field_workers, as: :field_workerable, dependent: :destroy
  has_many :field_cars, as: :field_carable, dependent: :destroy
  has_many :field_fires, as: :field_fireable, dependent: :destroy
  has_many :field_solvents, as: :field_solventable, dependent: :destroy
  has_many :field_special_vehicles, as: :field_special_vehicleable, dependent: :destroy
  has_many :field_machines, as: :field_machineable, dependent: :destroy

  has_closure_tree

  enum status: { requested: 0, submitted: 1, fix_requested: 2, approved: 3 }
  enum professional_construction: { y: 0, n: 1 }
  enum lead_engineer_check: { full_time: 0, non_dedicated: 1 }
  enum lead_engineer_work_experience: { five_years_or_more_after_high_school: 0, three_years_or_more_after_technical_college: 1, three_years_or_more_after_university: 2, ten_or_more_years: 3 },
    _prefix: true

  validates :occupation,                         presence: true, on: :update                            # 職種
  validates :construction_name,                  presence: true, length: { maximum: 100 }, on: :update  # 工事名
  validates :construction_details,               length: { maximum: 100 }, on: :update                  # 工事内容
  validates :start_date,                         presence: true, on: :update                            # 工期(自)
  validates :end_date,                           presence: true, on: :update                            # 工期(至)
  validates :contract_date,                      presence: true, on: :update                            # 契約日
  validates :site_agent_name,                    presence: true, on: :update                            # 現場代理人(氏名)
  validates :site_agent_apply,                   presence: true, length: { maximum: 40 }, on: :update   # 現場代理人(権限及び意見の申出方法)
  validates :supervisor_name,                    presence: true, on: :update                            # 監督員(氏名)
  validates :supervisor_apply,                   presence: true, length: { maximum: 40 }, on: :update   # 監督員(権限及び意見の申出方法)
  validates :professional_engineer_details,      length: { maximum: 40 }, on: :update                   # 専門技術者(担当工事内容)
  validates :construction_manager_name,          presence: true, on: :update                            # 工事担任責任者(氏名)
  validates :lead_engineer_name,                 presence: true, on: :update                            # 主任技術者(氏名)
  validates :lead_engineer_check,                presence: true, on: :update                            # 主任技術者(専任or非専任)
  validates :work_chief_name,                    presence: true, on: :update                            # 作業主任者(氏名)
  validates :work_conductor_name,                presence: true, on: :update                            # 作業指揮者名(氏名)
  validates :safety_officer_name,                presence: true, on: :update                            # 安全衛生担当責任者(氏名)
  validates :safety_manager_name,                presence: true, on: :update                            # 安全衛生責任者(氏名)
  validates :safety_promoter_name,               presence: true, on: :update                            # 安全推進者(氏名)
  validates :foreman_name,                       presence: true, on: :update                            # 職長(氏名)

  # 　氏名無しで更新させない
  validate :name_is_required_professional_engineer
  validate :name_is_required_registered_core_engineer

  before_create -> { self.uuid = SecureRandom.uuid }

  def to_param
    uuid
  end

  def prime_contractor?
    parent_id.nil?
  end

  private

  def name_is_required_professional_engineer
    if professional_engineer_name.blank? && (professional_engineer_details.present? || professional_engineer_qualification.present?)
      errors.add(:professional_engineer_name, '専門技術者の氏名を入力してください')
    end
  end

  def name_is_required_registered_core_engineer
    if registered_core_engineer_name.blank? && registered_core_engineer_qualification.present?
      errors.add(:registered_core_engineer_name, '登録基幹技能者の氏名を入力してください')
    end
  end
end
