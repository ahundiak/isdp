#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/cistruct.c */
extern int STRfield_count __((int is));
extern void STRfreeF __((structrep *s));
extern void STRfree __((void));
extern unsigned STRalign __((int is));
extern unsigned STRsizeof __((int is));
extern unsigned UNIsizeof __((int iu));
extern int STRfind __((PCIident tag, PCItype *p_type));
extern int STRgetfield __((int is, PCIident f_name, PCItype *p_type, PCIfield *p_info));
extern char *STRname __((int is));
extern int mkSTR __((PCIident tag, int U_or_S));
extern int STRnosize __((PCItype *T));
extern int STRcreate __((int U_or_S, PCIident tag, PCItype *p_type));
extern int mkSTRfield __((PCItype *f_type, PCIident f_name));
extern int mkSTRbitfield __((PCIcontext *ctx, PCIident name));
extern PCItype STRend __((int s_index));
extern void STRdump __((FILE *F));

#if defined(__cplusplus)
}
#endif


#undef __
