class xp::radosgw {

  include xp::ntp
  include xp::ceph
  require xp::radosgw::apache


  package { 'radosgw':
    ensure => installed
  }
  
  $user = hiera('user')
  $secret_key = hiera('secret_key')
  $access_key = hiera('access_key')
  # create on user
  exec { 'test-user':
    path    => ['/usr/bin'],
    command => "radosgw-admin user create --uid=${user} --display-name=${user} --secret=${secret_key} --access-key=${access_key}",
    require => Package['radosgw']
  }

}

