class RenameProfileMainToAdmin < ActiveRecord::Migration[8.1]
  def up
    execute "UPDATE users SET profile = 'admin' WHERE profile = 'main'"
  end

  def down
    execute "UPDATE users SET profile = 'main' WHERE profile = 'admin'"
  end
end
