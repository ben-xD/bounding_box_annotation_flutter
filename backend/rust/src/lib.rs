mod utils;

extern crate wasm_bindgen;

use mem::transmute;
use std::io::{Cursor, Seek, Write};
use std::mem;
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

// APPROACH 2:
// #[wasm_bindgen]
// pub struct Images {
//     pub large: Vec<u8>,
//     pub thumbnail: Vec<u8>
// }
// #[wasm_bindgen]
// pub fn resize_2(buffer: Vec<u8>) -> Images  {
//     let image = image::load_from_memory(&buffer).unwrap();
//     let thumbnail = resize(&image, ImageSize::Thumbnail);
//     let large = resize(&image, ImageSize::Large);
//
//     let large_image: Vec<u8> = Vec::new();
//     let mut cursor = Cursor::new(large_image);
//     large.into_image_bytes(&mut cursor);
//
//     let thumbnail_image: Vec<u8> = Vec::new();
//     let mut t_cursor = Cursor::new(thumbnail_image);
//     thumbnail.into_image_bytes(&mut t_cursor);
//
//     Images { large: cursor.into_inner(), thumbnail: t_cursor.into_inner() }
// }


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
pub fn resize_image(buffer: Vec<u8>) -> Vec<u8> {
    let sizes = vec![ImageSize::Large, ImageSize::Thumbnail];
    // Returns a tuple containing 1. byte array containing images and
    // 2. the byte offset needed to get the image.
    set_panic_hook();
    console::log_1(&"resize_image called in Rust".into());

    let image = image::load_from_memory(&buffer).unwrap();

    let mut offsets: Vec<u64> = Vec::new();
    let resized_images: Vec<u8> = Vec::new();
    let mut cursor = Cursor::new(resized_images);
    for size in sizes {
        offsets.push(cursor.position());
        console::log_2(&"Offset is: ".into(), &format!("{:?}", cursor.position()).into());
        let resized_image = resize(&image, size);
        resized_image.into_image_bytes(&mut cursor);
    };
    // We could've done this, but javascript can't deserialize it because
    // `Trace: byte length of BigUint64Array should be a multiple of 8
    // let image_count = offsets.len() as u8;
    let image_count = offsets.len() as u64;
    let image_count_u8 = image_count.to_le_bytes(); // Both rust and JS use little endian.
    let offsets_slice_u8 = unsafe { transmute(offsets.as_slice()) };
    cursor.write(offsets_slice_u8).unwrap();
    cursor.write(&image_count_u8).unwrap();

    // Actually, it's inverted.
    // The first byte for the number of images
    // The next u64 * number of images are for the pointers to the start of each image
    // The rest of the array contains image.
    cursor.into_inner()
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
    fn into_image_bytes<W: Write + Seek>(&self, bytes: &mut W);
}

impl ImageBytes for DynamicImage {
    fn into_image_bytes<W: Write + Seek>(&self, cursor: &mut W) {
        // console::log_2(&"Saving for image format: ".into(), &format!("{:?}", format).into());
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
        resized_image.into_image_bytes(&mut image_bytes);
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