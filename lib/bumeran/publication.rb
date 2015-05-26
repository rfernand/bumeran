module Bumeran
  class Publication
    attr_accessor :body
  
    def initialize
      self.body = default_publication_json()
    end
  
    private
    def default_publication_json
      return {
        descripcion: "",  # required
        titulo: "",       # required
        referencia: "",   # optional
        tipoTrabajoId: 0,
        denominacion: {
          # you can use an id
          id: 0
          # or create a new one
          #nombre: "",
          #logo: ""
        },
        preguntas: [  # optional
          {
            simple: {
              texto: ""   # required
            }
          }
        ],
        postulantesDiscapacitados: false, #optional
        lugarTrabajo: {
          #id: 0,         # TODO: found in the developers site but not found in the documentation
          paisId: 0,
          zonaId: 0,
          localidadId: 0,
          direccion: "",
          mostrarDireccionEnAviso: false
        },
        recepcionCandidato: {
          electronica: {
            email: ""      # required
          }
        },
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
  
  end
end
