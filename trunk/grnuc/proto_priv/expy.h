#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/expression/expy.I */
extern int expyerror __((char *s));
extern int id_present __((struct data_struct identifier, struct data_struct *p_value, struct GRid *p_expr_id));
extern int numeric_eval __((struct data_struct *result, struct data_struct value1, struct data_struct value2, int operator));
extern int boolean_eval __((struct data_struct *result, struct data_struct value1, struct data_struct value2, int operator));
extern int un_function_eval __((int f_type, struct data_struct f_arg, struct data_struct *result));
extern int bin_function_eval __((int f_type, struct data_struct f_arg1, struct data_struct f_arg2, struct data_struct *result));
extern int ifcomp_function_eval __((int f_type, struct data_struct f_arg1, struct data_struct f_arg2, struct data_struct f_arg3, struct data_struct f_arg4, struct data_struct *result));
extern int new_exp_Parse __((char *syntax, struct data_struct *result, char ***id_list, short int *id_count, int type_request, char *type_obtained));
extern int compute_Parse __((int count, struct GRid *parents_list, char *syntax, struct data_struct *result));
extern int EXP_evaluate __((char *syntax, double *pvalue));
extern int expyparse __((void));

#if defined(__cplusplus)
}
#endif


#undef __
