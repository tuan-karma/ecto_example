# Associations in "Programming Ecto" by Darin Wilson and Eric Meadows-Jonsson

Tóm lược phần thao tác với các dữ liệu liên kết trên Ecto trong sách của Darin Wilson và Eric Meadows-Jonsson.

Từ trang 76 trong sách pdf bản phát hành lần đầu năm 2019.

## Làm việc với các bản ghi duy nhất - _single record_

Khi thao tác với các dữ liệu con trong liên kết, câu hỏi đặt ra là: ta cần thay đổi một bản ghi duy nhất hay một tập hợp các bản ghi được liên kết với dữ liệu mẹ trong một lần?

Nếu bạn làm việc với các bản ghi đơn lẻ, tốt nhất là thực hiện các thay đổi bên ngoài `changeset`. Cụ thể là sử dụng `Ecto.buid_assoc` hoặc gán trực tiếp `FK_id` vào bản ghi con. Xem ví dụ điển hình sau:

```elixir
artist = Repo.get_by(Artist, name: "Miles David")
new_album = Ecto.build_assoc(artist, :albums, title: "Miles Ahead")
Repo.insert(album)

#=> {:ok, %MusicDB.Album{id: 6, title: "Miles Ahead", artist_id: 1, ...}}
```

## Làm việc với các bản ghi liên kết đến từ bên trong CSDL

Khi muốn truyền - `cast` và lọc - `filter` dữ liệu liên kết, tùy thuộc vào việc chúng ta làm việc với dữ liệu được tạo ra bên trong ứng dụng (cụ thể là dưới CSDL hoặc trong code) hay với các dữ liệu đến từ bên ngoài ứng dụng (vd: nhập từ `html form`) mà chúng ta chọn phương án tiếp cận khác nhau. Hàm `put_assoc/4` phù hợp cho các thao tác dữ liệu liên kết đến từ bên trong.

Ví dụ điển hình:
```elixir
artist =
  Repo.get_by(Artist, name: "Miles David")
  |> Repo.preload(:albums)

artist
|> change
|> put_assoc(:albums, [%{title: "Miles Ahead"} | artist.albums])
|> Repo.update()
```

* Lưu ý 1: các hàm tạo liên kết trong `Schema` như `has_many`, `belongs_to` có một tham số tùy chọn gọi là `:on_replace`. Hàm `Ecto.Changeset.put_assoc/4` của chúng ta làm việc trên toàn bộ tập dữ liệu con của liên kết nên nó sẽ thay thế các dữ liệu có sẵn tùy thuộc vào tham số tùy biến này, mặc định `on_replace: :raise` - nghĩa là Ecto sẽ `raise` một `runtime error` khi dữ liệu đưa vào thay thế dữ liệu có sẵn liên kết của dữ liệu mẹ.

* Lưu ý 2: hàm `put_assoc/4` có thể nhận tham số đầu vào thứ 3 là _Schema's Struct_ như `[%Album{...}]`, hoặc các _map_ như `[%{...}, %{...}]`, hoặc một _keyword list_ như `[[key: value], [...]]`.

## Làm việc với các bản ghi dữ liệu liên kết đến từ bên ngoài

Ví dụ điển hình:
```elixir
params = %{"name" => "Esperanza Spalding", "albums" => [%{"title" => "Junjo"}]}

changeset =
  %Artist{}
  |> cast(params, [:name])
  |> cast_assoc(:albums, with: &MusicDB.Album.changeset/2)

changeset.changes
#=>
%{albums: [#Ecto.Changeset<action: :insert, ...>],
          changes: %{title: "Junjo"}, errors: [],
          data: #MusicDB.Album<>, valid=>: true],
  name: "Esperanza Spalding"}
```

Một ví dụ tổng thể hơn cho thấy sức mạnh của `Ecto.Changeset.cast_assoc/3` khi làm việc với tổng thể các dữ liệu liên kết đến từ bên ngoài và trong:

```elixir
portrait = Repo.get_by(Album, title: "Portrait In Jazz")
kind_of_blue = Repo.get_by(Album, title: "Kind Of Blue")

params = %{"albums" =>
  [
    %{"title" => "Explorations"},
    %{"title" => "Portrait In Jazz (remastered)", "id", => portrait.id},
    %{"title" => "Explorations", "id" => kind_of_blue.id}
  ]
}

artist = Repo.get_by(Artist, name: "Bill Evans")
|> Repo.preload(:albums)

{:ok, artist} =
  artist
  |> cast(params, [])
  |> cast_assoc(:albums)
  |> Repo.update()

Enum.map(artist.albums, &({&1.id, &1.title}))

#=>
[
  {6, "Explorations"},
  {4, "Portrait In Jazz (remastered)"},
  {7, "Kind Of Blue"}
]
```

Hãy chú ý việc Ecto làm bên dưới cho chúng ta trong ví dụ trên:
  * Tạo ra bản ghi liên kết mới - album "Explorations", với id = 6 tự phát.
  * Update bản ghi "Portrait In Jazz" thành "Portrait in Jazz (remastered)" dựa trên id có sẵn (id = 4 = portrait.id)
  * Tạo ra bản ghi liên kết mới là album "Kind of Blue" mặc dù trong dữ liệu vào của bản ghi này có chứa id, nhưng nó không tìm thấy id này trong tập hợp các dữ liệu liên kết con của artist "Bill Evans" mà chúng ta đang thao tác.
  * Các bản ghi _khác_ có sẵn trong artist "Bill Evans" sẽ bị loại bỏ khỏi liên kết với nghệ sĩ này, tùy vào lựa chọn :on_replace trong Schema mà Ecto sẽ thực hiện các biện pháp loại bỏ khác nhau (:delete - xóa, :nilify - làm trống FK ...)



# Kinh nghiệm thực hành

Có lẽ do cách đặt tên hàm và biến trong tài liệu về các hàm thao tác với dữ liệu liên kết nên gây cho chúng ta khá nhiều bối rối trong lựa chọn và áp dụng các hàm này. Về cơ bản thì gần như tất cả các trường hợp liên kết, các chiều liên kết đều có thể dùng 1 trong 3 hàm kể trên, thậm chí có thể dùng hàm này thay thế hàm kia. Tôi tóm tắt lại dạng các hàm trên và đặt tên lại các biến bên trong để có một ảnh chụp trong tâm trí mỗi khi nghĩ đến các hàm này:

### `Ecto.build_assoc/3`

```elixir
child_struct = Ecto.build_assoc(parent_struct, :assoc_name, attrs // [])
#=> the above is equivalent to:
#=> ... for attrs is a map, e.g. attrs = %{"title" => "Autumn Leaves", "id" => 2}
params = Map.puts(attrs, "parent_id" => parent_struct.id)
child_struct = %Child_Struct{} |> Ecto.Changeset.cast(params)
```

  * Đôi khi sẽ là tiện lợi hơn nhiều nếu dùng trực tiếp hàm Map.put(child_params, "FK" => parent.id) khi phải thao tác với các dữ liệu liên kết phụ thuộc nhiều lớp riêng lẻ.
  * Lưu ý: buid_assoc không yêu cầu preload dữ liệu liên kết con vì nó chỉ tạo ra cấu trúc liên kết con mới mà không quan tâm tới các liên kết có sẵn.

### `Ecto.Changeset.put_assoc/4`
```elixir
new_parent_changeset = Ecto.Changeset.put_assoc(parrent_changeset, :assoc_name, child_records)
```

  * Hàm này sẽ thay thế/update toàn bộ dữ liệu con trong liên kết sẵn có của cấu trúc mẹ. Lưu ý tùy chọn `:on_replace` trong Schema của dữ liệu mẹ. Lưu ý: cần phải preload dữ liệu con trước khi thao tác.
  * Khi gọi Repo.insert cho the `new_parent_changeset` mới tạo ra, nó sẽ ghi nhận (cập nhật) toàn bộ dữ liệu mẹ và các liên kết con mới tạo ra trong một transaction. Lưu ý, hàm này sẽ bỏ qua các kiểm tra trong changeset, nên cẩn trọng.
  * `put_assoc` là lựa chọn tốt khi làm việc với các bản ghi mẹ và con tách rời, kể cả khi làm việc với các dữ liệu đến từ bên ngoài. Bạn có thể sử dụng changeset để tạo/cập nhật/xóa bản ghi con riêng biệt, sau đó sử dụng `put_assoc` trong một changeset riêng để cập nhật tập hợp bản ghi trong dữ liệu mẹ. Trường hợp thường thấy là khi làm việc với mối liên kết many_to_many, ví dụ như gắn tags vào các bài posts.


### `Ecto.Changeset.cast_assoc/3`
```elixir
new_parent_changeset = Ecto.Changeset.cast_assoc(parent_changeset_with_casted_params, :assoc_name, opts // [with: &MyApp.ChildSchema.changeset/2])
```

  * Làm việc với các cấu trúc dữ liệu đến từ bên ngoài ứng dụng, e.g. params_map_with_child_data.
  * Sử dụng hàm changeset trong child Schema để lọc và kiểm tra dữ liệu con tới.
  * Khi gọi Repo.update(new_parent_changeset) thì Ecto sẽ tự kiểm tra và quyết định xem dữ liệu nào sẽ được tạo mới, cập nhật, và xóa bỏ.
  * Dữ liệu từ bên ngoài đến dưới dạng `parent_params_map_with_child`, sau khi chui qua hàm Ecto.Changeset.cast sẽ tạo ra một changeset chứa changeset.params là tất cả tham số cần thiết để truyền vào `cast_assoc` gọi sau đó trên changeset vừa tạo ra.
