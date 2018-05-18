module Poros
  module Relations
    def has_many(key)
      define_method key do
        object = constantize(singularize(key))
        foreign_key = (self.class.to_s.downcase + '_uuid').to_sym

        object.where(foreign_key => self.uuid)
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
      object_name = word.split('_').map(&:capitalize).join

      Object.const_get(object_name)
    end
  end
end

