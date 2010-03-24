#ifndef OMDB
#define OMDB 1

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "OMmacros.h"

/* The following define the page type: */

#define DATA_PAGE	(1)
#define R_LF_RT_PAGE	(2)
#define R_NL_RT_PAGE	(3)
#define R_LF_NR_PAGE	(4)
#define R_NL_NR_PAGE	(5)
#define B_LF_RT_PAGE	(6)
#define B_NL_RT_PAGE	(7)
#define B_LF_NR_PAGE	(8)
#define B_NL_NR_PAGE	(9)

/* return value indicating normal execution */
#define DB_SUCCESS	(0)

/* values that action routines passed to a search routine can return: */
#define DB_TERMINATE	(0)
#define DB_CONTINUE	(1)

/* error codes: */

#define DB_KEYNOTFOUND 		(-100)
#define DB_PATH_HISTORY_ERR 	(-101)
#define DB_REINSERT_ARRAY_ERR 	(-102)
#define DB_E_BADKEYTYPE         (-103)
#define DB_E_GETPAGEFAIL        (-104)
#define DB_B_NODUP_ALLOWED      (-105)
#define DB_E_BADTREETYPE        (-106)
#define DB_E_TYPECONFLICT       (-107)
#define DB_E_KEYOUTOFRANGE      (-108)
#define DB_E_BADACTION          (-109)
#define DB_E_NULLDEREF          (-110)
#define DB_E_NULLIDREF          (-111)
#define DB_E_LKEYGTHKEY		(-112)
#define DB_E_LEVELGTTREEHI      (-113)
#define DB_I_EMPTYTREE 		(-114)
#define DB_E_BADREQTYPE		(-115)
#define DB_E_NOSUCHPAGE		(-116)
#define DB_E_SEEDPICK		(-117)
#define DB_E_BCHOOSELF		(-118)
#define DB_E_BSEARCH		(-119)
#define DB_E_NONEMPTYTREE       (-120)
#define DB_E_FROM_OM            (-121)

/* general constants */
#ifndef NULL
#define NULL			(0)
#endif
#ifndef TRUE
#define TRUE			(1)
#endif
#ifndef FALSE
#define FALSE			(0)
#endif

#define UNSIGNED_LONG_HIVALUE (4294967295)

#define DEREF(type, myobjid, myrip)			\
						\
        ( ((IF_EQ_OBJID(myobjid, NULL_OBJID)) ||   \
        (!(1 & (om$get_instance(objid=myobjid, p_rip=&myrip)))) )? NULL :\
	  ((type *)( ((int) myrip.p_object) + sizeof(OM_S_OBJECTHDR) + \
		sizeof(int) + sizeof(OM_S_OBJID) ))) 

#define REF(type, ptr)				\
						\
(( (ptr) == NULL ) ? NULL_OBJID : (*((type *)((int)(ptr) - \
sizeof(OM_S_OBJID)))))

/* system parameters */

#define DB_BYTES_RPAGE		(4096 - ( sizeof( OM_S_OBJECTHDR ) + sizeof( OM_S_OBJID )+sizeof(int) ) )

#define DB_BYTES_BPAGE		(512 - ( sizeof( OM_S_OBJECTHDR ) + sizeof( OM_S_OBJID )+sizeof(int) ) )

#define GET_FREE_PAGE( type, start_addr, treeclass, rip)	\
							\
	{						\
	OM_S_OBJID 	objid;				\
	OM_p_OBJID	ptr_objid;			\
	int sts;					\
        OM_S_NEIGHBOR   myneighbor;			\
							\
        myneighbor = OM_GS_NULL_NEIGHBOR;		\
        myneighbor.clusterid = 0;			\
	sts=om$construct(	classname=treeclass, 	\
				neighbor=myneighbor,    \
				osnum=OM_Gw_current_OS, \
				p_objid=&objid);	\
	if ( sts & 1 )					\
          {						\
	  start_addr = DEREF(type, objid, rip);		\
	  if ( start_addr != NULL )				\
		{						\
                ptr_objid = (OM_p_OBJID)((int)start_addr-		\
		  (int)sizeof(OM_S_OBJID));			\
		*ptr_objid = objid;			       \
		}						\
	  }							\
	else						\
	  {						\
	  printf("*** ERROR FROM CONSTRUCT: %x\n", sts);	\
	  om$report_error(sts=sts);				\
	  }							\
	}


#define PUT_FREE_PAGE( addr )				\
							\
	{						\
	OM_p_OBJECTHDR	p_object;			\
	OM_p_OBJID 	p_objid;			\
	int		sts;				\
							\
	p_object = ( OM_p_OBJECTHDR )( (int)addr - 		\
		(int)sizeof( OM_S_OBJID ) - (int)sizeof(int) - 	\
		(int)sizeof(OM_S_OBJECTHDR) );			\
	p_objid = ( OM_p_OBJID )( (int)addr - (int)sizeof( OM_S_OBJID ) );\
	sts=om$delete_object( 	osnum=OM_Gw_current_OS,	\
				object=p_object, 	\
				objid=*(p_objid) );	\
	if ( ! (sts&1) )				\
	   {						\
	   om$report_error(sts=sts);			\
	   exit();					\
	   }						\
	}

/* general macros */

#define MIN(X,Y)		( (X) < (Y) ? (X) : (Y) )
#define MAX(X,Y)		( (X) > (Y) ? (X) : (Y) )

#define DB_MOV_N_BYTES(S,D,N)	(blkmv(N, (char *) S, (char *) D))	

extern char DB_Zeropage[];
#define DB_ZERO_N_BYTES(D,N) \
	{ register int i; register char *TD = (char *)(D);  \
	   for (i = (N); i > 0; i -= DB_BYTES_RPAGE, \
			       TD += DB_BYTES_RPAGE) \
              blkmv(MIN(DB_BYTES_RPAGE,i), (char *) DB_Zeropage, (char *) TD); }
#endif
