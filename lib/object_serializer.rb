
#
# @author <a href="mailto:tjad.clark@korwe.com">Tjad Clark</a>
#

class JSOG
  class ObjectSerializer

    def initialize
      @reference_map = Hash.new
      @reference_counter = 0
    end

    def self.encode(obj)
      JSON.dump(ObjectSerializer.new.encode(obj))
    end

    def encode(obj)
      if obj.is_a? Array
        obj.map do |item|
          encode(item)
        end
      elsif obj.is_a? Hash
        Hash[value.map do |k,v|
          [k, encode(v)]
        end]
      else
        attribute_names = obj.instance_variables.map{|var_name| var_name.to_s.gsub(/^@/, '')}.select {|var_name| obj.respond_to? var_name}
        if !attribute_names.empty?
          ref_id = @reference_map[obj.object_id] = @reference_counter+=1
          Hash[
              [['@id',ref_id]] + attribute_names.map do |attr_name|
                value = obj.send attr_name.to_sym
                if @reference_map.has_key? value.object_id
                  [attr_name, {'@ref'=>@reference_map[value.object_id].to_s}]
                else
                  [attr_name, encode(value)]
                end

              end

          ]
        else
          if @reference_map.has_key? obj.object_id
            {'@ref'=>@reference_map[value.object_id].to_s}
          else
            obj
          end
        end
      end
    end


  end
end
