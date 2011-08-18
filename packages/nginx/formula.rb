class Nginx < DebianFormula
  homepage 'http://nginx.org/'
  url 'http://nginx.org/download/nginx-1.0.4.tar.gz'
  md5 'd23f6e6b07b57ac061e790b1ed64bb98'

  source 'https://github.com/agentzh/chunkin-nginx-module.git', :sha => '0654f34'
  source 'https://github.com/agentzh/headers-more-nginx-module.git', :tag => 'v0.15'
  source 'https://github.com/vkholodkov/nginx-upload-module.git', :tag => '2.2.0'

  name 'nginx'
  version '1.0.4+github4'
  section 'httpd'
  description 'a high performance web server and a reverse proxy server'

  build_depends \
    'libpcre3-dev',
    'zlib1g-dev',
    'libssl-dev (<< 1.0.0)'

  depends \
    'libpcre3',
    'zlib1g',
    'libssl0.9.8'

  provides  'nginx-full', 'nginx-common'
  replaces  'nginx-full', 'nginx-common'
  conflicts 'nginx-full', 'nginx-common'

  config_files \
    '/etc/nginx/nginx.conf',
    '/etc/nginx/mime.types',
    '/var/www/nginx-default/index.html'

  def patches
    {:p0 => 'request_start_variable.patch'}
  end

  def build
    configure \
      '--with-http_stub_status_module',
      '--with-http_ssl_module',
      '--with-http_gzip_static_module',
      '--with-pcre',
      '--with-debug',

      "--add-module=#{builddir/'chunkin-nginx-module.git'}",
      "--add-module=#{builddir/'headers-more-nginx-module.git'}",
      "--add-module=#{builddir/'nginx-upload-module.git'}",

      :prefix => prefix,

      :user => 'www-data',
      :group => 'www-data',

      :pid_path => '/var/run/nginx.pid',
      :lock_path => '/var/lock/nginx.lock',
      :conf_path => '/etc/nginx/nginx.conf',
      :http_log_path => '/var/log/nginx/access.log',
      :error_log_path => '/var/log/nginx/error.log',
      :http_proxy_temp_path => '/var/lib/nginx/proxy',
      :http_fastcgi_temp_path => '/var/lib/nginx/fastcgi',
      :http_client_body_temp_path => '/var/lib/nginx/body'

    make
  end

  def install
    # startup script
    (etc/'init.d').install_p(workdir/'init.d', 'nginx')

    # config files
    (etc/'nginx').install Dir['conf/*']

    # default site
    (var/'www/nginx-default').install Dir['html/*']

    # server
    sbin.install Dir['objs/nginx']

    # man page
    man8.install Dir['objs/nginx.8']
    sh 'gzip', man8/'nginx.8'

    # support dirs
    %w( run lock log/nginx lib/nginx ).map do |dir|
      (var/dir).mkpath
    end
  end
end
