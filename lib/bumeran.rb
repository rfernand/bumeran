require 'rails'
require 'time'
require 'httparty'
require 'erb'

module Bumeran
  include HTTParty
  base_uri 'https://developers.bumeran.com'

  # API login configuration, need initialization setup to work
  mattr_accessor :grant_type
  @@grant_type = "password"

  mattr_accessor :client_id
  @@client_id = nil

  mattr_accessor :username
  @@username = nil

  mattr_accessor :email
  @@email    = nil

  mattr_accessor :password
  @@password    = nil

  mattr_accessor :access_token
  @@access_token = nil

  @@token_type= nil

  mattr_accessor :expires_in
  @@expires_in = nil

  mattr_accessor :access_token_updated_at
  @@access_token_updated_at = nil

  mattr_accessor :options
  @@options = nil

  @@areas               = {}
  @@subareas            = {}
  @@paises              = {}
  @@zonas               = {}
  @@localidades         = {}
  @@plan_publicaciones  = {}
  @@frecuencias_pago    = {}
  @@idiomas             = {}
  @@industrias          = {}
  @@niveles_idiomas     = {}
  @@tipos_trabajo       = {}
  @@areas_estudio       = {}
  @@estados_estudio     = {}
  @@tipos_estudio       = {}
  @@direcciones         = {}
  @@denominaciones      = {}

  

  # Default way to setup Bumeran.
  def self.setup
    yield self
  end

  def self.initialize
    unless has_valid_access_token?
      login
      @@options = { query: {access_token: @@access_token} }
    end
  end


  def self.has_valid_access_token?
    if @@access_token_updated_at && @@expires_in
      (Time.now < @@access_token_updated_at  + @@expires_in)
    else
      false
    end
  end 

  # Publicaciones / Avisos

  # alias
  def self.publicar_aviso(aviso_id, plan_publicacion_id, pais_id)
    Bumeran.publish_publication(aviso_id, plan_publicacion_id, pais_id)
  end

  # alias
  def self.create_aviso(json)
    Bumeran.create_publication(json)
  end

  # alias
  def self.get_aviso(aviso_id)
    Bumeran.get_publication(aviso_id)
  end

  # alias
  def self.get_postulaciones_en_aviso(aviso_id)
    Bumeran.get_postulations_in_publication(aviso_id)
  end

  # alias
  def self.destroy_aviso(aviso_id)
    Bumeran.destroy_publication(aviso_id)
  end

  # creates and publish a publication
  def self.publish(json, pais_id, plan_publication_id)
    publication_id = Bumeran.create_publication(json)
    Bumeran.publish_publication(publication_id, pais_id, plan_publication_id)
    return publication_id
  end

  #

  def self.create_publication(json)
    Bumeran.initialize
    create_publication_path = "/v0/empresas/avisos"
    response = self.put(create_publication_path, @@options.merge(body: json, headers: { "Accept" => "application/json", "Content-Type" => "application/json"}))

    if Parser.parse_response(response)
      case response.code
        when 201
          # "Publication created, All good!"
          return response # body contains id del proceso publicado
        when 200
          # "TODO: Uhm.. no idea, is this good?"
          return response # body contains id del proceso publicado?
      end
    end
  end

  def self.publish_publication(publication_id, pais_id, plan_publication_id)
    Bumeran.initialize
    publish_publication_path = "/v0/empresas/avisos/#{publication_id}/publicacion/#{plan_publication_id}"
    response = self.put(publish_publication_path, @@options.merge(query: @@options[:query].merge({paisId: pais_id})))

    if Parser.parse_response(response)
      case response.code
        when 201
          # "Publication created, All good!"
          return response # body contains id del proceso publicado
        when 200
          # "TODO: Uhm.. no idea, is this good?"
          return response # body contains id del proceso publicado?
      end
    end
  end

  def self.get_publication(publication_id)
    Bumeran.initialize
    get_publication_path = "/v0/empresas/avisos/#{publication_id}"
    response = self.get(get_publication_path, @@options)

    return Parser.parse_response_to_json(response)
  end

  def self.get_postulations_in_publication(publication_id, page=0, postulations_per_page=20)
    Bumeran.initialize
    get_postulations_in_publication_path = "/v0/empresas/avisos/#{publication_id}/postulaciones"
    response = self.get(get_postulations_in_publication_path, @@options.merge(query: @@options[:query].merge({page: page, perPage: postulations_per_page})))

    return Parser.parse_response_to_json(response)
  end

  def self.get_postulation(postulation_id)
    Bumeran.initialize
    get_postulation_path = "/v0/empresas/postulaciones/#{postulation_id}"
    response = self.get(get_postulation_path, @@options)

    return Parser.parse_response_to_json(response)
  end

  def self.destroy_publication(publication_id)
    Bumeran.initialize
    destroy_publication_path = "/v0/empresas/avisos/#{publication_id}"
    response = self.delete(destroy_publication_path, @@options)

    return Parser.parse_response(response)
  end

  # Generation of service helpers
  SERVICES = {
    areas: {object: :area},
    subareas: {object: :subarea, parent: :area, parent_service: :areas},
    paises: {object: :pais},
    zonas: {object: :zona, parent: :pais, parent_service: :paises},
    localidades: {object: :localidad, parent: :zona, parent_service: :zonas},
    plan_publicaciones: {object: :plan_publicacion, parent: :pais, parent_service: :paises},
    denominaciones: {object: :denominacion},
    direcciones: {object: :direccion},
    frecuencias_pago: {object: :frencuencia_pago},
    idiomas: {object: :idioma},
    industrias: {object: :industria},
    niveles_idiomas: {object: :niveles_idioma},
    tipos_trabajo: {object: :tipo_trabajo},
    areas_estudio: {object: :area_estudio},
    estados_estudio: {object: :estado_estudio},
    tipos_estudio: {object: :tipo_estudio}
  }

  # GENERIC HELPER
  def self.generic_find_by_id(objects_sym, object_id)                       #def self.pais(pais_id)
    object = send(objects_sym).select{|id, content| id == object_id}        #  pais = paises.select{|id, pais| id == pais_id}
    object ? object[object_id] : nil                                        #  pais ? pais[pais_id] : nil
  end                                                                       #end                                               

  def self.generic_find_all_in(objects_sym, parent_object_sym, parent_service_sym, parent_object_id)  
    if !class_variable_get("@@#{objects_sym}").empty? &&  send(parent_object_sym, parent_object_id)[objects_sym.to_s] # if !@@zonas.empty? && pais(pais_id)["zonas"]
      send(parent_object_sym, parent_object_id)[objects_sym.to_s] # pais(pais_id)["zonas"]              #   pais(pais_id)["zonas"]
    else                                                                                                # else
      parent_object = send(parent_service_sym)[parent_object_id]                                        #   pais = paises[pais_id]

      if parent_object[objects_sym.to_s]                                                                #   if pais["zonas"]
        parent_object[objects_sym.to_s].merge!(send("get_#{objects_sym}_in", parent_object_id))         #      pais["zonas"].merge!(get_zonas_in(pais_id)) 
      else                                                                                              #   else
        parent_object[objects_sym.to_s] = send("get_#{objects_sym}_in", parent_object_id)               #      pais["zonas"] = get_zonas_in(pais_id)
      end                                                                                               #   end
    end                                                                                                 # end
  end

  # Generation of dynamic static methods 
  SERVICES.each do |service_name, service|

    #def self.pais(pais_id)
    define_singleton_method(service[:object]) do |object_id|  
      generic_find_by_id(service_name, object_id)  
    end

    # def self.zonas_in(pais_id)
    if service[:parent] && service[:parent_service]
      define_singleton_method("#{service_name}_in") do |parent_object_id|
        generic_find_all_in(service_name, service[:parent], service[:parent_service], parent_object_id)
      end
    end
  end

  # Helpers
  def self.areas
    @@areas.empty? ? get_areas : @@areas
  end

  def self.subareas
    if @@subareas.empty?
      areas.each do |area_id, area|
        area["subareas"] ? area["subareas"].merge!(get_subareas_in(area_id)) : area["subareas"] = get_subareas_in(area_id)
      end
    end
    @@subareas
  end

  def self.paises
    @@paises.empty? ? get_paises : @@paises
  end

  def self.zonas
    # zonas by pais
    if @@zonas.empty?
      paises.each do |pais_id, pais|
        pais["zonas"] ? pais["zonas"].merge!(get_zonas_in(pais_id)) : pais["zonas"] = get_zonas_in(pais_id)
      end
    end
    @@zonas
  end

  def self.localidades
    if @@localidades.empty?
      zonas.each do |zona_id, zona|
        begin
          zona["localidades"] ? zona["localidades"].merge!(get_localidades_in(zona_id)) : zona["localidades"] = get_localidades_in(zona_id)
        rescue StandardError => e
          pp "Error at get_localidades_in(#{zona["id"]}): #{e}"
        end
      end
    end
    @@localidades
  end

  def self.plan_publicaciones 
    if @@plan_publicaciones.empty?
      paises.each do |pais_id, pais|
        pais["plan_publicaciones"] ? pais["plan_publicaciones"].merge!(get_plan_publicaciones_in(pais_id)) : pais["plan_publicaciones"] = get_plan_publicaciones_in(pais_id)
      end
    end
    @@plan_publicaciones
  end

  def self.denominaciones
    @@denominaciones.empty? ? get_denominaciones : @@denominaciones
  end

  def self.direcciones
    @@direcciones.empty? ? get_direcciones : @@direcciones
  end

  def self.frecuencias_pago
    @@frecuencias_pago.empty? ? get_frecuencias_pago : @@frecuencias_pago
  end

  def self.idiomas
    @@idiomas.empty? ? get_idiomas : @@idiomas
  end

  def self.industrias
    @@industrias.empty? ? get_industrias : @@industrias
  end

  def self.niveles_idiomas
    @@niveles_idiomas.empty? ? get_niveles_idiomas : @@niveles_idiomas
  end

  def self.tipos_trabajo
    @@tipos_trabajo.empty? ? get_tipos_trabajo : @@tipos_trabajo
  end

  def self.areas_estudio
    @@areas_estudio.empty? ? get_areas_estudio : @@areas_estudio
  end

  def self.estados_estudio
    @@estados_estudio.empty? ? get_estados_estudio : @@estados_estudio
  end

  def self.tipos_estudio 
    @@tipos_estudio.empty? ? get_tipos_estudio : @@tipos_estudio
  end

  # Servicios comunes
  # Getters
  def self.get_areas #jobs areas
    Bumeran.initialize
    areas_path = "/v0/empresas/comunes/areas" 
    response = self.get(areas_path, @@options)

    json = Parser.parse_response_to_json(response)
    Parser.parse_json_to_hash(json, @@areas)
  end

  def self.get_subareas_in(area_id)
    Bumeran.initialize
    subareas_path = "/v0/empresas/comunes/areas/#{area_id}/subAreas" 
    response = self.get(subareas_path, @@options)

    json = Parser.parse_response_to_json(response)
    Parser.parse_json_to_hash(json, @@subareas) # to save the subareas in the @@subareas
    Parser.parse_json_to_hash(json, {})         # to return only the subareas in the area
  end

  # Servicios generales asociados a datos de localización
  def self.get_paises
    Bumeran.initialize
    paises_path = "/v0/empresas/localizaciones/paises" 
    response = self.get(paises_path, @@options)

    paises_json = Parser.parse_response_to_json(response)
    Parser.parse_json_to_hash(paises_json, @@paises)
  end

  def self.get_zonas_in(pais_id)
    Bumeran.initialize
    zonas_path = "/v0/empresas/localizaciones/paises/#{pais_id}/zonas" 
    response = self.get(zonas_path, @@options)

    json_zonas = Parser.parse_response_to_json(response)
    Parser.parse_json_to_hash(json_zonas, @@zonas) # to save the zone in the zonas hash
    Parser.parse_json_to_hash(json_zonas, {})      # to return only the zonas from the country
  end

  def self.get_localidades_in(zona_id)
    Bumeran.initialize
    localidades_path = "/v0/empresas/localizaciones/zonas/#{zona_id}/localidades" 
    response = self.get(localidades_path, @@options)

    json = Parser.parse_response_to_json(response)
    Parser.parse_json_to_hash(json, @@localidades) # to save the localidades
    Parser.parse_json_to_hash(json, {})            # to return only the localidades from the zone
  end

  def self.get_plan_publicaciones_in(pais_id)
    Bumeran.initialize
    plan_publicaciones_path = "/v0/empresas/planPublicaciones/#{pais_id}"
    response = self.get(plan_publicaciones_path, @@options)

    json = Parser.parse_response_to_json(response)
    Parser.parse_json_to_hash(json, @@plan_publicaciones) # to save the zone in the zonas hash
    return Parser.parse_json_to_hash(json, {}) 
  end

  # Otros servicios
  def self.get_denominaciones
    Bumeran.initialize
    denominaciones_path = "/v0/empresas/denominaciones"
    response = self.get(denominaciones_path, @@options)

    json = Parser.parse_response_to_json(response)
    return Parser.parse_json_to_hash(json, @@denominaciones)
  end

  def self.get_direcciones
    Bumeran.initialize
    direcciones_path = "/v0/empresas/direcciones"
    response = self.get(direcciones_path, @@options)

    json = Parser.parse_response_to_json(response)
    return Parser.parse_json_to_hash(json, @@direcciones)
  end

  def self.get_frecuencias_pago
    Bumeran.initialize
    frecuencias_pago_path = "/v0/empresas/comunes/frecuenciasPago"
    response = self.get(frecuencias_pago_path, @@options)

    json = Parser.parse_response_to_json(response)
    return Parser.parse_json_to_hash(json, @@frecuencias_pago)
  end

  def self.get_idiomas
    Bumeran.initialize
    idiomas_path = "/v0/empresas/comunes/idiomas"
    response = self.get(idiomas_path, @@options)

    json = Parser.parse_response_to_json(response)
    return Parser.parse_json_to_hash(json, @@idiomas)
  end

  def self.get_industrias
    Bumeran.initialize
    industrias_path = "/v0/empresas/comunes/industrias"
    response = self.get(industrias_path, @@options)

    json = Parser.parse_response_to_json(response)
    return Parser.parse_json_to_hash(json, @@industrias)
  end

  def self.get_niveles_idiomas
    Bumeran.initialize
    niveles_idiomas_path = "/v0/empresas/comunes/nivelesIdiomas"
    response = self.get(niveles_idiomas_path, @@options)

    json = Parser.parse_response_to_json(response)
    return Parser.parse_json_to_hash(json, @@niveles_idiomas)
  end

  def self.get_tipos_trabajo
    Bumeran.initialize
    tipos_trabajo_path = "/v0/empresas/comunes/tiposTrabajo"
    response = self.get(tipos_trabajo_path, @@options)

    json = Parser.parse_response_to_json(response)
    return Parser.parse_json_to_hash(json, @@tipos_trabajo)
  end

  # Servicios de estudios de los postulantes
  def self.get_areas_estudio 
    Bumeran.initialize
    areas_estudio_path = "/v0/estudios/areasEstudio" 
    response = self.get(areas_estudio_path, @@options)

    json = Parser.parse_response_to_json(response)
    return Parser.parse_json_to_hash(json, @@areas_estudio)
  end

  def self.get_estados_estudio
    Bumeran.initialize
    estados_estudio_path = "/v0/estudios/estadosEstudio" 
    response = self.get(estados_estudio_path, @@options)

    json = Parser.parse_response_to_json(response)
    return Parser.parse_json_to_hash(json, @@estados_estudio)
  end

  def self.get_tipos_estudio
    Bumeran.initialize
    tipos_estudio_path = "/v0/estudios/tiposEstudio" 
    response = self.get(tipos_estudio_path, @@options)

    json = Parser.parse_response_to_json(response)
    return Parser.parse_json_to_hash(json, @@tipos_estudio)
  end

  def self.get_estudio(estudio_id)
    Bumeran.initialize
    estudio_path = "/v0/estudios/#{estudio_id}" 
    response = self.get(estudio_path, @@options)

    return Parser.parse_response_to_json(response)
  end

  def self.get_conocimiento(conocimiento_id)
    Bumeran.initialize
    conocimiento_path = "/v0/conocimientos/#{conocimiento_id}"
    response = self.get(conocimiento_path, @@options)

    Parser.parse_response_to_json(response)
  end


  def self.get_conocimiento_custom(conocimiento_id)
    Bumeran.initialize
    conocimiento_custom_path = "/v0/conocimientos/custom/#{conocimiento_id}"
    response = self.get(conocimiento_custom_path, @@options)

    Parser.parse_response_to_json(response)
  end


  # Servicios de la experiencia laboral de los postulantes
  def self.get_experiencia_laboral(experiencia_laboral_id)
    Bumeran.initialize
    experiencia_laboral_path = "/v0/experienciasLaborales/#{experiencia_laboral_id}" 
    response = self.get(experiencia_laboral_path, @@options)

    return Parser.parse_response_to_json(response)
  end

  # Servicio de postulaciones a los avisos publicados por las empresas
  def self.get_postulacion(postulacion_id)
    Bumeran.initialize
    postulacion_path = "/v0/empresas/postulaciones/#{postulacion_id}" 
    response = self.get(postulacion_path, @@options)

    return Parser.parse_response_to_json(response)
  end

  def self.get_curriculum(curriculum_id)
    Bumeran.initialize
    curriculum_path = "/v0/empresas/curriculums/#{curriculum_id}" 
    response = self.get(curriculum_path, @@options)

    return Parser.parse_response_to_json(response)
  end

  # alias
  def self.discard_postulacion(postulacion_id)
    Bumeran.discard_postulation(postulacion_id)
  end

  def self.discard_postulation(postulacion_id)
    Bumeran.initialize
    discard_postulaciones_path = "/v0/empresas/postulaciones/#{postulacion_id}/descartar" 
    response = self.put(discard_postulaciones_path, @@options)

    return Parser.parse_response_to_json(response)
  end

  
  def self.login(client_id=@@client_id, username=@@username, password=@@password, grant_type=@@grant_type)
    login_path =  "/v0/empresas/usuarios/login"
    response = self.post(login_path, query: {grant_type: grant_type, client_id: client_id, username: username, password: password})

    if Parser.parse_response_to_json(response)
      # "All good!"
      @@access_token = response["accessToken"]
      @@token_type   = response["tokenType"]
      @@expires_in   = response["expiresIn"]
      @@access_token_updated_at = Time.now
      return @@access_token
    end
  end 


  class Parser
    def self.parse_json_to_hash(json, hash)
      json.each{|object| hash[object["id"]] ? hash[object["id"]].merge!(object) : hash[object["id"]] = object}
      return hash
    end

    def self.parse_response(response)
      case response.code
        when 200..201
          # "All good!"
          return response.body
        when 401
          raise "Error 401: Unauthorized. Check login info.\n #{response.body}"
        when 403
          raise "Error 403: Forbidden"
        when 404
          raise "Error 404 not found"
        when 500...600
          raise "ZOMG ERROR #{response.code}: #{response.request.path}, #{response.body}"
        else
          raise "Error #{response.code}, unkown response: #{response.request.path}, #{response.body}"
      end
    end
    def self.parse_response_to_json(response)
      case response.code
        when 200..201
          # "All good!"
          return JSON.parse(response.body)
        when 401
          raise "Error 401: Unauthorized. Check login info.\n #{response.body}"
        when 403
          raise "Error 403: Forbidden"
        when 404
          raise "Error 404 not found"
        when 500...600
          raise "ZOMG ERROR #{response.code}: #{response.request.path}, #{response.body}"
        else
          raise "Error #{response.code}, unkown response: #{response.request.path}, #{response.body}"
      end
    end
  end
end

require 'bumeran/publication'
