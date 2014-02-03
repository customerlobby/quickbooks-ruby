module Quickbooks
  module Model
    class CustomField < BaseModel
      xml_accessor :id, :from => 'Id', :as => Integer
      xml_accessor :name, :from => 'Name'
      xml_accessor :type, :from => 'Type'
      xml_accessor :string_value, :from => 'StringValue'
      xml_accessor :boolean_value, :from => 'BooleanValue'
      xml_accessor :date_value, :from => 'DateValue'
      xml_accessor :number_value, :from => 'NumberValue'
    end
  end
end