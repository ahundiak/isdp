#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/locate/locate/LCcriteria.C */
extern int LCget_criteria_class __((OM_p_CLASSLIST *class1));
extern int LCput_criteria_class __((OM_p_CLASSLIST class1));
extern int LCfree_class_criteria __((void));

#if defined(__cplusplus)
}
#endif


#undef __
