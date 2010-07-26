#ifndef OM_D_TYPES
#define	OM_D_TYPES	1

#ifndef	NULL
#define	NULL	0
#endif
#ifndef	FALSE
#define	FALSE	0
#endif
#ifndef	TRUE
#define	TRUE	1
#endif


typedef	int 			(*OM_p_FUNCPTR) (); /* function pointer */
typedef	unsigned int 		OMuint;
typedef unsigned long int 	OMulong;
typedef unsigned short int 	OMuword;
typedef short int 		OMword;
typedef unsigned char 		OMbyte;
	/* !!!!!!!!!!!!!! until new OPP */
typedef unsigned short int 	uword;
       /* !!!!!!!!!!!!!!!!!!!!!!!!!!!  */

typedef unsigned long int	OM_S_OBJID;
typedef unsigned long int	*OM_p_OBJID;

#define OM_K_MAXINT             ((int) 0x7fffffff)


/* define the generic doubly-linked list structure */

typedef struct OM_sd_dlink	*OM_p_DLINK;

struct OM_sd_dlink
{
  OM_p_DLINK	next;
  OM_p_DLINK	prev;
};
typedef struct OM_sd_dlink	OM_S_DLINK;

#endif
