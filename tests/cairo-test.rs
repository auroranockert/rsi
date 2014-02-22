mod cairo;

fn main() {
  use std;
  use cairo;
  use cairo::matrix::Matrix;
  use cairo::surface;
  use cairo::surface::Surface;
  use cairo::operator;

  let (width, height) = (500.0, 500.0);
  let mut s = Surface::image(surface::format::ARGB32, width as i32, height as i32);

  let mut cairo = cairo::Cairo::new(&mut s);

  let mut m = Matrix::new(width, 1.0, 1.0, -height, 0.0, height);

  cairo.transform(&m);

  cairo.set_source_rgb(0.0, 0.0, 0.0);
  cairo.move_to(0.0, 0.0);
  cairo.line_to(1.0, 1.0);
  cairo.line_to(0.0, 1.0);
  cairo.set_line_width(0.2);
  cairo.stroke();
  cairo.fill();

  cairo.set_source_rgb(0.0, 0.0, 0.0);
  cairo.line_to(1.0, 1.0);
  cairo.move_to(1.0, 0.0);
  cairo.line_to(0.0, 1.0);
  cairo.set_line_width(0.2);
  cairo.stroke();

  cairo.rectangle(0.0, 0.0, 0.5, 0.5);
  cairo.set_source_rgba(1.0, 0.0, 0.0, 0.80);
  cairo.fill();

  cairo.rectangle(0.0, 0.5, 0.5, 0.5);
  cairo.set_source_rgba(0.0, 1.0, 0.0, 0.60);
  cairo.fill();

  cairo.rectangle(0.5, 0.0, 0.5, 0.5);
  cairo.set_source_rgba(0.0, 0.0, 1.0, 0.40);
  cairo.fill();

  s.to_png("test1.png");
  s.finish();

  s = Surface::image(surface::format::ARGB32, width as i32, height as i32);
  cairo = cairo::Cairo::new(&mut s);

  cairo.save();
  cairo.set_source_rgb(0.3, 0.3, 1.0);
  cairo.paint();
  cairo.restore();

  cairo.move_to(0.0, 0.0);
  cairo.line_to(2.0 * width / 6.0, 2.0 * height / 6.0);
  cairo.line_to(3.0 * width / 6.0, 1.0 * height / 6.0);
  cairo.line_to(4.0 * width / 6.0, 2.0 * height / 6.0);
  cairo.line_to(6.0 * width / 6.0, 0.0 * height / 6.0);
  cairo.close_path();
  cairo.save();
  cairo.set_line_width(6.0);
  cairo.stroke_preserve();
  cairo.set_source_rgb(0.3, 0.3, 0.3);
  cairo.fill();
  cairo.restore();

  cairo.save();
  cairo.set_line_width(6.0);
  cairo.arc(1.0 * width / 6.0, 3.0 * height / 6.0, 0.5 * width / 6.0, 0.0 * height / 6.0, 2.0 * std::f64::consts::PI);
  cairo.stroke_preserve();
  cairo.set_source_rgb(1.0, 1.0, 0.0);
  cairo.fill();
  cairo.restore();

  s.to_png("test2.png");
  s.finish();

  let mut petal_size = 50.0;
  let size = petal_size * 8.0;

  s = Surface::image(surface::format::ARGB32, size as i32, size as i32);
  cairo = cairo::Cairo::new(&mut s);

  cairo.set_tolerance(0.1);

  /* Clear */
  cairo.set_operator(operator::Clear);
  cairo.paint();
  cairo.set_operator(operator::Over);

  cairo.translate(size / 2.0, size / 2.0);

  let n_groups = 3;
  for i in std::iter::range(0, n_groups) {
    let n_petals = [9, 7, 5][i];

    cairo.save();
    cairo.rotate([2.0, 1.0, 3.0][i]);

    match i {
      0 => cairo.set_source_rgba(1.00, 0.78, 0.57, 0.5),
      1 => cairo.set_source_rgba(0.91, 0.56, 0.64, 0.5),
      _ => cairo.set_source_rgba(0.51, 0.56, 0.67, 0.5)
    }

    let pm1 = [12.0, 16.0, 8.0][i];
    let pm2 = [3.0, 0.0, 1.0][i];

    for j in std::iter::range(1, n_petals + 1) {
      cairo.save();
      cairo.rotate(2.0 * (j as f64) * std::f64::consts::PI / (n_petals as f64));
      cairo.new_path();
      cairo.move_to(0.0, 0.0);
      cairo.rel_curve_to(petal_size, petal_size, (pm2 + 2.0) * petal_size, petal_size, 2.0 * petal_size + pm1, 0.0);
      cairo.rel_curve_to(pm2 * petal_size, -petal_size, -petal_size, -petal_size, -(2.0 * petal_size + pm1), 0.0);
      cairo.close_path();
      cairo.fill();
      cairo.restore();
    }

    petal_size -= [12.0, 4.0, 15.0][i];
    cairo.restore();
  }

  cairo.set_source_rgba(0.71, 0.81, 0.83, 0.5);

  cairo.arc(0.0, 0.0, petal_size, 0.0, 2.0 * std::f64::consts::PI);
  cairo.fill();

  s.to_png("test3.png");
  s.finish();

  println!("{:?}", cairo::font::Options::new().equal(&cairo::font::Options::new()));
}
