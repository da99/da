
module DA
  def human_time(raw_time : Int64)
    human_time Time.epoch(raw_time)
  end

  def human_time(time : Time)
    io = IO::Memory.new

    now = Time.now
    is_past = now > time
    is_future = is_past
    span = if is_past
             (now - time)
           else
             time - now
           end

    days = span.days
    hrs  = span.hours
    mins = span.minutes
    secs = span.seconds

    if is_past
      ans =  case

             when span >= 59.minutes && span < 61.minutes
               "1 hr. ago"

             when span < 1.minute
               "#{span} secs. ago"

             when span > 1.minute && span < 1.hour
               "#{span.minutes} mins. ago"

             else
               "#{time_span_to_words(span)} ago"
             end # case
      return ans
    end # if

    # === future time

    io = IO::Memory.new

    case
    when span >= 57.seconds && span <= 62.seconds
      return "in 1 min."
    when span >= 58.minutes && span <= 61.minutes
      return "in 1 hr."
    end

    "in #{time_span_to_words(span).join(", ")}"
  end # === def

  def time_span_to_words(span : Time::Span)
    days = span.days
    hrs  = span.hours
    mins = span.minutes
    secs = span.seconds
    words = Deque(String).new

    words << "1 day" if days == 1
    words << "#{days} days" if days > 1

    words << "1 hr." if hrs == 1
    words << "#{hrs} hrs." if hrs > 1

    words << "1 min." if mins == 1
    words << "#{mins} mins." if mins > 1

    if days == hrs == mins == 0
      words << "1 sec." if secs == 1
      words << "#{secs} secs." if secs > 1
    end

    words
  end # === def
end # === module DA
