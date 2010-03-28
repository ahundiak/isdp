#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/query/sl/ACqueri.I */
extern int DIprocess_query __((char *query, OMuword my_os, OM_S_OBJID my_id, int syntax));
extern int query __((char *op1, int oper, char *op2));

#if defined(__cplusplus)
}
#endif


#undef __
