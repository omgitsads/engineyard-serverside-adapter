require 'escape'

module EY
  module Serverside
    module Adapter
      class Command
        def initialize(*task)
          @task = task
          @arguments = []
        end
        
        def to_s
          Escape.shell_command [
            'engineyard-serverside',
            "_#{VERSION}_",
          ] + @task + @arguments
        end

        def array_argument(switch, values)
          compacted = values.compact.sort
          if compacted.any?
            @arguments << switch
            @arguments += values
          end
        end

        def boolean_argument(switch, value)
          if value
            @arguments << switch
          end
        end

        def hash_argument(switch, pairs)
          if pairs.any? {|k,v| !v.nil?}
            @arguments << switch
            @arguments += pairs.reject { |k,v| v.nil? }.map { |pair| pair.join(':') }.sort
          end
        end

        def instances_argument(instances)
          array_argument('--instances', instances.map{|i| i[:hostname]})

          role_pairs = instances.inject({}) do |roles, instance|
            roles.merge(instance[:hostname] => instance[:roles].join(','))
          end
          hash_argument('--instance-roles', role_pairs)

          role_pairs = instances.inject({}) do |roles, instance|
            roles.merge(instance[:hostname] => instance[:name])
          end
          hash_argument('--instance-names', role_pairs)
        end

        def string_argument(switch, value)
          @arguments << switch << value
        end

      end
    end
  end
end