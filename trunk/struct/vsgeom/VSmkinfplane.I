/* $Id: VSmkinfplane.I,v 1.4 2001/02/06 16:19:19 jayadev Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsgeom/VSmkinfplane.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSmkinfplane.I,v $
 *      Revision 1.4  2001/02/06 16:19:19  jayadev
 *      *** empty log message ***
 *
 *      Revision 1.3  2001/01/26 22:16:30  jayadev
 *      changes for etl#6024
 *
# Revision 1.2  2000/05/03  20:11:52  pinnacle
# Replaced: struct/vsgeom/VSmkinfplane.I for:  by rchennup for Service Pack
#
# Revision 1.1  2000/05/03  17:52:18  pinnacle
# Created: struct/vsgeom/VSmkinfplane.I by rchennup for Service Pack
#
# Revision 1.2  1999/05/12  15:44:54  pinnacle
# TR179900465
#
*
* History:
*      MM/DD/YY  AUTHOR  DESCRIPTION
*      05/12/99  ylong   TR179900465
*      05/03/00  Jayadev etl#1899 & 1491 Make infinite plane out of 3 points
*			  which make up maximum area 
*      01/26/00  Jayadev VSmakeInfinitePlaneNew() function for etl#6024
***************************************************************************/
class implementation EMSplane ;

#include "msdef.h"
#include "bserr.h"
#include "bstypes.h"
#include "growner.h"
#include "emssfintdef.h"
#include "EMSmsgdef.h"
#include "EMSssprops.h"
#include "VDobj.h"
#include "vsbeamdef.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsrgbxplint.h"
#include "vsplencompbx.h"

extern OMuword		OPP_EMSplane_class_id ;

/*----------------------------------------------------------------------------*/

long VSmakePlaneEncompassingBox( msg, inPlane, cst, box, outPlane )

long			*msg ;
struct GRobj_env 	*inPlane ;
struct GRvg_construct	*cst ;
GRrange			box ;
struct GRid		*outPlane ; {

	long		sts ;
	int		emsRC ,ii,jj=0,kk;
	IGRpoint	origin,
			intPnts[6] ,cstPnts[3],inpPnts[3];
	IGRvector	normal ;
	double		*min,
			*max ;
	struct IGRplane	planeDef ;
	int		count=0 ;
	IGRboolean      cstFlag = FALSE;

	outPlane->objid = NULL_OBJID ;

	planeDef.point = origin ;
	planeDef.normal= normal ;

	sts = om$send(	msg	= message EMSplane.GRdetplane(
							msg,
							&inPlane->_matrix_type,
							inPlane->_matrix,
							&planeDef ),
			senderid= inPlane->_objid,
			targetid= inPlane->_objid,
			targetos= inPlane->_osnum ) ;
	__CheckRC( sts, *msg, "EMSplane.GRdetplane", wrapup ) ;

	min = box + 0 ;
	max = box + 3 ;

	/*
	 * Intersect infinite plane with big box, since it is almost the largest
	 * possible we are garanteed to have at least 3 intersection points.
	 */
	BSrgbxplint( min, max, origin, normal, 1., &count, intPnts, msg ) ;
	if( BSERROR( *msg ) ) {
		*msg = EMS_E_BSerror ; sts = OM_W_ABORT ; goto wrapup ;
	}
	// The following are added for etl#1899 & 1491
	if((count == 0)||(count<3)){
		*msg = EMS_E_BSerror ; sts = OM_W_ABORT ; goto wrapup ;
	}
	if(count > 4){
                IGRint                  ind1, ind2, ind3, i1, i2, i3 ;
                IGRdouble               areaPts[12], max_area = 0.0, area = 0.0;
                struct IGRpolyline      poly ;

                poly.num_points = 4 ;
                poly.points     = areaPts ;

                cstFlag = TRUE;

                for( ind1=0; ind1<count-2; ++ind1 )
                  for( ind2=ind1; ind2<count-1; ++ind2 )
                    for( ind3=ind2; ind3<count; ++ind3 )
                    {
			if( ind1 == ind2 || ind1 == ind3 || ind2 == ind3 )
			   continue;

                        for(kk=0;kk<3;kk++)     
                        {
                           areaPts[kk]   = intPnts[ind1][kk] ;  
                           areaPts[kk+3] = intPnts[ind2][kk] ;
                           areaPts[kk+6] = intPnts[ind3][kk] ;
			   areaPts[kk+9] = intPnts[ind1][kk] ;
                        }
			MApyarea( msg, &poly, &area );
			if( *msg != MSSUCC ) continue ;
			if( area > max_area )
			{
			   max_area = area;
			   i1 = ind1; i2 = ind2 ; i3 = ind3 ;
			}
                    }

          	for(kk=0;kk<3;kk++)
		{
               	    cstPnts[0][kk] = intPnts[i1][kk];
		    cstPnts[1][kk] = intPnts[i2][kk];
		    cstPnts[2][kk] = intPnts[i3][kk];
		}
        }

	// always send only three input points for the plane construction
	if(cstFlag){
		for(ii=0;ii<3;ii++)
		  for(kk=0;kk<3;kk++)
			inpPnts[ii][kk] = cstPnts[ii][kk];
	}
	else
	{
		// get the first three points
		for(ii=0;ii<3;ii++)
                  for(kk=0;kk<3;kk++)
			inpPnts[ii][kk] = intPnts[ii][kk];
	}	
	outPlane->osnum = cst->env_info->_MD_OS ;
	sts = om$construct(	classid	= OPP_EMSplane_class_id,
				osnum	= outPlane->osnum,
				p_objid	= &outPlane->objid ) ;
	if( !( sts & 1 ) ) { *msg = EMS_E_OMerror ; goto wrapup ; }

	/*
	 * Construct big plane; the following method will use the first 3
	 * points of the array `intPnts'.
	 * Note : EMSplane.EMplane does not seem to set `emsRC' if successful,
	 * hence the following initialization.
	 */
	emsRC = MSSUCC ;
	sts = om$send(	msg	= message EMSplane.EMplane(	&emsRC,
								cst,
								inpPnts,
				/* 1 = parallelogram */		1 ),
			senderid= outPlane->objid,
			targetid= outPlane->objid,
			targetos= outPlane->osnum ) ;

	if( !( sts & 1 & emsRC & *cst->msg ) ) {
		/*
		 * If construction fails, plane deletes itself.
		 */
		if( emsRC & 1 ) {
			if( *cst->msg & 1 )	*msg = MSFAIL ;
			else			*msg	= *cst->msg ;
		} else	*msg = emsRC ;
		sts = OM_W_ABORT ;

		outPlane->objid = NULL_OBJID ;
	} else {
		sts 	= OM_S_SUCCESS ;
		*msg	= MSSUCC ;
	}

	wrapup :
		return sts ;

} /* VSmakePlaneEncompassingBox */
/*----------------------------------------------------------------------------*/
void VSmakeEncompassingBox( inBox1, inBox2, scale, outBox )
  
const GRrange	inBox1 ;
const GRrange	inBox2 ;
double		scale ;
GRrange		outBox ; {
  
  int	        i ;
  double	m,u,v ;
  
  /*
   * Find box containing above boxes.
   */
  for( i = 0 ; i < 3 ; i++ ) {
    outBox[i+0] = GRDGNLIMITS_MAX_D ;
    outBox[i+3] = GRDGNLIMITS_MIN_D ;
  }
  
  for( i = 0 ; i < 3 ; i++ ) {
    u = inBox1[i+0] ;
    v = inBox2[i+0] ;
    m = u > v ? v : u ;
    if( m < outBox[i+0] ) outBox[i+0] = m ;
    
    u = inBox1[i+3] ;
    v = inBox2[i+3] ;
    m = u > v ? u : v ;
    if( m > outBox[i+3] ) outBox[i+3] = m ;
  }
  scale *= 0.25 ;
  for( i = 0 ; i < 3 ; i++ ) {
    u = outBox[i+0] ;
    v = outBox[i+3] ;
    outBox[i+0] = ( 1 + scale ) * u - scale * v ;
    outBox[i+3] = ( 1 + scale ) * v - scale * u ;
  }
  
} /* VSmakeEncompassingBox */
/*----------------------------------------------------------------------------*/
long VSmakeBiggerPlane( msg, inPlane, element, elmBox, scale, cst, outPlane )
  
long			*msg ;
struct GRobj_env 	*inPlane,
                        *element ;
GRrange			elmBox ;
double			scale ;
struct GRvg_construct	*cst ;
struct GRid		*outPlane ; {
  
  /*
   * This function is interfaced by macro vs$makeBiggerPlane.
   */
  
  long		sts ;
  GRrange	inpBox,
                elmBoxLocal,
                bigBox ;
  IGRboolean	world = TRUE ;
  
  sts = om$send(	msg	= message GRgraphics.GRgetrang(
    msg,
    &inPlane->_matrix_type,
    inPlane->_matrix,
    &world,
    inpBox ),
			senderid= inPlane->_objid,
			targetid= inPlane->_objid,
			targetos= inPlane->_osnum ) ;
  __CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;
  
  if( !elmBox ) {
    if( !element ) vs$inv_arg() ;
    
    elmBox = elmBoxLocal ;
    sts = om$send(	msg	= message GRgraphics.GRgetrang(
      msg,
      &element->_matrix_type,
      element->_matrix,
      &world,
      elmBox ),
			senderid= element->_objid,
			targetid= element->_objid,
			targetos= element->_osnum ) ;
    __CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;
  }
  
  VSmakeEncompassingBox( inpBox, elmBox, scale, bigBox ) ;
  
  sts = VSmakePlaneEncompassingBox( msg, inPlane, cst, bigBox, outPlane );
  __CheckRC( sts, *msg, "VSmakePlaneEncompassingBox", wrapup ) ;
  
  wrapup :
    return sts ;
  
} /* VSmakeBiggerPlane */
/*----------------------------------------------------------------------------*/
long VSmakeInfinitePlane( msg, inPlane, cst, outPlane )
  
  long			*msg ;
struct GRobj_env 	*inPlane ;
struct GRvg_construct	*cst ;
struct GRid		*outPlane ; {
  
  int		i ;
  GRrange		box ;
  double		*min,
                        *max ;
  
  min	= box + 0 ;
  max	= box + 3 ;
  
  /*
   * Make big range box (almost as big as the limits of the design file).
   */
  /*
   * change 100.0 to 1000.0 to shrink box for TR179900465, by ylong
   */
  for( i = 0 ; i < 3 ; i++ ) {
    min[i] = GRDGNLIMITS_MIN_D / 1000. ;
    max[i] = GRDGNLIMITS_MAX_D / 1000. ;
  }
  
  return VSmakePlaneEncompassingBox( msg,inPlane,cst,box,outPlane ) ;
  
} /* VSmakeInfinitePlane */
/*----------------------------------------------------------------------------*/
long VSmakePlaneEncompassingBox1( msg, beam,inPlane, cst, outPlane )
  
long			*msg ;
struct GRobj_env 	*beam ;
struct GRobj_env 	*inPlane ;
struct GRvg_construct	*cst ;
struct GRid		*outPlane ; {
  
  long		sts ;
  int		emsRC ,i,ii,jj=0,kk;
  IGRpoint	origin,
                intPnts[6] ,cstPnts[3],inpPnts[3];
  IGRvector	normal ;
  double	*min,
                *max ;
  struct IGRplane	planeDef ;
  int		count=0 ;
  IGRboolean      cstFlag = FALSE;
  struct GRobj_env outOE;
  IGRlong retFlag = 0;
  struct  GRobj_env       gensolOE;
  IGRshort        world=TRUE;
  GRrange         range,new_range;
  IGRdouble       exp_factor;
  IGRboolean      retryFlag = FALSE;
  
  gensolOE.obj_id.objid = NULL_OBJID;
  outPlane->objid = NULL_OBJID ;
  
  planeDef.point = origin ;
  planeDef.normal= normal ;
  
  /* Get the range of the beam */
  
  // Take the EMSgensolid for range calculation
  vdobj$GetFoot(objOE=beam,footName = VS_K_bmGrCmpName,footOE = &gensolOE);
  if(gensolOE.obj_id.objid == NULL_OBJID) goto wrapup;
  
  vs$getRangeOfComposite( msg = msg,
			  composite = &gensolOE,
			  range     = range       );
  if(!(*msg&1)) goto wrapup;
  
  
 try_extRange:
  if(!retryFlag) exp_factor = 0.5;
  else exp_factor = 1.0;
  
  for(i=0;i<3;i++)
    new_range[i] = ((1.0+exp_factor)*range[i]) - (exp_factor*range[i+3]);
  
  for(i=0;i<3;i++)
    new_range[i+3] = -(exp_factor*range[i])+((1.0+exp_factor)*range[i+3]);
  
#ifdef DEBUG
  printf("\n rangeA[%f,%f,%f] rangeB[%f,%f,%f] \n",range[0],range[1],range[2],range[3],range[4],range[5]);
  printf("\n newrangeA[%f,%f,%f] newrangeB[%f,%f,%f] \n",new_range[0],new_range[1],new_range[2],new_range[3],new_range[4],new_range[5]);
#endif
  
  sts = om$send(	msg	= message EMSplane.GRdetplane(
    msg,
    &inPlane->_matrix_type,
    inPlane->_matrix,
    &planeDef ),
			senderid= inPlane->_objid,
			targetid= inPlane->_objid,
			targetos= inPlane->_osnum ) ;
  __CheckRC( sts, *msg, "EMSplane.GRdetplane", wrapup ) ;
  
  min = new_range + 0 ;
  max = new_range + 3 ;
  
  /*
   * Intersect infinite plane with big box, since it is almost the largest
   * possible we are garanteed to have at least 3 intersection points.
   */
  BSrgbxplint( min, max, origin, normal, 1., &count, intPnts, msg ) ;
  if( BSERROR( *msg ) ) {
    *msg = EMS_E_BSerror ; sts = OM_W_ABORT ; goto wrapup ;
  }
  
#ifdef DEBUG
  printf("\n no. of intersecting points %d \n",count);
  printf("\n inter0[%f,%f,%f] \n",intPnts[0][0],intPnts[0][1],intPnts[0][2]);
  printf("\n inter1[%f,%f,%f] \n",intPnts[1][0],intPnts[1][1],intPnts[1][2]);
  printf("\n inter2[%f,%f,%f] \n",intPnts[2][0],intPnts[2][1],intPnts[2][2]);
  printf("\n inter3[%f,%f,%f] \n",intPnts[3][0],intPnts[3][1],intPnts[3][2]);
#endif
  if(((count == 0)||(count<3)) && (!retryFlag)){ // try with extended range
    retryFlag = TRUE; goto try_extRange;
  }
  if(((count == 0)||(count<3)) && (retryFlag)){ // already tried extended range
    *msg = EMS_E_BSerror ; sts = OM_W_ABORT ; goto wrapup ;
  }
  if(count > 4){
    IGRint                  ind1, ind2, ind3, i1, i2, i3 ;
    IGRdouble               areaPts[12], max_area = 0.0, area = 0.0;
    struct IGRpolyline      poly ;
    
    poly.num_points = 4 ;
    poly.points     = areaPts ;
    
    cstFlag = TRUE;
    
    for( ind1=0; ind1<count-2; ++ind1 )
      for( ind2=ind1; ind2<count-1; ++ind2 )
	for( ind3=ind2; ind3<count; ++ind3 )
	{
	  if( ind1 == ind2 || ind1 == ind3 || ind2 == ind3 )
	    continue;
	  
	  for(kk=0;kk<3;kk++)     
	  {
	    areaPts[kk]   = intPnts[ind1][kk] ;  
	    areaPts[kk+3] = intPnts[ind2][kk] ;
	    areaPts[kk+6] = intPnts[ind3][kk] ;
	    areaPts[kk+9] = intPnts[ind1][kk] ;
	  }
	  MApyarea( msg, &poly, &area );
	  if( *msg != MSSUCC ) continue ;
	  if( area > max_area )
	  {
	    max_area = area;
	    i1 = ind1; i2 = ind2 ; i3 = ind3 ;
	  }
	}
    
    for(kk=0;kk<3;kk++)
    {
      cstPnts[0][kk] = intPnts[i1][kk];
      cstPnts[1][kk] = intPnts[i2][kk];
      cstPnts[2][kk] = intPnts[i3][kk];
    }
  }
  
  // always send only three input points for the plane construction
  if(cstFlag){
    for(ii=0;ii<3;ii++)
      for(kk=0;kk<3;kk++)
	inpPnts[ii][kk] = cstPnts[ii][kk];
  }
  else
  {
    // get the first three points
    for(ii=0;ii<3;ii++)
      for(kk=0;kk<3;kk++)
	inpPnts[ii][kk] = intPnts[ii][kk];
  }	
  outPlane->osnum = cst->env_info->_MD_OS ;
  sts = om$construct(	classid	= OPP_EMSplane_class_id,
			osnum	= outPlane->osnum,
			p_objid	= &outPlane->objid ) ;
  if( !( sts & 1 ) ) { *msg = EMS_E_OMerror ; goto wrapup ; }
  
  /*
   * Construct big plane; the following method will use the first 3
   * points of the array `intPnts'.
   * Note : EMSplane.EMplane does not seem to set `emsRC' if successful,
   * hence the following initialization.
   */
  emsRC = MSSUCC ;
  sts = om$send(	msg	= message EMSplane.EMplane(	&emsRC,
								cst,
								inpPnts,
				     /* 0 = rectangle*/		0 ),
			senderid= outPlane->objid,
			targetid= outPlane->objid,
			targetos= outPlane->osnum ) ;
  
  if( !( sts & 1 & emsRC & *cst->msg ) ) {
    /*
     * If construction fails, plane deletes itself.
     */
    if( emsRC & 1 ) {
      if( *cst->msg & 1 )	*msg = MSFAIL ;
      else			*msg	= *cst->msg ;
    } else	*msg = emsRC ;
    sts = OM_W_ABORT ;
    
    outPlane->objid = NULL_OBJID ;
  } else {
    sts 	= OM_S_SUCCESS ;
    *msg	= MSSUCC ;
  }
  
#ifdef DEBUG
  outOE.obj_id = *outPlane;
  outOE.mod_env= *cst->env_info;
  
  VDdumpSurface(&outOE,NULL,"plane.txt");
#endif
  wrapup :
    return sts ;
  
} /* VSmakePlaneEncompassingBox1 */
/*----------------------------------------------------------------------------*/

/* Extend the range of the beam two fold; intersect the beam's rangebox with
 * the inPlane and generate the outPlane out of intersection points
 */ 
long VSmakeInfinitePlaneNew( msg, beam, inPlane, cst, outPlane )
  
long			*msg ;
struct GRobj_env 	*beam ;
struct GRobj_env 	*inPlane ;
struct GRvg_construct	*cst ;
struct GRid		*outPlane ; {
  
  if((!beam) || (!inPlane) || (!cst) || (!outPlane)) return 0;
  
  return VSmakePlaneEncompassingBox1( msg,beam,inPlane,cst,outPlane ) ;
}
/*----------------------------------------------------------------------------*/

end implementation EMSplane ;
