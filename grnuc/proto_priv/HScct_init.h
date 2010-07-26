#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/cct/HScct_init.I */
extern void GRCreColorTb_button_intercept_routine __((Form fp, int xpos, int ypos, int button_number, int transition, int time_tag));
extern void GRCreColorTb_window_event_routine __((int f_label, int event, Form fp));
extern void GRCreColorTb_continuous_routine __((int form_label, int gadget_label, double value, Form fp));
static void get_table_type __((IGRshort *is_system_table));

#if defined(__cplusplus)
}
#endif


#undef __
