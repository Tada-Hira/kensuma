class FireUseTarget < ApplicationRecord
  has_many :field_fire_fire_use_targets, dependent: :destroy
  has_many :field_fires, through: :field_fire_fire_use_targets
end
