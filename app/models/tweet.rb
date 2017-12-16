class Tweet < ApplicationRecord
  include Magick

  belongs_to :user
  validates :content, length: {maximum: 280}, presence: true

  def create_with_image(user_id, params)
    content = params[:content]
    public_id = user_id.to_s + Time.current.to_i.to_s
    create_image(content, public_id)
    pic = upload_image(public_id)
    Tweet.create(user_id: user_id, content: content, public_id: public_id, pic: pic.to_json)
  end

  def update_with_image(user_id, params)
    content = params[:content]
    create_image(content, self.public_id)
    pic = upload_image(public_id)
    self.content = content
    self.pic = pic.to_json
    self.save!
  end

  def delete_with_image
    destroy_image(self.public_id)
    self.destroy!
  end

  private

  def create_image(content, public_id)
    content = content.scan(/.{1,#{20}}/).join('\n')
    image = Image.new(640, 480)
    draw = Draw.new
    draw.font = Rails.root.join('.fonts/ipaexg.ttf').to_s
    draw.pointsize = 24
    draw.annotate(image, 640, 480, 50, 50, content)
    image.write("/tmp/#{public_id}.png")
  end

  def upload_image(public_id)
    Cloudinary::Uploader.upload("/tmp/#{public_id}.png", :public_id => public_id) if Rails.env.production?
  end

  def destroy_image(public_id)
    Cloudinary::Uploader.destroy(public_id) if Rails.env.production?
  end
end
