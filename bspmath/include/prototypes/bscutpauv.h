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

/* bscutpauv.c */
extern void BScutpauv _BS_((IGRdouble[2 ],
		 IGRdouble[2 ],
		 IGRdouble[2 ],
		 IGRdouble,
		 IGRint,
		 IGRint ,
		 IGRdouble *,
		 IGRdouble *,
		 IGRdouble *,
		 IGRdouble,
		 IGRdouble ,
		 IGRdouble[2 ],
		 IGRdouble,
		 IGRdouble,
		 IGRdouble *,
		 BSrc *));

#if defined(__cplusplus)
}
#endif


