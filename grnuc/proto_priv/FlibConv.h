#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/fontbuilder/fconv/Flib_src/FlibConv.c */
extern int Flib_convert_font __((Typepath new_typeface, char typeface_desc[], int append, int fill_type));

#if defined(__cplusplus)
}
#endif


#undef __
