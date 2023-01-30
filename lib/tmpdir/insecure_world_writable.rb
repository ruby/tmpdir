# frozen_string_literal: true

class Dir
  module Tmpname
    module InsecureWorldWritable
      refine File::Stat do
        def insecure_world_writable?
          world_writable? && !sticky?
        end

        def not_insecure_world_writable?
          !insecure_world_writable?
        end
      end
    end
  end
end
