module QbwcRequests
  module Vendor
    module V07
      class Query < QbwcRequests::Base
        field :max_returned
        field :from_modified_date
      end
    end
  end
end
