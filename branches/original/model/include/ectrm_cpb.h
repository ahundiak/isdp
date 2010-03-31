

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern IGRlong  ECtrm_cpb __(( struct GRid          old_grid,      
                               struct GRid          *new_grid ));

#if defined(__cplusplus)
}
#endif


#undef __

