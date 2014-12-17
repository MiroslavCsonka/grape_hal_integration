require 'grape'

class GrapeHalIntegration < Grape::API

  @@endpoints = {}

  def self.links(class_name, action_name)
    links = class_name.endpoint(action_name)[:links]
    _links = Hash[links.map { |link|

                    if link.include? '#'
                      class_name2, action_name2 = link.split '#'
                      name = action_name2
                      endpoint = class_name2.constantize.endpoint(action_name2)
                    else
                      name = link
                      endpoint = class_name.endpoint(link)
                    end

                    raise "Unregistered link to '#{link}'" if endpoint.nil?

                    return [name, endpoint[:self]]
                  }]
    _links[:self] = class_name.endpoint(action_name)[:self]
    _links
  end

  def self.build_current_action(name)
    "#{self.name}##{name.to_s}"
  end

  def self.implement(name, url, links = [], &block)
    name = name.to_s
    http_verb, url = url.split ' '

    @@endpoints[build_current_action(name)] = {
        name: name,
        links: links,
        block: block,
        self: {
            href: url,
            method: http_verb.upcase
        }
    }
    @@endpoints[build_current_action(name)][:self][:templated] = true if url.include? '{'

    class_name = self.name.constantize
    get_params_name = url.scan(/\{([^}]*)\}/).flatten
    wrapper_block = lambda do
      get_params_values = get_params_name.map do |get_param_name|
        result = get_param_name.match(/(.+)_id/)
        value = params[get_param_name.intern]
        unless result.blank?
          begin
            klass = result[1].singularize.classify.constantize
            value = klass.find(value) if klass.class == Class
          rescue NameError
          end
        end
        value
      end

      hal = {_links: HalIntegrator.links(class_name, name)}
      response = self.instance_exec *get_params_values, &block
      hal.merge(response)
    end

    resource url.gsub('{', ':').gsub('}', '') do
      case http_verb.upcase
        when 'POST'
          post &wrapper_block
        when 'PUT'
          put &wrapper_block
        when 'DELETE'
          delete &wrapper_block
        when 'GET'
          get &wrapper_block
        else
          raise "Undefined http verb '#{http_verb}'"
      end
    end
  end

  def self.endpoint(name)
    @@endpoints[build_current_action(name.to_s)]
  end

  def self.endpoint_url(name)
    endpoint(name)[:self]
  end

  def self.method_missing(method_name, *arguments, &block)
    raise "Unknown name '#{build_current_action(method_name)}'" unless @@endpoints.has_key? build_current_action(method_name)
    context = arguments.shift
    context.instance_exec *arguments, &endpoint(method_name)[:block]
  end

end
