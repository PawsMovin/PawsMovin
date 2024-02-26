module PopularHelper
  def date_range_description(date, scale, min_date, max_date)
    case scale
    when "day"
      date.strftime("%B %d, %Y")
    when "week"
      "#{min_date.strftime('%B %d, %Y')} - #{max_date.strftime('%B %d, %Y')}"
    when "month"
      date.strftime("%B %Y")
    end
  end
end
