class History
  include ActionView::Helpers::NumberHelper
  
  attr_accessor :period
  
  def initialize(period=nil)
    period = 'today' if period.nil?
    @period = period
  end
  
  def jobs
    @jobs ||= Job.where(:completed_at => between)
  end
  
  def between
    case period
      when 'today'
        Time.current.at_beginning_of_day..Time.current
      when 'yesterday'
        (Time.current.at_beginning_of_day - 1.day)..Time.current.at_beginning_of_day
      when 'week'
        7.days.ago.at_beginning_of_day..Time.current
      when 'month'
        30.days.ago.at_beginning_of_day..Time.current
      when 'all'
        Time.new(1970,1,1)..Time.current
    end
  end
  
  def completed_jobs
    @success ||= jobs.where(:state => Job::Success)
  end
  
  def failed_jobs
    @failed ||= Job.where(:created_at => between).where(:state => Job::Failed)
  end
  
  def processing_jobs
    @transcoding ||= jobs.where(:state => Job::Processing)
  end
  
  def seconds_encoded
    completed_jobs.inject(0) { |sum, job| sum + job.duration.to_i }
  end
  
  def average_processing_time
    return 0 unless completed_jobs.any?
    
    total_time = completed_jobs.inject(0) do |sum, job|
      sum + (job.completed_at - job.transcoding_started_at)
    end
    
    total_time / completed_jobs.size
  end
  
  def average_queue_time
    return 0 unless completed_jobs.any?
    
    total_time = completed_jobs.inject(0) do |sum, job|
      sum + (job.transcoding_started_at - job.created_at)
    end
    
    total_time / completed_jobs.size
  end
end
