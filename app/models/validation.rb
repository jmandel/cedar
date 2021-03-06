# Validations are what Cedar is all about
class Validation
  include Mongoid::Document
  include Taggable
  field :name,                      type: String
  field :code,                      type: String
  field :description,               type: String
  field :overview_text,             type: String
  field :qrda_type,                 type: String # 1, 3, or all
  field :measure_type,              type: String # discrete, continuous, all
  field :performance_rate_required, type: Boolean
  field :tags,                      type: Array, default: []

  default_scope -> { order('qrda_type ASC, name ASC') }

  scope :qrda_type, -> (qrda_type) { where qrda_type: qrda_type }
  scope :measure_type, -> (measure_type) { where measure_type: measure_type }

  has_and_belongs_to_many :test_executions
  has_many                :documents
end
