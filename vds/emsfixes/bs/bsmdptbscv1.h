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

/* bsmdptbscv1.c */
extern void BSmdptbscv1 _BS_((IGRint,
		 IGRint,
		 IGRint,
		 IGRint,
		 IGRdouble *,
		 IGRdouble *,
		 IGRint,
		 IGRdouble *,
		 IGRdouble,
		 IGRdouble,
		 IGRdouble *,
		 IGRdouble *,
		 IGRdouble *,
		 BSrc *));

#if defined(__cplusplus)
}
#endif


