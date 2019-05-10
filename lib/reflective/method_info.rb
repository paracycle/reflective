module Reflective
  class MethodInfo
    def initialize(constant, method_name, visibility: :public)
      @method = Module.instance_method(:instance_method).bind(constant).call(method_name)
      @visibility = visibility
    end

    attr_reader :method, :visibility

    def name
      @name ||= UnboundMethod.instance_method(:name).bind(method).call
    end

    def owner
      @owner ||= method.owner
    end

    def public?
      visibility == :public
    end

    def protected?
      visibility == :protected
    end

    def private?
      visibility == :private
    end

    def static?
      Module.instance_method(:singleton_class?).bind(owner).call
    end

    def <=>(other)
      name <=> other.name
    end
  end
end
