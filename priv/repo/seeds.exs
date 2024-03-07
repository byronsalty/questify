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
alias Questify.Creator

{:ok, cthulu_theme} =
Creator.create_theme(%{
  "name" => "Cthulu",
  "description" => """
  The Cthulhu Mythos is a shared universe of horror fiction, originated by the American writer H.P. Lovecraft in the early 20th century. It encompasses a series of interconnected stories that explore themes of cosmic horror, forbidden knowledge, the insignificance of humanity in the universe, and the existence of ancient, powerful entities. These entities, often referred to as "Old Ones" or "Elder Gods," exist beyond the realm of human understanding and are often depicted as incomprehensibly alien and malevolent.
  """
})

Questify.Creator.chunk_file(cthulu_theme, "dev/books/cthulu.txt")

Creator.create_theme(%{
  "name" => "Vampires",
  "description" => "The vampire fantasy theme embodies a rich tapestry of gothic horror, romance, and the supernatural, captivating audiences with its exploration of immortality, power, and the human condition. Central to this theme are the vampires themselves—mythical beings who subsist by feeding on the life essence (typically in the form of blood) of the living. These creatures often possess supernatural abilities, such as enhanced strength, speed, and the power of seduction, alongside vulnerabilities like sunlight, garlic, or holy symbols. Vampire fiction delves into the moral complexities and existential dilemmas faced by these beings, often focusing on themes of love, redemption, and the eternal struggle between good and evil. Stories range from dark and menacing tales of predatory horror to more nuanced narratives that explore the vampire's struggle with their own nature and the search for meaning in an endless life. Through these narratives, the vampire fantasy theme probes deep philosophical questions, offering a compelling exploration of identity, morality, and the insatiable hunger for connection and survival."
})

Creator.create_theme(%{
  "name" => "Pirates",
  "description" => """
  The pirate fantasy theme captures the allure of freedom, adventure, and the high seas, weaving tales of daring escapades, treasure hunts, and swashbuckling action. Central to this theme are the pirates themselves—rebellious outlaws and seafarers who operate outside the bounds of society, often motivated by the pursuit of wealth, exploration, or simply the love of adventure. These stories are set in a world of wooden ships and vast oceans, where hidden islands, mysterious artifacts, and the promise of undiscovered riches lie just over the horizon. Pirate narratives frequently explore themes of loyalty, betrayal, and the quest for independence, pitting their charismatic and morally complex characters against the forces of the established order, be it the navy, rival pirates, or supernatural threats. The pirate fantasy genre is rich with iconic elements such as treasure maps marked with an "X," parrots on shoulders, eye patches, and the Jolly Roger flag, creating a romanticized yet perilous world that captivates the imagination. Through tales of camaraderie, rebellion, and adventure on the high seas, the pirate theme offers a thrilling escape into a world where freedom reigns and fortune awaits the bold.
  """
})

{:ok, punk_theme} =
Creator.create_theme(%{
  "name" => "Cyberpunk",
  "description" => "
  The cyberpunk theme immerses audiences in a dystopian future characterized by advanced technology, cybernetic enhancements, sprawling urban landscapes, and profound social divides. At its core, cyberpunk explores the fusion of man and machine, the impact of high-tech societies on human interaction, and the consequences of corporate dominance in an increasingly digital world. This genre often features protagonists who are hackers, rebels, or outcasts, navigating a world where information is power and technology is both a tool for liberation and a means of oppression. Cyberpunk settings are marked by neon-lit streets, towering skyscrapers, and a pervasive sense of decay, illustrating a stark contrast between the gleaming promises of technology and the grim realities of life in the underbelly of futuristic megacities. Themes of identity, privacy, and autonomy run deep, as characters grapple with artificial intelligence, virtual reality, and the blurring lines between physical and digital existence. Through gritty narratives filled with anti-heroes, mega-corporations, and cybernetic enhancements, cyberpunk offers a critical look at the potential future of human society, emphasizing the importance of maintaining one's humanity in the face of overwhelming technological advancement and societal fragmentation."
})

Questify.Creator.chunk_file(punk_theme, "dev/books/triplanet.txt")

{:ok, epic_theme}  = Creator.create_theme(%{
  "name" => "Epic",
  "description" => "This genre is defined by its expansive settings, often encompassing entire continents or realms where diverse races such as elves, dwarves, humans, and orcs coexist alongside dragons, wizards, and other fantastical beings. The narratives typically center around epic quests or battles between good and evil, with characters embarking on journeys that test their bravery, resolve, and morality. Magic plays a central role, not just as a tool for combat, but as a means to shape the world, forge alliances, and unravel mysteries that span centuries."
})



{:ok, test_user} =
  Accounts.register_user(%{
    "email" => "test@test.com",
    "password" => "testtesttest"
  })

{:ok, hello_quest} =
  Games.create_quest(%{
    "name" => "Hello World",
    "slug" => "hello",
    "img_url" => "https://d8g32g7q3zoxw.cloudfront.net/hello_world.webp",
    "description" => """
    A simple game to test out game mechanics. You find yourself alone in a beautiful mansion during a summer party, but something sinister lurks nearby. Can you resist the temptation?
    """,
    "creator_id" => test_user.id,
    "theme_id" => cthulu_theme.id
  })

Games.create_lore_action(hello_quest)
Games.create_trailblaze_action(hello_quest)

{:ok, hello_location_lobby} =
  Games.create_location(%{
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

{:ok, hello_location_pool} =
  Games.create_location(%{
    "name" => "Pool",
    "description" => """
    The backyard is beautiful and everyone is having fun at the party!
    """,
    "img_url" => "https://d8g32g7q3zoxw.cloudfront.net/hello_pool_party.png",
    "is_terminal" => true,
    "quest_id" => hello_quest.id
  })

{:ok, hello_location_basement} =
  Games.create_location(%{
    "name" => "Basement",
    "description" => """
    The staircase leads down, down, down... whoever dug this basement seems to have delved too deep.
    You encounter a Balrog and perish.
    """,
    "img_url" => "https://d8g32g7q3zoxw.cloudfront.net/hello_basement.png",
    "is_terminal" => true,
    "quest_id" => hello_quest.id
  })

{:ok, hello_action_1} =
  Games.create_action(%{
    "command" => "Go to the backyard",
    "description" => """
    You walk through the back doors toward the backyard.
    """,
    "quest_id" => hello_quest.id,
    "from_id" => hello_location_lobby.id,
    "to_id" => hello_location_pool.id
  })

{:ok, hello_action_2} =
  Games.create_action(%{
    "command" => "Investigate the room",
    "description" => """
    You see a handwritten note scrawled on the wall that says 'Beware of the basement'
    """,
    "quest_id" => hello_quest.id,
    "from_id" => hello_location_lobby.id,
    "to_id" => hello_location_lobby.id
  })

{:ok, hello_action_3} =
  Games.create_action(%{
    "command" => "Take the stairs going downward",
    "description" => """
    You walk onto the first step going downward, then another, and another...
    """,
    "quest_id" => hello_quest.id,
    "from_id" => hello_location_lobby.id,
    "to_id" => hello_location_basement.id
  })



{:ok, punk_quest} =
  Games.create_quest(%{
    "name" => "Cyberpunk Redemption",
    "slug" => "punk",
    "img_url" => "https://d8g32g7q3zoxw.cloudfront.net/cyberpunk.webp",
    "description" => """
    In the sprawling metropolis of Neo-City, a place where futuristic technology and cybernetic enhancements meet a society riddled with corruption, inequality, and underground rebellion. You are Alex Mercer, a former corporate security officer turned freelance hacker and mercenary, navigating a path of moral ambiguity in search of redemption.
    """,
    "creator_id" => test_user.id,
    "theme_id" => punk_theme.id
  })

Games.create_lore_action(punk_quest)
Games.create_trailblaze_action(punk_quest)

Games.create_location(%{
  "name" => "Police Precinct",
  "description" => """
  The precinct is a hub of high-tech policing, equipped with state-of-the-art forensic labs, interrogation rooms featuring lie detection software, and a centralized command center monitoring the city's safety through a network of cameras and AI algorithms.

  The atmosphere inside the precinct is tense, as officers balance the thin line between upholding the law and bending under the weight of corporate influence. Players can interact with various NPC characters, from grizzled veterans to idealistic rookies, each offering insights into the precinct's operations and the moral dilemmas faced by those within the law enforcement system.
  """,
  "is_terminal" => false,
  "is_starting" => true,
  "quest_id" => punk_quest.id
})


Code.eval_file("priv/repo/game_seeds/echo_cavern.exs")
