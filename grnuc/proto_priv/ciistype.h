#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/ciistype.c */
extern int HEADER __((int isschar));
extern int HEADER __((int isshort));
extern int HEADER __((int isint));
extern int HEADER __((int isdouble));
extern int HEADER __((int isGRobj));
extern int HEADER __((int ispointer));
extern int HEADER __((int isword));
extern int HEADER __((int isstring));
extern int HEADER __((int isarray));
extern int HEADER __((int isnumvalue));
extern int HEADER __((int isptreq));
extern int HEADER __((int isinteq));
extern int HEADER __((int isbsari));
extern int HEADER __((int isintvalue));
extern int HEADER __((int isstruct));
extern int HEADER __((int isscalar));
extern int HEADER __((int isfcnptr));
extern int HEADER __((int isvoidptr));
extern int HEADER __((int isvoid));
extern int HEADER __((int isvoidfcn));
extern int HEADER __((int isfunction));
extern int HEADER __((int isextern));
extern int HEADER __((int isuser));
extern int HEADER __((int isvar));
extern int HEADER __((int isconst));
extern int HEADER __((int isnull));

#if defined(__cplusplus)
}
#endif


#undef __
