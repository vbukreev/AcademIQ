class CreateSchools < ActiveRecord::Migration[7.2]
  def change
    create_table :schools do |t|
      t.string :name
      t.float :min_gpa
      t.string :location
      t.string :field
      t.text :description

      t.timestamps
    end
  end
end
