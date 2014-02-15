declare variable $id := '@@.id.@@';

let $p := doc('/db/cxan/packages.xml')/packages/pkg[@id eq $id]
(: TODO: Sort not as a string, but as a SemVer instead. :)
let $v := ( for $v_ in $p/version/@id order by $v_ descending return $v_ )[1]
let $c := concat('/db/cxan/packages/', $id, '/')
return
  <package xmlns=""> {
    $p,
    (: Return the latest cxan.xml, but the package descriptor for every
       version (to describe the dependencies for each version, for
       instance).  But the cxan.xml info are for the entire package. :)
    (: TODO: This explicit loop is a work around the bug I reported at
       http://exist.markmail.org/thread/vqn2ojcpfxcl6syf in eXist SVN
       pre-1.5. :)
    for $v_ in $p/version/@id return
      doc(concat($c, $v_, '/expath-pkg.xml')),
    doc(concat($c, $v, '/cxan.xml'))
  }
  </package>
