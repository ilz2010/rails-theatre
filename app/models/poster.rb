class Poster < ApplicationRecord
  #
  # Relations
  #
  belongs_to :t_perf, class_name: 'TPerformance'


  #
  # Scopes
  #
  scope :closest, -> (count) {order(date: :asc).limit(count).includes(t_perf: [{perf: [:p_type]}, :theatre, :t_hall]) if count} # For index

  scope :by_month, -> (month) {where_month(month) if month}
  scope :by_day, -> (day) {where_day_of_week(day) if day}
  scope :by_time, -> (time) {where_time(time) if time}

  scope :by_type, -> (id) {where(t_perf_id: TPerformance::by_type(id)) if id}
  scope :by_name, -> (id) {where(t_perf_id: TPerformance::by_name(id)) if id}
  scope :by_theatre, -> (id) {where(t_perf_id: TPerformance::by_theatre(id)) if id}
end
