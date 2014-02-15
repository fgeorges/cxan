declare namespace cxan = "http://cxan.org/ns/package";

<authors xmlns=""> {
   let $authors := collection('/db/cxan/packages/')/cxan:package/cxan:author
   for $a  in distinct-values($authors)
   for $id in distinct-values($authors[. eq $a]/@id)
   order by $a, $id
   return
      <author id="{ $id }">{ $a }</author>
}
</authors>
