#ifndef  emglobals_h
#define  emglobals_h

#define	EM_CONSTRAINED	0x01
#define EM_VIEWALIGNED	0x02
#define EM_FORM_CANCELLED 0x099
#define FORM2_FINISHED  999

EXTERN	int 	EMplacement_type;
EXTERN	char	EMplacement_view[20];
EXTERN	int	EMbackgrnd_part;
EXTERN  int     EMread_only_part;
EXTERN	char	EMitemno[20];

#endif   /* emglobals_h */
