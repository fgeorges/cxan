(: import uri: ##none :)

declare function local:basename($uri as xs:string) as xs:string
{
  tokenize($uri, '/')[last()]
};

declare function local:dirname($uri as xs:string, $basename as xs:string) as xs:string
{
  substring($uri, 0, string-length($uri) - string-length($basename))
};

declare function local:ensure-coll($uri as xs:string) as xs:string*
{
  if ( xmldb:collection-available($uri) ) then
    ()
  else
    let $name := local:basename($uri)
    let $dir  := local:dirname($uri, $name)
    return (
      local:ensure-coll($dir),
      xmldb:create-collection($dir, $name)
    )
};

declare function local:restore($backup as xs:string) as xs:string*
{
  (: TODO: Pass the document name in param... :)
  for $doc  in doc('/db/cxan/backup.xml')/documents/doc
  let $root := $doc/*
  let $uri  := $doc/@uri
  let $name := local:basename($uri)
  let $coll := local:dirname($uri, $name)
  return
    if ( starts-with($uri, '/db/cxan') ) then (
      local:ensure-coll($coll),
      xmldb:store($coll, $name, $root)
    )
    else (
      error(xs:QName('DB001'), concat('URI in the wrong collection: ', $uri))
    )
};

if ( count(collection('/db/cxan')) eq 1	) then
  <result> {
    (: TODO: Pass the document name in param... :)
    for $s in local:restore('/db/cxan/backup.xml')
    return
      <created>{ $s }</created>
  }
  </result>
else
  error(xs:QName('DB002'), 'More than one document in /db/cxan !')

