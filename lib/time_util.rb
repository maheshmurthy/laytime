module TimeUtil
  def to_time_info(mins)
    new_info = TimeInfo.new
    new_info.days = mins/(60*24)
    rem = mins % (60*24)
    new_info.hours = rem/60
    new_info.mins = rem % 60
    return new_info
  end

  def pad(value)
    "%02d" % value
  end

  def pretty_time_info(time_info)
    time_info.days.to_s + " days " + pad(time_info.hours) + "." + pad(time_info.mins)
  end

  def to_hr_min(value)
    hr = value/60
    min = value % 60
    "%02d.%02d" % [hr,min]
  end

  def pretty_time_with_zone(time)
    time.strftime("%d-%m-%Y %H.%M") if time
  end

  def pretty_time_mins(mins)
    time_info = to_time_info(mins)
    time_info.to_s
  end

  def pretty_time_info_for_id(id)
    if(id)
      info = TimeInfo.find_by_id(id)
      info.to_s
    else
    ""
    end
  end

  def pretty_time_diff_of_ids(id_avail, id_used)
    if(id_avail && id_used) 
      info_avail = TimeInfo.find_by_id(id_avail)
      info_used = TimeInfo.find_by_id(id_used)
      info_avail.diff(info_used).to_s
    else
      ""
    end
  end
end
