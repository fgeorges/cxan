declare namespace cxan = "http://cxan.org/ns/package";

<packages xmlns=""> {
  for $pkg in doc('/db/cxan/packages.xml')/packages/pkg
  order by $pkg/@id
  return
    <pkg>
      <id>{ string($pkg/@id) }</id>
      <name>{ string($pkg/name) }</name>
      {
        let $ver := ( for $v in $pkg/version/@id order by $v descending return $v )[1]
        let $uri := concat('/db/cxan/packages/', $pkg/@id, '/', $ver, '/cxan.xml')
        let $abs := doc($uri)/cxan:package/cxan:abstract
        return
          if ( exists($abs) ) then
            <desc>{ normalize-space($abs) }</desc>
          else
            ()
      }
    </pkg>
}
</packages>
