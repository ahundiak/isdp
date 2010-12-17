
/* add_btn.c */
extern int kill_add_button(void);
extern int Add_button_to_menu_bar(void);
extern int Add_button_to_popup_menu(void);
extern int Add_button_to_panel_menu(int gadget_label);
extern int execute_add_button(void);

/* button_gdt.c */
extern int kill_edit_button(void);
extern int setup_old_button_form(void);
extern int show_button_form_info(void);
extern int change_button_gadget(void);
extern void fi_button_form(int form_label, int label, double value, Form form);
extern int execute_edit_button(void);

/* command.c */
extern int command_screen(char *cmd);
extern int APP_process_command(int cmd_type, char *cmd);

/* cut_btn.c */
extern void kill_cut_button(void);
extern void Cut_button_from_menu_bar(int label);
extern void Cut_button_from_popup_menu(int label);
extern void Move_palette_up(char *pal_name, int ysize);
extern void Cut_button_from_panel_menu(int label);
extern void execute_cut_button(void);

/* define_menu.c */
extern int Goober_stop(void);
extern void kill_define_menu(void);
extern void Create_blank_button(int label, int x_size, int y_size, int x_pos, int y_pos);
extern void Create_initial_blank_menu_bar_buttons(void);
extern void Create_initial_blank_menu_panel_buttons(void);
extern void Create_initial_blank_popup_menu_buttons(void);
extern int Setup_sub_palette(Form form, int sub_palette_level, int base_line);
extern void Setup_palette_arrays(void);
extern void Determine_menu_type(Form form, int *type);
extern char _is_a_menu(char *file, char *directory);
extern int list_directory(void);
extern void init_define_form(void);
extern void Determine_button_size(Form palette_form, int pal_level);
extern void Determine_panel_button_sizes(void);
extern void setup_new_define_form(void);
extern void setup_old_define_form(void);
extern void show_define_form_info(void);
extern void create_work_form(void);
extern void fi_background_form(int form_label, int gadget_label, double value);
extern void Verify_name_field(void);
extern void fi_define_form(int form_label, int gadget_label, double value);
extern void is_it_a_new_form(void);
extern void execute_define_menu(void);

/* exec.c */
extern void fi_menubar_form(int form_label, int gadget_label, double value, Form form);
extern int myhandler(Display *display, XErrorEvent *myerr);

/* exit_mb.c */
extern void execute_EXIT(void);
extern void kill_EXIT(void);

/* free.c */
extern void _FB_free(void *pointer);

/* paste_btn.c */
extern void kill_paste_button(void);
extern void Paste_button_to_menu_bar(void);
extern void Paste_button_to_popup_menu(void);
extern void Move_palette_down(char *pal_name, int ysize);
extern void Paste_button_to_panel_menu(void);
extern void execute_paste_button(void);

/* poke.c */
extern void FIf_gadgets_in_point(Form form, int xpos, int ypos, int *num_gadgets, int gadget_array[100 ]);
extern int Select_gadget(int *gadget_label, int *xsize, int *ysize, int *display_flag, int *hilite_flag, int *accept_x, int *accept_y, int mode);

/* preview_menu.c */
extern void kill_preview_outline(void);
extern void fi_preview_form(int form_label, int gadget_label, double value);
extern void Init_preview_form(void);
extern void execute_preview_outline(void);

/* reload.c */
extern void kill_reload_symbols(void);
extern void execute_reload_symbols(void);

/* save_menu.c */
extern void kill_save_menu(void);
extern void Save_palette_to_outline_file(char *palette, int level);
extern void FIf_dump_menu_outline(void);
extern int Save_menu_panel(char *panel_name);
extern void fi_save_form(int form_label, int gadget_label, double value);
extern void execute_save_menu(void);

/* shellvar.c */
extern char *expand_shell_vars(char *unexpanded_filename);

/* stub.c */
extern void fi_construct_form(int form_label, int gadget_label, double value);
extern void kill_default_settings(void);
extern void kill_HELP(void);
extern void execute_default_settings(void);
extern void execute_HELP(void);

/* swap_btn.c */
extern void kill_swap_buttons(void);
extern void swap_buttons(int first, int second);
extern void execute_swap_buttons(void);

/* symbol_dir.c */
extern void fi_sym_dir_form(int form_label, int gadget_label, double value, Form form);
extern void Display_symbol_dir_form(void);

/* symbol_scrl.c */
extern void Init_scroll_area(char Symbol_file[200 ], Font Symbol_index);
extern void Set_scroll_view_area(Font Symbol_index);
extern void Set_scroll_symbol_file(char Symbol_file[200 ]);
extern void Display_new_top_gadget(void);
extern void fi_symbol_scroll(int form_label, int gadget_label, double value, Form form);

/* toolbox.c */
extern void Redisplay(Form form);
extern void Refresh_work_form(void);
extern void Report_fatal_form_error(int status, char file_string[200 ]);
extern void Report_fatal_error(char *error_string);
extern void Report_nonfatal_error(char *error_string);
extern void Form_multi_line_string(Form form, int label, char *string);
extern void Break_up_multi_line_string(Form form, int label, char *string);

/* validate.c */
extern int validate_integer_field(char i_str[200 ], Form form, int err_field_index, int *status);
extern double validate_double_field(char f_str[200 ], Form form, int err_field_index, int *status);
extern int print_error(Form form, int err_field_index, char t_str[200 ]);

/* whence.c */
extern char *IIwhence(char *name, char *workdir);

/* work_form.c */
extern void Find_palette_and_level(int gadget_label, int *pal_index, int *pal_level);
extern void fi_work_form(int form_label, int gadget_label, double value);
extern void fi_dummy_work_form(int form_label, int gadget_label, double value);
extern void fi_message_form(int form_label, int gadget_label, double value);
