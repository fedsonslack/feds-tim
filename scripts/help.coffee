# Description:
#   Generates help commands for Hubot.
#
# Commands:
#   hubot help - Displays all of the help commands that Hubot knows about.
#   hubot help <query> - Displays all help commands that match <query>.
#
# URLS:
#   /hubot/help
#
# Notes:
#   These commands are grabbed from comment blocks at the top of each file.

helpContents = (name, commands) ->

  """
<html>
  <head>
  <title>#{name} Help</title>
  <style type="text/css">
    body {
      background: #d3d6d9;
      color: #636c75;
      text-shadow: 0 1px 1px rgba(255, 255, 255, .5);
      font-family: Helvetica, Arial, sans-serif;
    }
    h1 {
      margin: 8px 0;
      padding: 0;
    }
    .commands {
      font-size: 15px;
      width: 800px;
      margin: 0 auto;
      font-family: monospace;
    }
    .full_command {
      padding: 10px;
      border-top: 1px solid #BEBEBE;
    }
    .result{
      opacity: 0.5;
      font-size: 13px;
    }
.result::before {
      content: "> ";
    }
    p {
      border-bottom: 1px solid #eee;
      margin: 6px 0 0 0;
      padding-bottom: 5px;
    }
    p:last-child {
      border: 0;
    }
  </style>
  </head>
  <body>
    <h1>#{name} Help</h1>
    <div class="commands">
      #{commands}
    </div>
  </body>
</html>
  """

module.exports = (robot) ->
  robot.respond /help\s*(.*)?$/i, (msg) ->
    cmds = robot.helpCommands()
    filter = msg.match[1]

    if filter
      cmds = cmds.filter (cmd) ->
        cmd.match new RegExp(filter, 'i')
      if cmds.length == 0
        msg.send "No available commands match #{filter}"
        return

    prefix = robot.alias or robot.name
    cmds = cmds.map (cmd) ->
      cmd = cmd.replace /^hubot/, prefix
      cmd.replace /hubot/ig, "#{robot.name}"

    emit = cmds.join "\n"

    msg.send 'Visit https://feds-tim.herokuapp.com/tim/help'

  robot.router.get "/#{robot.name}/help", (req, res) ->
    cmds = robot.helpCommands().map (cmd) ->
      cmd = htmlEncode(cmd)
      cmd_arr = cmd.split (' - ')
      cmd_arr[0] = "<div class=\"command\">#{cmd_arr[0]}</div>"
      cmd_arr[1] = "<div class=\"result\">#{cmd_arr[1]}</div>"
      return cmd_arr.join('\n')


    emit = "<div class='full_command'>#{cmds.join('</div><div class=\'full_command\'>')}</div>"

    emit = emit.replace /hubot/ig, "<span class=\"name\">@#{robot.name}</span>"

    res.setHeader 'content-type', 'text/html'
    res.end helpContents robot.name, emit


htmlEncode = (str) ->
  str.replace /[&<>"']/g, ($0) ->
    "&" + {"&":"amp", "<":"lt", ">":"gt", '"':"quot", "'":"#39"}[$0] + ";"