/* $Id: VRsplitnet.I,v 1.4 2001/11/08 04:16:25 anand Exp $  */

/***************************************************************************
 * I/ROUTE
 *
 * File:	vrtools/VRsplitnet.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRsplitnet.I,v $
 *	Revision 1.4  2001/11/08 04:16:25  anand
 *	Regression fix against TR 5305.
 *	
 *	Revision 1.3  2001/06/08 20:45:46  anand
 *	TR 5305
 *	
 *	Revision 1.2  2001/06/07 19:15:00  anand
 *	JTS CR MP 5189
 *	
 *
 * History:
 *	MM/DD/YY	AUTHOR	DESCRIPTION
 *
 *	06/07/01	Anand	CR 5189.
 *	11/07/01	Anand	Fixed a regression caused by fix for TR 5305.
 *				NDnotify_disconnect has been overridden by
 *				VRDepPlane which calls GRdelete! So, when one
 *				attempts to disconnect a VRDepPlane from a
 *				VRCnrlSeg using NDdisconnect (which internally
 *				calls NDnotify_disconnect), it gets deleted.
 *				Use Root.disconnect instead of NDdisconnect.
 *
 ***************************************************************************/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 function called by segment and split network command to split network

 CHANGE HISTORY:  momo 23-09-1991 : Design date

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

class implementation Root;


#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "msdef.h"
#include "VRcompdef.h"
#include "VRcordef.h"
#include "VRcsdef.h"
#include "igrdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "grerr.h"
#include "godef.h"
#include "nddef.h"
#include "asdef.h"
#include "VRdef.h"
#include "VRdimdef.h"
#include "VRmacros.h"
#include "asmacros.h"
#include "ndmacros.h"
#include "AS_status.h"
#include "VDmem.h"
#include "vrdbgmacros.h"


#define	AS_DEBUG
#define STILL_CONNECTED 3
#define NO_COMMON_PLANE 5

from GRgraphics 	import GRdelete ;
from NDnode		import NDget_objects, NDdelete, NDcopy,
			       NDconnect, NDchange_connect;
from VRGeneric		import VRGetIndex, VRSetStatus ;
from VRComponent	import VRGetOrientationDef;
from VRNozzle		import VRGetRefId;
from VRCnrlSeg		import VRget_planes, VRGetNeighbors, VRget_terminators;

extern GRclassid OPP_VRCnrlSeg_class_id;
extern GRclassid OPP_VRDepPlane_class_id;
extern GRclassid OPP_VRNozzle_class_id;
extern GRclassid OPP_VRCptIn_class_id;
extern GRclassid OPP_VRconsdist_class_id;
extern GRclassid OPP_VRcompoint_class_id;
/*****************************************************************************/

VRSplitNetwork( msg, component_id, md_env )

IGRlong				*msg;
struct		GRid		*component_id;
struct		GRmd_env	*md_env;

/*.VRSplitNetwork */
{
  IGRlong		status, retcode;
  struct	GRid	SegId[2];
  struct	GRid	*child[2] ;
  struct	GRid	term[2] ;
  IGRshort		index0,	index1;
  IGRint		i, j, NbChild[2];
  OMuword		classId ;

  extern OMuword OPP_VRcompoint_class_id ;


  for( i=0; i<2; i++ ) child[i] = NULL ;

  *msg = MSFAIL ;

  status =
  om$send( msg	     = message VRComponent.VRGetOrientationDef
                             ( msg, &SegId[0], &index0, NULL, &SegId[1], &index1, NULL ),
                    senderid = NULL_OBJID,
		    targetid = component_id->objid,
		    targetos = component_id->osnum ) ;
  as$status( action = RET_STATUS ) ;
  as$status( action = RET_STATUS, sts = *msg ) ;

  /*"First segment : [%d,%d]\n", SegId[0].osnum, SegId[0].objid*/
  /*"Second segment : [%d,%d]\n", SegId[1].osnum, SegId[1].objid*/

	if( SegId[1].objid == NULL_OBJID )
	{
		/*| one segment */
		*msg = MSSUCC;
		return OM_S_SUCCESS;
	}

	/*
	 * Retrieve terminal plane of first segment.
	 */

	status =
	om$send( msg	   = message VRCnrlSeg.VRget_planes
			( msg, NULL, NULL, index0 ? NULL : term,
			  index0 ? term : NULL ),
		senderid = NULL_OBJID,
		targetid = SegId[0].objid,
		targetos = SegId[0].osnum ) ;
	as$status( action = RET_STATUS ) ;
	as$status( action = RET_STATUS, sts = *msg ) ;

  	/*"  Terminal plane : [%d,%d]\n",term[0].osnum,term[0].objid*/

  	/*
   	* Retrieve terminal plane of second segment.
   	*/

  	status =
	om$send( msg	   = message VRCnrlSeg.VRget_planes
				( msg, NULL, NULL, index1 ? NULL : term+1,
				  index1 ? term+1 : NULL ),
		senderid = NULL_OBJID,
		targetid = SegId[1].objid,
		targetos = SegId[1].osnum ) ;
	as$status( action = RET_STATUS ) ;
	as$status( action = RET_STATUS, sts = *msg ) ;

  	/*"  Terminal plane : [%d,%d]\n",term[1].osnum,term[1].objid*/

  	/*
   	* Retrieve childrens constrain component of all terminal planes.
   	*/

	for( i=0; i<2; i++ )
	{
		/*"-> Process plane : [%d,%d]\n", term[i].osnum, term[i].objid*/

		status =
		om$send( msg      = message NDnode.NDget_objects
					( ND_CHILDREN, NULL, 0, NULL, 0,
					OM_K_MAXINT, &NbChild[i] ),
			senderid = NULL_OBJID,
			targetid = term[i].objid,
			targetos = term[i].osnum ) ;
		as$status( action = GOTO_VALUE, value = wrapup ) ;

		/*"\tNumber of child : %d\n",NbChild[i]*/

		child[i] = _CALLOC( NbChild[i], struct GRid );

		if( !child[i] )
		{
			*msg = OM_E_NODYNMEM;
			as$status( action = GOTO_VALUE, value = wrapup, sts = *msg ) ;
		}

    		status =
		om$send( msg      = message NDnode.NDget_objects
				( ND_CHILDREN, child[i], NbChild[i],
				  NULL, 0, OM_K_MAXINT, &NbChild[i] ),
			senderid = NULL_OBJID,
			targetid = term[i].objid,
			targetos = term[i].osnum ) ;
		as$status( action = GOTO_VALUE, value = wrapup ) ;

    		/*
     		* Keep just constrain component.
     		*/

		for( j=0; j<NbChild[i]; j++ )
		{
			/*"\tchildren n'%d : [%d,%d]\n", j, (child[i]+j)->osnum, (child[i]+j)->objid*/

			status =
			om$get_classid( objid     = (child[i]+j)->objid,
					osnum     = (child[i]+j)->osnum,
					p_classid = &classId ) ;
			as$status( action = GOTO_VALUE, value  = wrapup ) ;

			if( classId != OPP_VRcompoint_class_id )
			(child[i]+j)->objid = NULL_OBJID ;
    		}
  	}

  	/*
   	* Delete constrain component which have two parents
   	* terminal plane.
   	*/

	for( i=0; i<NbChild[0]; i++ )
	{
		if( (child[0]+i)->objid == NULL_OBJID ) continue ;

		/*"-> Process constrain : [%d,%d]\n", (child[0]+i)->osnum,(child[0]+i)->objid*/

		for( j=0; j<NbChild[1]; j++ )
		{
			if( (child[1]+j)->objid == NULL_OBJID ) continue ;

			/*"Is equal to [%d,%d]\n", (child[1]+j)->osnum, (child[1]+j)->objid*/

			if( 	(child[0]+i)->objid == (child[1]+j)->objid &&
				(child[0]+i)->osnum == (child[1]+j)->osnum )
			{
				/*|Yes -> delete*/

        			status =
				om$send( msg	   = message NDnode.NDdelete( md_env ),
					senderid = NULL_OBJID,
					targetid = (child[1]+j)->objid,
					targetos = (child[1]+j)->osnum ) ;
				as$status( action = GOTO_VALUE, value = wrapup ) ;

				(child[1]+j)->objid = NULL_OBJID ;
			}
		}
	}

	nd$exec_batch( mode = 0 ) ;

	status =
	VRdisconnect( msg, &SegId[0], &SegId[1], md_env ) ;
	as$status() ;
	as$status( sts = *msg ) ;

	status = VR$ComputeCorrection( p_retmsg = &retcode,
					CorType = VR_UNKNOWN,
					p_SegmentId = &SegId[0],
					p_MdEnv = md_env );

	status = VR$ComputeCorrection( p_retmsg = &retcode,
					CorType = VR_UNKNOWN,
					p_SegmentId = &SegId[1],
					p_MdEnv = md_env );
wrapup :
	for( i=0; i<2; i++ ) if( child[i] ) _FREE( child[i] ) ;

	*msg = ( *msg & status & 1 ) ? OM_S_SUCCESS : *msg ;

  return( *msg );

}

/********************************************************************************************/
/*
/*  Given 2 (or more?) components copy and separate their common plane
/*  if these component are not connected
*/

VRdisconnect( msg, seg1, seg2, md_env )

IGRint 			*msg;
struct	GRid 		*seg1,*seg2;
struct	GRmd_env 	*md_env;

/*. VRdisconnect */
{
    IGRint 		i1,n1,i2,i3,i4,i5,ic,ncom,nplane,ncomp;
    IGRint		nplane_comp, count, status, run, check, wait_index;
    IGRlong 		loc_msg;
    IGRboolean 		Inside_list, flag ;
    GRclassid 		classId;
    struct 	GRid 	*connected1,*planes,component[2],*plane_comp; 
    struct	GRid	plane1[10],plane2[10], common[4],clone[4];
    struct	GRid	*t_seg1, *t_seg2;

    extern GRclassid OPP_VRplane_class_id;
    extern GRclassid	OPP_VRDepPlane_class_id;

    SetProc( VRdisconnect ); Begin

    /* Init */
    connected1 	= NULL;
    planes     	= NULL;
    plane_comp 	= NULL;
    *msg 		= MSFAIL;

    /*" get plane of the 2 control segment %d %d\n",seg1->objid,seg2->objid */
    __DBGpr_obj(" Segment 1",*seg1);
    __DBGpr_obj(" Segment 2",*seg2);

    status = om$send( msg      = message NDnode.NDget_objects
		      ( ND_ROOT, plane1, 10, NULL, 0, OM_K_MAXINT, &count ),
		      senderid = NULL_OBJID,
		      targetid = seg1->objid,
		      targetos = seg1->osnum);
    as$status(action = RET_STATUS);

    /*"pl1 = %d %d %d %d\n", plane1[0].objid,plane1[1].objid,plane1[2].objid,plane1[3].objid */
    __DBGpr_objlist("Plane parents for seg1",count,plane1);

    /* Below code added by Anand - disconnect dependent planes from segment 1 */
    __DBGpr_int(" Number of plane parents for segment 1 (> 4?)",count);
    for( i1=4 ; i1<count ; i1++ )
    {
	om$get_classid( objid = plane1[i1].objid,
			osnum = plane1[i1].osnum,
			p_classid = &classId );

	if( om$is_ancestry_valid( subclassid = classId,
				  superclassid = OPP_VRDepPlane_class_id)
							      == OM_S_SUCCESS )
	{
	    OM_S_CHANSELECT	NDfather_channel, NDchild_channel;

	    __DBGpr_obj("Disconnecting from seg1, the Dep Plane", plane1[i1] );

	    status = om$make_chanselect(channame     ="NDfather.father",
					p_chanselect = &NDfather_channel );
	    as$status(action = RET_STATUS);

	    status = om$make_chanselect(channame     ="NDchildren.children",
					p_chanselect = &NDchild_channel );
	    as$status(action = RET_STATUS);

	    status = om$send( msg      = message Root.disconnect(
							      NDfather_channel,
							      plane1[i1].objid,
							      plane1[i1].osnum,
							      NDchild_channel
								),
			      senderid = NULL_OBJID,
			      targetid = seg1->objid,
			      targetos = seg1->osnum);
	    as$status(action = RET_STATUS);
	    __DBGpr_obj(" Disconnected Dep Plane from seg1", plane1[i1] );
	}
    }
    /* Above code added by Anand - disconnect dependent planes from segment 1 */

    status = om$send( msg      = message NDnode.NDget_objects
		      ( ND_ROOT, plane2, 10, NULL, 0, OM_K_MAXINT, &count ),
		      senderid = NULL_OBJID,
		      targetid = seg2->objid,
		      targetos = seg2->osnum);
    as$status(action = RET_STATUS);

    /*"pl2 = %d %d %d %d\n", plane2[0].objid,plane2[1].objid,plane2[2].objid,plane2[3].objid */
    __DBGpr_objlist("Plane parents for seg2",count,plane2);

    /* Below code added by Anand - disconnect dependent planes from segment 2 */
    __DBGpr_int(" Number of plane parents for segment 2 (> 4?)",count);
    for( i1=4 ; i1<count ; i1++ )
    {
	om$get_classid( objid = plane2[i1].objid,
			osnum = plane2[i1].osnum,
			p_classid = &classId );

	if( om$is_ancestry_valid( subclassid = classId,
				  superclassid = OPP_VRDepPlane_class_id)
							      == OM_S_SUCCESS )
	{
	    OM_S_CHANSELECT	NDfather_channel, NDchild_channel;

	    __DBGpr_obj("Disconnecting from seg2, the Dep Plane", plane2[i1] );

	    status = om$make_chanselect(channame     ="NDfather.father",
					p_chanselect = &NDfather_channel );
	    as$status(action = RET_STATUS);

	    status = om$make_chanselect(channame     ="NDchildren.children",
					p_chanselect = &NDchild_channel );
	    as$status(action = RET_STATUS);

	    status = om$send( msg      = message Root.disconnect(
							      NDfather_channel,
							      plane2[i1].objid,
							      plane2[i1].osnum,
							      NDchild_channel
								),
			      senderid = NULL_OBJID,
			      targetid = seg2->objid,
			      targetos = seg2->osnum);
	    as$status(action = RET_STATUS);
	    __DBGpr_obj(" Disconnected Dep Plane from seg2", plane2[i1] );
	}
    }
    /* Above code added by Anand - disconnect dependent planes from segment 2 */


    /* Get the list of common planes */

    for(i1=0,ncom=0;i1<4;i1++)
    {
	for(i2=0;i2<4;i2++)
	{
	    if( plane1[i1].objid == plane2[i2].objid &&
		plane1[i1].osnum == plane2[i2].osnum )
	    {
		common[ncom++] = plane1[i1];
		/*"plane %d common\n",common[ncom-1].objid*/
	    }
	}
    }

    if(ncom == 0)
    { 
	/*| no common plane */
	*msg = NO_COMMON_PLANE;
	End
	return(OM_S_SUCCESS);
    }
    __DBGpr_objlist("Planes common to both segments", ncom,common);

    /*| Get connected segments with common plane has parent */

    for(ic=0;ic<ncom;ic++)
    {
	t_seg1 = seg1;
	t_seg2 = seg2;
	for( run=0; run<2; run++ )
	{
	    if( run )
	    {
		t_seg2 = seg1;
		t_seg1 = seg2;
	    }
	    /*| call VRget_connected */
	    __DBGpr_obj(" Calling VRget_connected on plane",common[ic]);
	    __DBGpr_obj(" ... on segment", *t_seg1);
	    status = VRget_connected( t_seg1, t_seg2, &common[ic], 1,
				      &connected1, &n1, &planes, &nplane,
				      md_env);
	    as$status(action = GOTO_VALUE, value = wrapup);

	    __DBGpr_objlist(" Connected segments returned by VRget_connected",
							       n1, connected1);
	    __DBGpr_objlist(" Common planes returned by VRget_connected",
							       nplane, planes);

	/* verify that the second segment is not connected to the first one */

	    for(i1=0;i1<n1;i1++)
	    { 
		if( ( connected1[i1].objid == t_seg2->objid ) &&
		    ( connected1[i1].osnum == t_seg2->osnum ) ) 
		{
		    /*| Segment are still connected */
		    clone[ic].objid=NULL_OBJID;

#if defined(DBG_PROD_NAME)
		    if( DBG_Gb_dbg & DBG_PROD )
			fprintf( DBG_Gb_Fp, "Segments [%d,%d] and [%d,%d] were found to be connected in run no.%d on common plane [%d,%d]\n",
					   t_seg1->osnum, t_seg1->objid,
					   t_seg2->osnum, t_seg2->objid,
					   run,
					   common[ic].osnum, common[ic].objid);
#elif defined(vdsDEBUG)
		    printf(" Segments [%d,%d] and [%d,%d] were found to be connected in run no.%d on common plane [%d,%d]\n",
					   t_seg1->osnum, t_seg1->objid,
					   t_seg2->osnum, t_seg2->objid,
					   run,
					   common[ic].osnum, common[ic].objid);
#endif
		    break;
		}
	    }

	    if( i1<n1 )
		*msg = STILL_CONNECTED;
	    else
	    {
		__DBGpr_obj(" Doing NDcopy on",common[ic]);
		status = om$send( msg      = message NDnode.NDcopy
				  ( &loc_msg, 0, md_env, md_env, clone+ic ),
				  senderid = NULL_OBJID,
				  targetid = common[ic].objid,
				  targetos = common[ic].osnum);
		as$status(action = RET_STATUS );
		__DBGpr_obj(" clone of above plane is",clone[ic]);

		VRUpdateComPoints( common[ic], clone[ic], t_seg1 );

		status = VRCheckForDepPlanes( &flag, common[ic] );

		if( flag )
		{
		    status = VRUpdateConst( common[ic], clone[ic], connected1, n1, md_env );
		    as$status();
		}

		for(i1=0; i1<n1; i1++)
		{
	/* Only one change connect at the time because some of them may fail */

		    NDis_waiting( GR_DELETED, 0, common+ ic, &wait_index,
				  NULL, NULL, 1 );
		    __DBGpr_int(" wait_index returned by NDis_waiting on common plane", wait_index);

		    status=om$send( msg      = message NDnode.NDchange_connect
						      ( 1,common+ic,clone+ic ),
				    senderid = NULL_OBJID,
				    targetid = connected1[i1].objid,
				    targetos = connected1[i1].osnum);
		    __DBGpr_obj(" common plane parent replaced by clone plane on control seg with id", connected1[i1]);

		    if( wait_index != -1 )
			nd$wait_batch( type = GR_DELETED,
				       l_object = clone+ic,
				       nb_obj = 1 );


		    status =
		    om$send( msg      = message VRCnrlSeg.VRget_terminators
				    ( &loc_msg, &ncomp, NULL, NULL, component ),
			     senderid = NULL_OBJID,
			     targetid = connected1[i1].objid,
			     targetos = connected1[i1].osnum);
		    __DBGpr_objlist("Components on CnrlSeg",ncomp,component);

		    if( ncomp )
		    {
			for(i2=0;i2<ncomp;i2++)
			{
		    /*Retrieve parent planes*/
		    /*"-> Process component : %d\n",component[i2].objid*/
			    status = om$send
			    ( msg      = message NDnode.NDget_objects
							( ND_ROOT,NULL,0,
							  NULL, 0, OM_K_MAXINT,
							  &nplane_comp ),
			      senderid = NULL_OBJID,
			      targetid = component[i2].objid,
			      targetos = component[i2].osnum );
			    as$status( action = GOTO_VALUE, value = wrapup ) ;
			    /*"\tNumber of parents : %d\n", nplane_comp*/

			    plane_comp=(struct GRid *) _MALLOC(nplane_comp, struct GRid );
			    status = om$send
			    ( msg      = message NDnode.NDget_objects
			      ( ND_ROOT, plane_comp,
				nplane_comp, NULL, 0,
				OM_K_MAXINT, &nplane_comp
			      ),
			      senderid = NULL_OBJID,
			      targetid = component[i2].objid,
			      targetos = component[i2].osnum );
			    as$status( action = GOTO_VALUE, value = wrapup ) ;

			    for( check=0; check < nplane_comp; check++ )
			    {
				if( 
				   common[ic].objid == plane_comp[check].objid &&
				   common[ic].osnum == plane_comp[check].osnum )
				    break;
			    }

			    if( check == nplane_comp )
				/* Fix for JTS CR MP 5189. Cannot break here.
				 * Need to process the component on the "other
				 * end" as well. - Anand */
				// break;
				continue;

			    for(i3=0, Inside_list=FALSE;i3<nplane_comp;i3++)
			    {
				/*| See if parent is a plane */
				status = om$get_classid(objid=plane_comp[i3].objid,osnum=plane_comp[i3].osnum,
							p_classid=&classId);
				as$status(action=GOTO_VALUE,value=wrapup);
				if( classId != OPP_VRplane_class_id ) continue;

				for(i4=0;i4<ncom;i4++) 
				    if(plane_comp[i3].objid == common[i4].objid) 
				    { /*"\tparent plane %d is a common plane\n",plane_comp[i3].objid*/
					Inside_list = TRUE;
					break;
				    }

				if( i4>=ncom )
				{
				    /*"\tIs plane parent %d inside list\n",plane_comp[i3].objid*/
				    for(i5=0;i5<nplane;i5++) 
					if( plane_comp[i3].objid == planes[i5].objid)
					{
					    Inside_list = TRUE;
					    break;
					}
				}

				if( Inside_list )
				{
				    /*|\t-> Yes ===> Change connect of component*/
				    NDis_waiting( GR_DELETED, 0, common+ ic, &wait_index, NULL, NULL, 1 );

				    status = om$send
				    ( msg      = message NDnode.NDchange_connect( 1, common+ic, clone+ic),
				      senderid = NULL_OBJID,
				      targetid = component[i2].objid,
				      targetos = component[i2].osnum);

				    if( wait_index != -1 )
					nd$wait_batch( type = GR_DELETED,
						       l_object = clone+ic,
						       nb_obj  = 1 );

				    Inside_list = FALSE;
				    break;
				} 
				else
				{ 
				    /*|\t-> No ===> Do nothing */;
				}
			    }

			    if( plane_comp != NULL ) 
			    {
				_FREE(plane_comp );
				plane_comp = NULL;
			    }
			}
		    }
		}
	    }
	    _FREE( planes ); planes     = NULL;
	    _FREE( connected1 ); connected1 = NULL;
	}
    }


    *msg = MSSUCC;

wrapup :
    if(connected1 != NULL) 	_FREE( connected1 );
    if(planes     != NULL) 	_FREE( planes );
    if(plane_comp != NULL) 	_FREE( plane_comp );

    return(status);

}

/*
    Return all segments and all planes connected to a given segment
    and sharing one of the common plane. 
*/

VRget_connected(seg,seg1,common,ncom,p_connected,p_ncon,p_plane,p_nplane,md_env)
struct GRid *seg,          /* I segment whose connected elements are inquired */
	    *seg1,         /* I segment neighbour to seg                      */
            *common;	   /* I common plane 				      */
int ncom;		   /* I number of common planes			      */
struct GRid **p_connected; /* O connected elements space allocated by function*/
struct GRid **p_plane;     /* O planes parent space allocated by function     */
int         *p_ncon;	   /* O nb of connected elements 		      */
int         *p_nplane;	   /* O nb of planes 		                      */
struct GRmd_env *md_env;   /* I md_env					      */
/*.VRget_connected*/
{
 int status ;
 long msg;
 int size,i,j,k,l,n,nplane,size_plane;
 struct GRid *connected=NULL;
 struct GRid *planes=NULL;
#define MAX_NEIB 20
 struct GRid neib[MAX_NEIB];
 int nb_neib;
 struct GRid other_plane[4];
 int other_count;
 IGRboolean found;


 /*"Get segments connected to %d\n",seg->objid */

 size = 20;
 connected = (struct GRid *) _MALLOC(size,struct GRid);
 
 size_plane = ncom+20;
 planes = (struct GRid *) _MALLOC(size_plane, struct GRid );

 nplane=ncom;
 for(i=0;i<ncom;i++) planes[i]=common[i];
 
 n=1;
 connected[0] = *seg; 

 for(i=0;i<n;i++)
  {
/**
   printf( "Process segment -> %d\n", connected[i].objid );
   printf( "Except segment -> %d\n", seg1->objid );
**/
   /*|Get planes of segment*/
   status = om$send(msg = message NDnode.NDget_objects(ND_ROOT,other_plane,
                                           4,NULL,0,OM_K_MAXINT,&other_count),
                  senderid = NULL_OBJID,
                  targetid = connected[i].objid,
                  targetos = connected[i].osnum);
   as$status(action=GOTO_VALUE,value=error);
        
   for(j=0;j<4;j++) 
     {
      /*"\tplane %d already obtained\n",other_plane[j].objid*/
      for(k=0;k<nplane;k++) if(other_plane[j].objid == planes[k].objid)
							      break;
      if(k>=nplane) 
	{
	 if(nplane >= size_plane)
	   {size_plane += 20;
	    planes = (struct GRid *) _REALLOC( planes, size_plane, struct GRid );
	   }
	 /*|\tno --> store it */
	 planes[nplane++] = other_plane[j];
								   
	} else { /*|\tyes --> don't store it */ }
     }

   /*|Get neighbors of segment*/
   status = om$send(msg = message VRCnrlSeg.VRGetNeighbors(&msg,MAX_NEIB,
					&nb_neib,neib,md_env),
		    senderid = NULL_OBJID,
   		    targetid = connected[i].objid,
   		    targetos = connected[i].osnum);
   /*"\treturn %d neib\n",nb_neib */
   as$status(action = GOTO_VALUE, value = error );
   if(nb_neib > MAX_NEIB) return(OM_W_ABORT);

   for(j=0;j<nb_neib;j++)
    {
     /*  Does this segment have a common plane with the plane to split */
     if( i==0 && neib[j].objid == seg1->objid ) continue ;
      status = om$send(msg = message NDnode.NDget_objects(ND_ROOT,other_plane,4,
      					       NULL,0,OM_K_MAXINT,&other_count),
                  senderid = NULL_OBJID,
                  targetid = neib[j].objid,
                  targetos = neib[j].osnum);
      if(!(status&1)) continue;
      found = FALSE;
      for(k=0;!found && k<other_count;k++)
	{
	 for(l=0;!found && l<ncom;l++) 
          {
           if(  (common[l].objid == other_plane[k].objid)
	      &&(common[l].osnum == other_plane[k].osnum)) 
		{
		 found = TRUE;
		 /*"\t%d has a common plane\n",neib[j].objid */
		}
	  }
        }
      if(!found) continue;
      
      /*"\tIs %d already obtained\n",neib[j].objid */
      for(k=0;k<n;k++) if(neib[j].objid == connected[k].objid) break;
      if(k>=n) 
       {
	if(n >= size)
          {size += 20;
           connected = (struct GRid *) _REALLOC(connected, size,struct GRid );
          }
	/*|\tno --> store it */
        connected[n++] = neib[j];
       } else { /*|\tyes --> don't store it */ }
    }
  }


/* total success */

/**
printf("List of connected\n");
for(i=0;i<n;i++)
              printf("%d --> %d %d\n",i,connected[i].objid,connected[i].osnum);
printf("List of planes\n");
for(i=0;i<nplane;i++)
              printf("%d --> %d %d\n",i,planes[i].objid,planes[i].osnum);
**/

  *p_ncon = n;
  *p_connected = connected;
  *p_nplane = nplane;
  *p_plane = planes;
  return(OM_S_SUCCESS);

/* failure somewhere */

error :
  if(connected != NULL) _FREE(connected);
  if(planes != NULL) _FREE(planes);
  *p_connected = NULL;
  *p_plane = NULL;
  *p_ncon = 0;
  *p_nplane = 0;
  return(OM_W_ABORT);
}

/**    This Function Checks for the presence of any Dependents Planes
 **    associated with the VRPlane.
 **/

VRCheckForDepPlanes( IGRboolean *flag, struct GRid PlaneId )
{
	IGRint count, status, i;
	struct GRid *child;
	GRclassid Classid;

	status = om$send( msg       = message NDnode.NDget_objects( 
					ND_CHILDREN, NULL, 0, NULL, 0,
					OM_K_MAXINT, &count ),
			senderid    = NULL_OBJID,
			targetid    = PlaneId.objid,
			targetos    = PlaneId.osnum );
	as$status();

	child = (struct GRid *) _MALLOC( count, struct GRid );

	status = om$send( msg       = message NDnode.NDget_objects( 
					ND_CHILDREN, child, count, NULL, 0,
					OM_K_MAXINT, &count ),
			senderid    = NULL_OBJID,
			targetid    = PlaneId.objid,
			targetos    = PlaneId.osnum );
	as$status();

	for( i=0; i < count; i++ )
	{
		status = om$get_classid( objid = child[i].objid,
					osnum = child[i].osnum,
					p_classid = &Classid );
		as$status();
		
		if( Classid != OPP_VRCnrlSeg_class_id )
			break;
	}

	_FREE( child );
	if( i == count )
		*flag = FALSE;
	else
		*flag = TRUE;

	return OM_S_SUCCESS;
}

VRUpdateConst( struct GRid Old_plane, 
		struct GRid New_plane, 
		struct GRid *seg_list, 
		IGRint seg_count,
		struct GRmd_env *md_env )
{
  IGRint i, j, k, status, nb_sup, NbChilds, wait_index;
  IGRboolean flag;
  IGRlong retmsg;
  struct GRid comps[2], RefId; 
  struct GRid *buffer;
  struct GRid Constrain;
  GRclassid Classid;
  extern struct GRid NULL_GRID;

  SetProc( VRUpdateConst ); Begin
  __DBGpr_objlist(" Update planes on segments", seg_count, seg_list );

  for( i=0; i < seg_count; i++ )
  {
    status = om$send( msg     = message VRCnrlSeg.VRget_terminators
				( &retmsg, &nb_sup, md_env, 
						NULL, comps ),
				senderid  = NULL_OBJID,
				targetid  = seg_list[i].objid,
				targetos  = seg_list[i].osnum );
    as$status();

    for( j=0; j < 2; j++ )
    {
      status = om$get_classid( objid = comps[j].objid,
				osnum  = comps[j].osnum,
				p_classid = &Classid );

      if( ( status & 1 ) &&
		( om$is_ancestry_valid( subclassid = Classid,
		superclassid = OPP_VRNozzle_class_id ) == OM_S_SUCCESS ) ||
		( om$is_ancestry_valid( subclassid = Classid,
		superclassid = OPP_VRCptIn_class_id ) == OM_S_SUCCESS ) )
	
      {

        if ( om$is_ancestry_valid( subclassid = Classid,
                superclassid = OPP_VRNozzle_class_id ) == OM_S_SUCCESS )
        {
            status = om$send( msg = message VRNozzle.VRGetRefId
					( &retmsg, &RefId ),
				senderid = NULL_OBJID,
				targetid = comps[j].objid,
				targetos = comps[j].osnum );
            as$status();

            status = om$send( msg = message NDnode.NDget_objects
				(  ND_CHILDREN | ND_IN_BUF,
					NULL, 0, &buffer, 0,
					OM_K_MAXINT, &NbChilds ),
				senderid = NULL_OBJID,
				targetid = RefId.objid,
				targetos = RefId.osnum );
        }
	else
        {
            status = om$send( msg = message NDnode.NDget_objects
				(  ND_ROOT | ND_IN_BUF,
					NULL, 0, &buffer, 0,
					OM_K_MAXINT, &NbChilds ),
				senderid = NULL_OBJID,
				targetid = comps[j].objid,
				targetos = comps[j].osnum );
	}

        for( k=0; k < NbChilds; k++ )
        {
          om$get_classid( objid = buffer[k].objid,
			osnum = buffer[k].osnum,
			p_classid = &Classid );

          if( om$is_ancestry_valid( subclassid = Classid,
		superclassid = OPP_VRDepPlane_class_id) == OM_S_SUCCESS )
          {
	      /* Below code added by Anand - connect the dependent plane to our
	       * control segment in question */

	      __DBGpr_obj(" Connect dep plane ....", buffer[k] );
	      __DBGpr_obj(" ... to control segment", seg_list[i] );
	      status = om$send( msg      = message NDnode.NDconnect( 1,
								     &buffer[k],
								     NULL_GRID,
								     ND_NEW ),
				senderid = NULL_OBJID,
				targetid = seg_list[i].objid,
				targetos = seg_list[i].osnum );
	      as$status( action = RET_STATUS );

	      /* Above code added by Anand - connect the dependent plane to our
	       * control segment in question */

             status = VRReturnConst( &flag, buffer[k], Old_plane, &Constrain );
             if( flag )
             {
		NDis_waiting( GR_DELETED, 0, &Old_plane, &wait_index, NULL, NULL, 1 );

                status = om$send( msg = message NDnode.NDchange_connect
					( 1, &Old_plane, &New_plane ),
					senderid = NULL_OBJID,
					targetid = Constrain.objid,
					targetos = Constrain.osnum );
                as$status();

		if( wait_index != -1 )
			nd$wait_batch( type = GR_DELETED,
					l_object = &New_plane,
					nb_obj  = 1 );

              }
          }
        }
      }
    }
  }

  End
  return OM_S_SUCCESS;
}

VRReturnConst( IGRboolean *flag, struct GRid Dep_plane, struct GRid plane, struct GRid *Constrain )
{
	IGRint i, j, status, count;
	struct GRid *child, parents[2];
	GRclassid Classid;

	status = om$send( msg       = message NDnode.NDget_objects( 
					ND_CHILDREN, NULL, 0, NULL, 0,
					OM_K_MAXINT, &count ),
			senderid    = NULL_OBJID,
			targetid    = Dep_plane.objid,
			targetos    = Dep_plane.osnum );
	as$status();

	child = (struct GRid *) _MALLOC( count, struct GRid );

	status = om$send( msg       = message NDnode.NDget_objects( 
					ND_CHILDREN, child, count, NULL, 0,
					OM_K_MAXINT, &count ),
			senderid    = NULL_OBJID,
			targetid    = Dep_plane.objid,
			targetos    = Dep_plane.osnum );
	as$status();

	for( i=0; i < count; i++ )
	{
		om$get_classid( objid = child[i].objid,
				osnum = child[i].osnum,
				p_classid = &Classid );

		if( Classid != OPP_VRconsdist_class_id )
			continue;

		status = om$send( msg       = message NDnode.NDget_objects( 
					ND_ROOT, parents, 2, NULL, 0,
					OM_K_MAXINT, &count ),
			senderid    = NULL_OBJID,
			targetid    = child[i].objid,
			targetos    = child[i].osnum );
		as$status();

		for( j=0; j < 2; j++ )
		{
			if( parents[j].objid == Dep_plane.objid &&
		    		parents[j].osnum == Dep_plane.osnum )
		   		continue;

			if( parents[j].objid == plane.objid &&
		    		parents[j].osnum == plane.osnum )
			{
				*Constrain = child[i];
				*flag = TRUE;
				_FREE( child );
				return OM_S_SUCCESS;
			}
		}
	}
	*flag = FALSE;
	_FREE( child );
	return OM_S_SUCCESS;
}


VRUpdateComPoints( struct GRid Old_plane, 
		   struct GRid New_plane, 
		   struct GRid *seg )
{
	IGRint count, status, i, j, k, l, wait_index;
	IGRint compoint_parents, max_complanes, compoint_count;
	IGRint pl_cnt, chld_seg_cnt;
	struct GRid *child, *planes;
        struct GRid chld_seg[4];
	GRclassid Classid;

	status = om$send( msg       = message NDnode.NDget_objects( 
					ND_CHILDREN, NULL, 0, NULL, 0,
					OM_K_MAXINT, &count ),
			senderid    = NULL_OBJID,
			targetid    = Old_plane.objid,
			targetos    = Old_plane.osnum );
	as$status();

	child = (struct GRid *) _MALLOC( count, struct GRid );

	status = om$send( msg       = message NDnode.NDget_objects( 
					ND_CHILDREN, child, count, NULL, 0,
					OM_K_MAXINT, &count ),
			senderid    = NULL_OBJID,
			targetid    = Old_plane.objid,
			targetos    = Old_plane.osnum );
	as$status();

	for( i=0; i < count; i++ )
	{
	   status = om$get_classid( objid = child[i].objid,
					osnum = child[i].osnum,
					p_classid = &Classid );
	   as$status();
		
	   if( Classid == OPP_VRcompoint_class_id )
	   {
		compoint_parents = 0;
		status = om$send( msg       = message NDnode.NDget_objects( 
					ND_ROOT, NULL, 0, NULL, 0,
					OM_K_MAXINT, &compoint_parents ),
			senderid    = NULL_OBJID,
			targetid    = child[i].objid,
			targetos    = child[i].osnum );
		as$status();

		if( compoint_parents == 6 )
			max_complanes = 2;
		else
			max_complanes = 1;

		planes = (struct GRid *) _MALLOC( compoint_parents, struct GRid );

	      status = om$send( msg       = message NDnode.NDget_objects( 
					ND_ROOT, planes, compoint_parents, NULL, 0,
					OM_K_MAXINT, &compoint_parents ),
			senderid    = NULL_OBJID,
			targetid    = child[i].objid,
			targetos    = child[i].osnum );
			as$status();

	      k=0;
	      if( seg )
	      {
	        chld_seg_cnt = 4;
	        status = om$send( msg       = message NDnode.NDget_objects( 
					ND_ROOT, chld_seg, chld_seg_cnt,
					NULL, 0, OM_K_MAXINT, &chld_seg_cnt ),
			senderid    = NULL_OBJID,
			targetid    = seg->objid,
			targetos    = seg->osnum );
	        as$status();

		compoint_count = 0;
	        for ( k=0; k < 4; k++ )
	        {
		    for( l=0; l < compoint_parents; l++ )
	            {
		       if( chld_seg[k].objid == Old_plane.objid &&
				chld_seg[k].osnum == Old_plane.osnum )
			  continue;

		       if( chld_seg[k].objid == planes[l].objid &&
				chld_seg[k].osnum == planes[l].osnum )
			  compoint_count++;

		       if( compoint_count == max_complanes )
	                  break;
	            }
		
	            if( l != compoint_parents )
		       break;
	         }
	       }	

	       if( k != 4 )
	       {
	         /*  COMPOINT IS ON THE CORRECT SIDE OF THE SEG*/
		NDis_waiting( GR_DELETED, 0, &Old_plane, &wait_index, NULL, NULL, 1 );

	         status = om$send( msg = message NDnode.NDchange_connect
	                             ( 1, &Old_plane, &New_plane ),
				senderid = NULL_OBJID,
				targetid = child[i].objid,
				targetos = child[i].osnum );
	          as$status();

		if( wait_index != -1 )
			nd$wait_batch( type = GR_DELETED,
					l_object = &New_plane,
					nb_obj  = 1 );

	       }
	       _FREE(planes);
	   }
	}

	_FREE( child );

	return OM_S_SUCCESS;
}

end implementation Root;

