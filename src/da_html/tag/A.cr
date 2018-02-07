
module DA_HTML

  struct A

    include DA_Helpers

    # =============================================================================
    # Instance
    # =============================================================================

    REL_COMMON = Set{"nofollow", "noreferrer", "noopener"}
    @page     : DA_HTML::Base
    @id_class : String? = nil
    @target   : String? = nil
    @href     : String
    @rel      = Deque(String).new

    def initialize(@page, @id_class = nil, **attrs)
      @href = ""
      href_was_specified = false

      attrs.each { |k, v|
        case k
        when :rel
          v.split.each { |x|
            case x
            when "external", "help",
              "prev", "next",
              "nofollow", "noopener", "noreferrer",
              "search"
              @rel.push x
            else
              raise Invalid_Attr_Value.new(:a, k, v)
            end
          }

        when :target
          case v
          when "_self", "_blank", "_parent", "_top"
            @target = v
          else
            raise Invalid_Attr_Value.new(:a, k, v)
          end

        when :href
          _href = DA_URI.clean(v)
          if _href
            @href = _href
          else
            raise Invalid_Attr_Value.new(:a, k, v)
          end
          href_was_specified = true

        else
          raise Invalid_Attr_Value.new(:a, k, v)

        end # case
      }

      if !href_was_specified
        raise Invalid_Attr_Value.new(%[attribute for 'a' tag was not specified.])
      end

      if !@href || @href.strip.empty?
        raise Invalid_Attr_Value.new(:a, :href, @href)
      end

      REL_COMMON.each { |x|
        if !@rel.includes?(x)
          @rel.push x
        end
      }
    end # === def initialize

    def to_html
      p = @page
      p.raw! "<a"
      p.raw_id_class?(@id_class)

      ignore_nil(@target) { |x| p.raw_attr!(:target, x) }
      ignore_nil(@href) { |x| p.raw_attr!(:href, x) }
      ignore_nil(@rel) { |x| p.raw_attr!(:rel, x) }

      p.raw! ">"
      p.text?(with p yield p)
      p.raw! "</a>"
    end

    # =============================================================================
    # Class
    # =============================================================================

  end # === struct A

end # === module DA_HTML
