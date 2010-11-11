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

/* bsconcvlgd.c */
extern void BSconcvlgd _BS_((IGRint,
		 IGRdouble[2 ],
		 IGRdouble[2 ],
		 IGRdouble[2 ],
		 IGRdouble,
		 IGRdouble,
		 IGRint,
		 IGRint,
		 IGRdouble *,
		 IGRdouble *,
		 IGRdouble *,
		 IGRdouble,
		 IGRdouble,
		 IGRint,
		 IGRint *,
		 IGRdouble **,
		 BSrc *));

#if defined(__cplusplus)
}
#endif


