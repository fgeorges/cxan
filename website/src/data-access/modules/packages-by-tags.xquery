declare namespace cxan = "http://cxan.org/ns/package";

declare variable $tags-str := '@@.tags.@@';

declare function local:match($p as element(cxan:package), $tags as xs:string+)
{
  every $t in $tags satisfies $p[cxan:tag = $t]
};

let $tags := tokenize($tags-str, '/')
let $pp   := collection('/db/cxan/packages/')/cxan:package[local:match(., $tags)]
return
  <tags xmlns=""> {
    for $t in $tags
    order by $t
    return
      <tag id="{ $t }"/>,
    for $t in distinct-values($pp/cxan:tag)[not(. = $tags)]
    order by $t
    return
      <subtag id="{ $t }"/>,
    for $p in distinct-values($pp/@id)
    order by $p
    return
      <pkg id="{ $p }"/>
  }
  </tags>
