module Poros
  module Relations
    def has_many(key, class_name: nil, foreign_key: nil, primary_key: :uuid)

      define_method key do
        foreign_key = (foreign_key || self.class.to_s.downcase + '_uuid').to_sym
        object = constantize(singularize(class_name || key))
        primary_value = self.send(primary_key)

        object.where(foreign_key => primary_value)
      end
    end

    def belongs_to(key, class_name: nil, foreign_key: nil, primary_key: :uuid)
      define_method key do
        object = constantize(class_name || key)
        foreign_method = (foreign_key || (key.to_s + '_uuid')).to_sym
        primary_attr = primary_key || (key.to_s + '_uuid')

        object.where(primary_attr => self.send(foreign_method)).first
      end

      define_method key.to_s + '=' do |value|
        foreign_attr = foreign_key || (key.to_s + '_uuid=')
        primary_method = primary_key || (key.to_s + '_uuid')

        self.send(foreign_attr, value.send(primary_method))
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
      object_name = word
      if word.downcase == word
        object_name = word.to_s.split('_').map(&:capitalize).join
      end

      Object.const_get(object_name)
    end
  end
end
