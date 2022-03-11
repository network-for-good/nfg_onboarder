class NfgOnboarder::Session < ActiveRecord::Base
  self.table_name = 'onboarding_sessions'

  belongs_to :owner, polymorphic: true
  belongs_to :entity
  has_many :related_objects, class_name: 'NfgOnboarder::RelatedObject', foreign_key: :onboarding_session_id, dependent: :destroy

  validates :name, presence: true

  serialize :completed_high_level_steps, Array
  serialize :step_data, Hash

  serialize :onboarder_progress, Hash

  accepts_nested_attributes_for :related_objects

  scope :incomplete, -> { where('completed_at IS NULL') }
  scope :fundraisers, -> { includes(:related_objects).where(related_objects: { name: 'parent_id' }) }

  def completed_steps(current_high_level_step)
    if onboarder_progress[current_high_level_step].nil?
      onboarder_progress[current_high_level_step] = []
    end
    onboarder_progress[current_high_level_step]
  end

  def complete!
    return false if complete?
    update(completed_at: DateTime.now)
  end

  def complete?
    completed_at.present?
  end

  def current_completed_step_array
    [:onboarding, onboarder_prefix, current_high_level_step.try(:to_sym)].compact
  end

  def onboarder_progress_includes?(step)
    completed_steps(current_high_level_step).include?(step)
  end

  def does_current_completed_step_match_current_step?(high_level_step, step)
    current_high_level_step.to_sym == high_level_step.to_sym && current_step.to_sym == step.to_sym
  end

  def high_level_step_is_complete?
    completed_high_level_steps.include?(current_high_level_step)
  end

  def incomplete?
    !complete?
  end

  def related_objects=(object_hash)
    return if object_hash.blank?
    object_hash.each do |name, target|
      related_object = self.related_objects.build(name: name, target: target)
      related_object.save if self.id
    end
  end

  def started?
    created_at != updated_at
  end

  def method_missing(method_name, *args, &block)
    related_object = self.related_objects.find_by(name: method_name)
    related_object ? related_object.target : super
  end

  def respond_to_missing?(method_name, include_private)
    self.related_objects.find_by(name: method_name) || super(method_name, include_private)
  end
end
