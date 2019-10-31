require 'rails_helper'

RSpec.describe 'simple form error' do
  include RSpec::Rails::HelperExampleGroup

  it 'does something' do
    general_feedback = GeneralFeedback.new()
    general_feedback.valid?
    s = helper.simple_form_for general_feedback, url: '' do |f|
      f.input :comment, {}
    end

    expect(s).to include('<span class="govuk-visually-hidden">Error:</span>')
  end

end
