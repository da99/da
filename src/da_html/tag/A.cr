
module DA_HTML

  module A

    REL_COMMON = Set{"nofollow", "noreferrer", "noopener"}

    module Tag

      def a(id_class : String? = nil, **attrs)
        rel    = Deque(String).new
        target = nil
        href   = nil

        attrs.each { |k, v|
          case k
          when :rel
            v.split.each { |x|
              case x
              when "external", "help",
                "prev", "next",
                "nofollow", "noopener", "noreferrer",
                "search"
                rel.push x
              else
                raise Invalid_Attr_Value.new(:a, k, v)
              end
            }

          when :target
            case v
            when "_self", "_blank", "_parent", "_top"
              target = v
            else
              raise Invalid_Attr_Value.new(:a, k, v)
            end

          when :href
            href = DA_URI.clean(v)

          else
            raise Invalid_Attr_Value.new(:a, k, v)

          end # case
        }

        if !href || href.strip.empty?
          if !attrs[:href]?
            raise Invalid_Attr_Value.new(%[attribute for 'a' tag was not specified.])
          else
            raise Invalid_Attr_Value.new(%[attribute for 'a' tag has an invalid URL: #{attrs[:href]?.inspect}.])
          end
        end

        REL_COMMON.each { |x|
          if !rel.includes?(x)
            rel.push x
          end
        }

        raw! "<a"
        id_class!(id_class) if id_class
        attr!(:target, target) if target
        attr!(:href, href) if href
        attr!(:rel, rel) unless rel.empty?

        page = self
        raw! ">"
        text? {
          with page yield page
        }
        raw! "</a>"
      end # === def a

    end # === module Tag

  end # === struct A

end # === module DA_HTML
