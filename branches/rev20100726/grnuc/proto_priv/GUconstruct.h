#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/transco/GUconstruct.I */
extern IGRboolean GUconstruct __((IGRchar *buffer, struct GRid *object_info, IGRchar class_name[], IGRchar *p_level, short *p_symbology, short *p_props, IGRchar *class_attr, IGRdouble *scale_factor, struct GRmd_env *current_env));

#if defined(__cplusplus)
}
#endif


#undef __
