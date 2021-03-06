class AlertResultFinder
  MAXIMUM_RESULTS = 500

  attr_reader :query, :results

  def initialize(search_criteria_h, from_date, to_date)
    filters = VacancyAlertFilters.new(search_criteria_h)
    @query = VacancyAlertSearchBuilder.new(filters: filters,
                                           from: from_date, to: to_date).call
  end

  def call
    @results = ElasticSearchFinder.new.call(query[:search_query], query[:search_sort], MAXIMUM_RESULTS)
  end
end
