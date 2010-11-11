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

/* bsloophyper.c */
extern void BSloophyper _BS_((IGRint,
		 IGRdouble *,
		 IGRdouble *,
		 IGRdouble,
		 IGRdouble ,
		 IGRdouble,
		 IGRint *,
		 IGRint *,
		 IGRdouble **,
		 BSrc *));

#if defined(__cplusplus)
}
#endif


