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

  @@areas = []
  @@subareas = {}
  @@paises = []
  @@zonas = {}
  @@localidades = {}
  @@plan_publicaciones= {}
  @@frecuencias_pago = []

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

  # Publicaciones
  def self.publish(json)
    Bumeran.initialize
    new_publish_path = "/v0/empresas/avisos"
    response = self.put(new_publish_path, @@options.merge(body: json, headers: { "Accept" => "application/json", "Content-Type" => "application/json"}))

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
    get_publish_path = "/v0/empresas/avisos/#{publication_id}"
    response = self.get(get_publish_path, @@options)

    return Parser.parse_response_to_json(response)
  end

  def self.areas
    @@areas.empty? ? get_areas : @@areas
  end

  def self.subareas
    if @@subareas.empty?
      areas.each do |area|
        area["subareas"] = get_subareas_in(area["id"])
        @@subareas[area["id"]] = area["subareas"]
      end
    end
    @@subareas
  end

  # Servicios comunes
  def self.get_areas #jobs areas
    Bumeran.initialize
    areas_path = "/v0/empresas/comunes/areas" 
    response = self.get(areas_path, @@options)

    @@areas = Parser.parse_response_to_json(response)
  end

  def self.get_subareas_in(area_id)
    Bumeran.initialize
    subareas_path = "/v0/empresas/comunes/areas/#{area_id}/subAreas" 
    response = self.get(subareas_path, @@options)

    Parser.parse_response_to_json(response)
  end

  def self.paises
    @@paises.empty? ? get_paises : @@paises
  end

  def self.zonas
    if @@zonas.empty?
      paises.each do |pais|
        pais["zonas"] = get_zonas_in(pais["id"])
        @@zonas[pais["id"]] = pais["zonas"]
      end
    end
    @@zonas
  end

  def self.localidades
    if @@localidades.empty?
      zonas.each do |zona|
        zona["localidades"] = get_localidades_in(zona["id"])
        @@localidades[zona["id"]] = zona["localidades"]
      end
    end
    @@localidades
  end

  # Servicios generales asociados a datos de localización
  def self.get_paises
    Bumeran.initialize
    paises_path = "/v0/empresas/locacion/paises" 
    response = self.get(paises_path, @@options)

    @@paises = Parser.parse_response_to_json(response)
  end

  def self.get_zonas_in(pais_id)
    Bumeran.initialize
    zonas_path = "/v0/empresas/locacion/paises/#{pais_id}/zonas" 
    response = self.get(zonas_path, @@options)

    Parser.parse_response_to_json(response)
  end

  def self.get_localidades_in(zona_id)
    Bumeran.initialize
    localidades_path = "/v0/empresas/locacion/zonas/#{zona_id}/localidades" 
    response = self.get(localidades_path, @@options)

    Parser.parse_response_to_json(response)
  end

  def self.plan_publicaciones 
    if @@plan_publicaciones.empty?
      paises.each do |pais|
        pais["plan_publicaciones"] = get_plan_publicaciones_in(pais["id"])
        @@plan_publicaciones[pais["id"]] = pais["plan_publicaciones"]
      end
    end
    @@subareas
  end

  def self.get_plan_publicaciones_in(pais_id)
    Bumeran.initialize
    plan_publicaciones_path = "/v0/empresas/planPublicaciones/#{pais_id}"
    response = self.get(plan_publicaciones_path, @@options)

    return Parser.parse_response_to_json(response)
  end

  def self.denominaciones
    @@denominaciones.empty? ? get_denominaciones : @@denominaciones
  end

  def self.get_denominaciones
    Bumeran.initialize
    denominaciones_path = "/v0/empresas/denominaciones"
    response = self.get(denominaciones_path, @@options)

    @@denominaciones = Parser.parse_response_to_json(response)
  end

  def self.direcciones
    @@direcciones.empty? ? get_direcciones : @@direcciones
  end

  def self.get_direcciones
    Bumeran.initialize
    direcciones_path = "/v0/empresas/direcciones"
    response = self.get(direcciones_path, @@options)

    @@direcciones = Parser.parse_response_to_json(response)
  end

  def self.frecuencias_pago
    @@frecuencias_pago.empty? ? get_frecuencias_pago : @@frecuencias_pago
  end

  def self.get_frecuencias_pago
    Bumeran.initialize
    frecuencias_pago_path = "/v0/empresas/comunes/frecuenciasPago"
    response = self.get(frecuencias_pago_path, @@options)

    @@frecuencias_pago = Parser.parse_response_to_json(response)
  end

  def self.idiomas
    @@idiomas.empty? ? get_idiomas : @@idiomas
  end

  def self.get_idiomas
    Bumeran.initialize
    idiomas_path = "/v0/empresas/comunes/idiomas"
    response = self.get(idiomas_path, @@options)

    @@idiomas = Parser.parse_response_to_json(response)
  end

  def self.industrias
    @@industrias.empty? ? get_industrias : @@industrias
  end

  def self.get_industrias
    Bumeran.initialize
    industrias_path = "/v0/empresas/comunes/industrias"
    response = self.get(industrias_path, @@options)

    @@industrias = Parser.parse_response_to_json(response)
  end

  def self.niveles_idiomas
    @@niveles_idiomas.empty? ? get_niveles_idiomas : @@niveles_idiomas
  end

  def self.get_niveles_idiomas
    Bumeran.initialize
    niveles_idiomas_path = "/v0/empresas/comunes/nivelesIdiomas"
    response = self.get(niveles_idiomas_path, @@options)

    @niveles_idiomas = Parser.parse_response_to_json(response)
  end

  def self.tipos_trabajo
    @@tipos_trabajo.empty? ? get_tipos_trabajos : @@tipos_trabajo
  end

  def self.get_tipos_trabajo
    Bumeran.initialize
    tipos_trabajo_path = "/v0/empresas/comunes/tiposTrabajo"
    response = self.get(tipos_trabajo_path, @@options)

    @@tipos_trabajo = Parser.parse_response_to_json(response)
  end

  def self.areas_estudio
    @@areas_estudio.empty? ? get_areas_estudio : @@areas_estudio
  end

  # Servicios de estudios de los postulantes
  def self.get_areas_estudio 
    Bumeran.initialize
    areas_estudio_path = "/v0/estudios/areasEstudio" 
    response = self.get(areas_estudio_path, @@options)

    @@areas_estudio = Parser.parse_response_to_json(response)
  end

  def self.estados_estudio
    @@estados_estudio.empty? ? get_estados_estudio : @@estados_estudio
  end

  def self.get_estados_estudio
    Bumeran.initialize
    estados_estudio_path = "/v0/estudios/estadosEstudio" 
    response = self.get(estados_estudio_path, @@options)

    @@estados_estudio = Parser.parse_response_to_json(response)
  end

  def self.tipos_estudio 
    @@tipos_estudio.empty? ? get_tipos_estudio : @@tipos_estudio
  end

  def self.get_tipos_estudio
    Bumeran.initialize
    tipos_estudio_path = "/v0/estudios/tiposEstudio" 
    response = self.get(tipos_estudio_path, @@options)

    @@tipos_estudio = Parser.parse_response_to_json(response)
  end

  def self.get_estudio(estudio_id)
    Bumeran.initialize
    estudio_path = "/v0/estudios/#{estudio_id}" 
    response = self.get(estudio_path, @@options)

    return Parser.parse_response_to_json(response)
  end

  # Servicios de la experiencia laboral de los postulantes
  def self.get_experiencia_laboral(experiencia_laboral_id)
    Bumeran.initialize
    experiencia_laboral_path = "/v0/experienciaLaborales/#{experiencia_laboral_id}" 
    response = self.get(experiencia_laboral_path, @@options)

    return Parser.parse_response_to_json(response)
  end

  # Servicio de postulaciones a los avisos publicados por las empresas
  def self.get_postulacion(postulacion_id)
    Bumeran.initialize
    postulaciones_path = "/v0/empresas/postulaciones/#{postulacion_id}" 
    response = self.get(postulaciones_path, @@options)

    return Parser.parse_response_to_json(response)
  end

  def self.discard_postulacion(postulacion_id)
    Bumeran.initialize
    discard_postulaciones_path = "/v0/empresas/postulaciones/#{postulacion_id}/descartar" 
    response = self.put(discard_postulaciones_path, @@options)

    return Parser.parse_response_to_json(response)
  end

  
  def self.login(client_id=@@client_id, username=@@username, password=@@password, grant_type=@@grant_type)
    login_path =  "/v0/empresas/usuarios/login"
    # POST /v0/empresas/usuarios/login
    # sends post request with:
    #   grant_type=   Tipo de permiso de OAuth2  query string
    #   client_id=   Identificador del cliente de OAuth2 query string
    #   username=    Nombre de usuario query string
    #   password=    Password del usuario query string
    # recieves json
    # {
    #   "accessToken": "bdf48bc4-6b7a-4de9-82e5-5bf278d23855",
    #   "tokenType": "bearer",
    #   "expiresIn": 1199
    # }

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
          raise "ZOMG ERROR #{response.code}: #{response.body}"
        else
          raise "Error #{response.code}, unkown response: #{response.body}"
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
          raise "ZOMG ERROR #{response.code}: #{response.body}"
        else
          raise "Error #{response.code}, unkown response: #{response.body}"
      end
    end
  end
end
