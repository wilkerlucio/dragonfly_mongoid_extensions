module Dragonfly
  module MongoidExtensions
    module ClassMethods

      include Validations

      def register_dragonfly_app(accessor_prefix, app)
        metaclass.class_eval do
    
          # Defines e.g. 'image_accessor' for any activerecord class body
          define_method "#{accessor_prefix}_accessor" do |*args|
            attribute = args.shift
            options = args.length > 0 ? args.shift : {}
            
            # Define field for mongoid
            field "#{attribute}_uid"
            
            # Define ActiveRecord missing dirty events
            attr_reader "#{attribute}_uid_was"
          
            define_method "#{attribute}_uid=" do |value|
              if value != send("#{attribute}_uid")
                instance_variable_set("@#{attribute}_uid_changed", true)
                instance_variable_set("@#{attribute}_uid_was", send("#{attribute}_uid"))
              end
            
              write_attribute("#{attribute}_uid", value)
            end
          
            define_method "#{attribute}_uid_changed?" do
              instance_variable_get("@#{attribute}_uid_changed") || false
            end

            define_method "#{attribute}_uid_change" do
              send("#{attribute}_uid_changed?") ? [send("#{attribute}_uid_was"), send("#{attribute}_uid")] : nil
            end
            
            before_destroy do |obj|
              obj.send "#{attribute}_uid=", nil
            end
            
            # Prior to activerecord 3, adding before callbacks more than once does add it more than once
            before_save :save_attachments unless respond_to?(:before_save_callback_chain) && before_save_callback_chain.find(:save_attachments)
            before_destroy :destroy_attachments unless respond_to?(:before_destroy_callback_chain) && before_destroy_callback_chain.find(:destroy_attachments)
      
            # Register the new attribute
            dragonfly_apps_for_attributes[attribute] = app
            
            # Define default, if has
            if options[:default]
              define_method "#{attribute}_default" do
                options[:default]
              end
            end
            
            # Define the setter for the attribute
            define_method "#{attribute}=" do |value|
              attachments[attribute].assign(value)
            end
      
            # Define the getter for the attribute
            define_method attribute do
              attachments[attribute].to_value
            end
            
            # Define methods for delete
            define_method "remove_#{attribute}" do
              instance_variable_get("@remove_#{attribute}") || 0
            end
            
            define_method "remove_#{attribute}=" do |value|
              instance_variable_set("@remove_#{attribute}", value)
            end
            
            before_save :check_attachments_for_remove
          end
    
        end
        app
      end
      
      def dragonfly_apps_for_attributes
        @dragonfly_apps_for_attributes ||= {}
      end
    end
  end
end