mod utils;

extern crate wasm_bindgen;

use std::io::{Cursor, Seek, Write};
use image::{DynamicImage, ImageFormat};
use image::imageops::FilterType;
use wasm_bindgen::prelude::*;
use web_sys::console;
use crate::utils::set_panic_hook;

#[wasm_bindgen]
pub enum ImageSize {
    Large,
    Thumbnail,
}

#[wasm_bindgen]
pub fn resize_image(buffer: Vec<u8>) -> Vec<u8> {
    set_panic_hook();
    console::log_1(&"Wasm: resize_image called".into());

    let image = image::load_from_memory(&buffer).unwrap();
    let resized_image = resize(&image, ImageSize::Thumbnail);
    console::log_1(&"Wasm: image resized".into());

    let output_buffer = Vec::new();
    let mut cursor = Cursor::new(output_buffer);
    resized_image.into_image_bytes(&mut cursor);
    console::log_1(&"Wasm: image copied into buffer".into());

    cursor.into_inner()
}

trait ImageBytes {
    fn into_image_bytes<W: Write + Seek>(&self, bytes: &mut W);
}

impl ImageBytes for DynamicImage {
    fn into_image_bytes<W: Write + Seek>(&self, cursor: &mut W) {
        self.write_to(cursor, ImageFormat::Jpeg).unwrap();
    }
}

#[wasm_bindgen]
pub fn endianness() -> String {
    if cfg!(target_endian = "big") {
        "Big endian".to_string()
    } else {
        "Little endian".to_string()
    }
}

fn resize(image: &DynamicImage, size: ImageSize) -> DynamicImage {
    let size = match size {
        ImageSize::Large => (1000, 1000), // Not currently used.
        ImageSize::Thumbnail => (300, 300),
    };
    log_dimensions(&image);
    let resized_image = image.resize(size.0, size.1, FilterType::Lanczos3);
    log_dimensions(&resized_image);
    resized_image
}

fn log_dimensions(image: &DynamicImage) {
    let width = image.width();
    let height = image.height();
    let width_js: JsValue = width.into();
    let height_js: JsValue = height.into();
    console::log_2(&"Width: ".into(), &width_js);
    console::log_2(&"Height: ".into(), &height_js);
}

// https://doc.rust-lang.org/book/ch11-01-writing-tests.html
#[cfg(test)]
mod tests {
    use std::fs;
    use image::imageops::FilterType;
    use std::fs::File;
    use std::io::{Cursor, Read, Write};
    use crate::{ImageBytes, resize, resize_image};

    #[test]
    fn test_resize_image() {
        let original_buffer: Vec<u8> = fs::read("tests/images/banana.jpg").unwrap();
        let resized_buffer = resize_image(original_buffer);
        fs::write("test_output.png", resized_buffer).unwrap();
    }

    #[test]
    fn resize_to_thumbnail_from_bytes() {
        let image = image::open("tests/images/banana.jpg").unwrap();
        let resized_image = image.resize(160, 160, FilterType::Lanczos3);

        let image_bytes: Vec<u8> = Vec::new();
        let mut cursor = Cursor::new(image_bytes);
        resized_image.into_image_bytes(&mut cursor);
        let output_filename = "output_banana.png";
        let mut file = File::create(output_filename).unwrap();
        file.write(&cursor.get_ref()).unwrap();
    }

    #[test]
    fn resize_to_thumbnail() {
        // Image is resized correctly.
        let image = image::open("tests/images/input.png").unwrap();
        let resized_image = image.resize(160, 160, FilterType::Lanczos3);
        resized_image.save("output.png").unwrap();
    }
}