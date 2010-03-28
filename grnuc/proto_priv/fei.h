#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/gde/gdedriver/fei.c */
extern int find_closest_font __((char *fontname, double bodysize, int *font_id, float *actual_bodysize));
extern int load_font __((char *fontname, int bodysize));
extern int symbol_available __((char *symbol_file, int *font_id));
extern int load_symbol __((char *symbol_file));
extern int FEI_translate_color __((int vs, int color));
extern char FEI_map_character __((char *character));
extern int FEI_get_keyboard_data __((char *character, int *count));
extern int FEI_process_data __((int cmd_type, char *cmd));
extern int FEI_calc_text __((int font_id, char *text, int length, int *height, int *width, int *line_spacing));
extern int FEI_draw_text __((int window, int font_id, char *text, int length, int xpos, int ypos, int font_height, int *nx, int *ny));
extern int FEI_find_symbol_path_and_id __((char *path, char *symbol_name, int *symbol_id));
extern int FEI_find_font_id __((char *fontname, double bodysize, int *font_id, float *actual_bodysize, int gadget_type));
extern int FEI_find_form __((char *path, char *form_name));
extern int FEI_activate_help __((void));
extern int FEI_set_window_attr __((int window));
extern int FEI_enter __((void));

#if defined(__cplusplus)
}
#endif


#undef __
