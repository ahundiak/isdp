
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern IGRint  BL_get_sf_vc __((struct GRid      sf_grid, 
                                struct GRmd_env  *env,   
                                IGRdouble        par_u,
                                IGRdouble        par_v,
                                IGRint           ind, 
                                IGRpoint         pos,
                                IGRvector        vec,
                                IGRboolean       *closed));

#if defined(__cplusplus)
}
#endif


#undef __


