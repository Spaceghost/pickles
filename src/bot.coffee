irc     = require 'irc'
sys     = require 'sys'
env     = process.env

weather = require './weather'
image   = require './image'
github  = require './github'
fortune = require './fortune'
seen    = require './seen'

irc_server   = env.IRC_SERVER
irc_name     = env.IRC_NAME
irc_channels = env.IRC_CHANNELS.split ';'

descriptions = {}
handlers = []
client = null

dispatch = (message) ->
  for pair in handlers
    [ pattern, handler ] = pair
    if message.from isnt irc_name and match = message.match pattern
      message.match = match
      handler message

desc = (phrase, functionality) ->
  descriptions[ phrase ] = functionality

hear = (pattern, callback) ->
  handlers.push [ pattern, callback ]

say = (channels, message) ->
  client.say chan, message for chan in channels

listen = ->
  opts =
    autoRejoin: true
    channels: irc_channels
    debug: true
    realName: irc_name
    userName: irc_name

  client = new irc.Client irc_server, irc_name, opts
  client.addListener 'message', (from, to, message) ->
    dispatch message
    success "#{from} => #{to}: #{message}"
  client.addListener 'error', (message) ->
    error message

success = (message) ->
  console.log "\033[01;32m#{message}\033[0m"

error = (message) ->
  console.log "\033[01;31m#{message}\033[0m"

try
  listen()
  success 'Connected to server'
catch err
  error "Error connecting to server: #{err}"

hear /weather me (.*)/i, (message) ->
  console.log 'weather:ok => heard "weather me"'

#   if wanted = msg.match /weather me (.*)/i
#     seen.setSeenUser from, to
#     location = wanted[1]
#     weather.getWeather location, (err, weather) ->
#       if err or not weather
#         error "weather:error => #{err}"
#         speak to, "Could not find weather for: #{location}"
#       else
#         speak to, "Current: #{weather.current}"
#         speak to, "Today: #{weather.today}"
#         speak to, "Tomorrow: #{weather.tomorrow}"

hear /image me (.*)/i, (message) ->
  console.log 'image:ok => heard "image me"'

#   if wanted = msg.match /image me (.*)/i
#     seen.setSeenUser from, to
#     phrase = wanted[1]
#     image.getImage phrase, (err, img) ->
#       if err or not img
#         error "image:error => #{err}"
#         speak to, "Could not find image for: #{phrase}"
#       else
#         speak to, img

hear /commit me (.*) (.*)/i, (message) ->
  console.log 'commit:ok => heard "commit me"'

#   if wanted = msg.match /commit me (.*) (.*)/i
#     seen.setSeenuser from, to
#     user = wanted[1]
#     proj = wanted[2]
#     github.getLatestCommit user, proj, (err, commit) ->
#       if err or not commit
#         error "github:error => #{err}"
#         speak to, "Could not get latest commit for: #{user}/#{proj}"
#       else
#         speak to, "#{commit.author} commited '#{commit.message}' to #{user}/#{proj} on #{commit.date}"

hear /fortune me/i, (message) ->
  console.log 'fortune:ok => heard "fortune me"'

#   if wanted = msg.match /fortune me/i
#     seen.setSeenUser from, to
#     fortune.getFortune (err, data) ->
#       if err or not data
#         error "fortune:error => #{err}"
#         speak to, "Could not get fortune"
#       else
#         speak to, data

hear /seen (\w+)$/i, (message) ->
  console.log 'seen:ok => heard "seen"'

#   if wanted = msg.match /seen (\w+)$/i
#     seen.setSeenUser from, to
#     user = wanted[1]
#     seen.getSeenUser user, (err, at) ->
#       if err or not at
#         speak to, "#{from}: #{err}"
#       else
#         speak to, "#{from}: #{at}"

hear /roll me/i, (message) ->
  console.log 'roll:ok => heard "roll me"'

#   if wanted = msg.match /roll me/i
#     seen.setSeenUser from, to
#     speak to, "#{from} rolls a six sided die and gets #{Math.floor(Math.random() * 6) + 1}"
