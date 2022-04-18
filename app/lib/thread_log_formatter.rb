# frozen_string_literal: true

class ThreadLogFormatter < ::Logger::Formatter
  def call(severity, time, progname, msg)
    th = Thread.current
    "%-5s [%s#%d-%s]  %s\n" % [severity, format_datetime(time), $$, th.name || th.object_id.to_s, msg2str(msg)]
  end
end
