declare namespace cxan = "http://cxan.org/ns/package";

<tags xmlns=""> {
  for $t in distinct-values(collection('/db/cxan/packages/')/cxan:package/cxan:tag)
  order by $t
  return
    <tag>{ $t }</tag>
}
</tags>
