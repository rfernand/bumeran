# Bumeran

This gem was made to connect to the Bumeran api found in https://developers.bumeran.com 

## Getting started

Bumeran works with Rails 3.2 onwards. You can add it to your Gemfile with:

```ruby
gem 'bumeran'
```

...or can fetch the lastest developer version with:

```ruby
gem 'bumeran', :git => 'git@github.com:rfernand/bumeran.git', :branch => 'develop'
```
### Configuration

After you finished the gem installation, you need to configure it with your Bumeran user information. You can do it filling a file like config/initializers/bumeran.rb with:

```ruby
Bumeran.setup do |config|
  config.grant_type = "password" # Default value
  config.client_id  = ""         # Bumeran client id
  config.username   = ""         # Bumeran client username
  config.email      = ""         # Bumeran client email
  config.password   = ""         # Bumeran client password
end
```
## How to use


And more that don't need an ID. All return a json object, and raise an error (401, 404, 500) if there was one:
### Create a new publication
```ruby
publication = Bumeran::Publication.new
Bumeran.publish(publication.body.to_json)
```
### Get a publication
```ruby
Bumeran.get_publication(publication_id)
```
### And a lot of more getters

They recieve a corresponding object id and return a json object.

```ruby
Bumeran.get_estudio(estudio_id)
Bumeran.get_conocimiento(conocimiento_id)
Bumeran.get_conocimiento_custom(conocimiento_custom_id)
Bumeran.get_experiencia_laboral(experiencia_laboral_id)
Bumeran.get_postulacion(postulacion_id)
Bumeran.get_curriculum(curriculum_id)
Bumeran.get_subareas_in(area_id)
Bumeran.get_zonas_in(pais_id)
Bumeran.get_localidades_id(pais_id)
Bumeran.get_plan_publicaciones_in(pais_id)
```

### More queries and helpers
All return a json object. After the first query, the returned json is cached in the Bumeran module.

```ruby
Bumeran.areas
Bumeran.subareas
Bumeran.frecuencias_pago
Bumeran.paises
Bumeran.denominaciones
Bumeran.direcciones
Bumeran.frecuencias_pago
Bumeran.idiomas
Bumeran.industrias
Bumeran.niveles_idiomas
Bumeran.tipos_trabajo
Bumeran.areas_estudio
Bumeran.estados_estudio
Bumeran.tipos_estudio
Bumeran.tipos_estudio
```
