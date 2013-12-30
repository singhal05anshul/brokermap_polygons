class CreatePolygons < ActiveRecord::Migration
  def change
    create_table :polygons do |t|
      t.text :name
      t.polygon :boundary, :geographic => true
      t.string  :poly_type
      t.boolean :visibility
      t.timestamps
    end
   
  end
end
