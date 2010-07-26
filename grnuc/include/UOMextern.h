#ifndef UOMextern_included
#define UOMextern_included 1

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern int UOM_get_super_objid __(( OMuword osnum, OM_S_OBJID *objid ));
extern int UOM_lookup_type __(( OMuword osnum, char *typename,
                                UOMdimensions dims, UOM_TYPE **type ));
extern int UOM_lookup_dims __(( OMuword osnum, char *typename,
                                char *aliasname, UOMdimensions dims ));
extern int UOM_lookup_alias __(( OMuword osnum, char *aliasname,
                                 UOM_VARIANT **variant ));
extern int UOM_readout_spec __(( OMuword osnum, char *typename,
                                 int inquire, UOM_READOUT *primary,
                                 UOM_READOUT *secondary,
                                 UOM_READOUT *tertiary ));
extern int UOM_default_units __(( OMuword osnum, char *typename,
                                  int inquire, int *num_defaults,
                                  UOMalias_name *defaults ));
extern int UOM_convert_value_to_dbu __(( OMuword osnum, double ivalue,
                                         char *ialias, double *ovalue,
                                         UOMdimensions dims ));
extern int UOM_convert_dbu_to_value __(( OMuword osnum, double ivalue,
                                         char *oalias, double *ovalue ));
extern int UOM_convert_to_readout __(( OMuword osnum, double ivalue,
                                       char *ialias, char *typename,
                                       int *num_oalias, UOMalias_name *oalias,
                                       UOM_READOUT *readout, short *field_size,
                                       short *fraction_mode, char *out_buf ));
extern int UOM_add_function __(( int (*function)() ));
extern int UOM_del_function __(( int (*function)() ));
extern int UOM_cvt_imp_to_alias __(( long *msg, char *unit_type,
                                     OMuword osnum, double *working_units,
                                     short *num_alias, short num_conversions,
                                     struct GRIOreadout_spec *readout_spec,
                                     short *field_size, short inverse_scale,
                                     short *fraction_mode, char *cvt_list ));
extern int UOM_cvt_exp_to_alias __(( long *msg, char *unit_type,
                                     OMuword osnum, short *num_def,
                                     GRIOalias_name *output_alias,
                                     double *working_units,
                                     struct GRIOreadout_spec *readout_spec,
                                     short *field_size, short inverse_scale,
                                     short *fraction_mode, char *cvt_list ));
extern int UOM_cvt_imp_to_wrk __(( long *msg, char *unit_type,
                                   OMuword osnum, double primary,
                                   double secondary, double tertiary,
                                   double *working_units ));
extern int UOM_cvt_exp_to_wrk __(( long *msg, char *unit_type,
                                   OMuword osnum, double units,
                                   char *alias, double *working_units ));
extern int UOM_cvt_value_to_value __(( long *msg, char *unit_type,
                                       OMuword osnum, char *from_alias,
                                       char *to_alias, int num_vals,
                                       double *ivalues, double *ovalues ));
extern int UOM_is_unit_scalable __(( long *msg, char *unit_type,
                                     OMuword osnum, short *scalable ));
extern int UOM_update_readout_spec __(( long *msg, char *unit_type,
                                        OMuword osnum, short update,
                                       struct GRIOreadout_spec *readout_spec ));
extern int UOM_get_default_units __(( long *msg, char *unit_type,
                                      OMuword osnum, short *output,
                                      short *num_defaults,
                                      GRIOalias_name *defaults ));
extern int UOM_put_default_units __(( long *msg, char *unit_type,
                                      OMuword osnum, short *output,
                                      short *num_defaults,
                                      GRIOalias_name *defaults ));
extern int UOM_get_type_dbu __(( OMuword osnum, char *unit_type,
                                 char *dbualias ));
extern int UOM_mark_all_for_write __(( OMuword osnum ));
extern int UOM_mark_for_write __(( OMuword osnum, char *unit_type ));
extern int UOM_give_table __(( OMuword osnum, UOM_TYPE **table ));
extern int UOM_get_variant_shortname __(( OMuword osnum, UOM_VARIANT *variant,
                                          char *unit_type, char *aliasname,
                                          char *shortname, int *index ));
extern int UOM_get_type_aliases __(( OMuword osnum, UOM_TYPE *type,
                                     char *unit_type, char ***aliases ));
extern int UOM_get_variant_aliases __(( OMuword osnum, UOM_VARIANT *variant,
                                        char *unit_type, char *aliasname,
                                        char ***aliases ));
extern int UOM_report_error __(( int msg, char *error_string ));
extern int UOM_set_uom_table_processing_order __(( int ));
extern int UOM_convert_values __(( OMuword osnum, int nvalues,
                                   double ivalues[], char *ialias,
                                   double ovalues[], char *oalias ));
extern int UOM_call_notify_functions __(( OMuword osnum, char *typename,
                                          int default_changed ));

#if defined(__cplusplus)
}
#endif

#endif          /* #ifndef UOMextern_included above */
