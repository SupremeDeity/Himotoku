use image::{guess_format, GenericImageView};
use std::cmp::min;
use std::io::Cursor;

pub struct NativeImage {
    pub data: Vec<u8>,
}

pub fn rust_crop_image(image_bytes: Vec<u8>) -> Option<Vec<NativeImage>> {
    let format = guess_format(&image_bytes).unwrap();
    match image::load_from_memory_with_format(&image_bytes, format) {
        Ok(img_to_crop) => {
            let mut y = 0;
            let max_height = 6000;
            let mut piece_list: Vec<NativeImage> = vec![];
            let (img_width, img_height) = img_to_crop.dimensions();
            while y < img_height {
                let h = min(img_height - y, max_height);

                let cropped_img = img_to_crop.crop_imm(0, y, img_width, h);

                let mut buffer = Cursor::new(Vec::<u8>::new());
                // Add Error Handling
                cropped_img.write_to(&mut buffer, format).unwrap();

                let img_bytes: NativeImage = NativeImage {
                    data: buffer.into_inner(),
                };
                piece_list.push(img_bytes);
                y += h;
            }
            Some(piece_list)
        }
        Err(_) => None,
    }
}
