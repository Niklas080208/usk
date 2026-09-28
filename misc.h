#define PIX_blu 0x0000A6
#define PIX_red 0x00FF00
#define PIX_whi 0x2D2D2D
#define PIX_grn 0xFF0000

#define PIX_b   0x000011

void put_pixel(uint32_t pixel_grb);

void halt_with_error(uint32_t pause, uint32_t blinks);

void gpio_disable_input_output(int pin);

void gpio_enable_input_output(int pin);

void finish_pins_except_leds();

void reset_cpu();
