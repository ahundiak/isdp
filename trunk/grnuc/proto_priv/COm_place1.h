#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/nmacro_co/COm_place1.I */
extern int COm_place_router __((int form_label, int label, double value, char *form_ptr));
extern int COm_place_select __((int form_label, int label, double value, char *form_ptr));
extern int COm_place_option __((int form_label, int label, double value, char *form_ptr));
extern int COm_place_name __((int form_label, int label, double value, char *form_ptr));

#if defined(__cplusplus)
}
#endif


#undef __
