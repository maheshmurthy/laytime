module TimeUtil
  def to_time_info(mins)
    new_info = TimeInfo.new
    new_info.days = mins/(60*24)
    rem = mins % (60*24)
    new_info.hours = rem/60
    new_info.mins = rem % 60
    return new_info
  end
end
