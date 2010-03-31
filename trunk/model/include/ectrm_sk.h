

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern IGRlong  ECtrm_SK __(( struct GRid          old_grid,      
                              struct GRid          *new_grid,
                              IGRint               *member_cnt,
                              IGRboolean           *crv_closed,
                              struct GRid          *main_obj ));


#if defined(__cplusplus)
}
#endif


#undef __

