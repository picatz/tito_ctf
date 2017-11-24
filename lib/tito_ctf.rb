#!/usr/bin/env ruby
require "tito_ctf/version"
require 'slack-ruby-bot'
require 'eventmachine'
require 'faye/websocket'
require 'logger'
require 'securerandom'

module Game
  # A representation of a challenge to complete in the game.
  #
  # == Example
  #  challenge = Challenge.new(id: "uniq_id_string_here")
  Challenge  = Struct.new(:id, :text, :flag) do
		# Custom creation for this Struct.
		def initialize(id: SecureRandom.uuid, text:, flag:)
      super(id, text, flag)
		end

    def check(given)
      return true if self.flag == given
      false
    end
  end
  
  # A representation of a user in the game.
  #
  # == Example
  #  user = User.new(id: "uniq_id_string_here")
	User = Struct.new(:id, :points, :completed) do
		# Custom creation for this Struct.
		def initialize(id:, points: 0, completed: [])
      raise "A uniq id is required to create a user!" unless id
			super(id, points, completed)
		end

		# Mark the challenge complete for the user.
		def completed_challenge(challenge_id = nil)
	    unless challenge_id.nil?	
        self.completed << challenge_id
      else
        if challenge = self.next_challenge
          self.completed << challenge.id
        end
      end
		end

    # Get the next challenge for the user.
		def next_challenge
			Game.challenges do |challenge|
				return challenge unless self.completed.include?(challenge.id)
			end
			false
		end

    def add_points(ammount)
      self.points += ammount
    end

    def remove_points(ammount)
      self.points -= ammount
    end

		def finnished?
			return false if self.next_challenge
			true
		end
	end
  
  @users      = []
  @challenges = []
  
  def self.users
    return @users unless block_given?
    @users.each do |user|
      yield user
    end
  end

  def self.create_user(id)
    unless user = self.find_user(id)
      @users << Game::User.new(id: id)
    else
      nil
    end
  end

  def self.challenges
    return @challenges unless block_given?
    @challenges.each do |challenge|
      yield challenge 
    end
  end

  def self.create_challenge(text:, flag:)
    @challenges << Challenge.new(text: text, flag: flag)
  end

  def self.find_user(id)
    self.users do |user|
      return user if user.id == id
    end
    nil
  end
  
  def self.find_challenge(id)
    self.challenges do |challenge|
      return challenge if challenge.id == id
    end
    nil
  end

end

HELP = "*Tito CTF*
`Made with ♥ by Kent 'picat' Gruber`

*ABOUT*
>Tito CTF is a Slack Chat Bot based CTF platform. Easily Level up your skills whenever you're in slack! It's a gauntlet style CTF, meaning that you will need to sequentially go through each challenge in order to move on and eventually win!

*COMMANDS*
>`join` Join the game and try to get through all the challenges!
>`joined?` Check if you've joined the game already.
>`challenge` Get the next challenge in the queue to complete.
>`check` Check a given string to see if that's the flag for your current challenge.
>`points` Check how many points you have, if you've joined.
>`help` Show this help menu again.
".freeze

class Bot < SlackRubyBot::Bot
  
  command 'help' do |client, data|
    client.say(text: HELP, channel: data.channel)
  end
  
  command 'join' do |client, data|
    if Game.create_user(data.user)
      client.say(text: "Welcome to the game <@#{data.user}>!", channel: data.channel)
    else
      client.say(text: "You're already in the game <@#{data.user}>!", channel: data.channel)
    end
  end
  
  command 'joined?' do |client, data|
    if Game.find_user(data.user)
      client.say(text: ":white_check_mark: Yup, you've already joined the game <@#{data.user}>!", channel: data.channel)
    else
      client.say(text: "*Sorry*, looks live you haven't joined the game <@#{data.user}>!", channel: data.channel)
    end
  end
  
  command 'points' do |client, data|
    if user = Game.find_user(data.user)
      # easter egg
      if user.points == 0
        user.add_points(10)
        client.say(text: "Don't tell anyone, but I added `10` points to your score <@#{data.user}> because you had `0`!", channel: data.channel)
      else
        client.say(text: "You currently have `#{user.points}` points <@#{data.user}>!", channel: data.channel)
      end
    else
      client.say(text: "*Sorry*, looks live you haven't joined the game <@#{data.user}>!", channel: data.channel)
    end
  end
  
  command 'challenge' do |client, data|
    if user = Game.find_user(data.user)
      client.say(text: "<@#{data.user}> *CHALLENEGE* :crossed_swords: ```#{user.next_challenge.text}```", channel: data.channel)
    else
      client.say(text: "*Sorry*, looks live you haven't joined the game <@#{data.user}>!", channel: data.channel)
    end
  end
  
  command 'check' do |client, data|
    if user = Game.find_user(data.user)
      if challenge = user.next_challenge
        if challenge.check(data.text.split("check").last.strip) # pass
          user.add_points(10)
          user.completed_challenge(challenge.id)
          client.say(text: "<@#{data.user}> :tada: *Good job*, you've earned `10` points!", channel: data.channel)
          if next_challenge = user.next_challenge
            client.say(text: "<@#{data.user}>, here is the next one: ```#{next_challenge.text}```", channel: data.channel)
          else
            client.say(text: "<@#{data.user}> :trophy: *Awesome!* There are no more challenges to complete, you've completed the Tito CTF!", channel: data.channel)
          end
        else # fail
          client.say(text: "<@#{data.user}> :x: *Sorry*, that's not it!", channel: data.channel)
        end
      else
        client.say(text: "<@#{data.user}> There are no more challenges to complete!", channel: data.channel)
      end
    else
      client.say(text: "*Sorry*, looks live you haven't joined the game <@#{data.user}>!", channel: data.channel)
    end
  end
end
