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

/* bseuvcrsbnd.c */
extern void BSeuvcrsbnd _BS_((IGRint,
		 IGRint,
		 IGRint,
		 struct BSbox *,
		 IGRdouble,
		 IGRdouble ,
		 IGRdouble ,
		 IGRdouble ,
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


