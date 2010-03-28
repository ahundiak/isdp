#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/font/fontutil/GRfntutil.C */
extern unsigned short KJ_u_computefont __((unsigned int in_char));
extern char KJ_u_computechar __((unsigned int in_char, unsigned int in_ku));
extern int KJ_u_sjistodec __((unsigned char ch[2 ]));
extern unsigned short KJ_u_sjistojis __((unsigned int sjis));
extern int KJ_u_getfontchar __((unsigned char *code, short *font, unsigned char *ch));
extern int KJ_u_FScharok __((int font, unsigned int ch));

#if defined(__cplusplus)
}
#endif


#undef __
