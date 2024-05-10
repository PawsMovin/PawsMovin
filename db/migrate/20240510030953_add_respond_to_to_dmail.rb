class AddRespondToToDmail < ActiveRecord::Migration[7.1]
  def change
    add_reference(:dmails, :respond_to, foreign_key: { to_table: :users })
  end
end
