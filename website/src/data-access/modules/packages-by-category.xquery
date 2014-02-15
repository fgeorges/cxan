declare namespace cxan = "http://cxan.org/ns/package";

declare variable $category := '@@.category.@@';

declare function local:copy($cat as element(cat)) {
  <cat xmlns=""> {
    $cat/@*
    ,
    let $pp := collection('/db/cxan/packages/')/cxan:package[cxan:category/@id eq $cat/@id]
    for $p in distinct-values($pp/@id)
    order by $p
    return
      <pkg id="{ $p }"/>
    ,
    for $c in $cat/cat return local:copy($c)
  }
  </cat>
};

let $c := doc('/db/cxan/categories.xml')/categories//cat[@id eq $category]
return
  if ( $c ) then local:copy($c) else ()
