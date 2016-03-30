module ThoughtHelper
  def annotate_mentions(message)
    html_escape(message).gsub(Thought::MENTION_MATCHER) do |match|
      handle = Thought::MENTION_MATCHER.match(match)[1]

      link_to match, "/~#{handle}"
    end.gsub(Thought::CHECKIN_MATCHER) do |match|
      handle = Thought::CHECKIN_MATCHER.match(match)[1]

      link_to match, "/@#{handle}"
    end.html_safe
  end
end