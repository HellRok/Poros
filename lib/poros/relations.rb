module Poros
  module Relations
    def has_many(key)
      define_method key do
        object = constantize(singularize(key))
        foreign_key = (self.class.to_s.downcase + '_uuid').to_sym

        object.where(foreign_key => self.uuid)
      end
    end

    def belongs_to(key)
      define_method key do
        object = constantize(key)
        foreign_key = (key.to_s + '_uuid').to_sym

        object.find(self.send(foreign_key))
      end

      define_method key.to_s + '=' do |value|
        foreign_key = (key.to_s + '_uuid=')

        self.send(foreign_key, value.uuid)
      end
    end

    private

    def singularize(word)
      # I don't want to depend on rails or another gem so I'm doing something
      # incredibly basic that'll work 90+% of the time (for English anyways).
      case word.to_s
      when /ies$/
        word.to_s.chomp('ies') + 'y'
      when /s$/
        word.to_s.chomp('s')
      else
        word.to_s
      end
    end

    def constantize(word)
      object_name = word.to_s.split('_').map(&:capitalize).join

      Object.const_get(object_name)
    end
  end
end

