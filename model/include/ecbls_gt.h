
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif


extern IGRlong ECblendsf_gt __((IGRlong          *msg,        
                                struct GRid      base_surface, 
                                IGRpoint         base_point,    
                                struct GRmd_env  *env,        
                                IGRint           index,       
                                IGRdouble        *param_edge));


#if defined(__cplusplus)
}
#endif


#undef __


