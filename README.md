## Rails Db log tag

- allow to prepend prefix `tags` before db query logs. 

  For example: below show the prefix tag `[role: reading]` which is the role of database

  ```ruby
  Product.all
  # [role: reading] Product Load (0.4ms)  SELECT "products".* FROM "products" /* loading for inspect */ LIMIT ?  [["LIMIT", 11]]
  ```

## TODO: 

  + tag types

  + global setting

  + dynamic set tags 