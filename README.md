![Questify!](https://d8g32g7q3zoxw.cloudfront.net/questify_sm.png "Questify!")

# Questify

This is a intended to be a reasonably simple application that will be used to demonstrate various AI and LLM based capabilities in the context of an Elixir/Phoenix app.

The app will be a game will be modeled roughly in the style of a [Choose Your Own Adventure](https://en.wikipedia.org/wiki/Choose_Your_Own_Adventure) book, where the player is given a text prompt and asked to navigate a series of choices that will result in a non-linear story / game.


## Codebase and Context

This game and codebase are part of an article and speaking series, with the initial intention of being small and simple enough to be easily understood over the course of a presentation, but full featured enough to be a realistic use case.

This code base is organized in increasing levels of integration with LLM and AI capabilities, as roughly defined [in this article.](https://medium.com/@byronsalty/the-llm-analogy-f75b0ccc0977)

Redefined here we'll have:
  * Level 0 - Just a working app with no AI / LLM integrations
  * Level 1 - Integration with simple APIs
  * Level 2 - Retrieval Augmented Generation (RAG) architecture
  * Level 3 - Agent-based behaviors

The intention of this code base is to show these various integration levels so it will start out with each level as a separate branch for developers to dig through as part of this article and presentation series.

More information about the associated presentation can be [found here.](https://byronsalty.com/phoenix_llm.html)


## Local Dev

*Because of the use of Postgres as vector database, I highly recommend using docker for your local db with the provided scripts.*

I would also suggest not keeping anything too permanent in the database (don't world build by hand), because you'll likely `reset` the database a few times as you navigate to different branches.


Running a local dev instance:

  * Run `mix setup` to install and setup dependencies
  * Run the dev db with `dev/sh/runDB.sh`
  * Run `mix ecto.setup` to create and seed database.
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4500`](http://localhost:4500) from your browser.


## Learn more about Elixir / Phoenix

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
