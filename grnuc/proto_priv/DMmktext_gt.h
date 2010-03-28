#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_utils/DMmktext_gt.I */
extern int DMmake_annot_text __((unsigned char *text_string, IGRshort *text_length, IGRshort *text_buff_size, struct IGRestx *estx, IGRboolean symb_type, IGRchar *character, IGRint numbytes, struct GTattr *gtattr, IGRint *update_flag, IGRboolean tole_mode, IGRint type, IGRshort sixteen_font));
extern int DMadd_annot_char __((unsigned char *text_string, short *length, unsigned char *Str, int Bytes, struct GTattr *gtattr, int type));
extern int DMadd_seperator __((unsigned char *str, short *length, struct GTattr *gtattr));
extern int DMadd_line_feed __((unsigned char *str, short *length, struct GTattr *gtattr));
extern int DMadd_symbol_char __((unsigned char *str, short *length, int symb_char, double height, double width, struct GTattr *gtattr));
extern int DMadd_dual_field __((unsigned char *str, short *length, struct GTattr *gtattr));
extern int DMreplace_tol_sym __((unsigned char *string, short *text_length, int symb_char, IGRboolean tole_mode, struct IGRestx *estx, struct GTattr *gtattr));
extern int DMchange_text_mode __((unsigned char *string, IGRshort *length, IGRshort *buff_size, struct GTattr *gtattr, struct IGRestx *estx, IGRboolean dual_mode, IGRint type));
extern int DMinsert_text __((unsigned char *src_str, unsigned char *append_str, int index, int numbytes, IGRshort *length));
extern int DMdelete_text __((unsigned char *src_str, IGRshort *strlength, IGRshort DeleteFrom, IGRshort BytestoDel));
extern int DMcompute_valid_index __((unsigned char *text_string, IGRshort *text_length, IGRshort *CurrIndex, struct GTattr *gtattr, IGRboolean type));
extern int DMis_tol_sym_exists __((unsigned char *string, IGRshort *length));
extern int DMadd_tolerance_symbol __((unsigned char *string, IGRshort *length, struct GTattr *gtattr, IGRboolean tole_mode, struct IGRestx *estx, IGRchar type));
extern int DMget_possible_posn __((struct GTattr *gtattr, IGRboolean flag));
extern int DMupdt_disp_chars __((unsigned char *string, IGRshort *length, struct GTattr *gtattr, IGRboolean dual_mode, IGRboolean type));
extern int DMcompute_bytes_to_del __((IGRint *msg, unsigned char *text_string, IGRshort *text_length, struct GTattr *gtattr, IGRshort *current_index, IGRshort *BytestoDel, IGRshort *disp_char_del, IGRint *update_flag, IGRboolean type));
extern int DMskip_symbol __((unsigned char *text_string, IGRshort *text_length, IGRchar symbol_type, IGRshort *numbytes));
extern int DMmake_tol_symbol __((unsigned char *string, short *text_length, struct IGRestx *estx, struct GTattr *gtattr, IGRboolean dualmode));
extern IGRint DMget_tol_symbol_char __((unsigned char *string, IGRshort *text_length, IGRshort *symbol_index, IGRchar *symbol_char));
extern IGRint DMcompute_disp_char_posn __((unsigned char *text_string, IGRshort *text_length, struct GTattr *gtattr, IGRshort index, IGRboolean type));
extern int DMinquire_add_seperator __((IGRuchar *text_string, IGRshort *text_length, struct GTattr *gtattr, IGRshort *text_buff_size, IGRint type));
extern int DMadd_change_font __((struct GTattr *gtattr, int *index, unsigned char *text_string, short *length, int type));
extern int DMret_disp_char __((unsigned char *inp_str, int inp_length, short *num_str, unsigned char **str, short *len));

#if defined(__cplusplus)
}
#endif


#undef __
