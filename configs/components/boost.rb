component "boost" do |pkg, settings, platform|
  pkg.version "1.57.0"
  pkg.md5sum "25f9a8ac28beeb5ab84aa98510305299"
  # Apparently boost doesn't use dots to version they use underscores....arg
  pkg.url "http://buildsources.delivery.puppetlabs.net/#{pkg.get_name}_#{pkg.get_version.gsub('.','_')}.tar.gz"

  # This is pretty horrible.  But so is package management on OSX.
  if platform.is_osx?
    pkg.build_requires "pl-gcc-4.8.2"
    gpp = "#{settings[:bindir]}/g++"
  elsif platform.is_solaris?
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-gcc-4.8.2.#{platform.architecture}.pkg.gz"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-binutils-2.25.#{platform.architecture}.pkg.gz"

    pkg.environment "PATH" => "#{settings[:basedir]}/bin:/usr/ccs/bin:/usr/sfw/bin:$$PATH"
    linkflags = "-Wl,-rpath=#{settings[:libdir]}"
    b2flags = "define=_XOPEN_SOURCE=600"
    cflags = ""
    gpp = "#{settings[:basedir]}/bin/#{settings[:platform_triple]}-g++"
  else
    pkg.build_requires "pl-gcc"

    pkg.environment "PATH" => "#{settings[:bindir]}:$$PATH"
    linkflags = "-Wl,-rpath=#{settings[:libdir]},-rpath=#{settings[:libdir]}64"
    b2flags = ""
    cflags = "-fPIC"
    gpp = "#{settings[:bindir]}/g++"
  end

  pkg.build do
    [
      %Q{echo 'using gcc : 4.8.2 : #{gpp} : <linkflags>"#{linkflags}" <cflags>"#{cflags}" <cxxflags>"#{cflags}" ;' > ~/user-config.jam},
      "cd tools/build",
      "./bootstrap.sh --with-toolset=gcc",
      "./b2 install -d+2 --prefix=#{settings[:prefix]} toolset=gcc --debug-configuration"
    ]
  end

  pkg.install do
    [ "#{settings[:prefix]}/bin/b2 \
    -d+2 \
    #{b2flags} \
    --debug-configuration \
    --build-dir=. \
    --prefix=#{settings[:prefix]} \
    --with-filesystem \
    --with-log \
    --with-program_options \
    --with-regex \
    --with-system \
    --with-thread \
    --with-locale \
    --with-random \
    --with-chrono \
    install",
    "chmod 0644 #{settings[:includedir]}/boost/graph/vf2_sub_graph_iso.hpp",
    "chmod 0644 #{settings[:includedir]}/boost/thread/v2/shared_mutex.hpp"
    ]
  end

end
