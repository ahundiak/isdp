#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* IDcurbypoli.I */
extern  IGRint IDdyn_curbypol __(( 
        struct DPaddnl_info *DYinfo, 
        struct EX_button *point, 
        IGRdouble *matrix, 
	struct GRid **objects, 
	IGRint *num_objects,
	struct DPele_header **buffers, 
	IGRint *num_buffers, 
	IGRchar *dummy_in1, 
	IGRchar *dummy_in2, 
	IGRchar *dummy_in3,
	IGRchar *dummy_out1, 
	IGRchar *dummy_out2, 
	IGRchar *dummy_out3 ));

#if defined(__cplusplus)
}
#endif
