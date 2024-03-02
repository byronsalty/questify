# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Questify.Repo.insert!(%Questify.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.



alias Questify.Accounts
alias Questify.Games

{:ok, test_user} = Accounts.register_user(%{
  "email" => "test@test.com",
  "password" => "testtesttest"
})

{:ok, hello_quest} = Games.create_quest(%{
  "name" => "Hello World",
  "slug" => "hello",
  "img_url" => "https://d8g32g7q3zoxw.cloudfront.net/hello_world.webp",
  "description" => """
  A simple game to test out game mechanics. You find yourself alone in a beautiful mansion during a summer party, but something sinister lurks nearby. Can you resist the temptation?
  """,
  "creator_id" => test_user.id
})

Games.create_lore_action(hello_quest)
Games.create_trailblaze_action(hello_quest)

{:ok, hello_location_lobby} = Games.create_location(%{
  "name" => "Lobby",
  "description" => """
  You are in a opulent mansion and you want to get to the pool to attend a party.
  You see a glass backdoor to go outside in the backyard. You also see a dark creepy staircase going downward.
  """,
  "img_url" => "https://d8g32g7q3zoxw.cloudfront.net/hello_lobby.png",
  "is_terminal" => false,
  "is_starting" => true,
  "quest_id" => hello_quest.id
})

{:ok, hello_location_pool} = Games.create_location(%{
  "name" => "Pool",
  "description" => """
  The backyard is beautiful and everyone is having fun at the party!
  """,
  "img_url" => "https://d8g32g7q3zoxw.cloudfront.net/hello_pool_party.png",
  "is_terminal" => true,
  "quest_id" => hello_quest.id
})

{:ok, hello_location_basement} = Games.create_location(%{
  "name" => "Basement",
  "description" => """
  The staircase leads down, down, down... whoever dug this basement seems to have delved too deep.
  You encounter a Balrog and perish.
  """,
  "img_url" => "https://d8g32g7q3zoxw.cloudfront.net/hello_basement.png",
  "is_terminal" => true,
  "quest_id" => hello_quest.id
})

{:ok, hello_action_1} = Games.create_action(%{
  "command" => "Go to the backyard",
  "description" => """
  You walk through the back doors toward the backyard.
  """,
  "quest_id" => hello_quest.id,
  "from_id" => hello_location_lobby.id,
  "to_id" => hello_location_pool.id
})

{:ok, hello_action_2} = Games.create_action(%{
  "command" => "Investigate the room",
  "description" => """
  You see a handwritten note scrawled on the wall that says 'Beware of the basement'
  """,
  "quest_id" => hello_quest.id,
  "from_id" => hello_location_lobby.id,
  "to_id" => hello_location_lobby.id
})

{:ok, hello_action_3} = Games.create_action(%{
  "command" => "Take the stairs going downward",
  "description" => """
  You walk onto the first step going downward, then another, and another...
  """,
  "quest_id" => hello_quest.id,
  "from_id" => hello_location_lobby.id,
  "to_id" => hello_location_basement.id
})



Code.eval_file("priv/repo/game_seeds/echo_cavern.exs")
