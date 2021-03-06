class StatisticController < ApplicationController

  TIME_LIMIT = DateTime.parse 3.months.ago.to_s

  def index
    @top_searches = top_searches
    @failed_searches = failed_searches
    @last_searches = last_searches
  end


  private

  def top_searches
    Rails.cache.fetch('top_searches', :expires_in => 2.hours) do
      result = ActiveRecord::Base.connection.execute("select query, count(*) as c from search_histories where query is NOT NULL " +
          "AND count > 0 AND created_at > '#{TIME_LIMIT}' group by query order by c desc limit 25;")
      top = Array.new
      result.each do |entry|
        top << { :query => entry[0].strip.downcase, :count => entry[1].to_i}
      end
      top
    end
  end

  def last_searches
      result = ActiveRecord::Base.connection.execute("select query from search_histories where query is NOT NULL " +
          " order by created_at desc limit 25;")
      last = Array.new
      result.each do |entry|
        last << { :query => entry[0].strip.downcase, :count => entry[1].to_i}
      end
      last
  end

  def failed_searches
    Rails.cache.fetch('failed_searches', :expires_in => 2.hours) do
      result = ActiveRecord::Base.connection.execute("select query, count(*) as c from search_histories where query is NOT NULL " +
          "AND count = 0 AND created_at > '#{TIME_LIMIT}' group by query order by c desc limit 25; ")
      failed = Array.new
      result.each do |entry|
        failed << { :query => entry[0].strip.downcase, :count => entry[1].to_i}
      end
      failed
    end
  end


end
