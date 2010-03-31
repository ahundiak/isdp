

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern IGRlong ECtrm_alc __((IGRlong              *msg,
                             IGRint               task,        
                             struct GRid          object,      
                             struct GRmdenv_info  *env_info,   
                             struct IGRbsp_curve  **curve_data, 
                             struct GRprops       *props,      
                             IGRlong       *size ));        


#if defined(__cplusplus)
}
#endif


#undef __

