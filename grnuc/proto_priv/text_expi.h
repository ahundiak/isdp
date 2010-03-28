#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/expression/text_expi.I */
extern int EXP_text_exp_build __((IGRchar *expr_name, IGRchar *expr_syntax, GRspacenum osnum, GRobjid *expr_id));

#if defined(__cplusplus)
}
#endif


#undef __
