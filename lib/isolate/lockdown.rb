require 'isolate'
require 'isolate/lockdown/rake' if defined?(Rake)

module Isolate::Lockdown
  # Adapt from Isolate own source code
  def legitimize!(deps)
    specs = []

    deps.flatten.each do |dep|
      spec = Gem.source_index.find_name(dep.name, dep.requirement).last

      if spec
        specs.concat legitimize!(spec.runtime_dependencies)
        specs << spec
      end
    end

    specs.uniq
  end
end
