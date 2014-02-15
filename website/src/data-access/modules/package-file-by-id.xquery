declare variable $id      := '@@.id.@@';
declare variable $version := '@@.version.@@';

let $p := doc('/db/cxan/packages.xml')/packages/pkg[@id eq $id]
let $v :=
      if ( $version[.] ) then
        $version
      else
        (: TODO: Sort not as a string, but as a SemVer instead. :)
        ( for $v_ in $p/version/@id order by $v_ descending return $v_ )[1]
return
  $p/version[@id eq $v]/file[1]
