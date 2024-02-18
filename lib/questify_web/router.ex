defmodule QuestifyWeb.Router do
  use QuestifyWeb, :router

  import QuestifyWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {QuestifyWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", QuestifyWeb do
    pipe_through :browser

    get "/", PageController, :home

  end

  # Other scopes may use custom stacks.
  # scope "/api", QuestifyWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:questify, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: QuestifyWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", QuestifyWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{QuestifyWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", QuestifyWeb do
    pipe_through [:browser, :require_authenticated_user]



    live_session :require_authenticated_user,
      on_mount: [{QuestifyWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email


      live "/quests", QuestLive.Index, :index
      live "/quests/new", QuestLive.Index, :new
      live "/quests/:id/edit", QuestLive.Index, :edit

      live "/quests/:id", QuestLive.Show, :show
      live "/quests/:id/show/edit", QuestLive.Show, :edit

      # live "/locations", LocationLive.Index, :index
      live "/locations/:quest_id/new", LocationLive.Index, :new
      live "/locations/:quest_id/:id/edit", LocationLive.Index, :edit

      live "/locations/:quest_id/:id", LocationLive.Show, :show
      live "/locations/:quest_id/:id/show/edit", LocationLive.Show, :edit

      # live "/actions", ActionLive.Index, :index
      live "/actions/new", ActionLive.Index, :new
      live "/actions/:id/edit", ActionLive.Index, :edit

      live "/actions/:id", ActionLive.Show, :show
      live "/actions/:id/show/edit", ActionLive.Show, :edit
    end
  end

  scope "/", QuestifyWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{QuestifyWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
