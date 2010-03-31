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

/* IDwrapi.I */
extern IGRint lnlnint __((
	IGRpoint ln1_p, 
	IGRvector ln1_v, 
	IGRpoint ln2_p, 
	IGRvector ln2_v, 
	IGRpoint int_pt));

#if defined(__cplusplus)
}
#endif

