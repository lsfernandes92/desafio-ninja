module HeaderHelpers
  def accept_header
    { "Accept": 'application/vnd.api+json' }
  end

  def content_type_header
    { "Content-Type": 'application/vnd.api+json' }
  end
end
