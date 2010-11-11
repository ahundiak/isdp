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

/* bsintplcarz.c */
extern void BSintplcarz _BS_((IGRint,
		 IGRint,
		 IGRdouble *,
		 IGRint,
		 IGRint,
		 IGRint,
		 IGRint,
		 IGRdouble *,
		 IGRdouble,
		 IGRpoint,
		 IGRvector,
		 IGRshort,
		 IGRint *,
		 IGRint *,
		 IGRdouble **,
		 IGRdouble **,
		 BSrc *));

#if defined(__cplusplus)
}
#endif


