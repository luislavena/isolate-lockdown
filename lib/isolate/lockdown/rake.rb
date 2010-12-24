namespace :isolate do
  task :lockdown, [:folder] do |t, args|
    include Isolate::Lockdown

    args.with_defaults(:folder => 'tmp/lockdown')

    folder = args.folder
    safe_folder = "#{folder}.safe"
    temp_folder = "#{folder}.#{$$}"

    # remove previous safe folder if exists
    when_writing "remove previous safe folder" do
      FileUtils.rm_rf safe_folder if File.exist?(safe_folder)
    end

    # collect entries valid for current environment
    entries = Isolate.sandbox.entries.find_all { |e| e.matches?(Isolate.env) }

    # determine which specs are really needed
    specs = legitimize!(entries)

    # collect gem lib dir to be used for require
    require_paths = []

    specs.each do |spec|
      puts "Locking down #{spec.name} version #{spec.version}..."

      base = spec.full_gem_path

      spec.add_bindir(spec.executables).each do |exe|
        bin_dir = File.join(temp_folder, 'bin')
        full_exe = File.join(base, exe)

        FileUtils.mkdir_p(bin_dir) unless File.exist?(bin_dir)
        FileUtils.cp full_exe, bin_dir
      end
    end
  end
end
