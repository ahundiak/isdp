#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/locate/locate/LCcheckon.C */
extern int LCclass_check_off __((void));
extern int LCclass_check_on __((void));
extern int LCget_class_check __((void));
extern int LClayer_check_off __((void));
extern int LClayer_check_on __((void));
extern int LCget_layer_check __((void));
extern int LC_criteria_off __((void));
extern int LC_criteria_on __((void));

#if defined(__cplusplus)
}
#endif


#undef __
