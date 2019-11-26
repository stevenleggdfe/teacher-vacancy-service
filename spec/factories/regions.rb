FactoryBot.define do
  factory :region do
    name {
      [
        'London',
        'South East',
        'Yorkshire and the Humber',
        'East of England',
        'West Midlands',
        'North West',
        'North East',
        'South West',
        'East Midlands',
        'Not Applicable',
        'Wales (pseudo)'
      ].sample
    }
    initialize_with { Region.find_or_create_by(name: name) }
  end
end
