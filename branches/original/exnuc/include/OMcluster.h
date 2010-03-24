/*
---------------------------------------------------------------------------
	Name:			OMcluster.h
	Author:			Grace Oliver
	Creation Date:		June 27, 1986
	Operating System(s):	Unix SYSV, V2
	Abstract:

		Cluster Object Definitions

	Revision History:

	rme001	29-apr-1987	added new flag for free space so that
				part of an outrigger can be set free.

	geo001  17-nov-1987	4.6 changes: getobjectsize macro, and 
				macros to add, delete and grow queues
				
---------------------------------------------------------------------------
*/

#ifndef OM_D_CLUSTER
#define OM_D_CLUSTER	1

#ifndef OM_D_MINIMUM
#include	"OMminimum.h"
#endif
#ifndef OM_D_ERRORDEF
#include	"OMerrordef.h"
#endif
#ifndef OM_D_PRIMITIVES
#include	"OMprimitives.h"
#endif

extern	OMuint	OM_Gi_faultinTicks;
extern	OMuint	OM_Gi_faultinBytes;
extern	OMuint	OM_Gi_numFaults;

	/*===========================================================*/
	/* All objects are aligned on quad boundaries; the structure,
	   cluster free header, is of quad size in order to keep track
	   of any free space in the cluster.
	   All cluster extents' starting addresses are quad aligned. */ 
   	/*===========================================================*/

#define		OM_K_CLUSTER_OBJ_ALIGN	sizeof(OM_S_CLUSTFHDR)
#define		OM_K_OBJHDRSIZE		sizeof(OM_S_CLUSTFHDR)

	/*========================================================*/
	/* flag values to be used for argument to om$get_extent   */
	/* informs om$get_extent whether to update certain fields */
	/* within the cluster composite structure or not          */
	/*========================================================*/
	
#define		OM_K_NOT_FAULTING_CLUSTER	NULL

#define		OM_K_FAULTING_CLUSTER		1

#define		OM_K_CLUSTER_OBJ		2

	/*======================================================*/
        /* flag values to be used for argument to free space    */
        /* informs free space whether this is vla or object or  */
        /* part of an outrigger to be set free.                 */
	/*======================================================*/
#define         OM_K_OBJECT                     42

#define         OM_K_VLA                        24

#define         OM_K_OUTPART			66

	/* for use in constructing group or cluster objects */

#define		OM_K_NOEXTEND			-1

	/* for use in neighbor structure; means take default */

#define		OM_K_NOTACLUSTER		(OMuword)-1

	/*==============================================*/
	/* cluster's free headers use high order bit to */
	/* express whether this is free space or not.   */
        /* if bit is on; then free; else not free.      */
	/*==============================================*/
	
	/* look at size value; without freehdr high order bit */

#define	OM_GETFREESIZE(freesize) ( (freesize) & 0x7fffffff )

	/* turn freehdr size high order bit on to indicate free space */

#define	OM_SETFREEBIT(freesize) (freesize) = (freesize) | 0x80000000;

	/* true if free space; false if not free space */

#define	OM_FREEBIT(freesize) ( (freesize) & 0x80000000 )

/* structure definition of global array which keeps free chunk */
/* descriptor system statistics */

struct OM_sd_FCDs_average
{
  double	find_avg;
  double	num_finds;
};
typedef struct OM_sd_FCDs_average	OM_S_FCDs_AVG;
typedef struct OM_sd_FCDs_average	*OM_p_FCDs_AVG;

/*==========================================*/
/* Structure Field Offset		    */
/*==========================================*/

#define OM_SD_FIELD_OFFSET(sd, field) ((int)&((sd *)0)->field)

#define OM_SD_FIX_PTR(sd, field, ptr) \
	(ptr) = (sd *)((int)(ptr) - ((int)&((sd *)0)->field));

#endif
