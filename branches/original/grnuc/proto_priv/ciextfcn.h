#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/ciextfcn.c */
extern int XFNcall __((PCIlist *call));

#if defined(__cplusplus)
}
#endif


#undef __
