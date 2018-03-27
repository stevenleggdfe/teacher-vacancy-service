require 'rails_helper'
RSpec.feature 'Creating a vacancy' do
  let(:school) { create(:school) }

  include_context 'when authenticated as a member of hiring staff',
                  stub_basic_auth_env: true

  scenario 'Visiting the school page' do
    school = create(:school, name: 'Salisbury School')

    visit school_path(school.id)

    expect(page).to have_content('Salisbury School')
    expect(page).to have_content(/#{school.address}/)
    expect(page).to have_content(/#{school.town}/)

    click_link 'Publish a vacancy'

    expect(page).to have_content('Step 1 of 3')
  end

  context 'creating a new vacancy' do
    let!(:pay_scales) { create_list(:pay_scale, 3) }
    let!(:subjects) { create_list(:subject, 3) }
    let!(:leaderships) { create_list(:leadership, 3) }
    let(:vacancy) do
      VacancyPresenter.new(build(:vacancy, :complete,
                                 pay_scale: pay_scales.sample,
                                 subject: subjects.sample,
                                 leadership: leaderships.sample))
    end

    scenario 'redirects to step 1, job specification' do
      visit new_school_vacancy_path(school_id: school.id)

      expect(page.current_path).to eq(job_specification_school_vacancy_path(school_id: school.id))
      expect(page).to have_content("Publish a vacancy for #{school.name}")
      expect(page).to have_content('Step 1 of 3')
    end

    context '#job_specification' do
      scenario 'is invalid unless all mandatory fields are submitted' do
        visit new_school_vacancy_path(school_id: school.id)

        click_on 'Save and continue'

        within('.error-summary') do
          expect(page).to have_content('5 errors prevented this vacancy from being saved:')
        end

        within_row_for(text: I18n.t('vacancies.job_title')) do
          expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.job_title.blank'))
        end

        within_row_for(text: I18n.t('vacancies.headline')) do
          expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.headline.blank'))
        end

        within_row_for(text: I18n.t('vacancies.description')) do
          expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.job_description.blank'))
        end

        within_row_for(text: I18n.t('vacancies.salary_range')) do
          expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.minimum_salary.blank'))
        end

        within_row_for(text: I18n.t('vacancies.working_pattern')) do
          expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.working_pattern.blank'))
        end
      end

      scenario 'redirects to step 2, candidate profile, when submitted succesfuly' do
        visit new_school_vacancy_path(school_id: school.id)

        fill_in_job_specification_form_fields(vacancy)
        click_on 'Save and continue'

        expect(page).to have_content('Step 2 of 3')
      end
    end

    context '#candidate_profile' do
      scenario 'is invalid unless all mandatory fields are submitted' do
        visit new_school_vacancy_path(school_id: school.id)

        fill_in_job_specification_form_fields(vacancy)
        click_on 'Save and continue'

        click_on 'Save and continue' # submit empty form

        within('.error-summary') do
          expect(page).to have_content('3 errors prevented this vacancy from being saved:')
        end

        within_row_for(text: I18n.t('vacancies.education')) do
          expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.education.blank'))
        end

        within_row_for(text: I18n.t('vacancies.qualifications')) do
          expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.qualifications.blank'))
        end
        within_row_for(text: I18n.t('vacancies.experience')) do
          expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.experience.blank'))
        end
      end

      scenario 'redirects to step 3, application_details profile, when submitted succesfuly' do
        visit new_school_vacancy_path(school_id: school.id)

        fill_in_job_specification_form_fields(vacancy)
        click_on 'Save and continue'
        fill_in_candidate_specification_form_fields(vacancy)
        click_on 'Save and continue'

        expect(page).to have_content('Step 3 of 3')
      end
    end

    context '#application_details' do
      scenario 'is invalid unless all mandatory fields are submitted' do
        visit new_school_vacancy_path(school_id: school.id)

        fill_in_job_specification_form_fields(vacancy)
        click_on 'Save and continue'
        fill_in_candidate_specification_form_fields(vacancy)
        click_on 'Save and continue'
        click_on 'Save and continue'

        within('.error-summary') do
          expect(page).to have_content('4 errors prevented this vacancy from being saved:')
        end

        within_row_for(text: I18n.t('vacancies.contact_email')) do
          expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.contact_email.blank'))
        end

        within_row_for(element: 'legend', text: I18n.t('vacancies.deadline_date')) do
          expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.expires_on.blank'))
        end

        within_row_for(element: 'legend', text: I18n.t('vacancies.publication_date')) do
          expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.publish_on.blank'))
        end
      end

      scenario 'redirects to the vacancy review page when submitted succesfuly' do
        visit new_school_vacancy_path(school_id: school.id)

        fill_in_job_specification_form_fields(vacancy)
        click_on 'Save and continue'
        fill_in_candidate_specification_form_fields(vacancy)
        click_on 'Save and continue'
        fill_in_application_details_form_fields(vacancy)
        click_on 'Save and continue'

        expect(page).to_not have_content('Step 3 of 3')
        expect(page).to have_content(I18n.t('vacancies.review'))
      end
    end

    context '#review' do
      scenario 'is not available for published vacancies' do
        vacancy = create(:vacancy, :published, school_id: school.id)

        visit school_vacancy_review_path(school_id: school.id, vacancy_id: vacancy.id)

        expect(page).to have_current_path(school_vacancy_path(school_id: school.id, id: vacancy.id))
      end

      scenario 'lists all the vacancy details correctly' do
        vacancy = VacancyPresenter.new(create(:vacancy, :complete, :draft, school_id: school.id))
        visit school_vacancy_review_path(school_id: school.id, vacancy_id: vacancy.id)

        expect(page).to have_content("Review the vacancy for #{school.name}")

        verify_all_vacancy_details(vacancy)
      end

      context 'edit job_specification_details' do
        scenario 'updates the vacancy details' do
          vacancy = create(:vacancy, :draft, :complete, school_id: school.id)
          visit school_vacancy_review_path(school_id: school.id, vacancy_id: vacancy.id)
          find(:xpath, '//div[dt[contains(text(), "Job title")]]').find('a').click

          expect(page).to have_content('Step 1 of 3')

          fill_in 'job_specification_form[job_title]', with: 'An edited job title'
          click_on 'Save and continue'

          expect(page).to have_content("Review the vacancy for #{school.name}")
          expect(page).to have_content('An edited job title')
        end

        scenario 'fails validation until values are set correctly' do
          vacancy = create(:vacancy, :draft, :complete, school_id: school.id)
          visit school_vacancy_review_path(school_id: school.id, vacancy_id: vacancy.id)
          find(:xpath, '//div[dt[contains(text(), "Job title")]]').find('a').click

          fill_in 'job_specification_form[job_title]', with: ''
          click_on 'Save and continue'

          expect(page).to have_content('Job title can\'t be blank')

          fill_in 'job_specification_form[job_title]', with: 'A new job title'
          click_on 'Save and continue'

          expect(page).to have_content("Review the vacancy for #{school.name}")
          expect(page).to have_content('A new job title')
        end
      end

      context 'editing the candidate_specification_details' do
        scenario 'updates the vacancy details' do
          vacancy = create(:vacancy, :draft, :complete, school_id: school.id)
          visit school_vacancy_review_path(school_id: school.id, vacancy_id: vacancy.id)
          find(:xpath, '//div[dt[contains(text(), "Qualifications")]]').find('a').click

          expect(page).to have_content('Step 2 of 3')

          fill_in 'candidate_specification_form[qualifications]', with: 'Teaching diploma'
          click_on 'Save and continue'

          expect(page).to have_content("Review the vacancy for #{school.name}")
          expect(page).to have_content('Teaching diploma')
        end

        scenario 'fails validation until values are set correctly' do
          vacancy = create(:vacancy, :draft, :complete, school_id: school.id)
          visit school_vacancy_review_path(school_id: school.id, vacancy_id: vacancy.id)
          find(:xpath, '//div[dt[contains(text(), "Educational requirements")]]').find('a').click

          expect(page).to have_content('Step 2 of 3')

          fill_in 'candidate_specification_form[education]', with: ''
          click_on 'Save and continue'

          expect(page).to have_content('Education can\'t be blank')

          fill_in 'candidate_specification_form[education]', with: 'essential requirements'
          click_on 'Save and continue'

          expect(page).to have_content('Confirm and submit vacancy')
          expect(page).to have_content('essential requirements')
        end
      end

      context 'editing the application_details' do
        scenario 'fails validation until values are set correctly' do
          vacancy = create(:vacancy, :draft, :complete, school_id: school.id)
          visit school_vacancy_review_path(school_id: school.id, vacancy_id: vacancy.id)
          find(:xpath, '//div[dt[contains(text(), "Vacancy contact email")]]').find('a').click

          expect(page).to have_content('Step 3 of 3')

          fill_in 'application_details_form[contact_email]', with: 'not a valid email'
          click_on 'Save and continue'

          expect(page).to have_content('Contact email is invalid')

          fill_in 'application_details_form[contact_email]', with: 'a@valid.email'
          click_on 'Save and continue'

          expect(page).to have_content("Review the vacancy for #{school.name}")
          expect(page).to have_content('a@valid.email')
        end

        scenario 'updates the vacancy details' do
          vacancy = create(:vacancy, :draft, :complete, school_id: school.id)
          visit school_vacancy_review_path(school_id: school.id, vacancy_id: vacancy.id)
          find(:xpath, '//div[dt[contains(text(), "Vacancy contact email")]]').find('a').click

          expect(page).to have_content('Step 3 of 3')

          fill_in 'application_details_form[contact_email]', with: 'an@email.com'
          click_on 'Save and continue'

          expect(page).to have_content("Review the vacancy for #{school.name}")
          expect(page).to have_content('an@email.com')
        end
      end

      scenario 'redirects to the school vacancy page when published' do
        vacancy = create(:vacancy, :draft, school_id: school.id)
        visit school_vacancy_review_path(school_id: school.id, vacancy_id: vacancy.id)
        click_on 'Confirm and submit vacancy'

        expect(page).to have_content("The system reference number is #{vacancy.reference}")
        expect(page).to have_content('The vacancy has been posted, you can view it here:')
      end
    end

    context '#publish' do
      scenario 'can be published at a later date' do
        vacancy = create(:vacancy, :draft, school_id: school.id, publish_on: Time.zone.tomorrow)

        visit school_vacancy_review_path(school_id: school.id, vacancy_id: vacancy.id)
        click_on 'Confirm and submit vacancy'

        expect(page).to have_content("The system reference number is #{vacancy.reference}")
        expect(page).to have_content("The vacancy will be posted on #{vacancy.publish_on}, you can preview it here:")
        visit vacancy_url(vacancy)
        expect(page).to have_content("Date posted #{format_date(vacancy.publish_on)}")
      end

      scenario 'a published vacancy cannot be edited' do
        visit new_school_vacancy_path(school_id: school.id)

        fill_in_job_specification_form_fields(vacancy)
        click_on 'Save and continue'
        fill_in_candidate_specification_form_fields(vacancy)
        click_on 'Save and continue'
        fill_in_application_details_form_fields(vacancy)
        click_on 'Save and continue'
        click_on 'Confirm and submit vacancy'
        expect(page).to have_content('The vacancy has been posted, you can view it here:')

        visit candidate_specification_school_vacancy_path(school_id: school.id)
        expect(page.current_path).to eq(job_specification_school_vacancy_path(school_id: school.id))

        visit application_details_school_vacancy_path(school_id: school.id)
        expect(page.current_path).to eq(job_specification_school_vacancy_path(school_id: school.id))
      end
    end
  end

  def within_row_for(element: 'label', text:, &block)
    element = page.find(element, text: text).find(:xpath, '..')
    within(element, &block)
  end
end
