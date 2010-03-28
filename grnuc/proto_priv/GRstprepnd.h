#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/grio/units/GRstprepnd.C */
extern int GRIO_strprepend __((char *str1, char *str2));

#if defined(__cplusplus)
}
#endif


#undef __
