class History
  include ActionView::Helpers::NumberHelper
  
  attr_accessor :period
  
  def initialize(period)
    period = 'today' if period.nil?
    @period = period
  end
  
  def jobs
    Job.where(:completed_at => between)
  end
  
  def between
    case period
      when 'today'
        Time.now.at_beginning_of_day..Time.now
      when 'yesterday'
        (Time.now.at_beginning_of_day - 1.day)..Time.now.at_beginning_of_day
      when 'week'
        (Time.now.at_beginning_of_day - 7.days)..Time.now
      when 'month'
        Time.now.at_beginning_of_month..Time.now
      when 'all'
        Time.new(1970,1,1)..Time.now
    end
  end
  
  def completed_jobs
    jobs.where(:state => 'complete')
  end
  
  def failed_jobs
    jobs.where(:state => 'failed')
  end
  
  def transcoding_jobs
    jobs.where(:state => 'transcoding')
  end
  
  def seconds_encoded
    completed_jobs.inject(0) { |sum, job| sum + job.duration.to_i }
  end
  
  def average_processing_time
    return 0 unless completed_jobs.any?
    
    total_time = completed_jobs.inject(0) do |sum, job|
      diff = job.completed_at.to_i - job.transcoding_started_at.to_i
      sum + diff
    end
    total_time / completed_jobs.size
  end
  
  def average_queue_time
    return 0 unless completed_jobs.any?
    
    total_time = completed_jobs.inject(0) do |sum, job|
      diff = job.transcoding_started_at.to_i - job.created_at.to_i
      sum + diff
    end
    total_time / completed_jobs.size
  end
end
