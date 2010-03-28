#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/gopara/dist_pmi.I */
extern double dsqr __((double x));
extern double give_points_distance __((struct ret_struct p1, struct ret_struct p2));
extern double give_point_line_distance __((struct ret_struct p1, struct ret_struct l2));
extern double give_lines_distance __((struct ret_struct l1, struct ret_struct l2));
extern int give_distance __((struct GRid id1, struct GRid id2, double *ptr_dist, struct GRmd_env *md_env));

#if defined(__cplusplus)
}
#endif


#undef __
