require 'rmagick'
include Magick
class HomeController < ApplicationController

  def home
    params[:images].each_with_index do |image, index|
      filename = "image-#{index}"
      image_data = Base64.decode64(image[:url]['data:image/png;base64,'.length .. -1])
      blob = ActiveStorage::Blob.create_and_upload!(io: StringIO.new(image_data), filename: filename)
      blob.download
    end
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
end
