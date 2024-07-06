defmodule Hello.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Hello.Repo

  alias Hello.Accounts.{Users, UsersToken, UsersNotifier}

  ## Database getters

  @doc """
  Gets a users by email.

  ## Examples

      iex> get_users_by_email("foo@example.com")
      %Users{}

      iex> get_users_by_email("unknown@example.com")
      nil

  """
  def get_users_by_email(email) when is_binary(email) do
    Repo.get_by(Users, email: email)
  end

  @doc """
  Gets a users by email and password.

  ## Examples

      iex> get_users_by_email_and_password("foo@example.com", "correct_password")
      %Users{}

      iex> get_users_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_users_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    users = Repo.get_by(Users, email: email)
    if Users.valid_password?(users, password), do: users
  end

  @doc """
  Gets a single users.

  Raises `Ecto.NoResultsError` if the Users does not exist.

  ## Examples

      iex> get_users!(123)
      %Users{}

      iex> get_users!(456)
      ** (Ecto.NoResultsError)

  """
  def get_users!(id), do: Repo.get!(Users, id)

  ## Users registration

  @doc """
  Registers a users.

  ## Examples

      iex> register_users(%{field: value})
      {:ok, %Users{}}

      iex> register_users(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_users(attrs) do
    %Users{}
    |> Users.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking users changes.

  ## Examples

      iex> change_users_registration(users)
      %Ecto.Changeset{data: %Users{}}

  """
  def change_users_registration(%Users{} = users, attrs \\ %{}) do
    Users.registration_changeset(users, attrs, hash_password: false, validate_email: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the users email.

  ## Examples

      iex> change_users_email(users)
      %Ecto.Changeset{data: %Users{}}

  """
  def change_users_email(users, attrs \\ %{}) do
    Users.email_changeset(users, attrs, validate_email: false)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_users_email(users, "valid password", %{email: ...})
      {:ok, %Users{}}

      iex> apply_users_email(users, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_users_email(users, password, attrs) do
    users
    |> Users.email_changeset(attrs)
    |> Users.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the users email using the given token.

  If the token matches, the users email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_users_email(users, token) do
    context = "change:#{users.email}"

    with {:ok, query} <- UsersToken.verify_change_email_token_query(token, context),
         %UsersToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(users_email_multi(users, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp users_email_multi(users, email, context) do
    changeset =
      users
      |> Users.email_changeset(%{email: email})
      |> Users.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:users, changeset)
    |> Ecto.Multi.delete_all(:tokens, UsersToken.by_users_and_contexts_query(users, [context]))
  end

  @doc ~S"""
  Delivers the update email instructions to the given users.

  ## Examples

      iex> deliver_users_update_email_instructions(users, current_email, &url(~p"/users/settings/confirm_email/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_users_update_email_instructions(%Users{} = users, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, users_token} = UsersToken.build_email_token(users, "change:#{current_email}")

    Repo.insert!(users_token)
    UsersNotifier.deliver_update_email_instructions(users, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the users password.

  ## Examples

      iex> change_users_password(users)
      %Ecto.Changeset{data: %Users{}}

  """
  def change_users_password(users, attrs \\ %{}) do
    Users.password_changeset(users, attrs, hash_password: false)
  end

  @doc """
  Updates the users password.

  ## Examples

      iex> update_users_password(users, "valid password", %{password: ...})
      {:ok, %Users{}}

      iex> update_users_password(users, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_users_password(users, password, attrs) do
    changeset =
      users
      |> Users.password_changeset(attrs)
      |> Users.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:users, changeset)
    |> Ecto.Multi.delete_all(:tokens, UsersToken.by_users_and_contexts_query(users, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{users: users}} -> {:ok, users}
      {:error, :users, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_users_session_token(users) do
    {token, users_token} = UsersToken.build_session_token(users)
    Repo.insert!(users_token)
    token
  end

  @doc """
  Gets the users with the given signed token.
  """
  def get_users_by_session_token(token) do
    {:ok, query} = UsersToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_users_session_token(token) do
    Repo.delete_all(UsersToken.by_token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc ~S"""
  Delivers the confirmation email instructions to the given users.

  ## Examples

      iex> deliver_users_confirmation_instructions(users, &url(~p"/users/confirm/#{&1}"))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_users_confirmation_instructions(confirmed_users, &url(~p"/users/confirm/#{&1}"))
      {:error, :already_confirmed}

  """
  def deliver_users_confirmation_instructions(%Users{} = users, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if users.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, users_token} = UsersToken.build_email_token(users, "confirm")
      Repo.insert!(users_token)
      UsersNotifier.deliver_confirmation_instructions(users, confirmation_url_fun.(encoded_token))
    end
  end

  @doc """
  Confirms a users by the given token.

  If the token matches, the users account is marked as confirmed
  and the token is deleted.
  """
  def confirm_users(token) do
    with {:ok, query} <- UsersToken.verify_email_token_query(token, "confirm"),
         %Users{} = users <- Repo.one(query),
         {:ok, %{users: users}} <- Repo.transaction(confirm_users_multi(users)) do
      {:ok, users}
    else
      _ -> :error
    end
  end

  defp confirm_users_multi(users) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:users, Users.confirm_changeset(users))
    |> Ecto.Multi.delete_all(:tokens, UsersToken.by_users_and_contexts_query(users, ["confirm"]))
  end

  ## Reset password

  @doc ~S"""
  Delivers the reset password email to the given users.

  ## Examples

      iex> deliver_users_reset_password_instructions(users, &url(~p"/users/reset_password/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_users_reset_password_instructions(%Users{} = users, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, users_token} = UsersToken.build_email_token(users, "reset_password")
    Repo.insert!(users_token)
    UsersNotifier.deliver_reset_password_instructions(users, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the users by reset password token.

  ## Examples

      iex> get_users_by_reset_password_token("validtoken")
      %Users{}

      iex> get_users_by_reset_password_token("invalidtoken")
      nil

  """
  def get_users_by_reset_password_token(token) do
    with {:ok, query} <- UsersToken.verify_email_token_query(token, "reset_password"),
         %Users{} = users <- Repo.one(query) do
      users
    else
      _ -> nil
    end
  end

  @doc """
  Resets the users password.

  ## Examples

      iex> reset_users_password(users, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %Users{}}

      iex> reset_users_password(users, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_users_password(users, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:users, Users.password_changeset(users, attrs))
    |> Ecto.Multi.delete_all(:tokens, UsersToken.by_users_and_contexts_query(users, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{users: users}} -> {:ok, users}
      {:error, :users, changeset, _} -> {:error, changeset}
    end
  end

  alias Hello.Accounts.{User, UserToken, UserNotifier}

  ## Database getters

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Gets a user by email and password.

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password), do: user
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false, validate_email: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.

  ## Examples

      iex> change_user_email(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_email(user, attrs \\ %{}) do
    User.email_changeset(user, attrs, validate_email: false)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_user_email(user, "valid password", %{email: ...})
      {:ok, %User{}}

      iex> apply_user_email(user, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_user_email(user, password, attrs) do
    user
    |> User.email_changeset(attrs)
    |> User.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_user_email(user, token) do
    context = "change:#{user.email}"

    with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
         %UserToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(user_email_multi(user, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp user_email_multi(user, email, context) do
    changeset =
      user
      |> User.email_changeset(%{email: email})
      |> User.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, [context]))
  end

  @doc ~S"""
  Delivers the update email instructions to the given user.

  ## Examples

      iex> deliver_user_update_email_instructions(user, current_email, &url(~p"/users/settings/confirm_email/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)
    UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.

  ## Examples

      iex> change_user_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_password(user, attrs \\ %{}) do
    User.password_changeset(user, attrs, hash_password: false)
  end

  @doc """
  Updates the user password.

  ## Examples

      iex> update_user_password(user, "valid password", %{password: ...})
      {:ok, %User{}}

      iex> update_user_password(user, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_password(user, password, attrs) do
    changeset =
      user
      |> User.password_changeset(attrs)
      |> User.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_user_session_token(token) do
    Repo.delete_all(UserToken.by_token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc ~S"""
  Delivers the confirmation email instructions to the given user.

  ## Examples

      iex> deliver_user_confirmation_instructions(user, &url(~p"/users/confirm/#{&1}"))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_user_confirmation_instructions(confirmed_user, &url(~p"/users/confirm/#{&1}"))
      {:error, :already_confirmed}

  """
  def deliver_user_confirmation_instructions(%User{} = user, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if user.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token)
      UserNotifier.deliver_confirmation_instructions(user, confirmation_url_fun.(encoded_token))
    end
  end

  @doc """
  Confirms a user by the given token.

  If the token matches, the user account is marked as confirmed
  and the token is deleted.
  """
  def confirm_user(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "confirm"),
         %User{} = user <- Repo.one(query),
         {:ok, %{user: user}} <- Repo.transaction(confirm_user_multi(user)) do
      {:ok, user}
    else
      _ -> :error
    end
  end

  defp confirm_user_multi(user) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.confirm_changeset(user))
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, ["confirm"]))
  end

  ## Reset password

  @doc ~S"""
  Delivers the reset password email to the given user.

  ## Examples

      iex> deliver_user_reset_password_instructions(user, &url(~p"/users/reset_password/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_reset_password_instructions(%User{} = user, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "reset_password")
    Repo.insert!(user_token)
    UserNotifier.deliver_reset_password_instructions(user, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the user by reset password token.

  ## Examples

      iex> get_user_by_reset_password_token("validtoken")
      %User{}

      iex> get_user_by_reset_password_token("invalidtoken")
      nil

  """
  def get_user_by_reset_password_token(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "reset_password"),
         %User{} = user <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Resets the user password.

  ## Examples

      iex> reset_user_password(user, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %User{}}

      iex> reset_user_password(user, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_user_password(user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.password_changeset(user, attrs))
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end
end
