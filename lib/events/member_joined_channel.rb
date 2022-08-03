# frozen_string_literal: true

SlackRubyBotServer::Events.configure do |config|
  config.on :event, ['event_callback', 'member_joined_channel'] do |event|
    team = Team.where(team_id: event[:event][:team]).first || raise("Cannot find team with ID #{event[:event][:team]}.")

    slack_client = Slack::Web::Client.new(token: team.token)

    user = slack_client.users_info(user: event[:event][:user])
    user_name = user[:user][:name]

    channel = slack_client.conversations_info(channel: event[:event][:channel])
    channel_name = channel[:channel][:name]

    if system('which mpg123 > /dev/null 2>&1')
      fork { exec 'mpg123', 'assets/welcome.mp3' }
    else
      slack_client.chat_postMessage(channel: event[:event][:channel], text: "Welcome #{user_name} to #{channel_name}!")
      event.logger.info 'Cannot play audio message.'
    end
    event.logger.info "User #{user_name} joined #{channel_name}."

    { ok: true }
  end
end
