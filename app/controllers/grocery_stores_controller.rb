require 'csv'
require 'net/http'
require 'json'

class GroceryStoresController < ApplicationController
  before_action :confirm_logged_in
  before_action :admin_only

  def index
    begin
      page = params[:page].to_i
      limit = params[:limit].to_i
      offset = page*limit
      order = params[:order]
      dir = params[:dir]
      search = params[:search]
      if search.nil? or search.blank? or search.length == 1
        gstores = GroceryStore.offset(offset).limit(limit).clean_order(order, dir)
        count = GroceryStore.count
      else
        count = GroceryStore.search(search).count
        gstores = GroceryStore.search(search).offset(offset).limit(limit).clean_order(order, dir)
      end
      render :json => { 
        :status => 0, 
        :grocery_stores => gstores,
        :grocery_store_count => count
      }
    rescue StandardError => err
      $stderr.print err
      render :json => { 
        :status => 500,
        :error => 'Unknown error occured',
        :error_details => err
      }, :status => 500
    end

  end

  def show
    render :json => { 
      :status => 0, 
      :grocery_store => GroceryStore.find(params[:id])
    }
  end

  def create
    begin
      gstore = GroceryStore.new(grocery_store_params)
      attempt_geocode_if_needed(gstore)
      if gstore.save
        render :json =>  {
          :status => 0,
          :grocery_store => gstore
        }
      else
        render :json => {:status => 400, :error => 'Error Creating Grocery Store', :error_details => gstore.errors.messages}, :status => 400
      end
    rescue StandardError => err
      $stderr.print err
      render :json => { 
        :status => 500,
        :error => 'Unknown error occured',
        :error_details => err
      }, :status => 500
    end
  end

  def upload_csv
    begin
      csv_file = params[:csv_file].read
      end_of_line = csv_file.index("\n")
      csv_file[0..end_of_line] = csv_file[0..end_of_line].downcase
      csv_table = CSV.parse(csv_file, headers: true)

      number_sucessful = 0
      failed = []
      column = 2 # Skip title
      csv_table.each do |row|
        gstore = GroceryStore.new(:name => row['name'], :address => row['address'], 
          :city => row['city'], :state => row['state'], :zip => row['zip'], :lat => row['latitude'], :long => row['longitude'])
        attempt_geocode_if_needed(gstore)
        if gstore.save
          number_sucessful += 1
        else
          failed << column
        end
        column += 1
      end
      if number_sucessful == column-2
        render :json => {
          :status => 0, 
          :message => "File uploaded and All Grocery Stores were added successfully."
        }
      elsif number_sucessful.to_f/(column-2) > 0.8
        render :json => {
          :status => 0, 
          :message => "File uploaded and #{number_sucessful}/#{column-2} Grocery Stores were added successfully.",
          :details => "Grocery Stores at columns #{failed} failed to upload"
        }
      elsif number_sucessful == 0
        render :json => {
          :status => 400, 
          :message => "All Grocery Stores Failed to Upload",
          :errors => "All"
        }, :status => 400
      elsif number_sucessful.to_f/(column-2) < 0.5
        render :json => {
          :status => 400, 
          :message => "More than half the Grocery Stores Failed to Upload",
          :details => "Grocery Stores at columns #{failed} failed to upload"
        }, :status => 400
      end
    rescue StandardError => err
      $stderr.print err
      render :json => { 
        :status => 500,
        :error => 'Unknown error occured',
        :error_details => err
      }, :status => 500
    end
  end

  def destroy
    begin
      gstore = GroceryStore.find(params[:id])
      gstore.delete

      render :json => { 
        :status => 0, 
        :message => "Grocery Store '#{gstore.name} at #{gstore.address}' successfully deleted."
      }
    rescue StandardError => err
      $stderr.print err
      render :json => { 
        :status => 500,
        :error => 'Unknown error occured',
        :error_details => err
      }, :status => 500
    end
  end

  def update
    begin
      gstore = GroceryStore.find(params[:id])
      gstore.assign_attributes(grocery_store_params)
      pp gstore
      attempt_geocode_if_needed(gstore)
      if gstore.save
        render :json =>  {
          :status => 0,
          :grocery_store => gstore
        }
      else
        render :json => {:status => 400, :error => 'Error Creating Grocery Store', :error_details => gstore.errors.messages}, :status => 400
      end
    rescue StandardError => err
      $stderr.print err
      render :json => { 
        :status => 500,
        :error => 'Unknown error occured',
        :error_details => err
      }, :status => 500
    end
  end

  private

  def attempt_geocode_if_needed(gstore)
    unless gstore.valid?
      if gstore.only_coordinates_invalid?
        geoCoded = geocode(gstore.address, gstore.city, gstore.state, gstore.zip)
        pp geoCoded
        parse_geocode(gstore, geoCoded)
      end
    end
  end

  def parse_geocode(gstore, geoCoded)
    geoCoded = admin_area_decode(geoCoded)
    gstore.lat = geoCoded['latLng']['lat']
    gstore.long = geoCoded['latLng']['lng']
    if gstore.zip.nil?
      gstore.zip = geoCoded['postalCode']
    elsif gstore.city.nil? or gstore.city.empty?
      gstore.city = geoCoded['city']
      gstore.state = geoCoded['state']
    end
  end

  def admin_area_decode(location) 
    location[location['adminArea1Type'].downcase] = location['adminArea1'] if location['adminArea1']
    location[location['adminArea2Type'].downcase] = location['adminArea2'] if location['adminArea2']
    location[location['adminArea3Type'].downcase] = location['adminArea3'] if location['adminArea3']
    location[location['adminArea4Type'].downcase] = location['adminArea4'] if location['adminArea4']
    location[location['adminArea5Type'].downcase] = location['adminArea5'] if location['adminArea5']
    location[location['adminArea6Type'].downcase] = location['adminArea6'] if location['adminArea6']
    location
  end

  def geocode(address, city, state, zip)
    uri = URI('http://www.mapquestapi.com/geocoding/v1/address')
    if zip.nil?
      location = "#{address}, #{city}, #{state}"
    elsif city.nil? or city.blank?
      location = "#{address}, #{zip}"
    else
      location = "#{address}, #{city}, #{state}, #{zip}"
    end
    uri.query = URI.encode_www_form({ :key => ENV["MAPQUEST_KEY"], :location => location})
    response = JSON.parse(Net::HTTP.get(uri))
    if response['info']['statuscode'].to_i == 0
      return response['results'][0]['locations'][0]\
    end
    nil
  end

  def grocery_store_params
    params.require(:grocery_store).permit(:name, :address, :city, :state, :zip, :lat, :long, :quality)
  end
end
