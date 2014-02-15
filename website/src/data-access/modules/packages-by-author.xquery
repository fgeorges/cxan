declare namespace cxan = "http://cxan.org/ns/package";

(: TODO: Should use "as external", but that is not supported by eXist REST-like API. :)
declare variable $author := '@@.author.@@';

<packages-by-author xmlns=""> {
   let $pp := collection('/db/cxan/packages/')/cxan:package[cxan:author/@id = $author]
   return (
     <author>{ ( $pp/cxan:author[@id = $author] )[1]/string(.) }</author>,
     for $p in distinct-values($pp/@id)
     order by $p
     return
       <pkg id="{ $p }"/>
   )
}
</packages-by-author>
