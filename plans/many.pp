plan protoahv::many(
  $base      = 'plan',
  $source    = 'glob1',
  $key,
  $container = 'default-container-9292',
  $crm       = '10.16.22.49',
  $cores     = 2,
  $ram       = 2048,
  $number    = 10,
) {


  range(1, $number).each |$n| {
    $userdata = epp('protoahv/userdata.epp', {
        'name' => "${base}${n}",
        'key'  => $key,
      }
    )
    run_task('protoahv::clone', $crm, {
        name      => "${base}${n}",
        source    => $source,
        key       => $key,
        container => $container,
        cores     => $cores,
        ram       => $ram,
        userdata  => $userdata,
      }
    )
  }
}
