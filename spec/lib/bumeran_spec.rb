require 'spec_helper'

describe Bumeran do
  it 'is a sanity test' do
  end

  it 'has a valid model' do
    Bumeran.has_valid_access_token?.should be_true
  end

  it 'can publish', publish: true do
    publication = BumeranFixture.publication
    result = Bumeran.publish(publication.body.to_json)
    pp result
    result.to_i.should > 0
  end

  it 'can get publication', publish: true do
    publication = BumeranFixture.publication
    publication_id = Bumeran.publish(publication.body.to_json)
    pp publication_id
    #binding.pry
    
    publication_id.should > 0
    publication = Bumeran.get_publication(publication_id)
    #binding.pry
    pp publication
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

end
