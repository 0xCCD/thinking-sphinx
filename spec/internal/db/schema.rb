ActiveRecord::Schema.define do
  create_table(:articles, :force => true) do |t|
    t.string  :title
    t.text    :content
    t.boolean :published
    t.integer :user_id
    t.timestamps
  end

  create_table(:books, :force => true) do |t|
    t.string  :title
    t.string  :author
    t.integer :year
    t.boolean :delta, :default => true, :null => false
    t.timestamps
  end

  create_table(:cities, :force => true) do |t|
    t.string :name
    t.float  :lat
    t.float  :lng
  end

  create_table(:users, :force => true) do |t|
    t.string :name
    t.timestamps
  end
end
