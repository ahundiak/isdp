#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/query/parser/sql.c */
extern int set_buffer __((char *buf));
extern int yylex __((void));
extern int yyrestart __((void));
extern int yyerror __((char *s));
extern int QYlist_done __((void));
extern int QYadd_class __((char *class_name));
extern int QYis_in_class_list __((int class_name));
extern int yyparse __((void));

#if defined(__cplusplus)
}
#endif


#undef __
