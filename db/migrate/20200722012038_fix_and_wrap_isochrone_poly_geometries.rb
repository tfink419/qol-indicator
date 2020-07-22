class FixAndWrapIsochronePolyGeometries < ActiveRecord::Migration[5.2]
  def up
    IsochronePolygon.find_each do |iso_poly|
      iso_poly.geometry = '[['+iso_poly.geometry.gsub(/\{/,'[').gsub(/\}/,']')+']]'
      iso_poly.save
    end
  end
end
