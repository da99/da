
export default function partial(da_html) {
  const x = da_html;
  x.div(".first", function () {
    x.p("empty paragraph");
  });
  return x;
} // function
