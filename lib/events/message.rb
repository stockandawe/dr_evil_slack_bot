# frozen_string_literal: true

require 'os'

evil_quotes = {
  'breaking news' => 'one_million_dollars.mp3',
  'pull request merged' => 'begin_deploy.mp3',
  'new release published' => 'begin_deploy.mp3',
  'new issue created' => 'not_tollerate.mp3',
  'lat-binding-issues' => 'look_what_you_did.mp3',
  'gratitudes' => 'you_are_the_best_evil_son_an_evil_dad_could_ever_ask_for.mp3'
}

SlackRubyBotServer::Events.configure do |config|
  config.on :event, ['event_callback', 'message'] do |event|
    team = Team.where(team_id: event[:event][:team]).first
    if team.nil?
      event.logger.error "Cannot find team with ID #{event[:event][:team]}."
      break
    end

    slack_client = Slack::Web::Client.new(token: Team.first.token)

    channel = slack_client.conversations_info(channel: event[:event][:channel])
    channel_name = channel[:channel][:name]
    message = event[:event][:text]

    if evil_quotes.keys.any? { |word| message.downcase.include?(word) }
      key_for_quote = ''
      evil_quotes.each_key do |substring|
        key_for_quote = substring if message.downcase.include? substring
      end
      if OS.linux?
        fork { exec 'mpg123', "assets/#{evil_quotes[key_for_quote]}" }
      elsif OS.mac?
        fork { exec 'afplay', "assets/#{evil_quotes[key_for_quote]}" }
      else
        event.logger.info "Cannot play audio message: #{event[:event][:text]} in #{channel_name}."
      end
    end

    event.logger.info "Received message: #{event[:event][:text]} in #{channel_name}."

    { ok: true }
  end
end
