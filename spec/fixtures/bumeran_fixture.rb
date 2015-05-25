class BumeranFixture
  def self.publication
    publication =  Publication.new
    publication.body[:descripcion]             = "Descripcion de la publicacion de prueba"    # required
    publication.body[:titulo]                  = "Publicacion de prueba"                      # required
    #publication.body[:referencia]              = ""  #optional

    # We can use an id for denominacion
    publication.body[:denominacion][:id]      = 0                                             # required
    # or we can create a new one
    #publication.body[:denominacion][:nombre]  = ""
    #publication.body[:denominacion][:logo]    = ""

    #publication.body[:preguntas]  # optional
    publication.body[:preguntas][0][:simple][:texto] = "Pregunta de prueba"                   # optional
    publication.body[:preguntas] << {choice: {texto: "Pregunta de alternativas", indiceCorrecta: 2, opciones: [{opcion: "respuesta 1"}, {opcion: "respuesta 2"}, {opcion: "respuesta 3"}, {opcion: "respuesta 4"}]}}      # optional

    #publication.body["postulantesDiscapacitados"] false, #optional

    #publication.body["lugarTrabajo"]
    #publication.body[:lugarTrabajo][:id]                = 0  # TODO: found in the developers site but not in the documentation
    publication.body[:lugarTrabajo][:paisId]            = 1                      # required
    publication.body[:lugarTrabajo][:zonaId]            = 18                     # required
    publication.body[:lugarTrabajo][:localidadId]       = 6050                   # required
    publication.body[:lugarTrabajo][:direccion]         = "San Martin 256"       # required
    publication.body[:lugarTrabajo][:mostrarDireccionEnAviso] = false      # required

    publication.body[:recepcionCandidato][:electronica][:email] = "test@domain.com" # required
    # recepcionCandidato can aslo be with dias, rangoHorario and direccion
    publication.body[:areaId]             = 19        # required
    publication.body[:subAreaId]          = 26        # required
    ####publication.body[:requisitos]               # optional
    ###publication.body[:requisitos][:experiencia]
    publication.body[:requisitos][:experiencia][:minimo]     = 60             # required
    publication.body[:requisitos][:experiencia][:excluyente] = false          # required
    ###publication.body[:requisitos][:edad]
    publication.body[:requisitos][:edad][:edadMinima] = 18                    # required
    publication.body[:requisitos][:edad][:edadMaxima] = 40                    # required
    publication.body[:requisitos][:edad][:excluyente] = false                 # required
    ###publication.body["requisitos"]["educacion"]
    publication.body[:requisitos][:educacion][:estadoEstudioId] = 2           # required
    publication.body[:requisitos][:educacion][:tipoEstudioId]   = 3           # required
    publication.body[:requisitos][:educacion][:excluyente]      = false       # required
    ###publication.body["requisitos"]["idiomas"]
    publication.body[:requisitos][:idiomas][0][:nivelId]    = 10              # required
    publication.body[:requisitos][:idiomas][0][:idiomaId]   = 1               # required
    publication.body[:requisitos][:idiomas][0][:excluyente] = false           # required
    ###publication.body["requisitos"]["residencia"]
    publication.body[:requisitos][:residencia][:cercania]   = "provincia"     # required
    #publication.body[:requisitos][:residencia][:cantidadKm] = 0              # optional
    publication.body[:requisitos][:residencia][:excluyente] = false           # required
    ###publication.body["requisitos"]["salario"]
    publication.body[:requisitos][:salario][:tipo]             = "bruto"      # required
    publication.body[:requisitos][:salario][:salarioMinimo]    = 200000       # required
    publication.body[:requisitos][:salario][:salarioMaximo]    = 1000000      # required
    publication.body[:requisitos][:salario][:frecuenciaPagoId] = 4            # required
    publication.body[:requisitos][:salario][:mostrarAviso]     = true         # required
    publication.body[:requisitos][:salario][:solicitarCandidato] = true       # required
    publication.body[:requisitos][:salario][:excluyente]       = false        # optional
    ###publication.body[:requisitos][:genero]
    publication.body[:requisitos][:genero][:nombre]     = "masculino"       # required
    publication.body[:requisitos][:genero][:excluyente] = false             # required
    publication.body[:tipoTrabajoId] =  4                                   # required

    return publication

    # publish(publication.body.to_publication.body)
  end
end
