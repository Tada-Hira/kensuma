class Machine < ApplicationRecord
  belongs_to :business
  has_many :machine_tags, dependent: :destroy
  has_many :tags, through: :machine_tags

  before_create -> { self.uuid = SecureRandom.uuid }

  validates :name, presence: true
  validates :standards_performance, presence: true
  validates :control_number, presence: true
  validates :inspector, presence: true
  validates :handler, presence: true
  before_validation :convert_to_full_width_katakana # 機械名に対して半角で入力しても全角に変換する

  def to_param
    uuid
  end

  private

  # 半角カタカナを全角カタカナに変換する
  def convert_to_full_width_katakana
    if name.present?
      self.name = name.gsub(/[\uFF61-\uFF9F]+/) { |str| str.unicode_normalize(:nfkc) }
    end
  end
end
