use image::{guess_format, GenericImageView};
use std::cmp::min;
use std::io::Cursor;

use android_logger::Config;
use log::LevelFilter;

pub struct NativeImage {
    pub data: Vec<u8>,
}
pub fn init_android_logger() {
    android_logger::init_once(Config::default().with_max_level(LevelFilter::Trace));
    trace!("[RustLib]: Initialized android logger.")
}

pub fn rust_crop_image(image_bytes: Vec<u8>, max_height: u32) -> Option<Vec<NativeImage>> {
    let format = guess_format(&image_bytes).unwrap_or(image::ImageFormat::Jpeg);

    trace!("[RustLib]: Using format: {}", format.extensions_str()[0]);
    if !format.can_write() || !format.can_read() {
        error!("[RustLib]: ERROR -> Cannot encode/decode the format. Returning without change.");
        let img = vec![NativeImage { data: image_bytes }];
        Some(img)
    } else {
        match image::load_from_memory_with_format(&image_bytes, format) {
            Ok(img_to_crop) => {
                trace!("[RustLib]: Loaded image. Cropping...");
                let mut y = 0;
                let mut piece_list: Vec<NativeImage> = vec![];
                let (img_width, img_height) = img_to_crop.dimensions();
                while y < img_height {
                    let h = min(img_height - y, max_height);

                    let cropped_img = img_to_crop.crop_imm(0, y, img_width, h);
                    trace!("[RustLib]: Crop completed -> {}/{}", h, img_height);

                    let mut buffer = Cursor::new(Vec::<u8>::new());
                    // Add Error Handling
                    cropped_img
                        .write_to(&mut buffer, format)
                        .unwrap_or_else(|err| {
                            error!("[RustLib]: Error while writing re-encoding -> {}", err);
                            panic!();
                        });
                    trace!("[RustLib]: Converted cropped image to bytes.",);

                    let img_bytes: NativeImage = NativeImage {
                        data: buffer.into_inner(),
                    };
                    piece_list.push(img_bytes);
                    trace!("[RustLib]: Pushed image piece to List.");
                    y += h;
                }

                Some(piece_list)
            }
            Err(e) => {
                error!("[RustLib]: ERROR {}", e);
                let img = vec![NativeImage { data: image_bytes }];
                Some(img)
            }
        }
    }
}
