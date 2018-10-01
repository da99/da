
module DA_HTML
  struct To_Crystal

    def something
        if cr_io.empty?
          @cr_io << <<-Crystal

            def js_negative(x : Int32 | Int64)
              x
            end
            def js_positive(x : Int32 | Int64)
              x
            end
            def js_zero(x : Int32 | Int64)
              x
            end
            def js_empty(x : Array(T)) forall T
              x
            end
            def js_not_empty(x : Array(T)) forall T
              x
            end
            def js_each(x : Array(T)) forall T
              x
            end
            def js_each(x : Hash(K,V)) forall K,V
              x
            end

          Crystal
        end
    end


  end # === struct To_Crystal
end # === module DA_HTML
