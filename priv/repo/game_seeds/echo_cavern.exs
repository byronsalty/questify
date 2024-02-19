
alias Questify.Accounts
alias Questify.Games

test_user = Accounts.get_user_by_email("test@test.com")

{:ok, echo} = Games.create_quest(%{
  "name" => "The Secrets of Echo Cavern",
  "slug" => "echo",
  "img_url" => "https://d8g32g7q3zoxw.cloudfront.net/echo_cavern.webp",
  "description" => """
  In the small, seemingly quiet town of Echo Ridge, nestled between dense forests and shadowy hills, lies the mysterious Echo Cavern. Legends speak of ancient treasures and unspeakable horrors lurking within its depths. Recently, a series of strange disappearances have reignited interest and fear of the cavern's rumored curse.
  """,
  "creator_id" => test_user.id
})

{:ok, house} = Games.create_location(%{
  "name" => "Alex's House",
  "description" => """
  You stand in the comforting clutter of Alex's home, a testament to generations of adventurers. Maps pepper the walls, each a story of journeys past, while shelves overflow with books and artifacts, collected not for their value but for their tales. The morning light filters through the window, casting a warm glow over the preparations for yet another venture into the unknown.
  """,
  "img_url" => "https://d8g32g7q3zoxw.cloudfront.net/alex_home.webp",
  "is_terminal" => false,
  "is_starting" => true,
  "quest_id" => echo.id
})

{:ok, town_square} = Games.create_location(%{
  "name" => "Echo Ridge Town Square",
  "description" => """
  The town square buzzes with the everyday chatter of Echo Ridge's residents. Cobbled streets lead to various stalls, where vendors hawk their wares, from fresh produce to curious trinkets. Overheard, conversations swirl with rumors and tales of the cavern, each adding layers to the mystery. The town's clock tower stands sentinel, marking the passage of time and the urgency of your quest.
  """,
  "img_url" => "https://d8g32g7q3zoxw.cloudfront.net/town_square.webp",
  "is_terminal" => false,
  "quest_id" => echo.id
})

{:ok, library} = Games.create_location(%{
  "name" => "Old Echo Library",
  "description" => """
  Dust motes dance in the beams of light that pierce the shadowy silence of the Old Echo Library. Rows of ancient shelves groan under the weight of time-worn tomes and scrolls, their secrets guarded by the soft whisper of turning pages. Here, the past speaks, offering clues and knowledge to those brave enough to delve into its depths.
  """,
  "img_url" => "https://d8g32g7q3zoxw.cloudfront.net/library.webp",
  "is_terminal" => false,
  "quest_id" => echo.id
})

{:ok, woods} = Games.create_location(%{
  "name" => "The Whispering Woods",
  "description" => """
  Entering the Whispering Woods, the canopy closes above you, plunging the path into a twilight realm. Leaves rustle and branches sway, as if whispering the secrets of those who passed before. Shadows flit between trees, hinting at unseen watchers. Every step forward is a step into the lore that shrouds this place, a test of courage against the creeping fog of mystery.
  """,
  "img_url" => "https://d8g32g7q3zoxw.cloudfront.net/woods.webp",
  "is_terminal" => false,
  "quest_id" => echo.id
})

{:ok, mine} = Games.create_location(%{
  "name" => "The Abandoned Mine Entrance",
  "description" => """
  Before you yawns the dark maw of the abandoned mine, its entrance framed by timeworn beams and scattered debris. A chill wind sighs from within, as if exhaling the mine's forgotten stories. Danger lurks in the silent tunnels that stretch into the earth, promising not just hidden passages to the cavern but puzzles and perils left by those who once sought its secrets. You hear dripping straight ahead and see a left branch that is unknown.
  """,
  "img_url" => "https://d8g32g7q3zoxw.cloudfront.net/mine.webp",
  "is_terminal" => false,
  "quest_id" => echo.id
})

{:ok, lake} = Games.create_location(%{
  "name" => "The Crystal Lake",
  "description" => """
  Beneath the earth lies the Crystal Lake, a serene expanse of water reflecting the ethereal glow of bioluminescent algae and gem-like crystals. The beauty is mesmerizing, a tranquil oasis that belies the danger of its guardian. Here, the dance of light and shadow plays across the surface, hinting at depths filled with both wonder and warning.
  """,
  "img_url" => "https://d8g32g7q3zoxw.cloudfront.net/crystal_lake.webp",
  "is_terminal" => false,
  "quest_id" => echo.id
})

{:ok, chamber} = Games.create_location(%{
  "name" => "The Guardian's Chamber",
  "description" => """
  Deep within the heart of the cavern, the Guardian's Chamber unveils itself as a sanctum of ancient power. Pillars carved with forgotten runes hold aloft a ceiling lost to shadow, centering on the figure of the guardian spirit. Its presence is both awe-inspiring and humbling, a direct connection to the cavern's ancient mysteries and the pivotal moment of your journey.
  """,
  "img_url" => "https://d8g32g7q3zoxw.cloudfront.net/chamber.webp",
  "is_terminal" => true,
  "quest_id" => echo.id
})
{:ok, vault} = Games.create_location(%{
  "name" => "The Vault",
  "description" => """
  With a rumble that echoes through the cavern's depths, a section of the wall slides away, revealing the gleam of untold riches beyond. The Treasure Vault lies before you, just as the legends described. the Treasure Vault emerges as a testament to the cavern's history. Gold and jewels are dwarfed by the true treasure of knowledge and artifacts, each piece a chapter in the cavern's story. The air is thick with the weight of discovery, heavy with the promise of secrets unveiled.
  """,
  "img_url" => "https://d8g32g7q3zoxw.cloudfront.net/vault.webp",
  "is_terminal" => true,
  "quest_id" => echo.id
})
{:ok, hollow} = Games.create_location(%{
  "name" => "The Cursed Hollow",
  "description" => """
  The Cursed Hollow broods with a palpable darkness, an area of the cavern where the air thickens and shadows cling a little too closely. Here, the curse makes its presence known, a malevolent force that twists the very stone and air against you. It's a place of desperation, where the echoes of your footsteps mingle with the whispers of the past, urging haste in finding a salvation that seems ever out of reach.
  """,
  "img_url" => "https://d8g32g7q3zoxw.cloudfront.net/hollow.webp",
  "is_terminal" => true,
  "quest_id" => echo.id
})
{:ok, labyrinth} = Games.create_location(%{
  "name" => "The Labyrinth Tunnels",
  "description" => """
  The Labyrinth Tunnels present a confounding maze, its passages winding in an endless tease of freedom. Walls of rough-hewn stone close in, promising pathways that lead only to further puzzles. The dim light is a scant guide through the twists and turns, where each choice feels like a gamble against fate. Here, the cavern challenges your resolve, testing your wit and will to emerge into the light once more.
  """,
  "img_url" => "https://d8g32g7q3zoxw.cloudfront.net/labyrinth.webp",
  "is_terminal" => true,
  "quest_id" => echo.id
})

Games.create_action(%{
  "command" => "Investigate Desk",
  "description" => """
  You find notes on local legends and a sturdy flashlight, essential for dark places. You see an old map of the Woods and a hidden path to the Mine.
  """,
  "quest_id" => echo.id,
  "from_id" => house.id,
  "to_id" => house.id
})
Games.create_action(%{
  "command" => "Gather supplies",
  "description" => """
  You pack a backpack with water, food, and a first-aid kit, ready for anything.
  """,
  "quest_id" => echo.id,
  "from_id" => house.id,
  "to_id" => house.id
})
Games.create_action(%{
  "command" => "Leave Home",
  "description" => """
  Stepping out, you feel a mix of excitement and nervousness about the adventure ahead.
  """,
  "quest_id" => echo.id,
  "from_id" => house.id,
  "to_id" => town_square.id
})
Games.create_action(%{
  "command" => "Talk to Townsfolk",
  "description" => """
  You hear whispers of shadows moving in the cavern and warnings to stay away. The cavern entrance lies at the back of an old abandoned Mine hidden in the Woods.
  """,
  "quest_id" => echo.id,
  "from_id" => town_square.id,
  "to_id" => town_square.id
})
Games.create_action(%{
  "command" => "Purchase Supplies",
  "description" => """
  With a map and lantern now in hand, you feel better prepared for dark, winding paths.
  """,
  "quest_id" => echo.id,
  "from_id" => town_square.id,
  "to_id" => town_square.id
})
Games.create_action(%{
  "command" => "Research at Notice Board",
  "description" => """
  A posted article mentions recent disappearances linked to the cavern's depths, along with warnings to avoid the Old Mine at all costs.
  """,
  "quest_id" => echo.id,
  "from_id" => town_square.id,
  "to_id" => town_square.id
})
Games.create_action(%{
  "command" => "Head to Library",
  "description" => """
  You decide the library's ancient texts might hold clues to the cavern's secrets.
  """,
  "quest_id" => echo.id,
  "from_id" => town_square.id,
  "to_id" => library.id
})
Games.create_action(%{
  "command" => "Enter the Woods",
  "description" => """
  The dense trees of the Whispering Woods loom before you, promising mystery and danger.
  """,
  "quest_id" => echo.id,
  "from_id" => town_square.id,
  "to_id" => woods.id
})
Games.create_action(%{
  "command" => "Search Ancient Texts",
  "description" => """
  You uncover tales of a guardian spirit and a treasure hidden deep within the cavern.
  """,
  "quest_id" => echo.id,
  "from_id" => library.id,
  "to_id" => library.id
})
Games.create_action(%{
  "command" => "Ask Librarian",
  "description" => """
  The librarian shares rumors of hidden entrances in the old Mine and cautions about the cavern's curse.
  """,
  "quest_id" => echo.id,
  "from_id" => library.id,
  "to_id" => library.id
})
Games.create_action(%{
  "command" => "Decipher Old Scrolls",
  "description" => """
  A scroll reveals a cryptic reference to 'light guiding the worthy through darkness.
  """,
  "quest_id" => echo.id,
  "from_id" => library.id,
  "to_id" => library.id
})
Games.create_action(%{
  "command" => "Return to Town Square",
  "description" => """
  Knowledge richer, you head back, pondering the clues unearthed in the silence of the library.
  """,
  "quest_id" => echo.id,
  "from_id" => library.id,
  "to_id" => town_square.id
})
Games.create_action(%{
  "command" => "Head to Woods",
  "description" => """
  The dense trees of the Whispering Woods loom before you, promising mystery and danger.
  """,
  "quest_id" => echo.id,
  "from_id" => library.id,
  "to_id" => woods.id
})
Games.create_action(%{
  "command" => "Follow the Path",
  "description" => """
  The path twists, turns, and forks, each step taking you deeper into the forest's heart.
  """,
  "quest_id" => echo.id,
  "from_id" => woods.id,
  "to_id" => woods.id
})
Games.create_action(%{
  "command" => "Investigate Strange Sounds",
  "description" => """
  Following the sounds, you find a hidden glen, bathed in moonlight and mystery. The beauty of the scene before you turns to horror as hundreds of hungry eyes in the shadow surround you.
  """,
  "quest_id" => echo.id,
  "from_id" => woods.id,
  "to_id" => hollow.id
})
Games.create_action(%{
  "command" => "Camp",
  "description" => """
  A night under the stars gives you time to plan your next moves and gather your strength.
  """,
  "quest_id" => echo.id,
  "from_id" => woods.id,
  "to_id" => woods.id
})
Games.create_action(%{
  "command" => "Find a Mine Entrance",
  "description" => """
  A hidden path leads you to the old mine entrance, a silent gateway to the unknown.
  """,
  "quest_id" => echo.id,
  "from_id" => woods.id,
  "to_id" => mine.id
})
Games.create_action(%{
  "command" => "Return to Town",
  "description" => """
  Feeling the need for more preparation, you trace your steps back to the safety of Echo Ridge.
  """,
  "quest_id" => echo.id,
  "from_id" => woods.id,
  "to_id" => town_square.id
})
Games.create_action(%{
  "command" => "Enter Mine",
  "description" => """
  The air cools as you step into the mine, the darkness swallowing the light of the entrance behind you.
  """,
  "quest_id" => echo.id,
  "from_id" => mine.id,
  "to_id" => mine.id
})
Games.create_action(%{
  "command" => "Inspect Old Equipment",
  "description" => """
  Among the debris, you find a rope and pickaxe, remnants of the mine's working days. You find an old map and old lantern amongst the refuse.
  """,
  "quest_id" => echo.id,
  "from_id" => mine.id,
  "to_id" => mine.id
})
Games.create_action(%{
  "command" => "Use the Map",
  "description" => """
  The map reveals hidden passages not taken by many. With your well provisioned pack, lights and ropes you follow the hidden passages all the way to the vault.
  """,
  "quest_id" => echo.id,
  "from_id" => mine.id,
  "to_id" => labyrinth.id
})
Games.create_action(%{
  "command" => "Straight ahead to the Lake",
  "description" => """
  Navigating carefully, you avoid pitfalls and find yourself at the edge of an underground lake.
  """,
  "quest_id" => echo.id,
  "from_id" => mine.id,
  "to_id" => lake.id
})
Games.create_action(%{
  "command" => "Explore to the branch to the left",
  "description" => """
  You walk forward and the passage way is surprisingly clean and well kept, unlike before you can walk easily as you follow the first turn, then the next. You turn Right around a corner, then another. Or was it Left?
  """,
  "quest_id" => echo.id,
  "from_id" => mine.id,
  "to_id" => labyrinth.id
})
Games.create_action(%{
  "command" => "Explore to the branch to the left",
  "description" => """
  You walk forward and the passage way is surprisingly clean and well kept, unlike before you can walk easily as you follow the first turn, then the next. You turn Right around a corner, then another. Or was it Left?
  """,
  "quest_id" => echo.id,
  "from_id" => mine.id,
  "to_id" => labyrinth.id
})
Games.create_action(%{
  "command" => "Follow the faint eerie light",
  "description" => """
  After following the mysterious light at The Crystal Lake and discovering the concealed entrance, you find ancient markings that speak of a guardian. By respecting the cavern's history and solving the lore puzzle, a hidden path opens, leading you directly to The Guardian's Chamber.
  """,
  "quest_id" => echo.id,
  "from_id" => lake.id,
  "to_id" => chamber.id
})
Games.create_action(%{
  "command" => "Dive deep into the water",
  "description" => """
  The water's chill embraces you as you dive, following the tunnel's winding path. But when you emerge, gasping for air, you find yourself in a maze of shadows, each turn as perplexing as the last. The Labyrinth Tunnels ensnare you.
  """,
  "quest_id" => echo.id,
  "from_id" => lake.id,
  "to_id" => labyrinth.id
})
Games.create_action(%{
  "command" => "Swim across the shallows",
  "description" => """
  Braving the cold waters, you discover an underwater cave, promising yet another secret passage.
  """,
  "quest_id" => echo.id,
  "from_id" => lake.id,
  "to_id" => vault.id
})
Games.create_action(%{
  "command" => "Use the small boat",
  "description" => """
  Braving the cold waters, you discover an underwater cave, promising yet another secret passage.
  """,
  "quest_id" => echo.id,
  "from_id" => lake.id,
  "to_id" => vault.id
})
Games.create_action(%{
  "command" => "Search the shoreline",
  "description" => """
  Hidden behind a large bolder, nearly completely out of sight you find a small boat - just large enough for you and your pack
  """,
  "quest_id" => echo.id,
  "from_id" => lake.id,
  "to_id" => lake.id
})
