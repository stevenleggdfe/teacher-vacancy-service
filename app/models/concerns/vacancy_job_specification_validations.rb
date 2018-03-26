module VacancyJobSpecificationValidations
  extend ActiveSupport::Concern

  included do
    validates :job_title, :job_description, :headline,
              :minimum_salary, :working_pattern, presence: true

    validate :minimum_salary_lower_than_maximum, :working_hours
  end

  def minimum_salary_lower_than_maximum
    errors.add(:minimum_salary, min_salary_must_be_greater_than_max_error) if minimum_higher_than_maximum_salary?
  end

  def working_hours
    return if weekly_hours.blank?

    begin
      !!BigDecimal(weekly_hours)
      errors.add(:weekly_hours, negative_weekly_hours_error) if BigDecimal(weekly_hours).negative?
    rescue ArgumentError
      errors.add(:weekly_hours, invalid_weekly_hours_error)
    end
  end

  private

  def minimum_higher_than_maximum_salary?
    maximum_salary && minimum_salary > maximum_salary
  end

  def min_salary_must_be_greater_than_max_error
    I18n.t('activerecord.errors.models.vacancy.attributes.minimum_salary.greater_than_maximum_salary')
  end

  def negative_weekly_hours_error
    I18n.t('activerecord.errors.models.vacancy.attributes.weekly_hours.negative')
  end

  def invalid_weekly_hours_error
    I18n.t('activerecord.errors.models.vacancy.attributes.weekly_hours.invalid')
  end
end
