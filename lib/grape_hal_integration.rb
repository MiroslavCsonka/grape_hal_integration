require 'grape'

class GrapeHalIntegration < Grape::API

  @@endpoints = {}

  def self.build_action(name)
    "#{self.name}-#{name.to_s}"
  end

  def self.implement_new(name, url, links = [], &block)
    name = name.to_s
    http_verb, url = url.split ' '
    get_params_name = url.scan(/\{([^}]*)\}/).flatten
    @@endpoints[build_action(name)] = {
        name: name,
        links: links,
        block: block,
        self: {
            href: url,
            method: http_verb.upcase
        }
    }

    if url.include? '{'
      @@endpoints[build_action(name)][:self][:templated] = true
    end

    super_context = lambda do
      get_params_values = get_params_name.map do |get_param_name|
        params[get_param_name.intern]
      end
      self.instance_exec *get_params_values, &block
    end

    resource url.gsub('{', ':').gsub('}', '') do
      case http_verb.upcase
        when 'POST'
          post &super_context
        when 'PUT'
          put &super_context
        when 'DELETE'
          delete &super_context
        when 'GET'
          get &super_context
        else
          raise "Undefined http verb '#{http_verb}'"
      end
    end
  end

  def self.endpoint(name)
    @@endpoints[build_action(name.to_s)]
  end

  def self.method_missing(method_name, *arguments, &block)
    raise "Unknown name '#{build_action(method_name)}'" unless @@endpoints.has_key? build_action(method_name)
    context = arguments.shift
    context.instance_exec *arguments, &endpoint(method_name)[:block]
  end

  def self.endpoint_url(name)
    e = endpoint(name)
    raise "Could not find endpoint '#{name}'" unless e.is_a? Hash
    e[:self]
  end

end
