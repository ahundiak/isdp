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

/* bsfrtconic.c */
extern void BSfrtconic _BS_((IGRint,
		 IGRdouble[2 ],
		 IGRdouble[2 ],
		 IGRdouble[2 ],
		 IGRdouble[2 ],
		 IGRdouble[2 ],
		 IGRdouble,
		 IGRdouble *,
		 IGRboolean *,
		 BSrc *));

#if defined(__cplusplus)
}
#endif


