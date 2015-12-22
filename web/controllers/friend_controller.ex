defmodule BorrowersBackend.FriendController do
  use BorrowersBackend.Web, :controller

  alias BorrowersBackend.Friend

  plug :scrub_params, "friend" when action in [:create, :update]

  def index(conn, _params) do
    friends = Repo.all(Friend)
    render(conn, "index.json", friends: friends)
  end

  def create(conn, %{"friend" => friend_params}) do
    changeset = Friend.changeset(%Friend{}, friend_params)

    case Repo.insert(changeset) do
      {:ok, friend} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", friend_path(conn, :show, friend))
        |> render("show.json", friend: friend)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(BorrowersBackend.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    friend = Repo.get!(Friend, id)
    render(conn, "show.json", friend: friend)
  end

  def update(conn, %{"id" => id, "friend" => friend_params}) do
    friend = Repo.get!(Friend, id)
    changeset = Friend.changeset(friend, friend_params)

    case Repo.update(changeset) do
      {:ok, friend} ->
        render(conn, "show.json", friend: friend)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(BorrowersBackend.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    friend = Repo.get!(Friend, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(friend)

    send_resp(conn, :no_content, "")
  end
end