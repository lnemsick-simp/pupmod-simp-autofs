# Specification for parameters needed to create an autofs::map
#
type Autofs::Mapspec = Struct[{
  mount_point    => Stdlib::Absolutepath,
  master_options => Optional[String],
  mappings       => Variant[Autofs::DirectMapping, Array[Autofs::IndirectMapping,1]]
}]
