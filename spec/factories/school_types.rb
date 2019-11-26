FactoryBot.define do
  factory :school_type do
    label {
      [
        'Local authority maintained schools',
        'Independent schools',
        'Special schools',
        'Academies',
        'Other types',
        'Colleges',
        'Universities',
        'Free Schools',
        'Welsh schools'
      ].sample
    }
    initialize_with { SchoolType.find_or_create_by(label: label) }
  end
end
