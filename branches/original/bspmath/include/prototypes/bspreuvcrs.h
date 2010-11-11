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

/* bspreuvcrs.c */
extern void BSpreuvcrs _BS_((IGRint,
		 IGRint,
		 IGRint,
		 struct BSbox *,
		 struct BSequlgd12 *,
		 struct BStanghv_pts *,
		 IGRdouble,
		 IGRdouble,
		 IGRdouble ,
		 IGRdouble,
		 IGRdouble ,
		 IGRdouble *,
		 IGRdouble *,
		 IGRdouble *,
		 IGRdouble *,
		 IGRdouble *,
		 IGRdouble *,
		 IGRdouble *,
		 IGRint *,
		 IGRint *,
		 IGRdouble *,
		 BSrc *));

#if defined(__cplusplus)
}
#endif


