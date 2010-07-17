/* $Id: VRgraph_over.I,v 1.2 2001/02/20 01:13:28 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrcorrection / VRgraph_over.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRgraph_over.I,v $
 *	Revision 1.2  2001/02/20 01:13:28  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:50  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.4  1996/04/04  22:23:04  pinnacle
# Replaced: vrcorrection/VRgraph_over.I for:  by msmanem for route240
#
# Revision 1.3  1996/01/17  08:33:34  pinnacle
# Replaced: vrcorrection/VRgraph_over.I for:  by ashankar for route240
#
# Revision 1.2  1996/01/16  23:27:02  pinnacle
# Replaced: vrcorrection/VRgraph_over.I for:  by r240_int for route240
#
 *
 * History:
 *	01/16/96	tlb	Added prototypes
 *	04/04/96	msm	changed malloc to _MALLOC
 *
 *************************************************************************/
class implementation VRCorrection;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <string.h>
#include "exdef.h"
#include "nddef.h"
#include "grdpbdef.h"
#include "grownerdef.h"

#include "grerr.h"
#include "macro.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h" 
#include "DIomac.h" 

#include "exmacros.h"
#include "grownmacros.h"
#include "ndmacros.h"
#include "grdpbmacros.h"

#include "AS_status.h"
#include "vrtools_pto.h"

#include "v_miscmacros.h"
#include "vrdbgmacros.h"
#include "v_datamacros.h"

#define	AS_DEBUG

from	VRGeneric	import	VRGetNextOnCpt;
from 	DImaster 	import store_info, retrieve_info, remove_info;


/******************************************************************************/

method GRdelete( IGRlong			*msg;
	         struct		GRmd_env	*md_env )
{
  IGRint		status;
  IGRint		NbFather;                /* used by NDget_objects     */
  struct	GRid	my_grid; 
  struct	GRid	FatherId[my_nbParent];   /* List of my parents GRid   */

  *msg = MSSUCC;

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  status = om$send( msg      = message NDnode.NDget_objects
                               ( ND_ROOT, FatherId, my_nbParent, NULL, 0,
                                 OM_K_MAXINT, &NbFather
                               ),
                    targetid = my_id );

  if( NbFather != my_nbParent )
  {
	/*| Delete Correction */
	status = VRDeleteObjects( 1, &my_grid, md_env );
    	as$status();
  }

  return OM_S_SUCCESS;
}


/*********************************************************/

method GRget_locate_properties( IGRlong	*msg;
				IGRint	*properties )
{
   
   *msg = MSSUCC;

   *properties = GR_LC_OWN_READ     | GR_LC_OWN_WRITE     |
    	         GR_LC_CMP_READ     | GR_LC_CMP_WRITE     |
 		 GR_LC_OWN_PRM_READ | GR_LC_OWN_PRM_WRITE |
		 GR_LC_RIGID;

   return(OM_S_SUCCESS);

}

/*********************************************************/

method GRget_siblings (IGRlong *msg; IGRushort opts;
                        IGRint *num_siblings; struct GRid **siblings;
                        IGRint num_buff; struct GRid *buff)
{
	IGRint 		status;
	IGRlong 	retmsg;
	IGRint		NbFather,NbOlets;
	register IGRint	i;
	struct	GRid	FatherId[my_nbParent];   /* List of my parents GRid   */
	struct GRid	*pSibIds;
	struct GRmd_env	md_env;

	*msg = MSSUCC;
	*num_siblings=0;

	{/* get module env */
		IGRlong			NumberOfBytes;  /* number of bytes            */
		IGRlong			BytesReceived;   /* number of received bytes  */
		NumberOfBytes = sizeof( struct GRmd_env );
		status = gr$get_model_env( 	msg    = &retmsg,
						sizbuf = &NumberOfBytes,
						buffer = &md_env,
						nret   = &BytesReceived );
		as$status( action = RET_STATUS );
		as$status( sts = retmsg, action = RET_STATUS );
		/*"module_info = %d %d\n", md_env.md_id.objid, md_env.md_id.osnum */
	}/* end get module env */

	/* ---------------------------------------- */
	/* -- get number of components templates -- */
	/* ---------------------------------------- */

	status = 
	om$send( msg      = message NDnode.NDget_objects
                               ( ND_ROOT, FatherId, my_nbParent, NULL, 0,
                                 OM_K_MAXINT, &NbFather
                               ),
		targetid = my_id );
	as$status ( action = RET_STATUS );

	/*" %d templates found \n",NbFather */

	/* ------------------------- */
	/* -- get number of olets -- */
	/* ------------------------- */
	NbOlets=0;
	status =
	om$send ( msg = message VRGeneric.VRGetNextOnCpt
			( msg,me->my_CmpCptIndex[0],
			 (struct GRid *)NULL,
			 (IGRshort *) NULL,(IGRshort)0,
			 (IGRshort *)&NbOlets,
			 (struct GRid *)NULL,
			 (IGRshort)NULL,&md_env),
		targetid = FatherId[0].objid,
		targetos = FatherId[0].osnum );
	as$status ();

	/*" %d olets found \n",NbOlets */

#ifdef IF_PROBLEM_IN_THE_FUTURE

	/* ------------------ */
	/* -- get siblings -- */
	/* ------------------ */

	status =
	om$send ( msg = message ACncpx.GRget_siblings
			( msg, opts, num_siblings, siblings, num_buff,&SibIds),
		mode = OM_e_wrt_message,
		targetid = my_id );
	as$status ();
	if ( *num_siblings  > num_buff ) 
	{
		/* buffer has been allocated */
	}

	/* -- */
#endif

	*num_siblings = NbFather + NbOlets;

	if ( *num_siblings > num_buff ) 
	{
		/*| buffer has to be allocated */

		*siblings = NULL;
		/* *siblings =
		 * (struct GRid *) malloc (*num_siblings * sizeof(struct GRid));
		 */
		*siblings = _MALLOC ( *num_siblings, struct GRid );
		if ( !(*siblings) ) return OM_E_NODYNMEM;
		pSibIds = *siblings;
	}
	else
	{
		/*| No malloc needed */
		*siblings = buff;
	}


	/* ------------------------------ */
	/* -- get components templates -- */
	/* ------------------------------ */
	for ( i=0; i<NbFather; i++ )
	{
		(*siblings)[i] = FatherId[i];
	}

	/* --------------- */
	/* -- get Olets -- */
	/* --------------- */
	NbOlets=0;
	status =
	om$send ( msg = message VRGeneric.VRGetNextOnCpt
			( msg,me->my_CmpCptIndex[0], NULL,
			NULL,(IGRshort)NbOlets,(IGRshort *)&NbOlets,&(*siblings)[NbFather],NULL,&md_env),
		targetid = FatherId[0].objid,
		targetos = FatherId[0].osnum );
	as$status ();


	return OM_S_SUCCESS;
	
}/* end GRget_siblings */

/*****************************************************************************/
/*
/*	Naming override
/*
/**/

method IGRdir.remove ( DIint *status; DIchar *name; DIint index )
{
  *status = MSSUCC;
  return (OM_S_SUCCESS);
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method translate ( DIint *stat; DIchar *name; int index; DIchar *p_name; DIobjid *objid )
{
  IGRint 	status;
  IGRlong	suc;
  struct GRid 	feet_obj;

  status = om$send( msg      = message VRCorrection.VRGetCorCmpId
	                               ( &suc, name, -1, -1, NULL, &feet_obj ),
                    targetid = my_id );
  as$status( action = RET_STATUS );
  if(objid)
  *objid = feet_obj.objid;
  if(suc==0) *stat= DIR_W_NAME_NOT_FOUND;
   else      *stat= DIR_S_SUCCESS ;
  return ( OM_S_SUCCESS );
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method dump ( DIint *stat; DIchar *reg_exp; OM_p_CLASSLIST classlist;
                DIchar ***lines; DIgrid **grids; DIint *count; 
                DIchar options )
{
  IGRint		i, status;
  IGRlong		suc;
  char 			**mname = NULL;
  struct GRid		*ft = NULL,wk_ft;
  int 			wcount;

/*"option %d OPT_SYS %d\n",options,OPT_SYS */

  /* ft=(struct GRid *)om$malloc (size = me->my_NbCorCmp * sizeof(struct GRid));
   * mname=(char **) om$malloc (size =  me->my_NbCorCmp * sizeof(char **));
   */

  ft = _MALLOC ( me->my_NbCorCmp, struct GRid );
  mname = _MALLOC ( me->my_NbCorCmp, char * );

  wcount=0;

  for(i=0;i<me->my_NbCorCmp;i++)
   {
   status = om$send( msg      = message VRCorrection.VRGetCorCmpId
                                 ( &suc, me->my_StrCmpList[i].CmpName, -1, -1, 
				   NULL, &wk_ft
                                 ),
                      targetid = my_id );
   as$status( action = RET_STATUS );
   as$status( sts = suc, action = RET_STATUS );

    /* mname[wcount] = om$malloc(size = strlen(me->my_StrCmpList[i].CmpName)+1); 
     */
    mname[wcount] = _MALLOC( strlen(me->my_StrCmpList[i].CmpName)+1, char ); 
    strcpy(mname[wcount],me->my_StrCmpList[i].CmpName );

    /* because HB check probably classes before sending dump message    */
    /* and to have parent ACdiowner understand like a nested collection */

    ft[wcount]=wk_ft;

    wcount +=1;
   }

  *count= *count + wcount;
  *grids= (DIgrid *) ft;
  *lines=mname;
  *stat= DIR_S_SUCCESS ;
 return(1);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method add ( DIint  *status; DIchar *name; DIobjid objid; int *p_index )
{
 *status = DIR_E_ABORT;
 return(OM_S_SUCCESS);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method GRgetname(IGRlong *msg; IGRchar *name)
{
  if (di$untranslate ( objid = my_id, objname = name ) == DIR_S_SUCCESS)
     *msg = MSSUCC;
  else
     *msg = MSFAIL;

  return 1;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method GRputname(IGRlong *msg; IGRchar *name)
{
  char old_name[DI_PATH_MAX];
  int i;

  *msg = MSFAIL;

    /*| remove the names from the global table */

  for(i=0;i<100;i++)    /* to not loop forever .... */
   {
    if(di$untranslate ( objid = my_id, objname = old_name ) != DIR_S_SUCCESS)
      { 
       if(name == NULL || name[0] == '\0')  *msg = MSSUCC;
       else if (DIadd_dir ( OM_Gw_current_OS, my_id, name, 1 ) == DIR_S_SUCCESS)
    					    *msg = MSSUCC;
       break;
      }
    else if(DIunlink_dir ( old_name, 1 ) != DIR_S_SUCCESS) break;
   }

  return OM_S_SUCCESS;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method GRchgname(IGRlong *msg; struct GRmd_env *env; IGRchar *name)
{
 return (om$send(msg = message ASnode.GRputname(msg,name),
		 targetid = my_id));

}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method delete(int i)
{
  char name [DI_PATH_MAX];
  int i;

    /*| remove the names from the global table */

  for(i=0;i<100;i++)    /* to not loop forever .... */
   {
    if(di$untranslate ( objid = my_id, objname = name ) != DIR_S_SUCCESS) break;
    if(DIunlink_dir ( name, 1 ) != DIR_S_SUCCESS) break;
   }

 return  om$send(msg = message ASnode.delete(i),
		  mode = OM_e_wrt_message,
		  targetid = my_id);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method DIgive_output (  char *formula )
{
 strcat(formula,"()");
 return OM_S_SUCCESS;
}

end implementation VRCorrection;
