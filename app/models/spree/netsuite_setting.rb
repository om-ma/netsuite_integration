class Spree::NetsuiteSetting < ApplicationRecord
	def self.active?
		first&.active == true
	end
end
