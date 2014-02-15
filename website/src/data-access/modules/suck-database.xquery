(: import uri: ##none :)

<documents xmlns=""> {
  for $doc in collection('/db/cxan/')
  return
    <doc uri="{ document-uri($doc) }"> {
      $doc
    }
    </doc>
}
</documents>
