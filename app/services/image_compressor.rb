class ImageCompressor
    def self.compress(file)
        image = MiniMagick::Image.open(file.path)


      # resize max 1024px
      image.resize "1024x1024>"

      # compress quality
      image.quality "75"

      # convert to jpeg (optional)
      image.format "jpg"

      tempfile = Tempfile.new([ "compressed", ".jpg" ])
      image.write(tempfile.path)
      tempfile
    end
end
