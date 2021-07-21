# Transactions and Multi - sách Darin's Ecto

CSDL cần tính toàn vẹn, và điều đó đồng nghĩa với `giao dịch` - `transaction`. Các `transactions` cho phép bạn nhóm các hành động CSDL lại với nhau để có thể chắc chắn rằng chúng sẽ thành công toàn bộ, hoặc không làm gì cả.

## Tiến hành `giao dịch` - `transaction` với hàm

```elixir
artist = %Artist{name: "Jhonny Hogdes"}

Repo.transaction(fn ->
  Repo.insert!(artist)
  Repo.insert!(Log.changeset_for_insert(artist))
)

#=> {:ok, %MusicDB.Log{...}}
```

## Thực hiện `giao dịch` - `transaction` bằng Ecto.Multi

```elixir
alias Ecto.Multi

artist = %Artist{name: "Johnny Hodges"}

multi =
  Multi.new
  |> Multi.insert(:artist, artist)
  |> Multi.insert(:log, Log.changeset_for_insert(artist))

Repo.transaction(multi)

#=>
{:ok,
    %{
      artist: %MusicsDB.Artist{...},
      log: %MusicDB.Log{...}
    }
}
```

## Bắt lỗi với Ecto.Multi

```elixir
artist = Repo.get_by(Artist, name: "Johnny Hodges")
artist_changeset = Artist.changeset(artist, %{name: "John Cornelius Hodges"})

invalid_changeset = Artist.changeset(%Artist{}, %{name: nil})

multi =
  Multi.new
  |> Multi.update(:artist, artist_changeset)
  |> Multi.insert(:invalid, invalid_changeset)

Repo.transaction(multi)

#=>
{:error, :invalid, #Ecto.Changeset<
                      action: :insert,
                      changes: %{},
                      errors: [name: {"can't be blank", [validation: :required]}],
                      data: #MusicDB.Artist<>,
                      valid?: false
                    >,
  %{}
}
```

