#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/grio/expreval/COexprules.C */
extern IGRlong perform_op __((IGRchar op, IGRdouble *val1, IGRdouble *val2, IGRdouble *result));
extern IGRboolean rule_check __((IGRchar op, enum COexpr_value_type type1, enum COexpr_value_type type2, enum COexpr_value_type *new_type));
extern IGRboolean get_func_index_from_name __((IGRchar *func_name, IGRint *index));
extern IGRboolean call_func __((IGRlong *status, IGRchar *fun, struct COexpr_stacktype *arg, struct COexpr_stacktype *result));
extern IGRlong evaluate_expr __((IGRchar op, IGRboolean scalar, struct COexpr_stacktype *arg1, struct COexpr_stacktype *arg2, struct COexpr_stacktype *result));

#if defined(__cplusplus)
}
#endif


#undef __
