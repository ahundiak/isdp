

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern IGRlong ECtrm_del __((IGRint               task,        
                             struct GRid          object,      
                             struct GRmd_env      *obj_env ));        


#if defined(__cplusplus)
}
#endif


#undef __

