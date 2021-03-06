class Mustache
  # The Generator is in charge of taking an array of Mustache tokens,
  # usually assembled by the Parser, and generating an interpolatable
  # Ruby string. This string is considered the "compiled" template
  # because at that point we're relying on Ruby to do the parsing and
  # run our code.
  #
  # For example, let's take this template:
  #
  #   Hi {{thing}}!
  #
  # If we run this through the Parser we'll get these tokens:
  #
  #   [:multi,
  #     [:static, "Hi "],
  #     [:mustache, :etag, "thing"],
  #     [:static, "!\n"]]
  #
  # Now let's hand that to the Generator:
  #
  # >> puts Mustache::Generator.new.compile(tokens)
  # "Hi #{CGI.escapeHTML(ctx[:thing].to_s)}!\n"
  #
  # You can see the generated Ruby string for any template with the
  # mustache(1) command line tool:
  #
  #   $ mustache --compile test.mustache
  #   "Hi #{CGI.escapeHTML(ctx[:thing].to_s)}!\n"
  class Generator
    # Options are unused for now but may become useful in the future.
    def initialize(options = {})
      @options = options
    end

    # Given an array of tokens, returns an interpolatable Ruby string.
    def compile(exp)
      "\"#{compile!(exp)}\""
    end

    # Given an array of tokens, converts them into Ruby code. In
    # particular there are three types of expressions we are concerned
    # with:
    #
    #   :multi
    #     Mixed bag of :static, :mustache, and whatever.
    #
    #   :static
    #     Normal HTML, the stuff outside of {{mustaches}}.
    #
    #   :mustache
    #     Any Mustache tag, from sections to partials.
    #
    # To give you an idea of what you'll be dealing with take this
    # template:
    #
    #   Hello {{name}}
    #   You have just won ${{value}}!
    #   {{#in_ca}}
    #   Well, ${{taxed_value}}, after taxes.
    #   {{/in_ca}}
    #
    # If we run this through the Parser, we'll get back this array of
    # tokens:
    #
    #   [:multi,
    #    [:static, "Hello "],
    #    [:mustache, :etag, "name"],
    #    [:static, "\nYou have just won $"],
    #    [:mustache, :etag, "value"],
    #    [:static, "!\n"],
    #    [:mustache,
    #     :section,
    #     "in_ca",
    #     [:multi,
    #      [:static, "Well, $"],
    #      [:mustache, :etag, "taxed_value"],
    #      [:static, ", after taxes.\n"]]]]
    def compile!(exp)
      case exp.first
      when :multi
        exp[1..-1].map { |e| compile!(e) }.join
      when :static
        str(exp[1])
      when :mustache
        send("on_#{exp[1]}", *exp[2..-1])
      else
        raise "Unhandled exp: #{exp.first}"
      end
    end

    # Callback fired when the compiler finds a section token. We're
    # passed the section name and the array of tokens.
    def on_section(name, content)
      # Convert the tokenized content of this section into a Ruby
      # string we can use.
      code = compile(content)

      # Compile the Ruby for this section now that we know what's
      # inside the section.
      ev(<<-compiled)
      if v = ctx[#{name.to_sym.inspect}]
        if v == true
          #{code}
        elsif v.is_a?(Proc)
          v.call(#{code})
        else
          v = [v] unless v.is_a?(Array) # shortcut when passed non-array
          v.map { |h| ctx.push(h); r = #{code}; ctx.pop; r }.join
        end
      end
      compiled
    end

    # Fired when we find an inverted section. Just like `on_section`,
    # we're passed the inverted section name and the array of tokens.
    def on_inverted_section(name, content)
      # Convert the tokenized content of this section into a Ruby
      # string we can use.
      code = compile(content)

      # Compile the Ruby for this inverted section now that we know
      # what's inside.
      ev(<<-compiled)
      v = ctx[#{name.to_sym.inspect}]
      if v.nil? || v == false || v.respond_to?(:empty?) && v.empty?
        #{code}
      end
      compiled
    end

    # Fired when the compiler finds a partial. We want to return code
    # which calls a partial at runtime instead of expanding and
    # including the partial's body to allow for recursive partials.
    def on_partial(name)
      ev("ctx.partial(#{name.to_sym.inspect})")
    end

    # An unescaped tag.
    def on_utag(name)
      ev("ctx[#{name.to_sym.inspect}]")
    end

    # An escaped tag.
    def on_etag(name)
      ev("CGI.escapeHTML(ctx[#{name.to_sym.inspect}].to_s)")
    end

    # An interpolation-friendly version of a string, for use within a
    # Ruby string.
    def ev(s)
      "#\{#{s}}"
    end

    def str(s)
      s.inspect[1..-2]
    end
  end
end
