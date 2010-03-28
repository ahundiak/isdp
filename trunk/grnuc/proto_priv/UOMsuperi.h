#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/grio/uom/UOMsuperi.I */
extern int UOM_convert_old_unit_objects __((OMuword osnum, UOM_TYPE **ouom_types));
extern int UOM_get_super_objid __((OMuword osnum, OM_S_OBJID *uom_super));
extern int UOM_lookup_type_locally __((OMuword osnum, char *name, char *dims, UOM_TYPE *types, UOM_TYPE **type));
extern int UOM_lookup_alias_locally __((UOM_TYPE *type, char *alias, UOM_VARIANT **variant));
extern int UOM_lookup_dims __((OMuword osnum, char *typename, char *alias, char dims[]));
extern int UOM_lookup_alias __((OMuword osnum, char *alias, UOM_VARIANT **variant));
extern int UOM_readout_spec __((OMuword osnum, char *typename, int inquire, UOM_READOUT *primary, UOM_READOUT *secondary, UOM_READOUT *tertiary));
extern int UOM_convert_to_readout __((OMuword osnum, double ivalue, char *ialias, char *typename, int *num_oalias, UOMalias_name *oalias, UOM_READOUT *readout, short *field_size, short *fraction_mode, char *out_buf));
extern void UOM_cvt_grio_readout __((struct GRIOreadout_spec *grioreadout, UOM_READOUT *uomreadout));
extern void UOM_cvt_uom_readout __((UOM_READOUT *uomreadout, struct GRIOreadout_spec *grioreadout));
extern int UOM_cvt_imp_to_alias __((long *msg, char *table_name, OMuword osnum, double *working_units, short *num_alias, int num_conversions, struct GRIOreadout_spec *readout_spec, short *field_size, int inverse_scale_flag, short *fraction_mode, char *cvt_list[]));
extern int UOM_cvt_exp_to_alias __((long *msg, char *table_name, OMuword osnum, short *num_def, GRIOalias_name *output_alias[], double *working_units, struct GRIOreadout_spec *readout_spec, short *field_size, int inverse_scale_flag, short *fraction_mode, char *cvt_string));
extern int UOM_cvt_imp_to_wrk __((long *msg, char *table_name, OMuword osnum, double primary, double second, double tertiary, double *working_units));
extern int UOM_cvt_exp_to_wrk __((long *msg, char *table_name, OMuword osnum, double units, char *alias, double *working_units));
extern int UOM_cvt_value_to_value __((long *msg, char *table_name, OMuword osnum, char *alias_to_cvt_from, char *alias_to_cvt_to, int num_vals, double *values_in, double *values_out));
extern int UOM_is_unit_scalable __((long *msg, char *unit_type, OMuword osnum, short *scale_flag));
extern int UOM_update_readout_spec __((long *msg, char *table_name, OMuword osnum, int update_flag, struct GRIOreadout_spec *readout_spec));
extern int UOM_get_default_units __((long *msg, char *table_name, OMuword osnum, short *flag, short *num_defaults, GRIOalias_name *default_units));
extern int UOM_put_default_units __((long *msg, char *table_name, OMuword osnum, short *flag, short *num_defaults, GRIOalias_name *default_units));
extern int UOM_default_units __((OMuword osnum, char *typename, int inquire, int *num_defaults, UOMalias_name *defaults));
extern int UOM_lookup_type __((OMuword osnum, char *typename, char dims[], UOM_TYPE **type));
extern int UOM_convert_value_to_dbu __((OMuword osnum, double ivalue, char *ialias, double *ovalue, char *dims));
extern int UOM_convert_dbu_to_value __((OMuword osnum, double ivalue, char *oalias, double *ovalue));
extern int UOM_convert_values __((OMuword osnum, int nvalues, double ivalues[], char *ialias, double ovalues[], char *oalias));
extern int UOM_add_function __((OM_p_FUNCPTR function));
extern int UOM_del_function __((OM_p_FUNCPTR function));
extern int UOM_call_notify_functions __((OMuword osnum, char *typename, int default_changed));
static int hash_dim __((char dim[], int tblsize));
static int cmp_dim __((char dim0[], char dim1[]));
static int UOM_lookup_osnum_table_entry __((OMuword osnum, int create, UOM_OSNUM_ENTRY **table_entry));
static int UOM_dump_hashtables __((UOM_OSNUM_ENTRY *ote));
static int UOM_create_hashtables __((UOM_OSNUM_ENTRY *ote));
extern int UOM_grio_float_to_ascii __((double float_in, struct GRIOreadout_spec *readout_spec, char *ascii_result));
extern int UOM_grio_float_to_sci __((double float_in, struct GRIOreadout_spec *readout_spec, char *ascii_result));
extern int UOM_grio_format_readout __((int *msg, struct GRIOreadout_spec *readout_spec, short *num_alias, GRIOalias_name *alias_list[], double *value_list, short *field_size, short *fraction_mode, char *return_string));
extern int UOM_cvt_to_lower __((char *str));
extern int UOM_mark_all_for_write __((OMuword osnum));
extern int UOM_mark_for_write __((OMuword osnum, char *typename));
extern int UOM_give_table __((OMuword osnum, UOM_TYPE **uom_table));
extern int UOM_get_type_dbu __((OMuword osnum, char *typename, char *dbualias));
extern int UOM_get_variant_shortname __((OMuword osnum, UOM_VARIANT *variant, char *typename, char *aliasname, char *shortname, int *index));
extern int UOM_set_uom_table_processing_order __((int inner_to_outer));
extern int UOM_get_type_aliases __((OMuword osnum, UOM_TYPE *type, char *typename, char ***aliases));
extern int UOM_get_variant_aliases __((OMuword osnum, UOM_VARIANT *variant, char *typename, char *aliasname, char ***aliases));
extern int UOM_report_error __((int msg, char *errstr));

#if defined(__cplusplus)
}
#endif


#undef __
