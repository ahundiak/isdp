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

/* bscisieuv.c */
extern void BScisieuv _BS_((IGRint,
		 IGRint,
		 IGRdouble *,
		 BSpair,
		 BSpair,
		 IGRdouble,
		 IGRdouble,
		 IGRint *,
		 IGRdouble **,
		 BSrc *));

#if defined(__cplusplus)
}
#endif


