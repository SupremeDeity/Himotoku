use super::*;
// Section: wire functions

#[wasm_bindgen]
pub fn wire_init_android_logger(port_: MessagePort) {
    wire_init_android_logger_impl(port_)
}

#[wasm_bindgen]
pub fn wire_rust_crop_image(port_: MessagePort, image_bytes: Box<[u8]>, max_height: u32) {
    wire_rust_crop_image_impl(port_, image_bytes, max_height)
}

// Section: allocate functions

// Section: related functions

// Section: impl Wire2Api

impl Wire2Api<Vec<u8>> for Box<[u8]> {
    fn wire2api(self) -> Vec<u8> {
        self.into_vec()
    }
}
// Section: impl Wire2Api for JsValue

impl Wire2Api<u32> for JsValue {
    fn wire2api(self) -> u32 {
        self.unchecked_into_f64() as _
    }
}
impl Wire2Api<u8> for JsValue {
    fn wire2api(self) -> u8 {
        self.unchecked_into_f64() as _
    }
}
impl Wire2Api<Vec<u8>> for JsValue {
    fn wire2api(self) -> Vec<u8> {
        self.unchecked_into::<js_sys::Uint8Array>().to_vec().into()
    }
}
