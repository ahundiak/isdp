#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/gopara/ASmatrix.I */
extern void v_identity __((IGRpoint V));
extern void v_equal __((IGRpoint v1, IGRpoint v2));
extern void v_scale __((IGRpoint v, IGRdouble s, IGRpoint V));
extern void v_neg __((IGRpoint v, IGRpoint V));
extern void v_add __((IGRpoint v1, IGRpoint v2, IGRpoint V));
extern void v_sub __((IGRpoint v1, IGRpoint v2, IGRpoint V));
extern void v_comb __((IGRdouble s1, IGRpoint v1, IGRdouble s2, IGRpoint v2, IGRpoint V));
extern void v_cross __((IGRpoint v1, IGRpoint v2, IGRpoint V));
extern IGRdouble v_dot __((IGRpoint v1, IGRpoint v2));
extern IGRdouble v_len __((IGRpoint v));
extern IGRboolean v_zero __((IGRpoint v));
extern int v_dist_line __((IGRdouble *p1, IGRdouble *p2, IGRdouble *v0, IGRdouble *dist, IGRdouble *trans));
extern void m_mul_v __((IGRdouble m[], IGRpoint v, IGRpoint V));
extern void mt_mul_v __((IGRdouble m[], IGRpoint v, IGRpoint V));
extern IGRboolean mat3_4 __((IGRdouble *mat3, IGRdouble *mat4));
extern IGRboolean mat4_3 __((IGRdouble *mat4, IGRdouble *mat3));
extern int AStrans_mat __((IGRmatrix mat, IGRmatrix trans_mat));
extern int ASinvmat __((IGRmatrix mat, IGRmatrix inv_mat));
extern int ASmake_ref __((IGRpoint p1, IGRpoint p2, IGRpoint p3, IGRdouble *tmat));
extern void ASmatv __((IGRint flag, IGRdouble *matrix, IGRdouble *in, IGRdouble *out));

#if defined(__cplusplus)
}
#endif


#undef __
