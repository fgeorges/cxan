declare variable $name    := '@@.name.@@';
declare variable $version := '@@.version.@@';

let $p := doc('/db/cxan/packages.xml')/packages/pkg[name eq $name]
let $v :=
      if ( $version[.] ) then
        $version
      else
        (: TODO: Sort not as a string, but as a SemVer instead. :)
        ( for $v_ in $p/version/@id order by $v_ descending return $v_ )[1]
return
  $p/version[@id eq $v]/file[1]
