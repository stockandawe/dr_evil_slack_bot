evil_quotes = {
  "welcome" => "welcome.mp3",
  "New release published" => "are-those-sharks-with-laser-beams-attached-to-their-heads.mp3",
  "BREAKING NEWS" => "why_make_trillions.mp3",
}

SlackRubyBotServer::Events.configure do |config|
  config.on :event, ['event_callback', 'message'] do |event|
    team = Team.where(team_id: event[:event][:team]).first || raise("Cannot find team with ID #{event[:event][:team]}.")

    slack_client = Slack::Web::Client.new(token: Team.first.token)

    channel = slack_client.conversations_info(channel: event[:event][:channel])
    channel_name = channel[:channel][:name]
    message = event[:event][:text]

    if evil_quotes.keys.any? { |word| message.include?(word) }
      key_for_quote = ""
      evil_quotes.keys.each do |substring|
        key_for_quote = substring if message.include? substring
      end
      ## works on mac
      fork{ exec 'afplay', "../../assets/#{evil_quotes[key_for_quote]}" }
    end

    event.logger.info "Received message: #{event[:event][:text]} in #{channel_name}."

    { ok: true }
  end
end
