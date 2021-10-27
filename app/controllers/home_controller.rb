require 'rmagick'
include Magick
class HomeController < ApplicationController

  def home
    @images = []
    imageList = ImageList.new
    params[:images].each_with_index do |image, index|
      filename = "image-#{index}.jpeg"
      # think about jpeg/png
      image_data = Base64.decode64(image[:url]['data:image/jpeg;base64,'.length .. -1])
      File.open("#{Rails.root}/tmp/storage/#{filename}", 'wb') do |f|
        f.write image_data
      end
      file = File.open("#{Rails.root}/tmp/storage/#{filename}")
      blob = ActiveStorage::Blob.create_and_upload!(io: file, filename: filename)
      @images.push(image: ImageList.new("#{Rails.root}/tmp/storage/#{filename}"), width: image[:width], height: image[:height])
      File.delete("#{Rails.root}/tmp/storage/#{filename}")
    end

    bg = "#{Rails.root}/app/assets/images/bg.png"
    read_bg = ImageList.new(bg)
    # padding = params[]
    if params[:alignment] == "horizontal"
      size = 0
      x = 0
      diff1 = ((1600-10*(@images.count+1))/@images.count).floor # bg image width
      diff2 = 900 # bg image height
      @images = adjust_image_sizes(@images, diff1, diff2)
      @images.each do |image|
        image[:image].resize_to_fit!(image[:width], image[:height])
        read_bg.composite!(image[:image], x+10, 0+10, OverCompositeOp)
        x += image[:width]+10
        size += image[:width]
      end
    else
      size = 0
      y = 0
      diff1 = 1600 # bg image width
      diff2 = ((900-10*(@images.count+1))/@images.count).floor # bg image height
      @images = adjust_image_sizes(@images, diff1, diff2)
      @images.each do |image|
        image[:image].resize_to_fit!(image[:width], image[:height])
        read_bg.composite!(image[:image], 0+10, y+10, OverCompositeOp)
        y += image[:height]+10
        size += image[:height]
      end
    end

    read_bg.write("#{Rails.root}/app/assets/images/collage.png")

  end

  def calculate_total_width_height(images,alignment)
    sum = 0
    if alignment == "vertical"
      images.each do |image|
        sum += image[:width]
      end
    else
      images.each do |image|
        sum += image[:height]
      end
    end
    return sum
  end

  def adjust_image_sizes(images, diff1, diff2)
    images.each do |image|
      w = diff1.to_f/image[:image].columns
      h = diff2.to_f/image[:image].rows
      ratio = [w, h].min
      image[:width] = ratio*image[:image].columns
      image[:height] = ratio*image[:image].rows
    end
    return images
  end

end
