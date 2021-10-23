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
    bg_size = read_bg.columns
    size = calculate_total_width_height(@images,"vertical")
    if size > bg_size
      diff = ((bg_size-size).abs)/@images.count
      @images = adjust_image_sizes(@images, diff)
    end
    # padding = params[]
    if params[:alignment] == "vertical"
      size = 0
      x = 0
      @images = adjust_image_sizes(@images, 0)
      @images.each do |image|
        # logger.debug("@@@----@@@#{image[:width]}---#{image[:height]}")
        image[:image].resize_to_fit!(image[:width], image[:height])
        read_bg.composite!(image[:image], x+10, 0+10, OverCompositeOp)
        x += image[:width]+10
        size += image[:width]
        # logger.debug("@--#{image[:width]}---#{image[:height]}")
      end
    # else
    #   bg_size = read_bg.columns
    #   images.each do |image|

    #   end
    end

    read_bg.write("#{Rails.root}/app/assets/images/collage.png")


    # bg = "#{Rails.root}/app/assets/images/bg.png"
    # f1 = "#{Rails.root}/app/assets/images/flower1.png"
    # f2 = "#{Rails.root}/app/assets/images/flower2.png"
    # f3 = "#{Rails.root}/app/assets/images/flower3.png"
    # f4 = "#{Rails.root}/app/assets/images/flower4.png"
    # read = []
    # read_bg = ImageList.new(bg)
    # 1. need to resize the backgroud image based on horizontal/vertical
    # read_bg.resize_to_fit!(read_bg.rows+1300)
    # read[0] = ImageList.new(f1)
    # read[0].resize_to_fit!(read[0].columns/4, read[0].rows/4)
    # read[1] = ImageList.new(f2)
    # read[1].resize_to_fit!(read[1].columns/4, read[1].rows/4)
    # read[2] = ImageList.new(f3)
    # read[2].resize_to_fit!(read[2].columns/4, read[2].rows/4)
    # read[3] = ImageList.new(f4)
    # read[3].resize_to_fit!(read[3].columns/4, read[3].rows/4)

    # pasha-pashi
    # read_bg.composite!(read_f1, 0, 0, OverCompositeOp)
    # read_bg.composite!(read_f2, (read_f1.columns)+10, 0, OverCompositeOp)
    # read_bg.composite!(read_f3, read_f2.columns+read_f1.columns+10, 0, OverCompositeOp)

    # upor-niche
    # read_bg.composite!(read_f1, 0+10, 0, OverCompositeOp)
    # read_bg.composite!(read_f2, 0+10, (read_f1.columns)+10, OverCompositeOp)
    # read_bg.composite!(read_f3, 0+10, read_f2.columns+read_f1.columns+20, OverCompositeOp)
    # read_bg.composite!(read_f4, 0+10, read_f3.columns+read_f2.columns+read_f1.columns+30, OverCompositeOp)
    # read_bg.composite!(read_f4, 0+10, read_f3.columns+read_f2.columns+read_f1.columns+30, OverCompositeOp)

    # x = 0
    # y = 0
    # (0..3).each do |i|
    #   read_bg.composite!(read[i], x+10, y, OverCompositeOp)
    #   y += read[i].columns+10
    # end

    # read_bg.crop!(x+10, 0, read[1].columns + 30, 1300)
    # read_bg.write("#{Rails.root}/app/assets/images/collage.png")

  end

  def calculate_total_width_height(images,alignment)
    sum = 0
    if alignment == "vertical"
      images.each do |image|
        sum += image[:width]
      end
    end
    return sum
  end

  def adjust_image_sizes(images, diff)
    diff1 = (1600/images.count).floor
    diff2 = 900
    images.each do |image|
      # ratio = [(image[:width]-diff)/image[:width], (image[:height]-diff)/image[:height]].min
      # image[:width] = ratio*image[:width]
      # image[:height] = ratio*image[:height]
      w = diff1.to_f/image[:image].columns
      h = diff2.to_f/image[:image].rows
      ratio = [w, h].min
      logger.debug("---ratio=#{ratio}---#{diff1/image[:image].columns}---#{image[:image].rows}")
      image[:width] = ratio*image[:image].columns
      image[:height] = ratio*image[:image].rows

      logger.debug("-----#{image[:image].columns}----#{image[:image].rows}")
    end
    return images
  end

end
