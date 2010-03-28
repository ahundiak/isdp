#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/ciparse.c */
extern action PCIxflag __((char *sw));
extern action PCIeflag __((char *errlog));
extern void cistat __((void));
extern int FILEclose __((void));
extern int FILEparse __((SysVfname fcmd));
extern int MKdot_e __((SysVfname dot_u, SysVfname dot_e));
extern int PCIdump __((SysVfname source));
extern int MKcode __((SysVfname file, int show));
extern int sortargs __((int argc, char **argv));
extern void PCIwriterc __((int rc));
extern int main __((int argc, char *argv[]));

#if defined(__cplusplus)
}
#endif


#undef __
