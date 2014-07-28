class xp::radosgw::apache {
  exec { 'key-add':
    path    => ['/usr/bin'],
    command => 'wget -q -O- https://raw.github.com/ceph/ceph/master/keys/autobuild.asc | sudo apt-key add -'
  }

  $ceph_apache_list = '/etc/apt/sources.list.d/ceph-apache.list'
  file { $ceph_apache_list:
    ensure  => present,
    content => "deb http://gitbuilder.ceph.com/apache2-deb-wheezy-x86_64-basic/ref/master wheezy main"
  }

  $ceph_fastcgi_list = '/etc/apt/sources.list.d/ceph-fastcgi.list'
  file { $ceph_fastcgi_list:
    ensure  => present,
    content => "deb http://gitbuilder.ceph.com/libapache-mod-fastcgi-deb-wheezy-x86_64-basic/ref/master wheezy main"
  }
  exec { 'apt-update':
    path    => ['/usr/bin'],
    command => 'apt-get update',
    require => [Exec['key-add'], File[$ceph_apache_list], File[$ceph_fastcgi_list]]
  }

  package { 
    ['apache2', 'libapache2-mod-fastcgi']:
    ensure  => installed,
    require => Exec['apt-update']
  }

  # TODO ServerName in apache2

  # enable apache modules
  exec { 'mod-rewrite':
    path    => ['/usr/sbin', '/usr/bin'],
    command => 'a2enmod rewrite',
    require => Package['apache2']
  }

  exec { 'mod-fastcgi':
    path    => ['/usr/sbin', '/usr/bin'],
    command => 'a2enmod fastcgi',
    require => [Package['libapache2-mod-fastcgi'], Exec['mod-rewrite']],
    notify  => Service['apache2']
  }

  service { 'apache2':
    ensure  => 'running',
    require => [Package['apache2']]
  }

  $radosgw_host = hiera('ceph_radosgw')
  # enable the specific site
  file {
    '/etc/apache2/sites-available/rgw.conf':
      ensure  => file,
      mode    => '0644',
      owner   => root,
      group   => root,
      content => template('xp/ceph/rgw.conf.erb'),
      require => [Package['apache2']]
  }


  exec { 'enable-rgw-site':
    path    => ['/usr/sbin', '/usr/bin'],
    command => 'a2ensite rgw.conf',
    require => [Package['apache2']],
    notify  => Service['apache2']
  }

  exec { 'disable-default-site':
    path    => ['/usr/sbin', '/usr/bin'],
    command => 'a2dissite default',
    require => [Package['apache2']],
    notify  => Service['apache2']
  }

  file { '/var/www/s3gw.fcgi':
    ensure  => file,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    source  => "puppet://${puppetmaster}/modules/xp/radosgw/s3gw.fcgi",
    require => Package['apache2'],
    notify  => Service['apache2']
  }


}
