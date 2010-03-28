#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/csrc_130/DMfields.I */
extern int DMprint_fields_contents __((struct DMfields_contents fields[]));
extern int DMrecompute_fields __((char *text1, struct DMnon_ascii_text *text2, int extraction_mask, int extraction_flag, int editable_mask, int editable_flag));
extern int DMextract_fields __((struct DMnon_ascii_text *text, int mask, int flag, struct DMfields_contents fields[], int *count));
extern int DMextract_sub_strings __((struct DMnon_ascii_text *text, struct DMfields_contents sub_strings[], int *count));
extern int DMfind_escape_sequence __((char *string, int length, int *index));
extern int DMskip_escape_sequence __((char *string, int *index));
extern int DMmemupd __((char *string1, int i1, int j1, short *length1, int size1, char *string2, int i2, int j2));
static double DMidentify_double __((char *string, char *double_names, double *double_values));
static short DMidentify_short __((char *string, char *short_names, short *short_values));
static char DMidentify_char __((char *string, char *short_names, short *short_values));
static DMdelete_comma __((struct DMnon_ascii_text *text, int *index));
static DMinsert_comma __((struct DMnon_ascii_text *text, int *index));
static DMinsert_separator __((struct DMnon_ascii_text *text, int *index));
static DMreplace_ascii_by_double __((struct DMnon_ascii_text *text, int *index, char *double_names, double *double_values));
static DMreplace_double_by_ascii __((struct DMnon_ascii_text *text, int *index));
static DMreplace_ascii_by_short __((struct DMnon_ascii_text *text, int *index, char *short_names, short *short_values));
static DMreplace_short_by_ascii __((struct DMnon_ascii_text *text, int *index));
static DMreplace_ascii_by_char __((struct DMnon_ascii_text *text, int *index, char *short_names, short *short_values));
static DMreplace_char_by_ascii __((struct DMnon_ascii_text *text, int *index));
extern int DMconvert_a_to_b __((struct DMnon_ascii_text *text));
extern int DMa_to_b __((struct DMnon_ascii_text *text, char *double_names, char *double_values, char *short_names, char *short_values));
extern int DMconvert_b_to_a __((struct DMnon_ascii_text *text));
extern int DMprocess_escape_sequence __((struct DMnon_ascii_text *text, int *index, int option, char *d_names[], double *d_values, char *s_names[], double *s_values));
extern int DMconvert __((char *string, char *d_format, double value));

#if defined(__cplusplus)
}
#endif


#undef __
