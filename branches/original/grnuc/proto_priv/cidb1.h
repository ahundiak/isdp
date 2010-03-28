#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/src/cidb.C */
extern int DBopen __((char *dbname));
extern int DBinit __((char *dbname));
extern int DBclose __((void));
extern int DBcmd __((char *dbcmd, char *fout));
extern int DBsearch __((char *criteria, char *tblname, int *tobj, short *tosnum, int *nbobj));
extern int DBread __((char *tblname, int *obj, short *osnum, char *colname, char *value));
extern int DBwrite __((char *tblname, int *obj, short *osnum, char *colname, char *value));
extern int DBflush __((char *tblname));
extern int fillCITMP __((int *obj, char *tblname, int clear));
extern int DBselect __((char *tblname, int obj, int osnum));
extern int DBattach __((char *tblname, int *tobj, short *tosnum, int nbobj));
extern int DBdetach __((char *tblname, int *tobj, short *tosnum, int nbobj));
extern int sendsqlcmd __((int flag));
extern int DBsynchro __((void));
extern int empty_fifos __((void));

#if defined(__cplusplus)
}
#endif


#undef __
