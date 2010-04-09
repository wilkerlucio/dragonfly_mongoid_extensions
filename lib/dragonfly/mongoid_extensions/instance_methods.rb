module Dragonfly
  module MongoidExtensions
    module InstanceMethods
      
      def attachments
        @attachments ||= self.class.dragonfly_apps_for_attributes.inject({}) do |hash, (attribute, app)|
          hash[attribute] = Attachment.new(app, self, attribute)
          hash
        end
      end

      private
      
      def save_attachments
        attachments.each do |attribute, attachment|
          attachment.save!
        end
      end
      
      def destroy_attachments
        attachments.each do |attribute, attachment|
          attachment.destroy!
        end
      end
      
      def check_attachments_for_remove
        attachments.each do |attribute, attachment|
          if instance_variable_get("@remove_#{attribute}").to_s.match(/^1|true$/i)
            send("#{attribute}_uid=", nil)
            attachment.destroy!
          end
        end
      end
    end
  end
end