require 'spec_helper'

describe Bumeran do
  it 'is a sanity test' do
  end

  it 'has a valid model' do
    bumeran = Bumeran.new
    bumeran.has_valid_access_token?.should be_true
  end

  it 'can publish', publish: true do
    bumeran = Bumeran.new
    result = bumeran.test_publish
    pp result
    result.to_i.should > 0
  end

  it 'can get publication', publish: true do
    bumeran = Bumeran.new
    publication_id = bumeran.test_publish.to_i
    pp publication_id
    #binding.pry
    
    publication_id.should > 0
    publication = bumeran.get_publication(publication_id)
    #binding.pry
    pp publication
  end
  

  it 'can get areas', getters: true do
    bumeran = Bumeran.new
    pp bumeran.areas
    bumeran.areas.count.should > 0
  end

  it 'can get subareas', getters: true do
    bumeran = Bumeran.new
    pp bumeran.subareas
    bumeran.subareas.count.should > 0
  end

  it 'can get frecuencias_pago', getters: true do
    bumeran = Bumeran.new
    pp bumeran.frecuencias_pago
    bumeran.frecuencias_pago.count.should > 0
  end

end
