require 'rmagick'
include Magick
class HomeController < ApplicationController

  def home
    @images = []
    imageList = ImageList.new
    params[:images].each_with_index do |image, index|
      filename = "image-#{index}.#{image[:extention]}"
      image_data = Base64.decode64(image[:url]["data:image/#{image[:extention]};base64,".length .. -1])

      # image_data = Base64.decode64(image[:url][image_type[0].length .. -1])
      File.open("#{Rails.root}/tmp/storage/#{filename}", 'wb') do |f|
        f.write image_data
      end
      file = File.open("#{Rails.root}/tmp/storage/#{filename}")
      blob = ActiveStorage::Blob.create_and_upload!(io: file, filename: filename)
      # @images.push(image: ImageList.new("#{Rails.root}/tmp/storage/#{filename}"), width: image[:width], height: image[:height])
      @images.push(image: ImageList.new("#{Rails.root}/tmp/storage/#{filename}"))
      File.delete("#{Rails.root}/tmp/storage/#{filename}")
    end
    color = params[:color]
    read_bg = Image.new(1600,900) {self.background_color = color}
    padding = params[:border].to_i
    if params[:alignment] == "horizontal"
      size = 0
      x = 0
      diff1 = ((1600-padding*(@images.count+1))/@images.count).floor # bg image width
      diff2 = 900 # bg image height
      @images = adjust_image_sizes(@images, diff1, diff2)
      max_height = 0
      @images.each do |image|
        image[:image].resize_to_fit!(image[:width], image[:height])
        read_bg.composite!(image[:image], x+padding, 0+padding, OverCompositeOp)
        x += image[:width]+padding
        size += image[:width]
        if max_height < image[:height]
          max_height = image[:height]
        end
      end
      read_bg.crop!(0, 0, 1600, max_height+padding*2)
    else
      size = 0
      y = 0
      diff1 = 1600 # bg image width
      diff2 = ((900-padding*(@images.count+1))/@images.count).floor # bg image height
      @images = adjust_image_sizes(@images, diff1, diff2)
      max_width = 0
      @images.each do |image|
        image[:image].resize_to_fit!(image[:width], image[:height])
        read_bg.composite!(image[:image], 0+padding, y+padding, OverCompositeOp)
        y += image[:height]+padding
        size += image[:height]
        if max_width < image[:width]
          max_width = image[:width]
        end
      end
      read_bg.crop!(0, 0, max_width+padding*2, 900)
    end


    read_bg.write("#{Rails.root}/tmp/storage/collage.png")
    blob = ActiveStorage::Blob.create_and_upload!(io: File.open("#{Rails.root}/tmp/storage/collage.png"), filename: "collage.png")
    File.delete("#{Rails.root}/tmp/storage/collage.png")

    render json: {image: url_for(blob)}
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
