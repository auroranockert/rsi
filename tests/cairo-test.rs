mod cairo;

fn main() {
  use std;
  use cairo::Cairo;
  use cairo::matrix::Matrix;
  use cairo::surface;
  use cairo::surface::Surface;

  let (width, height) = (500.0, 500.0);
  let mut s = Surface::image(surface::ARGB32, width as i32, height as i32);

  let mut cairo = Cairo::new(&mut s);

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

  s = Surface::image(surface::ARGB32, width as i32, height as i32);
  cairo = Cairo::new(&mut s);

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
}
