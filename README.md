# Questify

This is a intended to be a reasonably simple application that will be used to demonstrate various AI and LLM based capabilities in the context of an Elixir/Phoenix app.

The app will be a game will be modeled roughly in the style of a [Choose Your Own Adventure](https://en.wikipedia.org/wiki/Choose_Your_Own_Adventure) book, where the player is given a text prompt and asked to navigate a series of choices that will result in a non-linear story / game.


## Local Dev

Running a local dev instance:

  * Run `mix setup` to install and setup dependencies
  * Run the dev db with `dev/sh/runDB.sh`
  * Run `mix ecto.setup` to create and seed database.
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4500`](http://localhost:4500) from your browser.

## Prompting an Adventure

Here are some prompts used to create a story:

```
User
Help me write an interesting Choose Your Own Adventure story. Let's start with an overall plot, two different possible positive outcomes and two different possible negative outcomes.

Ok. Given that plot and possible outcomes, we are going to create the world of this story. This is for a game which is based on various locations that the player can explore and learn more. Can you tell me 10 locations involved in this story? One of them should be the starting location and each final outcome should have a location associated as well.

User
These are great. Could you give a description for each in the style of a book where you are telling the reader what they are seeing?

Create now could you define a set of commands/actions that would be available at each location and which location they would take you to? (We don't need any for the Outcome locations)

These are great. The format that I need is a Description (what the person learns if they are talking or investigating, or seeing if they move) 
```

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
