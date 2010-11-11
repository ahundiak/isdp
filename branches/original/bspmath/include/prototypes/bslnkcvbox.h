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

/* bslnkcvbox.c */
extern void BSlnkcvbox _BS_((IGRint,
		 struct BSboundary_sol **,
		 IGRint *,
		 IGRint *,
		 struct BSbox **,
		 IGRboolean *,
		 IGRdouble *,
		 IGRdouble *,
		 IGRdouble *,
		 IGRdouble *,
		 BSrc *));

#if defined(__cplusplus)
}
#endif


