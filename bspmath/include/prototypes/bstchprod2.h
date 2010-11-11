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

/* bstchprod2.c */
extern void BStchprod2 _BS_((IGRint,
		 IGRint,
		 IGRdouble *,
		 IGRint,
		 IGRint,
		 IGRdouble *,
		 IGRdouble *,
		 BSrc *));

#if defined(__cplusplus)
}
#endif


