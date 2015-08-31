require 'spec_helper'

describe Bumeran do
  it 'is a sanity test' do
  end

  it 'has a valid model' do
    Bumeran.has_valid_access_token?.should be_true
  end

  it 'can create publication', create: true do
    publication = BumeranFixture.publication
    result = Bumeran.create_aviso(publication.body.to_json)
    pp result
    result.to_i.should > 0
  end

  it 'can publish publication', create: true do
    publication = BumeranFixture.publication
    published_publication_id = Bumeran.publish(publication.body.to_json, 1, 30) # pais Argentina = 1, plan publicacion "simple" = 30 
    pp published_publication_id
    published_publication_id.to_i.should > 0
  end

  it 'can create, get, publish and destroy publication', publish: true do
    publication = BumeranFixture.publication
    publication_id = Bumeran.create_aviso(publication.body.to_json)
    pp publication_id
    publication_id.should > 0

    publication = Bumeran.get_publication(publication_id)
    pp publication
    publication["id"].should > 0

    published_publication = Bumeran.publicar_aviso(publication_id, 1, 30) # pais Argentina = 1, plan publicacion "simple" = 30 
    pp published_publication

    deleted_publication = Bumeran.destroy_aviso(publication_id)
    pp deleted_publication
  end

  it 'can get areas', getters: true do
    pp Bumeran.areas
    Bumeran.areas.count.should > 0
  end

  it 'can get subareas', getters: true do
    pp Bumeran.subareas
    Bumeran.subareas.count.should > 0
  end

  it 'can get frecuencias_pago', getters: true do
    pp Bumeran.frecuencias_pago
    Bumeran.frecuencias_pago.count.should > 0
  end

  it 'can get paises' do
    pp Bumeran.paises
    Bumeran.paises.count.should > 0
  end

  # localidades gives error! (API problem)
  it 'can get paises, zonas, localidades, and plan plublicaciones' do
    pp Bumeran.paises
    Bumeran.paises.count.should > 0
    Bumeran.zonas.count.should > 0
    #Bumeran.localidades.count.should > 0
    Bumeran.plan_publicaciones.count.should > 0
  end

  it 'can get denominaciones', getters: true do
    pp Bumeran.denominaciones
    Bumeran.denominaciones.count.should > 0
  end

  it 'can get direcciones', getters: true do
    pp Bumeran.direcciones
    Bumeran.direcciones.count.should > 0
  end

  it 'can get frecuencias_pago', getters: true do
    pp Bumeran.frecuencias_pago
    Bumeran.frecuencias_pago.count.should > 0
  end


  it 'can get idiomas', getters: true do
    pp Bumeran.idiomas
    Bumeran.idiomas.count.should > 0
  end

  it 'can get industrias', getters: true do
    pp Bumeran.industrias
    Bumeran.industrias.count.should > 0
  end

  it 'can get niveles_idiomas', getters: true do
    pp Bumeran.niveles_idiomas
    Bumeran.niveles_idiomas.count.should > 0
  end

  it 'can get tipos_trabajo', getters: true do
    pp Bumeran.tipos_trabajo
    Bumeran.tipos_trabajo.count.should > 0
  end

  it 'can get areas_estudio', getters: true do
    pp Bumeran.areas_estudio
    Bumeran.areas_estudio.count.should > 0
  end

  it 'can get estados_estudio', getters: true do
    pp Bumeran.estados_estudio
    Bumeran.estados_estudio.count.should > 0
  end

  it 'can get tipos_estudio', getters: true do
    pp Bumeran.tipos_estudio
    Bumeran.tipos_estudio.count.should > 0
  end

  it 'can get tipos_estudio', getters: true do
    pp Bumeran.tipos_estudio
    Bumeran.tipos_estudio.count.should > 0
  end

  it 'can get estudio', getters: true do
    params = {}
    params['curriculum_id']=1000
    estudio = Bumeran.get_estudio(1285190, params)
    pp estudio
    estudio["titulo"].class.should be String
  end

  it 'can get conocimiento', getters: true do
    #conocimiento = Bumeran.get_conocimiento(140)
    #pp conocimiento
    #conocimiento["nombre"].class.should be String
    params = {}
    params['curriculum_id']=1000
    conocimiento = Bumeran.get_conocimiento(140, params)
    pp conocimiento
    conocimiento["nombre"].class.should be String
  end

  it 'can get conocimiento_custom', getters: true do
    params = {}
    params['curriculum_id']=1000
    conocimiento_custom = Bumeran.get_conocimiento_custom(623710, params)
    pp conocimiento_custom
    conocimiento_custom["nombre"].class.should be String
  end

  it 'can get experiencia_laboral', getters: true do
    params = {}
    params['curriculum_id']=1000
    experiencia_laboral = Bumeran.get_experiencia_laboral(1651500, params)
    pp experiencia_laboral
    experiencia_laboral["puesto"].class.should be String
  end

  it 'can get postulacion', getters: true do
    postulacion = Bumeran.get_postulacion(1000)
    pp postulacion
    postulacion["estado"].class.should be String
  end

  it 'can get curriculum', getters: true do
    curriculum = Bumeran.get_curriculum(1000)
    pp curriculum
    curriculum["nombre"].class.should be String
  end

end
