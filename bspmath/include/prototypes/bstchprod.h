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

/* bstchprod.c */
extern void BStchprod _BS_((IGRint,
		 IGRint,
		 IGRdouble *,
		 IGRdouble *,
		 IGRdouble *));

#if defined(__cplusplus)
}
#endif


