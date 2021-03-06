require 'rails_helper'

RSpec.describe JobSpecificationForm, type: :model do
  subject { JobSpecificationForm.new({}) }

  context 'validations' do
    describe '#working_patterns' do
      let(:job_specification) { JobSpecificationForm.new(working_patterns: nil) }

      it 'requests an entry in the field' do
        expect(job_specification.valid?).to be false
        expect(job_specification.errors.messages[:working_patterns][0])
          .to eq('Select a working pattern')
      end
    end

    describe '#job_title' do
      let(:job_specification) { JobSpecificationForm.new(job_title: job_title) }

      context 'when title is blank' do
        let(:job_title) { nil }

        it 'requests an entry in the field' do
          expect(job_specification.valid?).to be false
          expect(job_specification.errors.messages[:job_title][0])
            .to eq('Enter a job title')
        end
      end

      context 'when title is too short' do
        let(:job_title) { 'aa' }

        it 'validates minimum length' do
          expect(job_specification.valid?).to be false
          expect(job_specification.errors.messages[:job_title][0])
            .to eq(I18n.t('activemodel.errors.models.job_specification_form.attributes.job_title.too_short', count: 4))
        end
      end

      context 'when title is too long' do
        let(:job_title) { 'Long title' * 100 }

        it 'validates max length' do
          expect(job_specification.valid?).to be false
          expect(job_specification.errors.messages[:job_title][0])
            .to eq(I18n.t('activemodel.errors.models.job_specification_form.attributes.job_title.too_long', count: 100))
        end
      end
    end

    describe '#job_description' do
      let(:job_specification) { JobSpecificationForm.new(job_description: job_description) }

      context 'when description is blank' do
        let(:job_description) { nil }

        it 'requests an entry in the field' do
          expect(job_specification.valid?).to be false
          expect(job_specification.errors.messages[:job_description][0])
            .to eq('Enter a job description')
        end
      end

      context 'when description is too short' do
        let(:job_description) { 'short' }

        it 'validates minimum length' do
          expect(job_specification.valid?).to be false
          expect(job_specification.errors.messages[:job_description][0])
            .to eq(
              I18n.t('activemodel.errors.models.job_specification_form.attributes.job_description.too_short',
                count: 10)
              )
        end
      end

      context 'when description is too long' do
        let(:job_description) { 'Long text' * 10000 }

        it 'validates max length' do
          expect(job_specification.valid?).to be false
          expect(job_specification.errors.messages[:job_description][0])
            .to eq(
              I18n.t('activemodel.errors.models.job_specification_form.attributes.job_description.too_long',
                count: 50000)
              )
        end
      end
    end

    describe '#minimum_salary' do
      let(:job_specification) { JobSpecificationForm.new(minimum_salary: nil) }

      it 'requests an entry in the field' do
        expect(job_specification.valid?).to be false
        expect(job_specification.errors.messages[:minimum_salary][0])
          .to eq('Enter a minimum salary')
      end
    end

    describe '#maximum_salary' do
      let(:job_specification) do
        JobSpecificationForm.new(job_title: 'job title',
                                 job_description: 'description', working_patterns: ['full_time'],
                                 minimum_salary: 20, maximum_salary: 10)
      end

      it 'the maximum salary should be higher than the minimum salary' do
        expect(job_specification.valid?).to be false
        expect(job_specification.errors.messages[:maximum_salary][0])
          .to eq('Maximum salary must be more than the minimum salary')
      end
    end
  end

  describe '#starts_on' do
    it 'has no validation applied when blank' do
      job_specification_form = JobSpecificationForm.new(starts_on: nil)
      job_specification_form.valid?

      expect(job_specification_form).to have(:no).errors_on(:starts_on)
    end

    it 'must be in the future' do
      job_specification_form = JobSpecificationForm.new(starts_on: 1.day.ago)
      expect(job_specification_form.valid?).to be false

      expect(job_specification_form).to have(1).errors_on(:starts_on)
      expect(job_specification_form.errors.messages[:starts_on][0])
        .to eq('Start date must be in the future')
    end

    it 'must be before the ends_on date' do
      job_specification_form = JobSpecificationForm.new(starts_on: Time.zone.today + 10.days,
                                                        ends_on: Time.zone.today + 5.days)
      expect(job_specification_form.valid?).to be false

      expect(job_specification_form).to have(1).errors_on(:starts_on)
      expect(job_specification_form.errors.messages[:starts_on][0])
        .to eq('Start date must be before end date')
    end

    it 'must be after the closing date' do
      job_specification_form = JobSpecificationForm.new(starts_on: Time.zone.today,
                                                        expires_on: Time.zone.tomorrow)
      expect(job_specification_form.valid?).to be false

      expect(job_specification_form).to have(1).errors_on(:starts_on)
      expect(job_specification_form.errors.messages[:starts_on][0])
        .to eq('Start date must be after application deadline')
    end
  end

  describe '#ends_on' do
    it 'has no validation applied when blank' do
      job_specification_form = JobSpecificationForm.new(ends_on: nil)
      job_specification_form.valid?

      expect(job_specification_form).to have(:no).errors_on(:ends_on)
    end

    it 'must be in the future' do
      job_specification_form = JobSpecificationForm.new(ends_on: 1.day.ago)
      expect(job_specification_form.valid?).to be false

      expect(job_specification_form).to have(1).errors_on(:ends_on)
      expect(job_specification_form.errors.messages[:ends_on][0])
        .to eq('End date must be in the future')
    end

    it 'must be after the closing date' do
      job_specification_form = JobSpecificationForm.new(ends_on: Time.zone.today,
                                                        expires_on: Time.zone.tomorrow)
      expect(job_specification_form.valid?).to be false

      expect(job_specification_form).to have(1).errors_on(:ends_on)
      expect(job_specification_form.errors.messages[:ends_on][0])
        .to eq('End date must be after application deadline')
    end
  end

  context 'when all attributes are valid' do
    let(:min_pay_scale) { create(:pay_scale) }
    let(:max_pay_scale) { create(:pay_scale) }
    let(:main_subject) { create(:subject) }
    let(:leadership) { create(:leadership) }

    it 'a JobSpecificationForm can be converted to a vacancy' do
      job_specification_form = JobSpecificationForm.new(job_title: 'English Teacher',
                                                        job_description: 'description',
                                                        working_patterns: ['full_time'],
                                                        minimum_salary: 20000, maximum_salary: 40000,
                                                        benefits: 'benefits', subject_id: main_subject.id,
                                                        min_pay_scale_id: min_pay_scale.id,
                                                        max_pay_scale_id: max_pay_scale.id,
                                                        leadership_id: leadership.id,
                                                        newly_qualified_teacher: true)

      expect(job_specification_form.valid?).to be true
      expect(job_specification_form.vacancy.job_title).to eq('English Teacher')
      expect(job_specification_form.vacancy.job_description).to eq('description')
      expect(job_specification_form.vacancy.working_patterns).to eq(['full_time'])
      expect(job_specification_form.vacancy.minimum_salary).to eq('20000')
      expect(job_specification_form.vacancy.maximum_salary).to eq('40000')
      expect(job_specification_form.vacancy.benefits).to eq('benefits')
      expect(job_specification_form.vacancy.min_pay_scale.label).to eq(min_pay_scale.label)
      expect(job_specification_form.vacancy.max_pay_scale.label).to eq(max_pay_scale.label)
      expect(job_specification_form.vacancy.subject.name).to eq(main_subject.name)
      expect(job_specification_form.vacancy.leadership.title).to eq(leadership.title)
      expect(job_specification_form.vacancy.newly_qualified_teacher).to eq(true)
    end
  end
end
