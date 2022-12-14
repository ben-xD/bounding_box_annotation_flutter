mod utils;

extern crate wasm_bindgen;

use std::io::Cursor;
use image::{DynamicImage, ImageFormat};
use image::imageops::FilterType;
use wasm_bindgen::prelude::*;
use crate::utils::set_panic_hook;

#[wasm_bindgen]
pub enum ImageSize {
    Large,
    Thumbnail,
}

#[wasm_bindgen]
pub struct ImagesBytes {
    offsets: Vec<u8>,
    resized_images: Vec<u8>,
}

// returning tuples isn't supported: https://github.com/rustwasm/wasm-bindgen/issues/122
// https://github.com/rustwasm/wasm-bindgen/issues/111
// #[wasm_bindgen]
// pub fn resize_image(buffer: Vec<u8>, sizes: Vec<ImageSize>) -> (Vec<u8>, Vec<u8>) {

// Consider stream processing image.
// https://rustwasm.github.io/wasm-bindgen/api/web_sys/struct.ReadableStream.html
// https://rustwasm.github.io/wasm-bindgen/api/web_sys/struct.WritableStream.html
// Replace string with enum, and support multiple sizes.

// TODO read https://github.com/rustwasm/wasm-bindgen/issues/111 and use some workaround to send ImagesBytes to server.
#[wasm_bindgen]
pub fn resize_image(buffer: Vec<u8>, sizes: Vec<ImageSize>) -> ImagesBytes {
    /// Returns a tuple containing 1. byte array containing images and
    /// 2. the byte offset needed to get the image.
    set_panic_hook();

    let image = image::load_from_memory(&buffer).unwrap();

    let mut resized_images: Vec<u8> = Vec::new();
    let mut offsets: Vec<u8> = Vec::new();
    for size in sizes {
        let resized_image = resize(&image, size);
        resized_image.to_image_bytes(&mut resized_images, &mut offsets)
    }
    ImagesBytes { offsets, resized_images }
}

// fn get_format(filename: String) -> Option<ImageFormat> {
//     let extension = filename.split(".").last().unwrap().to_lowercase();
//     if extension.eq("jpg") || extension.eq("jpeg") {
//         Some(ImageFormat::Jpeg)
//     } else if extension.eq("png") {
//         Some(ImageFormat::Png)
//     } else {
//         None
//     }
// }

trait ImageBytes {
    fn to_image_bytes(&self, bytes: &mut Vec<u8>) -> Vec<u8>;
}

impl ImageBytes for DynamicImage {
    fn to_image_bytes(&self, bytes: &mut Vec<u8>) {
        // console::log_2(&"Saving for image format: ".into(), &format!("{:?}", format).into());
        self.write_to(&mut Cursor::new(bytes), ImageFormat::Jpeg).unwrap();
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
        ImageSize::Large => (1000, 1000),
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
    use web_sys::console;
    console::log_2(&"Width: ".into(), &width_js);
    console::log_2(&"Height: ".into(), &height_js);
}

// https://doc.rust-lang.org/book/ch11-01-writing-tests.html
#[cfg(test)]
mod tests {
    use image::imageops::FilterType;
    use std::fs::File;
    use std::io::{Write};
    use image::ImageFormat;
    use crate::ImageBytes;

    #[test]
    fn resize_to_thumbnail_broken() {
        // Image gets corrupted.
        let image = image::open("tests/images/banana.jpg").unwrap();
        let resized_image = image.resize(160, 160, FilterType::Lanczos3);

        let mut image_bytes: Vec<u8> = Vec::new();
        resized_image.to_image_bytes();
        let output_filename = "output_banana.png";
        let mut file = File::create(output_filename).unwrap();
        file.write(&image_bytes).unwrap();
    }

    #[test]
    fn resize_to_thumbnail_2() {
        // Image is resized correctly.
        let image = image::open("tests/images/input.png").unwrap();
        let resized_image = image.resize(160, 160, FilterType::Lanczos3);
        resized_image.save("output.png").unwrap();
    }
}