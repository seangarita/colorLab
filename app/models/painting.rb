require "s3"

class Painting < ActiveRecord::Base
	attr_accessor :binary, :s3Url, :s3ThumbnailUrl
	before_validation :populateS3Uuid
	after_initialize :populateUrls
	before_destroy :deleteFromS3
	validates :s3Uuid, :presence => true
	validates :name, :presence => true
	
	private
		@@imageExtension = ".png"
		@@thumbnailExtension = ".png.thumb.png"
		def deleteFromS3
			service = S3::Service.new(:access_key_id => ENV["COLORLAB_ACCESS_KEY_ID"], :secret_access_key => ENV["COLORLAB_SECRET_ACCESS_KEY"])
			bucket = service.buckets.find("colorlab")
			imageObject = bucket.objects.find(self.s3Uuid + @@imageExtension)
			thumbnailObject = bucket.objects.find(self.s3Uuid + @@thumbnailExtension)
			return imageObject.destroy && thumbnailObject.destroy
		end
		def populateUrls
			if (self.s3Uuid)
				@s3Url = ENV["COLORLAB_BUCKET_BASE_URL"] + self.s3Uuid + @@imageExtension
				@s3ThumbnailUrl = ENV["COLORLAB_BUCKET_BASE_URL"] + self.s3Uuid + @@thumbnailExtension
			end
		end
		def populateS3Uuid
			self.name = binary.original_filename
			if (convertToPainting)
				uuidOrFalse = uploadToS3
				if (uuidOrFalse)
					self.s3Uuid = uuidOrFalse
					populateUrls()
				else
					false
				end
			else
				false
			end
		end
		def convertToPainting
			return system("bin/runCLab.sh " + binary.path)
		end
		def uploadToS3
			service = S3::Service.new(:access_key_id => ENV["COLORLAB_ACCESS_KEY_ID"], :secret_access_key => ENV["COLORLAB_SECRET_ACCESS_KEY"])
			bucket = service.buckets.find("colorlab")
			uuid = SecureRandom.uuid
			# Upload Image
			imageObject = bucket.objects.build(uuid.to_s + ".png")
			imageObject.content = open(binary.path + ".png")
			imageObject.content_type = "image/png"
			imageObject.acl = :public_read
			# Upload Thumbnail
			thumbnailObject = bucket.objects.build(uuid.to_s + ".png.thumb.png")
			thumbnailObject.content = open(binary.path + ".png.thumb.png")
			thumbnailObject.content_type = "image/png"
			thumbnailObject.acl = :public_read
			if (imageObject.save && thumbnailObject.save)
				return uuid
			else
				return false
			end
		end
end
