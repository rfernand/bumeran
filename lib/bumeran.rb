require 'rails'
require 'time'
require 'httparty'
require 'erb'

class Bumeran
  include HTTParty
  base_uri 'https://developers.bumeran.com'

  # API login configuration, need initialization setup to work
  cattr_accessor :grant_type
  @@grant_type = "password"

  cattr_accessor :client_id
  @@client_id = nil

  cattr_accessor :username
  @@username = nil

  cattr_accessor :email
  @@email    = nil

  cattr_accessor :password
  @@password    = nil

  cattr_accessor :access_token
  @@access_token = nil

  cattr_accessor :expires_in
  @@expires_in = nil

  cattr_accessor :access_token_updated_at
  @@access_token_updated_at = nil

  cattr_accessor :options
  @@options = nil

  @@areas = []
  @@subareas = {}
  @@paises = []
  @@zonas = {}
  @@localidades = {}
  @@plan_publicaciones= {}

  # Default way to setup Bumeran.
  def self.setup
    yield self
  end

  def initialize
    unless has_valid_access_token?
      login
      @@options = { query: {access_token: @@access_token} }
    end
  end


  def has_valid_access_token?
    if @@access_token_updated_at && @@expires_in
      (Time.now < @@access_token_updated_at  + @@expires_in)
    else
      false
    end
  end 

  # Publicaciones
  def publish(json)
    initialize
    new_publish_path = "/v0/empresas/avisos"
    response = self.class.put(new_publish_path, @@options.merge(body: json, headers: { "Accept" => "application/json", "Content-Type" => "application/json"}))

    if parse_response(response)
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

  def get_publication(publication_id)
    get_publish_path = "/v0/empresas/avisos/#{publication_id}"
    response = self.class.get(get_publish_path, @@options)

    return parse_response_to_json(response)
  end

  def areas
    if @@areas.empty?
      get_areas
    end
    @@areas
  end

  def subareas
    if @@subareas.empty?
      areas.each do |area|
        area["subareas"] = get_subareas_in(area["id"])
        @@subareas[area["id"]] = area["subareas"]
      end
    end
    @@subareas
  end

  # Servicios comunes
  def get_areas #jobs areas
    initialize
    areas_path = "/v0/empresas/comunes/areas" 
    response = self.class.get(areas_path, @@options)

    @@areas = parse_response_to_json(response)
  end

  def get_subareas_in(area_id)
    initialize
    subareas_path = "/v0/empresas/comunes/areas/#{area_id}/subAreas" 
    response = self.class.get(subareas_path, @@options)

    parse_response_to_json(response)
  end

  def paises
    if @@paises.empty?
      get_paises
    end
    @@paises
  end

  def zonas
    if @@zonas.empty?
      paises.each do |pais|
        pais["zonas"] = get_zonas_in(pais["id"])
        @@zonas[pais["id"]] = pais["zonas"]
      end
    end
    @@zonas
  end

  def localidades
    if @@localidades.empty?
      zonas.each do |zona|
        zona["localidades"] = get_localidades_in(zona["id"])
        @@localidades[zona["id"]] = zona["localidades"]
      end
    end
    @@localidades
  end

  # Servicios generales asociados a datos de localización
  def get_paises
    initialize
    paises_path = "/v0/empresas/locacion/paises" 
    response = self.class.get(paises_path, @@options)

    @@paises = parse_response_to_json(response)
  end

  def get_zonas_in(pais_id)
    initialize
    zonas_path = "/v0/empresas/locacion/paises/#{pais_id}/zonas" 
    response = self.class.get(zonas_path, @@options)

    parse_response_to_json(response)
  end

  def get_localidades_in(zona_id)
    initialize
    localidades_path = "/v0/empresas/locacion/zonas/#{zona_id}/localidades" 
    response = self.class.get(localidades_path, @@options)

    parse_response_to_json(response)
  end

  def plan_publicaciones 
    if @@plan_publicaciones.empty?
      paises.each do |pais|
        pais["plan_publicaciones"] = get_plan_publicaciones_in(pais["id"])
        @@plan_publicaciones[pais["id"]] = pais["plan_publicaciones"]
      end
    end
    @@subareas
  end

  def get_plan_publicaciones_in(pais_id)
    initialize
    plan_publicaciones_path = "/v0/empresas/planPublicaciones/#{pais_id}"
    response = self.class.get(plan_publicaciones_path, @@options)

    return parse_response_to_json(response)
  end

  def get_denominaciones
    initialize
    denominaciones_path = "/v0/empresas/denominaciones"
    response = self.class.get(denominaciones_path, @@options)

    return parse_response_to_json(response)
  end

  def get_direcciones
    initialize
    direcciones_path = "/v0/empresas/direcciones"
    response = self.class.get(direcciones_path, @@options)

    return parse_response_to_json(response)
  end

  def frecuencias_pago
    initialize
    frecuencias_pago_path = "/v0/empresas/comunes/frecuenciasPago"
    response = self.class.get(frecuencias_pago_path, @@options)

    return parse_response_to_json(response)
  end

  def idiomas
    initialize
    idiomas_path = "/v0/empresas/comunes/idiomas"
    response = self.class.get(idiomas_path, @@options)

    return parse_response_to_json(response)
  end

  def industrias
    initialize
    industrias_path = "/v0/empresas/comunes/industrias"
    response = self.class.get(industrias_path, @@options)

    return parse_response_to_json(response)
  end

  def niveles_idiomas
    initialize
    niveles_idiomas_path = "/v0/empresas/comunes/nivelesIdiomas"
    response = self.class.get(niveles_idiomas_path, @@options)

    return parse_response_to_json(response)
  end

  def tipos_trabajo
    initialize
    tipos_trabajo_path = "/v0/empresas/comunes/tiposTrabajo"
    response = self.class.get(tipos_trabajo_path, @@options)

    return parse_response_to_json(response)
  end

  # Servicios de estudios de los postulantes
  def areas_estudio 
    initialize
    areas_estudio_path = "/v0/estudios/areasEstudio" 
    response = self.class.get(areas_estudio_path, @@options)

    return parse_response_to_json(response)
  end

  def estados_estudio
    initialize
    estados_estudio_path = "/v0/estudios/estadosEstudio" 
    response = self.class.get(estados_estudio_path, @@options)

    return parse_response_to_json(response)
  end

  def tipos_estudio
    initialize
    tipos_estudio_path = "/v0/estudios/tiposEstudio" 
    response = self.class.get(tipos_estudio_path, @@options)

    return parse_response_to_json(response)
  end

  def get_estudio(estudio_id)
    initialize
    estudio_path = "/v0/estudios/#{estudio_id}" 
    response = self.class.get(estudio_path, @@options)

    return parse_response_to_json(response)
  end

  # Servicios de la experiencia laboral de los postulantes
  def get_experiencia_laboral(experiencia_laboral_id)
    initialize
    experiencia_laboral_path = "/v0/experienciaLaborales/#{experiencia_laboral_id}" 
    response = self.class.get(experiencia_laboral_path, @@options)

    return parse_response_to_json(response)
  end

  # Servicio de postulaciones a los avisos publicados por las empresas
  def get_postulacion(postulacion_id)
    initialize
    postulaciones_path = "/v0/empresas/postulaciones/#{postulacion_id}" 
    response = self.class.get(postulaciones_path, @@options)

    return parse_response_to_json(response)
  end

  def discard_postulacion(postulacion_id)
    initialize
    discard_postulaciones_path = "/v0/empresas/postulaciones/#{postulacion_id}/descartar" 
    response = self.class.put(discard_postulaciones_path, @@options)

    return parse_response_to_json(response)
  end

  
  def login(client_id=@@client_id, username=@@username, password=@@password, grant_type=@@grant_type)
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

    response = self.class.post(login_path, query: {grant_type: grant_type, client_id: client_id, username: username, password: password})

    if parse_response_to_json(response)
      # "All good!"
      @@access_token = response["accessToken"]
      token_type   = response["tokenType"]
      @@expires_in   = response["expiresIn"]
      @@access_token_updated_at = Time.now
      return @@access_token
    end
  end 


  private
  def parse_response(response)
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
  def parse_response_to_json(response)
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
