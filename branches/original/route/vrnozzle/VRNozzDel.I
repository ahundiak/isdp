/* $Id: VRNozzDel.I,v 1.1.1.1 2001/01/04 21:12:58 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrnozzle / VRNozzDel.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRNozzDel.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:58  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.3  1997/05/21  20:29:06  pinnacle
# Replaced: ./vrnozzle/VRNozzDel.I for:  by lawaddel for route
#
# Revision 1.2  1996/08/20  04:56:08  pinnacle
# Replaced: vrnozzle/VRNozzDel.I for:  by ashankar for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1996/04/04  21:50:54  pinnacle
# Replaced: vrnozzle/VRNozzDel.I for:  by ashankar for route240
#
# Revision 1.2  1996/01/17  00:12:58  pinnacle
# Replaced: vrnozzle/VRNozzDel.I for:  by r240_int for route240
#
 *
 * History:
 *	01/16/96	tlb	Add prototypes
 *      05/16/97        ashankar  TR179602393- Prevent crashes when processing
 *                                nozzles
 *
 *************************************************************************/

class implementation VRNozzle;

#include "nddef.h"
#include "ndmacros.h"
#include "vrtools_pto.h"
#include "VDmem.h"

#define AS_DEBUG	1

#define VRMAX_SIZE	10

/**********************************************************************/
method NDdelete( struct GRmd_env *md_env )
{
  IGRlong		retmsg;
  IGRint		NbBuff=0, NbChild=0, NbSup=0, NbRef=0, NbSeg=0;
  IGRint 		status, i, j, k;
  IGRint		cn_type= ND_COMP;
  struct GRid		RefId, SgId;
  struct GRid		ReferId[VRMAX_SIZE], SegId[VRMAX_SIZE], RootId[VRMAX_SIZE];
  struct GRid		*Buffer= NULL, *p_RootId;
  GRclassid             obj_class, ObjClass;

  extern GRclassid OPP_VRCnrlSeg_class_id;
  extern GRclassid OPP_VRDepPlane_class_id;

  status = om$send ( msg = message VRNozzle.VRGetRefId( &retmsg, &RefId ),
                     targetid = my_id);

  /* ---------------------------------------------------------------------- */
  /* -- Get Referencial children and look for Deplanes in these children -- */
  /* ---------------------------------------------------------------------- */

  if (RefId.objid != NULL_OBJID )
  {
	status = om$send( msg = message NDnode.NDget_objects
				( ND_CHILDREN, RootId, VRMAX_SIZE, NULL, 0, OM_K_MAXINT, &NbChild ),
 		          targetid = RefId.objid,
			  targetos = RefId.osnum);
	as$status();

	/* -- If more than VRMAX_SIZE childs allocate memory and reget the childs -- */
	if ( NbChild > VRMAX_SIZE )
	{
		/*| Allocate memory because ref has too many child */
		Buffer = (struct GRid *) _MALLOC( NbChild, struct GRid );
      		if( !Buffer ) return OM_E_NODYNMEM;

		status = om$send( msg = message NDnode.NDget_objects
					( ND_CHILDREN, Buffer, NbChild, NULL, 0, OM_K_MAXINT, &NbBuff ),
 		          	  targetid = RefId.objid,
			  	  targetos = RefId.osnum);
		as$status( action = GOTO_VALUE, value  = wrapup ) ;
		NbChild = NbBuff;
	}

	if ( Buffer )	p_RootId = Buffer;
	else		p_RootId = RootId;

	/* -- Find DepPlanes in child list -- */
	for( i=0, k=0; i<NbChild; i++ )
	{
		status = om$get_classid( osnum     = p_RootId[i].osnum,
                                 	 objid     = p_RootId[i].objid,
                               	 	 p_classid = &ObjClass );

      		if( om$is_ancestry_valid( subclassid   = ObjClass,
            				  superclassid = OPP_VRDepPlane_class_id ) == OM_S_SUCCESS )
         	{
			/*"RefId DepPlane = %d %d\n", p_RootId[i].objid, p_RootId[i].osnum*/
			ReferId[k++] = p_RootId[i];
		}
	}
	NbRef = k;	
  }
  else /* Added for TR179602393 by Shankar */
  {
     status = om$send( mode     = OM_e_wrt_message,
                    msg      = message VRGeneric.NDdelete( md_env ),
                    targetid = my_id );
     as$status( action = RET_STATUS );

     return OM_S_SUCCESS;
  }
  
  SgId.objid = NULL_OBJID;

  status = om$send( msg      = message VRGeneric.VRGetSupports( &retmsg, 1, &SgId, &NbSup),
 		    targetid = my_id);
  as$status();

  if ( SgId.objid != NULL_OBJID && NbSup )
  {
	NbChild = 0;
	status = om$send( msg = message NDnode.NDget_objects
				( ND_ROOT, RootId, VRMAX_SIZE, NULL, 0, OM_K_MAXINT, &NbChild ),
 		          targetid = SgId.objid,
			  targetos = SgId.osnum);

	if( NbChild > VRMAX_SIZE )
  	{
		printf("More than 10 parents for the segment connected to this nozzle \n");
		printf("Cannot continue \n");
		return OM_S_SUCCESS;
  	}

	for( i=0, k=0; i<NbChild; i= i+1 )
	{
		status = om$get_classid( osnum     = RootId[i].osnum,
                                 	 objid     = RootId[i].objid,
                               	 	 p_classid = &obj_class );

      		if( om$is_ancestry_valid( subclassid   = obj_class,
            				  superclassid = OPP_VRDepPlane_class_id ) == OM_S_SUCCESS )
         	{
			/*"Segment DepPlaneId = %d %d\n", RootId[i].objid, RootId[i].osnum*/
			SegId[k++] = RootId[i];
		}
	}
	NbSeg = k;
  }

  for ( i = 0; i<NbSeg; i++)
  {
	for ( j = 0; j<NbRef ; j++)
	{
		if ( (SegId[i].objid == ReferId[j].objid) && (SegId[i].objid != NULL_OBJID) )
		{
		/*"deleted Id = %d\n",SegId[i].objid*/
		nd$wait_batch( type       = GR_DELETED, 
				l_object   = &SegId[i],
				l_obj_info = &cn_type,
				nb_obj     = 1 );

		}
	}
  }

  status = om$send( mode     = OM_e_wrt_message,
                    msg      = message VRGeneric.NDdelete( md_env ),
                    targetid = my_id );
  as$status( action = RET_STATUS );
  

  wrapup : 

  if( Buffer ) _FREE( Buffer );

  return OM_S_SUCCESS;
}
/**********************************************************************/

method NDmove_to_root ( IGRlong *msg; struct GRid *src_grid;
                        struct GRmd_env *md_env )

/*.NDmove_to_root*/
{


	IGRint		status;
	IGRlong		retmsg;
	IGRint		NbRoots,k=0;
	struct GRid	*buffer,LostTopoIds[VR_MAX_CPTS];
	IGRboolean	bDelete=FALSE;

*msg = MSSUCC;

src_grid->objid = NULL_OBJID;


	/* -- Get my templates -- */

	status = 
	om$send( msg	 = message NDnode.NDget_objects(
						ND_ROOT | ND_IN_BUF,
						NULL,
						0,
						&buffer,
						0,
						OM_K_MAXINT,
						&NbRoots ),
	           	targetid = my_id);
	as$status();

	/* -- Update my instances -- */
	if ( 	(NbRoots < (me->nNbTopo + me->nNbAttr + 1)) ||
		!(status & 1)  )
	{
		/* -- If bad number of templates :Reset my instances -- */
		/*| ERROR -> Templates not valid */
		me->nNbTopo = me->nNbAttr = 0;
		bDelete=TRUE;
	}
	else
	{
		/* -- Else count number of templates in delete list -- */

		IGRint 		wait_index[VR_MAX_CPTS + VR_NB_ATTR + 1];
		IGRint		i;

		status =
		NDis_waiting(	GR_DELETED, 
				0, 
				buffer, 
				wait_index,  /* -1 if not waiting */
				NULL, 
				NULL, 
				NbRoots);


		for ( i = 0;i<NbRoots; i++)
		{
			if ( wait_index[i] != -1 )
			{
				if ( i >= (NbRoots - me->nNbTopo) )
				{
					/*" loosing topo[%d]\n",i*/
					LostTopoIds[k] = buffer[i];
					k++;
				}
				else
				{
					/*" loosing mandatory template[%d]\n",i*/
					bDelete=TRUE;
					break;
				}
			}
		}/* end for() */

	}

	/*" %d Topo left\n",me->nNbTopo */

  {
	/* -- Delete via batch -- */
	IGRint		cn_type= ND_COMP;
	struct GRid	MyId;


	if ( bDelete )
	{

		/*| Get deleted */
		MyId.objid = my_id;
		MyId.osnum = OM_Gw_current_OS;

		/* -- Delete via batch : Call VRDeleteObjects function ( 15-05-92 ) -- */
		status = VRDeleteObjects( 1, &MyId, md_env );
		as$status();

	}
	else
	{
		/*" Disconnect from %d lost topo\n",k */
		while ( k>0 )
		{

			IGRshort	nCpNum;
			struct GRid	CorId;

			k--;

			/*| Get ride of correction */

			status = 
			om$send( msg = message VRNozzle.VRGetCptOnSup
					( &retmsg,&LostTopoIds[k],
					  &nCpNum, md_env),
							  
	           	targetid = my_id);
			as$status( action = CONTINUE );

			status = 
			om$send( msg = message VRNozzle.VRGetCorOnCpt
					( &retmsg, nCpNum, &CorId, md_env),
							  
	           	targetid = my_id);
			as$status( action = CONTINUE );

			nd$wait_batch( type       = GR_DELETED, 
					l_object   = &CorId,
					l_obj_info = &cn_type,
					nb_obj     = 1 );

			status = 
			om$send( msg = message VRNozzle.VRDisconnect
					( &retmsg,&LostTopoIds[k],md_env ),
							  
	           	targetid = my_id);
			as$status();

		}/* end disconnect from all lost topo templates */

	}/* end I stay alive */

    }/* end update graph */

return ( OM_S_SUCCESS );

}
end implementation VRNozzle;
