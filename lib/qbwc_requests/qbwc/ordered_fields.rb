module Qbwc
  module OrderedFields

    module ClassMethods
      def field attribute_name
        @attr_order ||= Set.new
        @attr_order << attribute_name
        attr_accessor attribute_name
      end
      def has_one attribute_name
        @attr_order ||= Set.new
        @attr_order << attribute_name
        attr_accessor attribute_name
      end
      def attr_order
        @attr_order
      end
    end

    class SubModelsValidator < ActiveModel::Validator
      def validate record
        for field in record.class.attr_order
          value = record.send(field)
          if value.respond_to?(:valid?) and value.invalid?
            for error in value.errors
              record.errors.add("#{field}##{error}", value.errors.messages[error] )
            end
          end
        end
      end
    end

    def self.included(base)
      base.extend(ActiveModel::Naming)
      base.include(ActiveModel::Validations)
      base.include(ActiveModel::Conversion)
      base.extend(ClassMethods)
      base.validates_with(SubModelsValidator)
    end
    
    def ordered_fields
      new_hash = {}
      for attribute in self.class.attr_order
        value = send(attribute)
        if value.present?
          if value.respond_to?(:ordered_fields)
            new_hash[attribute] = value.ordered_fields
          else
            new_hash[attribute] = value
          end
        end
      end
      new_hash
    end
  end
end
