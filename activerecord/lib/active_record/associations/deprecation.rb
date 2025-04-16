# frozen_string_literal: true

module ActiveRecord::Associations::Deprecation # :nodoc:
  def self.guard_deprecated_access(reflection)
    # For HABTMs, we check the deprecated flag in the parent association (the
    # actual HABTM), and we do not guard the internal has_many :through.
    if parent_reflection = reflection.options[:_parent_reflection]
      reflection = parent_reflection
    end

    <<~RUBY if reflection.deprecated? || reflection.through_reflection?
      self.class.reflect_on_association(:#{reflection.name}).tap do |reflection|
        ActiveRecord::Associations::Deprecation.warn(reflection) if reflection.deprecated?
        ActiveRecord::Associations::Deprecation.guard_through_association(reflection) if reflection.through_reflection?
      end
    RUBY
  end

  def self.warn(reflection)
    ActiveRecord.deprecator.warn("The association #{reflection.active_record.name}##{reflection.name} is deprecated")
  end

  def self.through_association(reflection)
    reflection.deprecated_nested_reflections.each { warn(_1) }
  end
end
