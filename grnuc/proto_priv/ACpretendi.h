#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/macro/ACpretendi.I */
extern int ACmkstring __((char *ft, char *dwn, char *ftnm));

#if defined(__cplusplus)
}
#endif


#undef __
