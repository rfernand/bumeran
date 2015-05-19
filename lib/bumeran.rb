require 'rails'
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


  # Default way to setup Bumeran.
  def self.setup
    yield self
  end

 def initialize
    auth_token = login
    @options = { query: {access_token: auth_token} }
  end


  def default_publication_json
    return {
        descripcion: "",
        titulo: "",
        referencia: "",  #optional
        tipoTrabajoId: 0,
        denominacion: {
          id: 0,
          nombre: "",
          logo: ""
        },
        preguntas: [  # optional
          {
            simple: {
              texto: ""
            }
          }
        ],
        postulantesDiscapacitados: false, #optional
        lugarTrabajo: {
          id: 0,
          direccion: "",
          zonaId: 0,
          paisId: 0,
          localidadId: 0,
          mostrarDireccionEnAviso: false
        },
        recepcionCandidato: {},
        areaId: 0,
        subAreaId: 0,
        requisitos: {     # optional
          experiencia: {
            minimo: 0,
            excluyente: false
          },
          edad: {
            edadMinima: 0,
            edadMaxima: 0,
            excluyente: false
          },
          educacion: {
            estadoEstudioId: 0,
            tipoEstudioId: 0,
            excluyente: false
          },
          idiomas: [
            {
              nivelId: 0,
              idiomaId: 0,
              excluyente: false
            }
          ],
          residencia: {
            cercania: "",
            cantidadKm: 0,
            excluyente: false
          },
          salario: {
            tipo: "",
            salarioMinimo: 0,
            salarioMaximo: 0,
            frecuenciaPagoId: 0,
            mostrarAviso: false,
            solicitarCandidato: false,
            excluyente: false
          },
          genero: {
            nombre: "",
            excluyente: false
          }
        }
      }
  end

  def publish_test
    json =  default_publication_json
    json[:descripcion]             = ""
    json[:titulo]                  = ""
    #json[:referencia]              = ""  #optional
    
    json[:denominacion][:id]      = 0
    json[:denominacion][:nombre]  = ""
    json[:denominacion][:logo]    = ""

    json[:preguntas]  # optional
    #json[:preguntas][:texto]

    #json["postulantesDiscapacitados"] false, #optional

    #json["lugarTrabajo"]
    json[:lugarTrabajo][:id]                = 0
    json[:lugarTrabajo][:direccion]         = ""
    json[:lugarTrabajo][:zonaId]            = 0
    json[:lugarTrabajo][:paisId]            = 0
    json[:lugarTrabajo][:localidadId]       = 0
    json[:lugarTrabajo][:mostrarDireccionEnAviso] = false

    json[:recepcionCandidato] = {}
    json[:areaId]             = 0
    json[:subAreaId]          = 0
    ####json[:requisitos]               # optional
    ###json[:requisitos][:experiencia]
    #json[:requisitos][:experiencia][:minimo]     = 0
    #json[:requisitos][:experiencia][:excluyente] = false
    ###json[:requisitos][:edad]
    #json[:requisitos][:edad][:edadMinima] = 0
    #json[:requisitos][:edad][:edadMaxima] = 0
    #json[:requisitos][:edad][:excluyente] = false
    ###json["requisitos"]["educacion"]
    #json["requisitos"]["educacion"]["estadoEstudioId"] = 0
    #json["requisitos"]["educacion"]["tipoEstudioId"]   = 0
    #json["requisitos"]["educacion"]["excluyente"]      = false
    ###json["requisitos"]["idiomas"]
    #json["requisitos"]["idiomas"]["nivelId"]    = 0
    #json["requisitos"]["idiomas"]["idiomaId"]   = 0
    #json["requisitos"]["idiomas"]["excluyente"] = false
    ###json["requisitos"]["residencia"]
    #json["requisitos"]["residencia"]["cercania"]   = ""
    #json["requisitos"]["residencia"]["cantidadKm"] = 0
    #json["requisitos"]["residencia"]["excluyente"] = false
    ###json["requisitos"]["salario"]
    #json["requisitos"]["salario"]["tipo"]             = ""
    #json["requisitos"]["salario"]["salarioMinimo"]    = 0
    #json["requisitos"]["salario"]["salarioMaximo"]    = 0
    #json["requisitos"]["salario"]["frecuenciaPagoId"] = 0
    #json["requisitos"]["salario"]["mostrarAviso"]     = false
    #json["requisitos"]["salario"]["solicitarCandidato"] = false
    #json["requisitos"]["salario"]["excluyente"]       = false
    ###json["requisitos"]["genero"]
    #json["requisitos"]["genero"]["nombre"]     = ""
    #json["requisitos"]["genero"]["excluyente"] = false
    json[:tipoTrabajoId] =  0

    publish(json.to_json)
  end

  # Publicaciones
  def publish(json)
    new_publish_path = "/v0/empresas/avisos"
    response = self.class.put(new_publish_path, @options.merge(body: json, headers: { "Accept" => "application/json", "Content-Type" => "application/json"}))

    if check_response(response)
      case response.code
        when 201
          # "Publication created, All good!"
          return response.body # id del proceso publicado
        when 200
          # "TODO: Uhm.. no idea, is this good?"
          return response.body # id del proceso publicado?
      end
    end
  end

  def get_publication(publication_id)
    get_publish_path = "/v0/empresas/avisos/#{publication_id}"
    response = self.class.put(get_publish_path, @options)

    return check_response(response)
  end

  # Servicios comunes
  def areas #jobs areas
    areas_path = "/v0/empresas/comunes/areas" 
    response = self.class.get(areas_path, @options)

    return check_response(response)
  end

  def subareas_in(area_id)
    subareas_path = "/v0/empresas/comunes/areas/#{area_id}/subAreas" 
    response = self.class.get(subareas_path, @options)

    return check_response(response)
  end

  def frecuencias_pago
    frecuencias_pago_path = "/v0/empresas/comunes/frecuenciasPago"
    response = self.class.get(frecuencias_pago_path, @options)

    return check_response(response)
  end

  def idiomas
    idiomas_path = "/v0/empresas/comunes/idiomas"
    response = self.class.get(idiomas_path, @options)

    return check_response(response)
  end

  def industrias
    industrias_path = "/v0/empresas/comunes/industrias"
    response = self.class.get(industrias_path, @options)

    return check_response(response)
  end

  def niveles_idiomas
    niveles_idiomas_path = "/v0/empresas/comunes/nivelesIdiomas"
    response = self.class.get(niveles_idiomas_path, @options)

    return check_response(response)
  end

  def tipos_trabajo
    tipos_trabajo_path = "/v0/empresas/comunes/tiposTrabajo"
    response = self.class.get(tipos_trabajo_path, @options)

    return check_response(response)
  end

  # Servicios de estudios de los postulantes
  def areas_estudio 
    areas_estudio_path = "/v0/estudios/areasEstudio" 
    response = self.class.get(areas_estudio_path, @options)

    return check_response(response)
  end

  def estados_estudio
    estados_estudio_path = "/v0/estudios/estadosEstudio" 
    response = self.class.get(estados_estudio_path, @options)

    return check_response(response)
  end

  def tipos_estudio
    tipos_estudio_path = "/v0/estudios/tiposEstudio" 
    response = self.class.get(tipos_estudio_path, @options)

    return check_response(response)
  end

  def get_estudio(estudio_id)
    estudio_path = "/v0/estudios/#{estudio_id}" 
    response = self.class.get(estudio_path, @options)

    return check_response(response)
  end

  # Servicios de la experiencia laboral de los postulantes
  def get_experiencia_laboral(experiencia_laboral_id)
    experiencia_laboral_path = "/v0/experienciaLaborales/#{experiencia_laboral_id}" 
    response = self.class.get(experiencia_laboral_path, @options)

    return check_response(response)
  end

  # Servicios generales asociados a datos de localización
  def paises
    paises_path = "/v0/empresas/locacion/paises" 
    response = self.class.get(paises_path, @options)

    return check_response(response)
  end

  def zonas_in(pais_id)
    zonas_path = "/v0/empresas/locacion/paises/#{pais_id}/zonas" 
    response = self.class.get(zonas_path, @options)

    return check_response(response)
  end

  def localidades_in(zona_id)
    localidades_path = "/v0/empresas/locacion/zonas/#{zona_id}/localidades" 
    response = self.class.get(localidades_path, @options)

    return check_response(response)
  end

  # Servicio de postulaciones a los avisos publicados por las empresas
  def get_postulacion(postulacion_id)
    postulaciones_path = "/v0/empresas/postulaciones/#{postulacion_id}" 
    response = self.class.get(postulaciones_path, @options)

    return check_response(response)
  end

  def discard_postulacion(postulacion_id)
    discard_postulaciones_path = "/v0/empresas/postulaciones/#{postulacion_id}/descartar" 
    response = self.class.put(discard_postulaciones_path, @options)

    return check_response(response)
  end

  
  def login
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

    response = self.class.post(login_path, query: {grant_type: @@grant_type, client_id: @@client_id, username: @@username, password: @@password})

    if check_response(response)
      # "All good!"
      access_token = response["accessToken"]
      token_type   = response["tokenType"]
      expires_in   = response["expiresIn"]
      return access_token
    end
  end 


  private
  def check_response(response)
    case response.code
      when 200..201
        # "All good!"
        return response
      when 401
        raise "Unauthorized, check login info"
      when 403
        raise "Error 403: Forbidden"
      when 404
        raise "Error 404 not found"
      when 500...600
        raise "ZOMG ERROR #{response.code}"
      else
        raise "Error #{response.code}, unkown response"
    end
  end
end
