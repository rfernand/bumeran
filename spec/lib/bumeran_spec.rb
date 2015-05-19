require 'spec_helper'

describe Bumeran do
  it 'is a sanity test' do
  end

  it 'has a valid model' do
    bumeran = Bumeran.new
    bumeran.has_valid_access_token?.should be_true
  end

  it 'can publish' do
    bumeran = Bumeran.new
    bumeran.test_publish.code.should == 201
  end

  it 'can get areas' do
    bumeran = Bumeran.new
    bumeran.areas.count.should > 0
  end

  it 'can get subareas' do
    bumeran = Bumeran.new
    bumeran.subareas.count.should > 0
  end

  it 'can get frecuencias_pago' do
    bumeran = Bumeran.new
    bumeran.frecuencias_pago.count.should > 0
  end

end
