require 'rails_helper'
require 'export_user_records_to_big_query'

RSpec.shared_examples 'a successful Big Query export' do
  it 'inserts into the dataset' do
    expect(dataset_stub).to receive(:insert).with('users', expected_table_data, autocreate: true)

    subject.run!
  end
end

RSpec.describe ExportUserRecordsToBigQuery do
  before do
    ENV['BIG_QUERY_DATASET'] = 'test_dataset'
    expect(bigquery_stub).to receive(:dataset).with('test_dataset').and_return(dataset_stub)
    expect(dataset_stub).to receive(:table).and_return(table_stub)
  end

  subject { ExportUserRecordsToBigQuery.new(bigquery: bigquery_stub) }

  let(:bigquery_stub) { instance_double('Google::Cloud::Bigquery::Project') }
  let(:dataset_stub) { instance_double('Google::Cloud::Bigquery::Dataset') }

  context 'when the user table exists in the dataset' do
    let(:table_stub) { instance_double('Google::Cloud::Bigquery::Table') }
    before { create(:user) }

    it 'deletes the table first before inserting new table data' do
      expect(table_stub).to receive(:delete).and_return(true)
      expect(dataset_stub).to receive(:reload!)
      expect(dataset_stub).to receive(:insert)

      subject.run!
    end
  end

  context 'when the user table does not exist in the dataset' do
    let(:table_stub) { nil }

    context 'with one user' do
      let(:publish_on) { format_date_as_timestamp(user.publish_on) }
      let(:expiry_time) { user.expiry_time }
      let(:ends_on) { nil }
      let(:starts_on) { nil }
      let(:subjects) { [user.subject.name] }

      let(:expected_table_data) do
        [
          {
          id: user.id,
          slug: user.slug,
          job_title: user.job_title,
          minimum_salary: user.minimum_salary,
          maximum_salary: user.maximum_salary,
          starts_on: starts_on,
          ends_on: ends_on,
          subjects: subjects,
          min_pay_scale: user.min_pay_scale&.label,
          max_pay_scale: user.max_pay_scale&.label,
          leadership: user.leadership&.title,
          education: user.education,
          qualifications: user.qualifications,
          experience: user.experience,
          status: user.status,
          expiry_time: expiry_time,
          publish_on: publish_on,
          school: {
            urn: user.school.urn,
            county: user.school.county,
          },
          created_at: user.created_at,
          updated_at: user.updated_at,
          application_link: user.application_link,
          newly_qualified_teacher: user.newly_qualified_teacher,
          total_pageviews: user.total_pageviews,
          total_get_more_info_clicks: user.total_get_more_info_clicks,
          working_patterns: user.working_patterns,
          listed_elsewhere: user.listed_elsewhere,
          hired_status: user.hired_status,
          pro_rata_salary: user.pro_rata_salary,
          publisher_user_id: user.publisher_user&.oid,
        }
      ]
      end

      context 'with no expiry_time' do
        let(:user) { create(:user, :with_no_expiry_time).reload }
        let(:expiry_time) { format_date_as_timestamp(user.expires_on) }

        it_behaves_like 'a successful Big Query export'
      end

      context 'when there is a starts_on and ends_on' do
        let(:user) { create(:user, :complete).reload }
        let(:starts_on) { user.starts_on.strftime('%F') }
        let(:ends_on) { user.ends_on.strftime('%F') }

        it_behaves_like 'a successful Big Query export'
      end

      context 'when a user has no publish_on date' do
        let(:user) { create(:user, publish_on: nil).reload }
        let(:publish_on) { nil }

        it_behaves_like 'a successful Big Query export'
      end

      context 'with no subjects' do
        let(:user) { create(:user, subject: nil).reload }
        let(:subjects) { [] }

        it_behaves_like 'a successful Big Query export'
      end

      context 'with only one subject' do
        let(:user) { create(:user).reload }

        it_behaves_like 'a successful Big Query export'
      end

      context 'with multiple subjects' do
        let(:user) { create(:user, :first_supporting_subject, :second_supporting_subject).reload }
        let(:subjects) do
          [user.subject.name, user.first_supporting_subject.name, user.second_supporting_subject.name]
        end

        it_behaves_like 'a successful Big Query export'
      end
    end

    context 'when the number of vacancies is greater than the batch size' do
      before { create_list(:user, 3) }

      it 'inserts into big query twice' do
        expect(dataset_stub).to receive(:insert).twice

        subject.run!(batch_size: 2)
      end
    end

    def format_date_as_timestamp(date)
      date.strftime('%FT%T%:z')
    end
  end
end
