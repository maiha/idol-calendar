class LiveUpdate < Sequel::Model
  def extractor
    eval(extractor_name)
  end

  def source
    extractor.source
  end
end
