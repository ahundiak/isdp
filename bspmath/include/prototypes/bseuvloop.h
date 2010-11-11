#if defined(__STDC__) || defined(__cplusplus) || defined(NT)
#ifndef _BS_
#define _BS_(args) args
#endif
#else
#ifndef _BS_
#define _BS_(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* bseuvloop.c */
extern void BSeuvloop _BS_((IGRint,
		 IGRint,
		 IGRint,
		 struct BSbox *,
		 struct BSequlgd12 *,
		 struct BStanghv_pts *,
		 IGRdouble,
		 IGRint *,
		 IGRint *,
		 IGRdouble **,
		 BSrc *));

#if defined(__cplusplus)
}
#endif


