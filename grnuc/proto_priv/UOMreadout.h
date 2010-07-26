#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/grio/uom/UOMreadout.C */
extern int UOM_gcd __((int n, int d));
extern int UOM_strprepend __((char *str1, char *str2));
extern int UOM_float_to_sci __((double d, UOM_READOUT *readout, char *out_buf));
extern int UOM_float_to_frac __((int reduce_flag, double value, int denominator, char *string));
extern int UOM_float_to_ascii __((double d, UOM_READOUT *readout, char *out_buf));
static void add_alias __((char *out_buf, char *alias, UOM_READOUT *readout));
static int process_decimal __((char *out_buf, UOMalias_name alias, double *value, UOM_READOUT *readout, char *tmp, OM_p_FUNCPTR conv_func));
static int process_fraction __((char *out_buf, UOMalias_name alias, double *value, UOM_READOUT *readout, char *tmp, short *fraction_mode));
extern int UOM_format_readout __((UOM_READOUT *readout, short *num_alias, UOMalias_name *alias_list, double *value_list, short *field_size, short *fraction_mode, char *out_buf));
extern int UOM_set_default_readout __((UOM_READOUT *readout));

#if defined(__cplusplus)
}
#endif


#undef __
