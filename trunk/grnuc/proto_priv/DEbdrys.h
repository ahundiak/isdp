#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/so/DEbdrys.C */
extern int DEset_bdrys __((double bdrys[6 ], struct IGRdisplay symbs[3 ], int count, double u1, double u2, double u3, double u4, double u5, double u6, struct IGRdisplay *symb1, struct IGRdisplay *symb2, struct IGRdisplay *symb3));
extern int DEinter_bound __((int *p_count, double bdrys[6 ], struct IGRdisplay symbs[3 ], double u1, double u2, double u3, double u4, struct IGRdisplay *symb1, struct IGRdisplay *symb2));

#if defined(__cplusplus)
}
#endif


#undef __
