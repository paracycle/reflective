# typed: false

module Reflective
  class Type
    def self.for(name)
      constant = Object.const_get(name, false)
      new(constant)
    end

    def initialize(constant)
      @constant = constant
    end

    attr_reader :constant

    def constants
      constants = Module.instance_method(:constants).bind(@constant).call(false)
      constants.map do |const|
        [const, constant.const_get(const, false)]
      end.to_h
    end

    def methods(own: true, visibility: [:public, :protected, :private], kind: :instance)
      kind = Array(kind)
      visibility = Array(visibility)
      methods = []

      if kind.include?(:instance)
        methods.concat(methods_for(constant, own: own, visibility: visibility))
      end

      if kind.include?(:class)
        methods.concat(methods_for(constant.singleton_class, own: own, visibility: visibility))
      end

      methods
    end

    def name
      Module.instance_method(:name).bind(constant).call
    end

    def class
      Kernel.instance_method(:class).bind(constant).call
    end

    def superclass
      return unless Class == constant
      Class.instance_method(:superclass).bind(constant).call
    end

    def equal?(other)
      BasicObject.instance_method(:equal?).bind(constant).call(other)
    end

    def ==(other)
      constant == other.constant
    end

    def public?
      constant_name = name
      return false unless constant_name

      begin
        # can't use !! here because the constant might override ! and mess with us
        eval(constant_name) # rubocop:disable Security/Eval
        true
      rescue NameError
        false
      end
    end

    private

    def methods_for(mod, own:, visibility:)
      method_names_by_visibility(mod)
        .delete_if { |vis, _method_list| !visibility.include?(vis) }
        .flat_map do |visibility, method_list|
          method_list
            .sort!
            .map do |name|
              next if name == :initialize
              MethodInfo.new(mod, name, visibility: visibility)
            end
            .compact
            .select do |method_info|
              !own || method_info.owner == mod
            end
        end
    end

    def method_names_by_visibility(mod)
      {
        public: Module.instance_method(:public_instance_methods).bind(mod).call,
        protected: Module.instance_method(:protected_instance_methods).bind(mod).call,
        private: Module.instance_method(:private_instance_methods).bind(mod).call,
      }
    end

  end
end
