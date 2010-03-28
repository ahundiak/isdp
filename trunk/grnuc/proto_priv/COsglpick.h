#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/misc/COsglpick.C */
extern long COsingle_pick __((IGRchar *Title, IGRchar *item_list[], IGRlong num_items, IGRint list_width, IGRint list_height));
static void single_pick_notification_routine __((IGRint f_label, IGRint g_label, IGRdouble value, Form fp));
extern int Create_SelFrLst_form __((Form *ptr_to_SelFrLst_form, IGRint char_cols, IGRint char_rows));

#if defined(__cplusplus)
}
#endif


#undef __
