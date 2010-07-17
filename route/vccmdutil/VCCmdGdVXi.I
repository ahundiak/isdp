
/* $Id: VCCmdGdVXi.I,v 1.4 2001/04/30 18:54:51 louis Exp $ */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccmdutil/VCCmdGdVXi.I
 *
 * Description:
 *      Command object for insert/move/delete Guide vertex
 *
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCmdGdVXi.I,v $
 *        Revision 1.4  2001/04/30 18:54:51  louis
 *        tr3010
 *
 *        Revision 1.3  2001/02/20 01:10:24  build
 *        Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *        Revision 1.2  2001/01/11 20:34:06  anand
 *        SP merge
 *
# Revision 1.1  2000/04/13  21:19:16  pinnacle
# Created: route/vccmdutil/VCCmdGdVXi.I by lawaddel for Service Pack
#
# Revision 1.1  2000/03/24  14:16:18  pinnacle
# Created for Guide Vertex Move/Delete/Insert command.
#
 *
 * History:
 *        03/24/2000		Alwin		Creation
 *        04/10/2000            law       TR179901302-backshells move with ends
 *	  04/18/01		law	  TR3010-connectors displaced when
 *					  guide end is moved.
 *
 *************************************************************************/

class implementation VCCmdGdVX;

#include <stdio.h>
#include <float.h>

#include "FI.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "OMtypes.h"
#include "ODE.h"

#include "igetypedef.h"
#include "igrdef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "grio.h"
#include "grmacros.h"

#include "ex.h"
#include "exmacros.h"
#include "msdef.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "coimport.h"
#include "COBmacros.h"

#include "bsvalues.h"
#include "bserr.h"
#include "bstypes.h"
#include "bsparameters.h"
#include "bsdistptpt.h"
#include "bsdptseg2.h"

#include "asmacros.h"
#include "AS_status.h"
#include "ACrg_collect.h"
#include "acrepdef.h"
#include "acrepmacros.h"

#include "parametric.h"

#include "VCdefine.h"
#include "VCstructs.h"
#include "VCCmdDef.h"
#include "VCparameters.h"
#include "VCproto.h"
#include "VCsys.h"
#include "vrdbgmacros.h"
#include "bsdistptpt.h"
#include "nddef.h"
#include "ndmacros.h"
#include "VDmem.h"
#include "adpdef.h"

#define	NO_DELETE	1

from  	IGEgragad 	import 	DPinrot;
from	GRlinear	import	GRgetpolyline;
from    GRlinear   	import	GRputpolyline;
from    VCGuide   	import	VCGd_GetGRid;
from    NDnode          import  NDget_objects;
from    VCRoot		import  VCGetMatrix;
from	GRgraphics	import	GRxform;
from	ACncpx		import  ACgive_structure;




method init ( int type ; char * str_ptr )
{
  int		  status;

  SetProc( Md init ); Begin 

  /*A initialize superclass */
  status = om$send (mode     = OM_e_wrt_message,
                    msg      = message VDS_LOCATE.init( type, str_ptr),
                    targetid = my_id);
  as$status( action = RET_STATUS );

  /*me->MyType = type;*/
  switch (type)
  {
    case 0:     me->SendType  = VCCB_INS_VERTEX;
                break;
    case 1:     me->SendType  = VCCB_MOV_VERTEX;
                break;
    case 2:     me->SendType  = VCCB_DEL_VERTEX;
                break;
    default:    me->SendType = -1;
                break;
  }

  me->LineId.objid = NULL_OBJID;
  me->LineId.osnum = me->ModuleInfo.md_id.osnum;

  me->RefId.objid = NULL_OBJID;
  me->RefId.osnum = me->ModuleInfo.md_id.osnum;
  me->SegmentNo      = -1;
  me->VtxNo       = -1;

  End
  return OM_S_SUCCESS;
}

method VCGetItem ( long * sts )
{
  SetProc( Md VCGetItem ); Begin 

  me->RefId = me->event1.located_object[0].located_obj;
  me->MdEnv = me->event1.located_object[0].module_info;

  __DBGpr_obj( " Located Guide Id ", me->RefId );

  End
  return OM_S_SUCCESS;
}

method VCGdModify ( long * sts )
{
  IGRint		  		status, action;
  IGRint				cn_type;
  IGRlong      			retmsg;
  IGRdouble    			dpt[3];
  IGRdouble    			d3pt[3];
  GRobjid        		New;
  struct IGRpolyline	LineIn;
  struct GRpost_info    post_info;

  SetProc( Md VCGdModify ); Begin 

  d3pt[0] = me->event1.event.button.x;
  d3pt[1] = me->event1.event.button.y;
  d3pt[2] = me->event1.event.button.z;

  status = VC_detent (d3pt, &me->Detent, dpt);

  if (VCSYSGLB_preserve)
  {
#ifdef MY_DEBUG
    printf (" preserve %d coordinate\n",me->IX);
#endif
    dpt[me->IX] = me->dDyn[me->IX+3];
  }

  status =
  gr$display_object( object_id = &me->RefId,
                     mode      = GRbe);

  action = 0;  // this would get only the No. of Points on the line
  LineIn.num_points = 0;
  LineIn.points = NULL;
  status =
  om$send(msg = message GRlinear.GRgetpolyline
                        (&retmsg, &me->MdEnv.md_env.matrix_type,
                          me->MdEnv.md_env.matrix, &action, &LineIn ),
             targetid = me->LineId.objid,
             targetos = me->LineId.osnum);
  as$status();

  //Allocating more than what is needed, to prevent reallocing during insert
  LineIn.points = _MALLOC (3 * (LineIn.num_points+1), IGRdouble);

  action = 1; // Fetch the Coordinates also
  status =
  om$send(msg = message GRlinear.GRgetpolyline
                        (&retmsg, &me->MdEnv.md_env.matrix_type,
                          me->MdEnv.md_env.matrix, &action, &LineIn ),
             targetid = me->LineId.objid,
             targetos = me->LineId.osnum);
  as$status();

  /* replace the New Coordinates of the Vertex being changed */
  if( me->SendType == VCCB_MOV_VERTEX )
  {
    /******* TR179901302 Added moving backshells ***/
    if(me->VtxNo == 0 || (me->VtxNo  == (LineIn.num_points - 1)))
    {
       struct GRid *p_Children;
       IGRint NbChildren,Ndx;
       IGRchar         c200ClassName[200];
       IGRmatrix TranMatrix;
       IGRshort Type;
       __DBGpr_com("Checking CPT0 for backshells");
       status =
               om$send( msg      = message NDnode.NDget_objects
                ( ND_CHILDREN | ND_IN_BUF, NULL, 0, &p_Children, 0,
                  OM_K_MAXINT, &NbChildren ),
                  targetid = me->RefId.objid,
                  targetos = me->RefId.osnum);
       __DBGpr_int(" NbChildren",NbChildren);
       for(Ndx = 0; Ndx < NbChildren; Ndx++)
       {
         om$get_classname (objid = p_Children[Ndx].objid,
                           osnum = p_Children[Ndx].osnum,
                       classname = c200ClassName);
         if (!strcmp(c200ClassName,"VCBksh"))
         {
            IGRint i;
            IGRdouble dP0,dP1,dCptCoor0[3],dCptCoor1[3],oldcoord[3];
            IGRdouble NewMatrix[16],Matrix[16], scale;
            BSrc          bsretcode;
            IGRlong retcode;
            for(i=0; i<3; i++)
            {
	      dCptCoor0[i] = LineIn.points[i];
              dCptCoor1[i] = LineIn.points[3*(LineIn.num_points - 1)+i];
            }
            __DBGpr_com("Found a backshell child of guide");
            status = om$send ( msg = message VCRoot.VCGetMatrix( &retcode, -1,
                                        Matrix, &me->MdEnv ),
                                targetid = p_Children[Ndx].objid,
                                targetos = p_Children[Ndx].osnum );
            oldcoord[0] = Matrix[3];
            oldcoord[1] = Matrix[7];
            oldcoord[2] = Matrix[11];
            MAidmx( &retcode, NewMatrix );
            NewMatrix[3] = Matrix[3];
            NewMatrix[7] = Matrix[7];
            NewMatrix[11]= Matrix[11];

            __DBGpr_vec("Old location ",oldcoord);
            dP0 = BSdistptpt (&bsretcode, oldcoord, dCptCoor0);
            dP1 = BSdistptpt (&bsretcode, oldcoord, dCptCoor1);
            if((dP0 < dP1 && me->VtxNo == 0) ||
               (dP0 > dP1 && (me->VtxNo == (LineIn.num_points - 1))))
            {
               IGRdouble     TempMatrix[16], oldcoord[3];
               IGRdouble     dCoord[4], dLocCoord[4], OutMatrix[16];
               IGRshort      nTranType;
               IGRshort      nFour=4, nOne=1;
               IGRint msg;
               struct ret_struct     ParamAttr;
               IGRint                FootIndex = -1;
               __DBGpr_int("Backshell is on vertex",(IGRint) me->VtxNo);
               /* Invert original matrix */
               status =
                     gr$display_object( object_id = &p_Children[Ndx],
                                                      mode      = GRbe);
               MAinvmx( &retcode, &nFour, NewMatrix, NewMatrix);
               __DBGpr_mat("inverse of original matrix",Matrix);
               /**** Transform the position to the new guide end *****/
               MAidmx( &retcode, TempMatrix );
               TempMatrix[3] = dpt[0] ;
               TempMatrix[7] = dpt[1] ;
               TempMatrix[11] = dpt[2];
               __DBGpr_mat("New location matrix",TempMatrix);
               VC_mat_multiply (TempMatrix, NewMatrix, TranMatrix);
               MAtypemx( &retcode, TranMatrix, &Type );
               status= om$send( msg   = message ACncpx.ACgive_structure (&msg,
                             &FootIndex, VC_N_PID_SCALE_DB, &ParamAttr,
                             &me->MdEnv),
                     targetid =  p_Children[Ndx].objid,
                     targetos =  p_Children[Ndx].osnum );

/******** TR179901302-JTS TR3010 ****** Causing offset when guide is moved
               TranMatrix[3] *= ParamAttr.var.root_pm_st.value;
               TranMatrix[7] *= ParamAttr.var.root_pm_st.value;
               TranMatrix[11] *= ParamAttr.var.root_pm_st.value;
******************/

               __DBGpr_mat("Transform matrix",TranMatrix);

               status =
                    om$send ( msg      = message GRgraphics.GRxform ( &retcode,
                                                &me->MdEnv,
                                                &Type,
                                                TranMatrix,
                                                &p_Children[Ndx].objid ),
                     targetid =  p_Children[Ndx].objid,
                     targetos =  p_Children[Ndx].osnum );
            }
         }
      }
      _FREE(p_Children);
    } /* end tr179901302 */
	  LineIn.points[me->VtxNo*3] = dpt[0];
	  LineIn.points[me->VtxNo*3+1] = dpt[1];
	  LineIn.points[me->VtxNo*3+2] = dpt[2];
  }
  else if( me->SendType == VCCB_DEL_VERTEX )
  {
	IGRint i, j;
	for( i=0, j=0; i<LineIn.num_points; i++ )
	{
		if( me->VtxNo == i ) continue;

		LineIn.points[j*3+0] = LineIn.points[i*3+0];
		LineIn.points[j*3+1] = LineIn.points[i*3+1];
		LineIn.points[j*3+2] = LineIn.points[i*3+2];
		__DBGpr_vec( " Points retained ", &LineIn.points[j*3] );
		j++;
	}
	LineIn.num_points--;
	__DBGpr_int( " Decreased the No. of points ", LineIn.num_points );
  }
  else /* Insert Vertex case */
  {
	/* Loop for Number of line segments ( No. of points - 1 ) */
	IGRint i;

	for( i=LineIn.num_points-1; i>=me->SegmentNo; i-- )
	{
		LineIn.points[(i+1)*3+0] = LineIn.points[i*3+0];
		LineIn.points[(i+1)*3+1] = LineIn.points[i*3+1];
		LineIn.points[(i+1)*3+2] = LineIn.points[i*3+2];
	}
	LineIn.points[me->SegmentNo*3+0] = dpt[0];
	LineIn.points[me->SegmentNo*3+1] = dpt[1];
	LineIn.points[me->SegmentNo*3+2] = dpt[2];

	LineIn.num_points ++; // Increase the number of points by 1

	for( i=0; i<LineIn.num_points; i++ )
	   __DBGpr_vec( " New Set of Points ", &LineIn.points[i*3] );
  }

  New = NULL_OBJID;
  post_info.construct_flag = FALSE;
  status = 
  om$send(msg = message GRlinear.GRputpolyline
                        ( &retmsg, &me->ModuleInfo, &post_info, 
						 &LineIn, &New ),
             targetid = me->LineId.objid,
             targetos = me->LineId.osnum);
  as$status();
  __DBGpr_int( " Changed Line Id ", New );

  _FREE( LineIn.points );

  /* do the wait batch */

  cn_type = ND_COMP;
  nd$wait_batch (type   = GR_GEOM_POSTED,
             l_object   = &me->RefId,
             l_obj_info = &cn_type,
             nb_obj     = 1);

  nd$exec_batch();
  status = OM_S_SUCCESS ;

  /*   set up for next   */
  me->LineId.objid = NULL_OBJID;
  me->LineId.osnum = me->ModuleInfo.md_id.osnum;

  me->RefId.objid = NULL_OBJID;
  me->RefId.osnum = me->ModuleInfo.md_id.osnum;
  me->SegmentNo   = -1;
  me->VtxNo       = -1;

  End
  return OM_S_SUCCESS;
}

method dynamics ( int dynamics ; int * sts )
{
  int		  status;

  struct  VCmlmoddyn_info  info;
  struct  IGRpolyline      line;
  struct  IGRdisplay       loc_dis;
  IGRdouble                d9points[9];
  IGRint                   i;

  extern IGRint VCmlmoddyn();

  SetProc( Md dynamics ); Begin 

  if (dynamics == VC_MLDYN_MVTX)
  {
    loc_dis = me->ActiveDisplay;
    loc_dis.weight = 1;
    loc_dis.style  = 0;
    loc_dis.color  = 6;

    info.dynamics = dynamics;

    info.Detent    = me->Detent;

    if (VCSYSGLB_preserve)
    {
      info.dy_index = me->IX;
      info.dy_value = me->dDyn[me->IX];
    }
    else
    {
      info.dy_index = -1;
    }

    for (i=0; i<9; i++)
      d9points[i] = me->dDyn[i];

    line.num_points = 3;
    line.points     = d9points;

    /*A Build buffers */

#ifdef MY_DEBUG
    printf (" ML dynamics setup,dy_index,dy_value %d %f\n",info.dy_index,
                                                     info.dy_value);
#endif

    status =
    dp$build_dis_buffer(buffer      = &info.dpele_buff,
                        type        = IGRPY,
                        geometry    = &line,
                        display_att = &loc_dis);

    status =
    dp$dynamics(dyn_fun     = VCmlmoddyn,
                information = &info);
  }
  else
  {
    status = om$send(msg = message CEO.dynamics( dynamics, sts ),
                    mode = OM_e_wrt_message,
                targetid = my_id );
    as$status();
  }

  End
  return OM_S_SUCCESS;
}

/* Based on the user key-in point, we've to find out the closest vertex in
the Guide ( line string connected to it ). And store the vertex number in the
instance data */
method VCGdLocateVertex ( int * sts )
{
  IGRlong        		retmsg;
  IGRint				i, status;
  IGRint				action, IXloc;
  IGRdouble				dist=0.0;
  IGRdouble				NewDist=0.0;
  IGRpoint				dInputPt;

  IGRmatrix				win_matrix;
  struct IGRpolyline    LineIn;

  SetProc( Md VCGdLocateVertex ); Begin 

  LineIn.num_points = 0;
  IXloc = -1;

  status =
  om$send (msg = message IGEgragad.DPinrot( &retmsg, win_matrix ),
      senderid = NULL_OBJID,
      targetid = me->event1.event.button.objid,
      targetos = me->event1.event.button.osnum);
  as$status();

  for (i=0; i<3; i++)
    if ((win_matrix[i+8] > 0.99) ||
        (win_matrix[i+8] < -0.99))    IXloc = i;

  me->IX = -1;

  dInputPt[0] = me->event1.event.button.x;
  dInputPt[1] = me->event1.event.button.y;
  dInputPt[2] = me->event1.event.button.z;
  __DBGpr_vec( " Input Point ", dInputPt );

  /* Get the Parent Line String */
  om$send( msg = message VCGuide.VCGd_GetGRid
							( &retmsg, &me->LineId, &me->ModuleInfo ),
			targetid = me->RefId.objid,
			targetos = me->RefId.osnum );
  as$status();
  __DBGpr_obj( " Line Id ", me->LineId );

  action = 0;  // this would get only the No. of Points on the line
  LineIn.points = NULL;
  status =
  om$send(msg = message GRlinear.GRgetpolyline
						(&retmsg, &me->ModuleInfo.md_env.matrix_type,
						  me->ModuleInfo.md_env.matrix, &action, &LineIn ),
			 targetid = me->LineId.objid,
			 targetos = me->LineId.osnum);
  as$status();

  if( (me->SendType == VCCB_DEL_VERTEX) && (LineIn.num_points <=2) )
  {
	UI_status( "You can't delete vertex of a Guide with 2 vertices !!! " );
	me->ret = *sts = NO_DELETE;
	__DBGpr_com( " You can't delete vertex - Guide with 2 vertices !!! " );
	End
	return OM_S_SUCCESS;
  }

  LineIn.points = _MALLOC (3 * LineIn.num_points, IGRdouble);

  action = 1; // Fetch the Coordinates also
  status =
  om$send(msg = message GRlinear.GRgetpolyline
						(&retmsg, &me->ModuleInfo.md_env.matrix_type,
						  me->ModuleInfo.md_env.matrix, &action, &LineIn ),
			 targetid = me->LineId.objid,
			 targetos = me->LineId.osnum);
  as$status();

  __DBGpr_int( " Nb of Vertices in Guide ", LineIn.num_points );
  for( i=0; i<LineIn.num_points; i++ )
	__DBGpr_vec( " Vertices ", &LineIn.points[i*3] );

  dist = BSdistptpt( &retmsg, dInputPt, &LineIn.points[0] );
  __DBGpr_dbl( " Distance wrt origin of line ", dist );
  me->VtxNo = 0;

  for( i=1; i<LineIn.num_points; i++ )
  {

	__DBGpr_int( " Vertex No ", i );
	__DBGpr_vec( " Vertex Information ", &LineIn.points[i*3] );

	NewDist = BSdistptpt( &retmsg, dInputPt, &LineIn.points[i*3] );

#ifdef vdsDEBUG
		printf( "\t\n Vertex Number <%d> \n", i );
		printf("\t\n Distance between <%d> and InputPt : <%f> \n", i, NewDist );
#endif

	if( NewDist < dist ) 
	{
		me->VtxNo = i;
		dist = NewDist;
	}
  }

  __DBGpr_int( " Closest vertex no is ", me->VtxNo );
  if( me->SendType == VCCB_DEL_VERTEX )
  {
	_FREE( LineIn.points );
	me->ret = *sts = 0;
	End
	return OM_S_SUCCESS;
  }

  /* From the vertex number identify the coordinates involved in the dynamics*/
  if( me->VtxNo == 0 || me->VtxNo == (LineIn.num_points-1) )
  {
		IGRint				Index;

		/* User has located the end vertices */
		if( me->VtxNo == 0 ) Index = (me->VtxNo+1)*3;
		else Index = (me->VtxNo-1)*3;

		me->dDyn[0] = me->dDyn[6] = LineIn.points[Index+0];
		me->dDyn[1] = me->dDyn[7] = LineIn.points[Index+1];
		me->dDyn[2] = me->dDyn[8] = LineIn.points[Index+2];

		Index = me->VtxNo*3;
		me->dDyn[3] = LineIn.points[Index+0];
		me->dDyn[4] = LineIn.points[Index+1];
		me->dDyn[5] = LineIn.points[Index+2];
  }
  else
  {
		IGRint				Index;

		/* User has located other than end vertices */
		Index = (me->VtxNo - 1)*3;
		me->dDyn[0] = LineIn.points[Index+0];
		me->dDyn[1] = LineIn.points[Index+1];
		me->dDyn[2] = LineIn.points[Index+2];

		Index = me->VtxNo * 3;
		me->dDyn[3] = LineIn.points[Index+0];
		me->dDyn[4] = LineIn.points[Index+1];
		me->dDyn[5] = LineIn.points[Index+2];

		Index = (me->VtxNo + 1)*3;
		me->dDyn[6] = LineIn.points[Index+0];
		me->dDyn[7] = LineIn.points[Index+1];
		me->dDyn[8] = LineIn.points[Index+2];
  }
  __DBGpr_vec( " First Point for Dynamics ", me->dDyn );
  __DBGpr_vec( " Second Point for Dynamics ", &me->dDyn[3] );
  __DBGpr_vec( " Third Point for Dynamics ", &me->dDyn[6] );

  _FREE( LineIn.points );

  if (me->SendType == VCCB_MOV_VERTEX)
  {
    status =
    om$send (msg = message VCCmdGdVX.VCGdVXcorners (&me->dDyn[0], &me->dDyn[6]),
        targetid = my_id);
  }
  else
    me->Detent.NumCorners = -1;

  if (!(VCSYSGLB_preserve)) goto quit;

  if (me->SendType == VCCB_MOV_VERTEX)
  {   /*  find ortho plane that contains all three vertices   */
    for (i=0; i<3; i++)
    {
      if ((me->dDyn[i] == me->dDyn[i+3]) && (me->dDyn[i] == me->dDyn[i+6]))
      {
         me->IX = i;
      }
    }

    if (me->IX < 0) me->IX = IXloc;
  }

quit:
  End
  return OM_S_SUCCESS;
}

method VCGdLocateSegment ( long * sts )
{
  IGRint		  		status, action, i;
  IGRint 				IXloc, iVert, Index;
  IGRdouble				dSavDist, dCoord[3];
  IGRlong				retmsg;
  struct IGRpolyline	LineIn;

  SetProc( Md VCGdLocateSegment ); Begin 

  /* Get the Parent Line String */
  om$send( msg = message VCGuide.VCGd_GetGRid
                            ( &retmsg, &me->LineId, &me->ModuleInfo ),
            targetid = me->RefId.objid,
            targetos = me->RefId.osnum );
  as$status();
  __DBGpr_obj( " Line Id ", me->LineId );

  action = 0;  // this would get only the No. of Points on the line
  LineIn.points = NULL;
  LineIn.num_points = 0;

  status =
  om$send(msg = message GRlinear.GRgetpolyline
                        (&retmsg, &me->ModuleInfo.md_env.matrix_type,
                          me->ModuleInfo.md_env.matrix, &action, &LineIn ),
             targetid = me->LineId.objid,
             targetos = me->LineId.osnum);
  as$status();

  LineIn.points = _MALLOC (3 * LineIn.num_points, IGRdouble);

  action = 1; // Fetch the Coordinates also
  status =
  om$send(msg = message GRlinear.GRgetpolyline
						(&retmsg, &me->ModuleInfo.md_env.matrix_type,
						  me->ModuleInfo.md_env.matrix, &action, &LineIn ),
			 targetid = me->LineId.objid,
			 targetos = me->LineId.osnum);
  as$status();

  {
	 IGRmatrix	win_matrix;
	 IXloc = -1;

	 status =
	 om$send (msg = message IGEgragad.DPinrot( &retmsg, win_matrix ),
		 senderid = NULL_OBJID,
		 targetid = me->event1.event.button.objid,
		 targetos = me->event1.event.button.osnum);
	 as$status();

	 for (i=0; i<3; i++)
	   if ((win_matrix[i+8] > 0.99) ||
		   (win_matrix[i+8] < -0.99))    IXloc = i;
  }

	dSavDist = MAXDOUBLE;
	dCoord[0] = me->event1.event.button.x;
	dCoord[1] = me->event1.event.button.y;
	dCoord[2] = me->event1.event.button.z;

    for (iVert=0; iVert < LineIn.num_points-1; iVert++)
    {
	  IGRdouble      dDist;
	  IGRdouble      minpar;
	  IGRdouble      minpt[3];
	  IGRdouble      dLocal[3];
	  IGRboolean     bEndVtx;
	  IGRboolean     bBegVtx;
	  BSrc           rc;

      for (i=0; i<3; i++)
        dLocal[i] = dCoord[i];

      {   
		/*    locate segment    */
        if (IXloc >= 0)
          dLocal[IXloc] = (LineIn.points[3*iVert+IXloc] +
                           LineIn.points[3*(iVert+1)+IXloc]) / 2.0;

        BSdptseg2 (dLocal, &LineIn.points[3*iVert],
                    &LineIn.points[3*(iVert+1)],
                    minpt, &minpar, &dDist, &rc);
      }

#ifdef vdsDEBUG
    printf (" scan segment/vertex ivert, ddist = %d %f\n",iVert,dDist);
#endif

      if (dDist < dSavDist)
      {
        dSavDist = dDist;

		me->SegmentNo = iVert+1;
	  }
	}
	__DBGpr_int( " Segment selected is ", me->SegmentNo );

	Index = (me->SegmentNo-1)*3;
	me->dDyn[0] = LineIn.points[Index+0];
	me->dDyn[1] = LineIn.points[Index+1];
	me->dDyn[2] = LineIn.points[Index+2];

	me->dDyn[3] = dCoord[0];
	me->dDyn[4] = dCoord[1];
	me->dDyn[5] = dCoord[2];

	Index = me->SegmentNo*3;
	me->dDyn[6] = LineIn.points[Index+0];
	me->dDyn[7] = LineIn.points[Index+1];
	me->dDyn[8] = LineIn.points[Index+2];

  _FREE( LineIn.points );

  {
	me->IX = IXloc;

    status =
    om$send (msg = message VCCmdGdVX.VCGdVXcorners (&me->dDyn[0], &me->dDyn[6]),
        targetid = my_id);
  }

  End
  return OM_S_SUCCESS;
}

method  VCGdVXcorners (IGRdouble    *pT1;
                     IGRdouble    *pT2)
{
  IGRint    i;
  BSrc      rc;

  SetProc( Md VCGdVXcorners ); Begin 

  for (i=0; i<18; i++)
    me->Detent.dCorners[i] = 0.0;

  me->Detent.nDigit = VC_digit (pT1, pT2);

  switch (me->Detent.nDigit)
  {
    case 1:
    case 2:
    case 3:
      me->Detent.NumCorners = 0;

      me->Detent.dCorners[0] = pT1[0];
      me->Detent.dCorners[1] = pT1[1];
      me->Detent.dCorners[2] = pT1[2];

      me->Detent.dCorners[3] = pT2[0];
      me->Detent.dCorners[4] = pT2[1];
      me->Detent.dCorners[5] = pT2[2];

      me->Detent.dDist =  BSdistptpt(&rc, pT1, pT2) / 10.0;
      break;

    case 4:     /*    xy, two corners   */
      me->Detent.NumCorners = 2;

      me->Detent.dCorners[0] = pT2[0];
      me->Detent.dCorners[1] = pT1[1];
      me->Detent.dCorners[2] = pT1[2];

      me->Detent.dCorners[3] = pT1[0];
      me->Detent.dCorners[4] = pT2[1];
      me->Detent.dCorners[5] = pT2[2];

      me->Detent.dDist =  BSdistptpt(&rc, pT1, pT2) / 10.0;
      break;

    case 5:     /*    xz, two corners   */
      me->Detent.NumCorners = 2;

      me->Detent.dCorners[0] = pT2[0];
      me->Detent.dCorners[1] = pT1[1];
      me->Detent.dCorners[2] = pT1[2];

      me->Detent.dCorners[3] = pT1[0];
      me->Detent.dCorners[4] = pT2[1];
      me->Detent.dCorners[5] = pT2[2];

      me->Detent.dDist =  BSdistptpt(&rc, pT1, pT2) / 10.0;
      break;

    case 6:     /*    yz, two corners   */
      me->Detent.NumCorners = 2;

      me->Detent.dCorners[0] = pT1[0];
      me->Detent.dCorners[1] = pT2[1];
      me->Detent.dCorners[2] = pT1[2];

      me->Detent.dCorners[3] = pT2[0];
      me->Detent.dCorners[4] = pT1[1];
      me->Detent.dCorners[5] = pT2[2];

      me->Detent.dDist =  BSdistptpt(&rc, pT1, pT2) / 10.0;
      break;

    case 7:
    case 8:     /*   xyz, six corners    */
      me->Detent.NumCorners = 6;

      me->Detent.dCorners[0] = pT2[0];
      me->Detent.dCorners[1] = pT1[1];
      me->Detent.dCorners[2] = pT1[2];

      me->Detent.dCorners[3] = pT1[0];
      me->Detent.dCorners[4] = pT2[1];
      me->Detent.dCorners[5] = pT2[2];

      me->Detent.dCorners[6] = pT1[0];
      me->Detent.dCorners[7] = pT2[1];
      me->Detent.dCorners[8] = pT1[2];

      me->Detent.dCorners[9]  = pT2[0];
      me->Detent.dCorners[10] = pT1[1];
      me->Detent.dCorners[11] = pT2[2];

      me->Detent.dCorners[12] = pT1[0];
      me->Detent.dCorners[13] = pT1[1];
      me->Detent.dCorners[14] = pT2[2];

      me->Detent.dCorners[15] = pT2[0];
      me->Detent.dCorners[16] = pT2[1];
      me->Detent.dCorners[17] = pT1[2];

      me->Detent.dDist =  BSdistptpt(&rc, pT1, pT2) / 10.0;
      break;

    default:
      me->Detent.NumCorners = -1;
      break;
  }

#ifdef vdsDEBUG
  printf ("setup detent %d %d\n",me->Detent.nDigit, me->Detent.NumCorners);
#endif

  End
  return (OM_S_SUCCESS);
}

end implementation VCCmdGdVX;
