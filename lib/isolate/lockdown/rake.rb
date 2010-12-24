namespace :isolate do
  task :lockdown, [:folder] do |t, args|
    include Isolate::Lockdown

    args.with_defaults(:folder => 'tmp/lockdown')

    folder = args.folder
    safe_folder = "#{folder}.safe"
    temp_folder = "#{folder}.#{$$}"
    loader_script = File.join(folder, 'paths.rb')

    # remove previous safe folder if exists
    when_writing "Removing previous safe folder" do
      FileUtils.rm_rf safe_folder if File.exist?(safe_folder)
    end

    # collect entries valid for current environment
    entries = Isolate.sandbox.entries.find_all { |e| e.matches?(Isolate.env) }

    # determine which specs are really needed
    specs = legitimize!(entries)

    # collect gem lib dir to be used for require
    require_paths = []

    specs.each do |spec|
      puts "Locking down #{spec.name} version #{spec.version}"

      base = spec.full_gem_path

      spec.add_bindir(spec.executables).each do |exe|
        bin_dir = File.join(temp_folder, 'bin')
        full_exe = File.join(base, exe)

        FileUtils.mkdir_p(bin_dir) unless File.exist?(bin_dir)
        FileUtils.cp full_exe, bin_dir
      end

      spec.require_paths.each do |path|
        # do not add bindir to load path
        next if path == spec.bindir

        lib_dir = File.join(temp_folder, path)
        require_paths << File.join(folder, path)

        FileUtils.mkdir_p(lib_dir)

        glob = File.join(base, path, '*')
        Dir.glob(glob).each do |full_lib|
          if File.file?(full_lib)
            FileUtils.cp(full_lib, lib_dir)
          else
            FileUtils.cp_r(full_lib, lib_dir)
          end
        end
      end
    end

    FileUtils.mv(folder, safe_folder) if File.exist?(folder)
    FileUtils.mv(temp_folder, folder)

    when_writing("Updating #{loader_script}") do
      File.open(loader_script, 'w') do |f|
        require_paths.uniq.each do |path|
          f.puts "$:.unshift File.expand_path(#{path.inspect})"
        end
      end
    end
  end
end
