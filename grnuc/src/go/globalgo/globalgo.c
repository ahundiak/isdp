/* #######################    APOGEE COMPILED   ######################## */
#include <FI.h>
#include <palgo.h>

/*
 * jhw - palette command globals
 */
struct palette_cmd GRpal_cur_cmd = {0,0,0,0};
int (* GRpal_btn_locate_func)() = 0;
struct palette * GRpal_palettes = 0;


