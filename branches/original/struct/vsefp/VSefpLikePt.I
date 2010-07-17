/* $Id: VSefpLikePt.I,v 1.3 2001/03/02 21:03:45 jayadev Exp $ */

/***************************************************************************
 * I/STRUCT
 *
 * File:  vsefp/VSefpLikePt.I
 *
 * Description:
 *	
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSefpLikePt.I,v $
 *	Revision 1.3  2001/03/02 21:03:45  jayadev
 *	get all smart attributes for end treats in one call
 *	
 *	Revision 1.2  2001/01/17 00:05:45  ramarao
 *	*** empty log message ***
 *	
# Revision 1.10  2000/10/12  17:31:14  pinnacle
# ah
#
# Revision 1.9  2000/06/28  16:57:18  pinnacle
# ah
#
# Revision 1.8  2000/05/05  19:11:44  pinnacle
# ah
#
# Revision 1.6  2000/05/04  22:29:18  pinnacle
# ylong
#
# Revision 1.5  2000/05/04  19:59:10  pinnacle
# change tolerance to 1 mm
#
# Revision 1.4  2000/04/28  14:50:18  pinnacle
# ylong
#
# Revision 1.3  2000/04/26  21:38:42  pinnacle
# Added VSlikeCMD_PickedPieces by ylong
#
# Revision 1.2  2000/04/26  17:37:00  pinnacle
# (No comment)
#
# Revision 1.1  2000/04/26  15:59:48  pinnacle
# ylong
#
# Revision 1.1  2000/04/11  16:22:04  pinnacle
# TR179901360 & TR179901363
#
# Revision 1.1  2000/04/11  13:52:14  pinnacle
# ylong
#
# Revision 1.10  2000/04/03  19:41:06  pinnacle
# (No comment)
#
# Revision 1.9  2000/02/23  23:12:44  pinnacle
# ylong
#
# Revision 1.8  2000/01/24  15:58:12  pinnacle
# ah
#
# Revision 1.5  1999/06/25  18:27:36  pinnacle
# ylong
#
# Revision 1.1  1999/06/14  21:28:20  pinnacle
# mdong
#
 *
 * History:
 * MM/DD/YY	AUTHOR		DESCRIPTION
 * 03/31/99	ylong		mirror like
 * 06/14/99	Ming		Add function VSlikePart_StoreInfo().
 * 06/21/99	ylong		modify further
 * 12/06/99	ylong		1. if plate area is greater than 300000 mm2,
 *				   it is taken as an individual.
 *				2. misc bug
 * 12/30/99	ylong		update form if any change found
 * 01/12/00	ylong		added comparison of beam surface areas
 * 01/24/00     ah              Fixed crash when VDCenterline fails
 * 01/24/00     ylong		Added partNum as a criteria for TR179901139
 * 04/03/00     ylong		Crashed by single edge of plates
 * 04/10/00     ylong		TR179901360
 * 04/11/00     ylong		TR179901363
 * 05/04/00     ylong		Change tolerance bs_tol to 1 mm
 * 05/05/00     ah              Cleaned the tolerance up a bit
 * 05/05/00     ah              Take out the call to VSlikePieceMassCmp
 * 06/28/00     ah              Replace VSlike.h with VDlikePart.h
 * 10/04/00     ah              Stopped the deletion of neat plate macros
 ***************************************************************************/

class implementation Root;

#include "VDmaster.h"
#include "VDobj.h"
#include "VDsa.h"
#include "VDgeom.h"
#include "VDlikePart.h"
#include "vsgeommacros.h"
#include "VDefp.h"
#include "VSefp.h"
#include "vspart.h"
#include "bsparameters.h"
#include "bscveval.h"
#include "bsdividecv.h"
#include "bstrans1.h"
#include "bsptoldtnw.h"
#include "bstrfrhommx.h"
#include "bsptnwtold.h"
#include "bsalloccv.h"
#include "bststcvfarc.h"
#include "bsarclen.h"
#include "bsmkvec.h"
#include "bscv_copy.h"
#include "bsfreecv.h"

#if 0 
#define  vsDEBUG  1
#define  vserrDEBUG 1
#define  DEBUG  1
#endif

#include "vsdbgmacros.h"

/* 
 * If plate area is greater than MAX_AREA (300000.0 square mm's) ,
 * it is taken as individual. So surface area is about 2 times .3 sq m
 */
#define	MAX_AREA	600000.0

IGRboolean  VSlikeGetAng2Edg();
IGRboolean  VSlikePtsEq();
IGRboolean  VSlikeCrvEqual();
IGRstat     VSlikeGetNeatEdges();
IGRstat     VSlikeCMD_GetAttributes();

from GRvg        import  GRdetplane;
from VDSroot     import  VDGetCenterLine;
from GRgraphics  import  GRgetrang;
from VSbeam	 import	 VSgetMassProperties;

static	IGRdouble	bs_tol ;   // tollerance
#define VS_LIKE_PART_TOL 1.0

/*
 * print points
 */
void print_points(IGRpoint *p, IGRint num) {
      IGRint j ;

      for(j = 0; j < num; j++) {
         printf("%d: [%f, %f, %f]\n", j, p[j][0], p[j][1], p[j][2]);
      }
}
/* ---------------------------------------------------------
 * initialization of structure
 */
void VSlikeInitLikePiece(  TVSlikePiece *PC ) 
{
	IGRint	i ;

	if( ! PC ) return ;

	PC->pieceOE.obj_id.objid = NULL_OBJID ;
	PC->pieceLike	= -1 ;		// piece like has the same value
	PC->partName[0] = '\0';		// added for CR179900828
	PC->partNum[0]  = '\0';		// added for TR179901139
	PC->category[0] = '\0';		// applied to both plate and beam
	PC->material[0] = '\0';		// applied to both plate and beam
	PC->grade[30] = '\0';		// applied to both plate and beam
	PC->planar = 0 ;		// applied to both plate and beam
	PC->area = 0.0 ;		// applied to both plate and beam
	PC->thickness = 0.0 ;		// plate
	PC->family[0] = '\0';		// beam
	PC->length = -1.0 ;		// beam
	PC->beamCL_ID.objid = NULL_OBJID ;	// beam
	PC->x_height = -1.0 ;		// beam  added for TR179001363

	PC->planePoint[0] = 0.0 ;
	PC->planePoint[1] = 0.0 ;
	PC->planePoint[2] = 0.0 ;

	PC->beamCL.crv = NULL ;		// beam
	PC->beamCL.num_pts = 0 ;	// beam
	PC->beamCL.crv = NULL ;		// beam
	PC->beamCL.crvlen = 0 ;		// beam

	PC->treat[0] = '\0' ;
	PC->edges.count = 0 ;
	PC->edges.angl[0] = -1. ;
	PC->edges.edge[0].crv = NULL ;
	PC->edges.edge[0].crvlen = -1. ;
	PC->edges.edge[0].num_pts = 0 ;

}
/* ---------------------------------------------------------
 * test by printing out .
 */
void VSlikePrintTest( const TVSlikeCrv *CV ) 
{
    IGRdouble  dx, dy, dz, chord;
    IGRpoint   pt1[1], pt2[1];
    IGRint     i, j ,k, np ;

    BSrc       rc;
    IGRboolean ret;
 
    //SetProc(VSlikePrintTest); Begin

    //vdgeom$Print(crv = CV->crv);
    np = CV->num_pts ;
    BScveval(CV->crv, 0.0, 0, pt1, &rc);
    BScveval(CV->crv, 1.0, 0, pt2, &rc);
 
    printf("   crv len : %f\n", CV->crvlen);
    printf("   ends    : p1[%f %f %f]\n", pt1[0][0], pt1[0][1], pt1[0][2]) ;
    printf("             p2[%f %f %f]\n", pt2[0][0], pt2[0][1], pt2[0][2] );
    printf("   sample points:\n" ) ;
    for(i = 0; i < CV->num_pts; i++)
    {
       printf("    %d:  [%f %f %f]\n", 
                    i, CV->pts[i][0], CV->pts[i][1], CV->pts[i][2]) ;
    }

    //End
}


/* ----------------------------------------------------
 * comparison rule for sorting a double list
 * Slight tweak to get rid of negative tolerance
 */
 
int VSlikeCMD_doubleCMP( double *e1, double *e2)
{
  if(*e1 - *e2 > bs_tol) return ( 1);
  if(*e2 - *e1 > bs_tol) return (-1);
  return 0;
}
 
/* -----------------------------------------------------
 * comparison rule for sorting TVSlikePiece list
 */
IGRint VSlikeCMD_PieceCmp( TVSlikePiece *e1, TVSlikePiece *e2 )
{
   IGRint  retFlag = 0;
 
   if (!strcmp(e1->family,"skip")) return -1;
   if (!strcmp(e2->family,"skip")) return  1;
   
   retFlag = strcmp(e1->category, e2->category);
   if( retFlag ) return(retFlag);
 
   retFlag = strcmp(e1->partNum, e2->partNum);
   if( retFlag ) return(retFlag);
 
   retFlag = strcmp(e1->material, e2->material);
   if( retFlag ) return(retFlag);
 
   retFlag = strcmp(e1->grade,    e2->grade);
   if( retFlag ) return(retFlag);
 
   retFlag = strcmp(e1->family, e2->family);
   if( retFlag ) return(retFlag);
 
   retFlag = VSlikeCMD_doubleCMP(&e1->length,   &e2->length);
   if( retFlag ) return(retFlag);
 
   retFlag = strcmp(e1->treat, e2->treat);
   if( retFlag ) return(retFlag);
 
   retFlag = VSlikeCMD_doubleCMP(&e1->thickness,&e2->thickness);
   if( retFlag ) return(retFlag);

   // modified by ylong 01/12/2k
   if( !strcmp(e1->category, "plate") && !strcmp(e2->category, "plate") &&
                  e1->area > MAX_AREA && e2->area > MAX_AREA ) 
   {
	return ( strcmp(e1->partName, e2->partName) );
   }
   else 
   {
	retFlag = VSlikeCMD_doubleCMP(&e1->area, &e2->area);
	if( retFlag ) return(retFlag);
   }
 
   retFlag = e1->planar - e2->planar ;
   if( retFlag ) return(retFlag);

   return retFlag;
}
 
 
/* -------------------------------------------------------------------
 * comparison rule for sorting TVSlikePiece list based on like mark
 */
IGRint  VSlikeCMD_LikeSort( TVSlikePiece *e1, TVSlikePiece *e2 )
{
   IGRint	retFlag ;

   retFlag = e1->pieceLike - e2->pieceLike ;
   if( !retFlag ) retFlag = strcmp( e1->partName, e2->partName ) ;

   return retFlag ;
}


/* ----------------------------------------------------------------------------
 * Get sample points from a curve and transform the points onto x-y plane 
 * so that both ends of points are on x axis, and one end is at origin in
 * order to perform comparison of two point arrays conveniently. 
 */
IGRstat VSlikeGetCrvSamplePts( TGRplane     *pln,      // input curve plane
                               TGRbsp_curve *crv,      // input curve
                               IGRint       *num_pts,  // output # of sample pts
                               IGRpoint     *pts)      // output sample pts
{
  IGRint        i;
  IGRlong       msg ;
  IGRstat       retFlag = 0;
 
  IGRvector     xyNormal;
  IGRpoint      xyPoint ;
  IGRvector     srfNormal;
  IGRpoint      srfPoint;
  IGRpoint      pt1[4], pt2[4], xpts[2*MAX_NUM_PTS];

  BSrc          rc;
  IGRdouble     mat[3][3], m4x4[16] ;
  IGRvector     vector;
  IGRdouble     tstart, tend, scale, par[MAX_NUM_PTS] ;
  IGRint        nspc ;
 
  IGRboolean    ret = FALSE;
 
  SetProc( VSlikeGetCrvSamplePts ); Begin
  // Arg check
  if ( pln == NULL || crv == NULL ) goto wrapup;

  tstart = 0.0;
  tend = 1.0;

  // set the number of sample pts, 2 for line segment, MAX_NUM_PTS = 17
  // for curve, and get sample points from curve.
  if(crv->order > 2) 
  {
     *num_pts = MAX_NUM_PTS ;
     nspc = *num_pts - 1 ;
     BSdividecv( &rc, crv, &tstart, &tend, &nspc, par ); 
     for(i = 0; i < *num_pts; i++) {
       BScveval( crv, par[i], 0, &pts[i], &rc);
     }
  }
  else
  {
     *num_pts = 2 ;
     BScveval( crv, tstart, 0, &pts[0], &rc);
     BScveval( crv, tend,   0, &pts[1], &rc);
  }
 
  #ifdef DEBUG
  print_points(pts, *num_pts);
  #endif
    
  // set a standard plane's normal which coincides with z axis, and a point
  // same as start point of curve
  for(i = 0; i < 3; i++)
  {
    srfPoint[i] = pts[0][i];
    srfNormal[i] = pln->normal[i];
    xyPoint [i] = 0.0;
    xyNormal[i] = 0.0;
  }
  xyNormal[2] = 1.0;

  // get translation vector and rotation matrix
  ret = BStrans1(&rc,
                  srfPoint, srfNormal,   // input  old coordinate
                  xyPoint,  xyNormal,    // input  new coordinate
                  vector,                // output translation vector
                  mat,                   // output rotation matrix
                  &scale                 // output scale factor
                );

  if( !(ret && rc == BSSUCC) )
  {
      printf("BStrans1 failed on loop, %s.%d\n",__FILE__,__LINE__);
      goto wrapup;
  }
 
  // transform points to standard coordinate plane
  for( i = 0; i < *num_pts; i++ )
  {
    BSptoldtnw( &rc, vector, mat, &scale, pts[i], pts[i] ) ;
  }

  if( !(ret && rc == BSSUCC) )
  {
      printf("BScvoton failed on loop, %s.  %d\n",__FILE__,__LINE__);
      goto wrapup;
  }
 
  if( !crv->phy_closed ) {
    // set rotating vector that rotates points further about first 
    // point so that last point is onto x axis, for a not closed curve
    for( i = 0; i < 3; i++ ) {
      vector[i] = pts[*num_pts-1][i] - pts[0][i] ;
    }
  }
  else {
    // set rotating vector that rotates points further about connected
    // point so that the middle point is onto x axis, for a closed curve
    for( i = 0; i < 3; i++ ) {
      vector[i] = pts[(*num_pts-1)/2][i] - pts[0][i] ;
    }
  }
  MAxrotmx( &msg, vector, m4x4 ) ;
  BStrfrhommx(m4x4, mat, vector, &scale, &rc) ; // extract mat from m4x4

  for( i = 0; i < 3; i++ )
  {
    vector[i] = - pts[0][i] ;
  }

  for( i = 0; i < *num_pts; i++ )
  {
    BSptnwtold(&rc, vector, mat, &scale, pts[i], pts[i] ) ;
  }

  if( !(ret && rc == BSSUCC) )
  {
      printf("BScvoton failed on loop, %s.  %d\n",__FILE__,__LINE__);
      goto wrapup;
  }

  retFlag = 1;
 
wrapup:
 
  End
  return retFlag;
}


/* -------------------------------------------------------------------
 * get beam center lines and corresponding plane's points and normals
 */
IGRstat VSlikeBeamCenterLine( TVSlikePiece *beam )
{
    IGRlong      sts, msg ;
    IGRint       i, 
                 count   = 1 ;
    IGRdouble    start = 0., endp = 1.0, dir = .5 ;
    TGRplane     plane;
    TGRid        *beamCL_IDp;
    BSrc         rc ;
    IGRstat      ret = 0 ;

    IGRshort     arc_ind;
    IGRpoint     center;
    IGRdouble    rad;
    TGRbsp_curve *arc = NULL;
 
  
    SetProc( VSlikeBeamCenterLine ); Begin
    
    #ifdef DEBUG
    vdobj$Print(objOE = &beam->pieceOE);
    #endif

    beamCL_IDp = &beam->beamCL_ID;
    beam->beamCL.crv = NULL;
    
    sts = om$send(  msg    = message VDSroot.VDGetCenterLine(
                                                &msg,
                                                &beam->pieceOE.mod_env,
                                                &count,
                                                &beamCL_IDp),
                  senderid = NULL_OBJID,
                  targetid = beam->pieceOE.obj_id.objid,
                  targetos = beam->pieceOE.obj_id.osnum 
                 );

    if (!(sts & msg & 1)) {
      printf("VDGetCenterLine failed on loop, %s at %d\n",__FILE__,__LINE__);
      vdobj$Print(objOE = &beam->pieceOE);
      goto wrapup;
    }

    vs$get_geometry( msg      = &msg,
                     grobjId  = &beam->beamCL_ID,
                     grobjEnv = &beam->pieceOE.mod_env ,
                     geometry = &beam->beamCL.crv ) ;

    if (!(sts & msg & 1)) {
      printf("vs$get_geometry failed on loop, %s.%d\n",__FILE__,__LINE__);
      vdobj$Print(objOE = &beam->pieceOE);
      goto wrapup;
    }

    plane.normal = beam->planeNormal;
    plane.point  = beam->planePoint;
    sts = om$send(msg      = message GRvg.GRdetplane
                              (&msg, 
                               &beam->pieceOE.mod_env.md_env.matrix_type,
                                beam->pieceOE.mod_env.md_env.matrix,
                               &plane),
                  senderid = NULL_OBJID,
                  targetid = beamCL_IDp->objid,
                  targetos = beamCL_IDp->osnum );

    if (!(sts & 1)) {
      printf("GRvg.GRdetplane failed, %s.%d\n",__FILE__,__LINE__);
      vdobj$Print(objOE = &beam->pieceOE);
      ret = 0 ;
      goto wrapup;
    }
    else if (!( msg & 1)) {
      plane.point[0] = plane.point[1] = plane.point[2] = 0.;
      plane.normal[0] = plane.normal[1] = 0.;
      plane.normal[2] = 1.;
    }

    // get crv sample points and transform. if arc, get radius.
    BSalloccv(beam->beamCL.crv->order,
              beam->beamCL.crv->num_poles,
              beam->beamCL.crv->rational,
              beam->beamCL.crv->num_boundaries,
              &arc,
              &rc) ;
    BStstcvfarc(beam->beamCL.crv, &arc_ind, center, &rad, arc, &rc);
    if( rc == BSSUCC && arc_ind != 0 ) { 
      beam->beamCL.num_pts = 1;
      beam->beamCL.crvlen = rad ;
      ret = 1 ;
    }
    else {
      ret = VSlikeGetCrvSamplePts( &plane,
                                   beam->beamCL.crv, 
                                   &beam->beamCL.num_pts,
                                   beam->beamCL.pts) ;

      BSarclen( &rc, (IGRshort*)&ret, 
                beam->beamCL.crv,
                &start, &endp, &dir,
                &beam->beamCL.crvlen);
    }

    if( !ret ) {
      printf("VSlikeGetCrvSamplePts() failed, %s.%d\n",__FILE__,__LINE__);
      vdobj$Print(objOE = &beam->pieceOE);
    }

wrapup:
    if( arc != NULL ) { BSfreecv( &rc, arc ); }
    if (!ret) {
      strcpy(beam->family,"skip");
      //printf("Setting beam family to skip\n");
    }
    
    End
    return ret ;
}
 

/*----------------------------------------------------------------
 * get plane of plate and determine if a plate is planar or not.
 */

IGRint   VSlikeCMD_planar( TVSlikePiece *plate )
{
  IGRstat     stat;
  IGRlong     msg;
  TGRplane    plane;
  TGRobj_env *pieceOE;
 
  SetProc(VSlikeCMD_planar); Begin
  pieceOE = &plate->pieceOE ;
  plane.point  = plate->planePoint;
  plane.normal = plate->planeNormal;;

  stat = om$send ( msg = message GRvg.GRdetplane 
                                      (&msg,
                                       &pieceOE->mod_env.md_env.matrix_type,
                                        pieceOE->mod_env.md_env.matrix,
                                       &plane),
                   senderid = NULL_OBJID,
                   targetid = pieceOE->obj_id.objid,
                   targetos = pieceOE->obj_id.osnum 
                 );

  End

  return ( stat & msg & 1 ) ;
}
 
/* --------------------------------------------------------------
 * extract the attributes from parts
 */
IGRstat VSlikeCMD_GetAttributes(TVSlikeInfo *info)
{
  IGRint	i;
  IGRchar	std_pcmk[128] ;
  IGRlong	sts ;
  IGRdouble	start = 0., endp = 1.0, dir = .5 ;
  IGRstat	retFlag = 0;
  BSrc		rc;
  
  TVSlikePiece *pieceLIKE;
  TGRobj_env    pieceOE;
  
  SetProc( VSlikeCMD_ProcessPieces ); Begin

  sts = MSSUCC ;
  pieceLIKE = NULL ;

  // Set global tolerance here
  bs_tol = VS_LIKE_PART_TOL;

  for(i = 0; i < info->pieceCNT; i++)
  {
    pieceLIKE = &info->pieceLIKEs[i];
    pieceOE   =  pieceLIKE->pieceOE;

    #ifdef vsDEBUG
    vdobj$Print(objOE = &pieceOE);
    #endif

    vdsa$GetStruct( objOE = &pieceOE,
		    name  = "SA_OBJ:category",
		    txt   = pieceLIKE->category);
    vdsa$GetStruct( objOE = &pieceOE,
		    name  = "part_num",
		    txt   = pieceLIKE->partNum);
    vdsa$GetStruct( objOE = &pieceOE,
		    name  = "material",
		    txt   = pieceLIKE->material);
    vdsa$GetStruct( objOE = &pieceOE,
		    name  = "grade",
		    txt   = pieceLIKE->grade);
    vdsa$GetStruct( objOE = &pieceOE,
		    name  = "memb_name",
		    txt   = pieceLIKE->partName);
    vdsa$GetStruct( objOE = &pieceOE,
                    name  = "surface_area",
                    dbl   = &pieceLIKE->area);

    pieceLIKE->pieceLike = -1 ;  // before perform piece like

    if( !strcmp(pieceLIKE->category, "plate") )
    {
      pieceLIKE->planar = VSlikeCMD_planar( pieceLIKE );

      vdsa$GetStruct( objOE = &pieceOE,
                      name  = "plate_thk",
                      dbl   = &pieceLIKE->thickness);

      // check if the plate is a standard part. if so, give it std_pcmk.
      vdsa$GetStruct( objOE = &pieceOE,
                      name  = "SA_PPL:pcmk:std_pcmk",
                      txt   =  std_pcmk);
      if( strcmp( std_pcmk, "NOT STANDARD") ) {
	if( isdigit(std_pcmk[0]) ) {
		pieceLIKE->pieceLike = atoi(std_pcmk) ;
	}
      }

    }
      
    if( !strcmp(pieceLIKE->category, "beam") )
    {
      vdsa$GetStruct( objOE = &pieceOE,
                      name  = "family_name",
                      txt   = pieceLIKE->family);
      vdsa$GetStruct( objOE = &pieceOE,
                      name  = "end_treats",
                      txt   = pieceLIKE->treat);
      vdsa$GetStruct( objOE = &pieceOE,
                      name  = "memb_cut_leng",
                      dbl   = &pieceLIKE->length);
      vdsa$GetStruct( objOE = &pieceOE,
                      name  = "x_Height",
                      dbl   = &pieceLIKE->x_height);

      sts = VSlikeBeamCenterLine( pieceLIKE );

      if( ! sts || ! strcmp( pieceLIKE->family , "skip"))
	continue ;

      if((pieceLIKE->beamCL.crv) && (pieceLIKE->beamCL.crv->phy_closed)) {
        //vdsa$GetStruct can not get length for a closed beam.
        BSarclen( &rc,      
                  (IGRshort*) &sts,
                  pieceLIKE->beamCL.crv,
                  &start,
                  &endp,
                  &dir,
                  &pieceLIKE->length) ;
      }
    }

  }
  
  retFlag = 1;

wrapup:

  End

  return retFlag;
  
}

/* --------------------------------------------
 * Get pieces one by one
 */
IGRstat VSlikeCMD_PickedPieces(TVSlikeInfo *info, TGRobj_env *objOE)
{
  IGRstat	retFlag = 0;
  TGRobj_env	*pieceOEs = NULL;
  TVSlikePiece	*ptr = NULL ;

  IGRint      pieceCNT = 0;
  IGRint      i;
  
  SetProc( VSlikeCMD_PickedPieces ); Begin

  pieceCNT = info->pieceCNT + 1 ;
  ptr = info->pieceLIKEs ;
  info->pieceCNT = pieceCNT ;
  info->pieceLIKEs = _CALLOC(pieceCNT, TVSlikePiece);
  if ( info->pieceLIKEs == NULL) {
    printf("Unable to allocate memory for like pieces\n");
    goto wrapup;
  }
  
  for(i = 0; i < pieceCNT-1; i++) {
    VSlikeInitLikePiece(  &( info->pieceLIKEs[i] )  );
    info->pieceLIKEs[i].pieceOE = ptr[i].pieceOE;
  }
  VSlikeInitLikePiece(  &( info->pieceLIKEs[pieceCNT-1] )  );
  info->pieceLIKEs[pieceCNT-1].pieceOE = *objOE ;

  retFlag = 1 ;

wrapup:
  End
  _FREE( ptr ) ;
  return retFlag;
}
/* --------------------------------------------
 * Pick up pieces using a fence
 */
IGRstat VSlikeCMD_PickedPiecesFence(TVSlikeInfo *info, TGRobj_env *fenceOE)
{
  IGRstat     retFlag = 0;

  TGRobj_env *pieceOEs = NULL;

  IGRint      pieceCNT = 0;
  IGRint      i;
  
  // Don't do one without the other
  IGRint  response;
  IGRchar response_data[1024];
  
  SetProc( VSlikeCMD_PickedPiecesFence ); Begin

  *response_data = 0;
   response = 0;
  
  as$start_fence(set           = &fenceOE->obj_id,
		 set_env       = &fenceOE->mod_env,
		 nb_obj        = &pieceCNT,
		 response      = &response,
		 response_data = response_data,
       		 p_obj_env     = &pieceOEs);

  if (response != EX_DATA) goto wrapup;

  info->pieceCNT   = pieceCNT;
  info->pieceLIKEs = _CALLOC(pieceCNT,TVSlikePiece);
  if ( info->pieceLIKEs == NULL) {
    printf("Unable to allocate memory for like pieces\n");
    goto wrapup;
  }
  
  for(i = 0; i < pieceCNT; i++) {

    VSlikeInitLikePiece(  &( info->pieceLIKEs[i] )  );

    info->pieceLIKEs[i].pieceOE = pieceOEs[i];
    
  }
  ASend_fence();
  retFlag = 1 ;

wrapup:
  End
  return retFlag;
}

/*-------------------------------------------------------------------------
 * compare mass properties, currently, centriods.
 * VSintegral defined as:
 * {
 *	double	area, volume, mass ;
 *
 *	union	{
 *			struct { double Ixx, Iyy, Izz,
 *					Ixy, Iyz, Izx ;
 *			}
 *			double array[6] ;
 *	} MofI
 *
 *	double		dims[3] ;
 *
 *	IGRpoint	cetroid ;
 * }
 */
IGRboolean  VSlikePieceMassCmp( TVSlikePiece *P1,  TVSlikePiece *P2 )
{
	IGRboolean	retFlag = FALSE, status ;
	IGRlong		sts, msg ;
	VSintegral	mp1, mp2 ;
	IGRpoint	cent1, cent2;
	IGRdouble	par1, par2, dist1, dist2, seg1, seg2, dir, start ;
	TGRbsp_curve	*curve = NULL ;
	BSrc		rc ;

	mp1.centroid[0] = 0 ;
	mp1.centroid[1] = 0 ;
	mp1.centroid[2] = 0 ;

	mp2.centroid[0] = 0 ;
	mp2.centroid[1] = 0 ;
	mp2.centroid[2] = 0 ;

	// Get mass properties of beam 1
	sts = om$send(	msg	 = message VSbeam.VSgetMassProperties
					(&msg, &P1->pieceOE.mod_env, &mp1 ),
			senderid = NULL_OBJID ,
			targetid = P1->pieceOE.obj_id.objid ,
			targetos = P1->pieceOE.obj_id.osnum );
	if( !(sts&msg&1) ) {
		printf("VSbeam.VSgetMassProperties failed\n");
		goto wrapup ;
	}

	// Get mass properties of beam 2
	sts = om$send(	msg	 = message VSbeam.VSgetMassProperties
					(&msg, &P2->pieceOE.mod_env, &mp2 ),
			senderid = NULL_OBJID ,
			targetid = P2->pieceOE.obj_id.objid ,
			targetos = P2->pieceOE.obj_id.osnum );
	if( !(sts&msg&1) ) {
		printf("VSbeam.VSgetMassProperties failed\n");
		goto wrapup ;
	}

	// Get point projected from centriod to the axis of beam 1
	curve = P1->beamCL.crv ;
	BSmdstptcv(curve, mp1.centroid, &par1, cent1, &dist1, &rc) ;
	if( rc != BSSUCC ) {
		printf("BSmdstptcv failed\n");
		goto wrapup ;
	}

	// Get crv len between u = 0 and u = par1 along axis of beam 1
	seg1 = -1. ;
	start = 0. ;
	dir = .5*(start + par1) ;
	BSarclen2(&rc, &status, curve, &start, &par1, &dir, &seg1) ;
	if( rc != BSSUCC ) {
		printf("BSarclen failed\n");
		goto wrapup ;
	}

	// Get point projected from centriod to the axis of beam 2
	curve = P2->beamCL.crv ;
	BSmdstptcv(curve, mp2.centroid, &par2, cent2, &dist2, &rc) ;
	if( rc != BSSUCC ) {
		printf("BSmdstptcv failed\n");
		goto wrapup ;
	}

	// Get crv len between u = 0 and u = par2 along axis of beam 2
	seg2 = -1. ;
	start = 0. ;
	dir = .5*(start + par2) ;
	BSarclen2(&rc, &status, curve, &start, &par2, &dir, &seg2) ;
	if( rc != BSSUCC ) {
		printf("BSarclen failed\n");
		goto wrapup ;
	}

	// If dist1=dist2 and seg1=seg2, then two beams equal about centroid
	if( fabs(dist1 - dist2) > bs_tol ) {
	  printf("Not equal about dist\n");
	  
		goto wrapup ;
	}

	if( fabs(seg1 - seg2) > bs_tol ) {
		seg2 = P2->beamCL.crvlen - seg2 ;
		if( fabs(seg1 - seg2) > bs_tol ) {
	  printf("Not equal about seg\n");
			goto wrapup ;
		}
	}

	//printf(" dist1 = %f, seg1 = %f\n", dist1, seg1);
	//printf(" dist2 = %f, seg2 = %f\n", dist2, seg2);

	retFlag = TRUE ;
wrapup:
	return retFlag ;
}

/*-------------------------------------------------------------------------
 *  compare two pieces to determine if they have the same parameter values
 *  except edges for plates and centerline for beams.
 *
 * ### Let family contain a skip value
 */
IGRboolean  VSlikePieceEqual(TVSlikePiece *P1,  TVSlikePiece *P2 ) 
{
  IGRboolean  ret ;

  SetProc(VSlikePieceEqual); Begin

  // Hate those goddamn Begins
  if (!strcmp(P1->family,"skip")) return FALSE;
  if (!strcmp(P2->family,"skip")) return FALSE;
  
  if( strcmp(P1->category, "beam") == 0 &&
      strcmp(P2->category, "beam") == 0 ) 
  {
    if (P1->beamCL.crv == NULL) return FALSE;
    if (P2->beamCL.crv == NULL) return FALSE;
        
     ret =  P1->beamCL.crv->planar &&  P2->beamCL.crv->planar   &&
            P1->x_height <= 250.   &&  P2->x_height <= 250.     &&
            fabs(P1->length - P2->length) < bs_tol     &&
            fabs(P1->area   - P2->area)   < bs_tol     && 
            strcmp(P1->material, P2->material) == 0 &&
            strcmp(P1->grade,    P2->grade   ) == 0 &&
            strcmp(P1->family,   P2->family  ) == 0 &&
            strcmp(P1->treat, P2->treat) == 0; 

     if( ret ) {
       //ret = VSlikePieceMassCmp( P1,  P2 );
       //printf("Just did VSlikePieceMassCmp %d\n",ret);
       
     }
     
  }
  else if( strcmp(P1->category, "plate") == 0 &&
           strcmp(P2->category, "plate") == 0 )
  {
     // currently, only applied to planar plane and area not greater 
     // than 300000 square mm's.
     ret =  P1->planar   &&   
            P2->planar   &&
	    P1->area <= MAX_AREA  && 
	    P2->area <= MAX_AREA  && 
            strcmp(P1->material, P2->material) == 0  &&
            strcmp(P1->grade,    P2->grade   ) == 0  &&
            fabs(P1->area - P2->area) < bs_tol       &&
            fabs(P1->thickness - P2->thickness) < bs_tol  ;
  }
  else {
     ret = FALSE ;
  }

  End
  return ret ;
}
  
/*------------------------------------------------------------------------
 *  Get neat surface for a plate, and then extract edges and angles between
 *  two chords of concatenate edges.
 */
IGRstat  VSlikeGetNeatEdges( TVSlikePiece *plate ) {

  IGRstat	retFlag = 0;

  IGRchar	footName[32];
  TGRobj_env	footOE;
  TGRobj_env	neatMacOE;
  TGRobj_env	srfOE;

  IGRlong	msg, sts;
  IGRdouble	start = 0.0, dir = 0.5, endp = 1.0, iner_ang, dist ;
  IGRint	i, j, edgeFlag;
  IGRint	num_edge ;
  IGRpoint	pts[2];

  BSrc		rc;
  IGRboolean	ret;
  TGRplane	plane;
  TVSlikeEdges	*edges ;


  SetProc( VSlikeGetNeatEdges ); Begin

  neatMacOE.obj_id.objid = NULL_OBJID ;

  // Arg check
  if ( plate == NULL ) {
     goto wrapup;
  }

  __DBGpr_com("Get Attached Neat Plate");
  __DBGpr_obj("plate->pieceOE", plate->pieceOE.obj_id);

  vsefp$GetAttachedNeatPlateMacro(	macName = VDEFP_NEAT_PLATE_MACRO_NAME,
					plateOE = &plate->pieceOE ,
					macOE   = &neatMacOE ) ;

  if (neatMacOE.obj_id.objid == NULL_OBJID) {
    __DBGpr_com("Place Neat Plate");
    vdefp$PlaceMacro(macName = VDEFP_NEAT_PLATE_MACRO_NAME,
                     tplOEs  = &plate->pieceOE,
                     macOE   = &neatMacOE);
  }

  __DBGpr_com("Neat Plate Placed");
/*
  // Hardcode to base surface for now
  vdobj$GetFoot(objOE    = &plate->pieceOE,
                footName = "plate:base",
                footOE   = &srfOE);
  if (srfOE.obj_id.objid == NULL_OBJID) {
	printf("vdobj$GetFoot failed\n") ;
	goto wrapup;
  }

  // Get neat if it exists
  VSefpGetNeatPlate(&srfOE, &neatMacOE, NULL) ;
  #ifdef DEBUG
  vdobj$Print(objOE = &srfOE);
  #endif

  // Place if don't have one
  if (neatMacOE.obj_id.objid == NULL_OBJID) {
    vdefp$PlaceMacro(macName = VDEFP_NEAT_PLATE_MACRO_NAME,
                     tplOEs  = &srfOE,
                     macOE   = &neatMacOE);
  }
  #ifdef DEBUG
  vdobj$Print(objOE = &neatMacOE);
  #endif
*/

  // Fail if still don't have one
  if (neatMacOE.obj_id.objid == NULL_OBJID) {
    printf("Problem getting neat_plate macro\n");
    goto wrapup;
  }
#ifdef DEBUG
  vdobj$Print(objOE = &neatMacOE);
#endif

  // Cycle through and pull geometry from the feet
  edgeFlag = 1;
  num_edge = 0 ;
  edges = &plate->edges ;
  j = 0 ;
  while(edgeFlag)
  {
    i = num_edge ;
    sprintf(footName,"edge%02d",i);
    __DBGpr_str("edge name", footName);
    footOE.obj_id.objid = NULL_OBJID;
    vdobj$GetFoot(objOE    = &neatMacOE,
                  footName =  footName,
                  footOE   = &footOE);
    if (footOE.obj_id.objid == NULL_OBJID)
    {
      __DBGpr_com("No more edges");
      edgeFlag = 0;
    }
    else 
    {
      __DBGpr_com("Found new edge");
      #ifdef DEBUG 
      vdobj$Print(objOE = &footOE);
      #endif
      vs$get_geometry( msg      = &msg,
                       grobjId  = &footOE.obj_id,
                       grobjEnv = &footOE.mod_env ,
                       geometry = &edges->edge[j].crv ) ;

      if ( !(msg & 1) || edges->edge[j].crv == NULL) {
        printf("Problem getting edge geometry\n");
        goto wrapup;
      }
      // kick out inside cuts of plate, consider inside cut in later version
      if( edges->edge[j].crv->phy_closed && strcmp(footName, "edge00")) {
	_FREE(edges->edge[j].crv) ;
	edges->edge[j].crv = NULL ;
      }
      else {
	j++ ;
      }

      num_edge++;
    }
  }
  num_edge = j ;
  plate->edges.count = num_edge ;

  plane.point  = plate->planePoint ;
  plane.normal = plate->planeNormal ;

  // reorder directions of curves so that the start point of an edge is
  // the end point of previous edge
  if( num_edge > 1 ) {
	BScveval( edges->edge[0].crv, 1.0, 0, &pts[0], &rc);
	if( rc != BSSUCC ) {
		printf("BScveval() failed\n");
		goto wrapup ;
	}
	BScveval( edges->edge[1].crv, 0.0, 0, &pts[1], &rc);
	if( rc != BSSUCC ) {
		printf("BScveval() failed\n");
		goto wrapup ;
	}
	ret = MA2ptdis(&msg , pts[0] , pts[1] , &dist );
  	if ( dist > bs_tol ) {
		BScveval( edges->edge[1].crv, 1.0, 0, &pts[1], &rc);
		ret = MA2ptdis(&msg , pts[0] , pts[1] , &dist );
	}

	if( dist > bs_tol ) {
		BSrev_cv(&rc, edges->edge[0].crv) ;	// return boolean
		if( rc != BSSUCC ) {
			printf("BSBSrev_cv() failed\n");
			goto wrapup ;
		}
	}

	for( i = 1; i < num_edge; i++ ) { 
		BScveval( edges->edge[i-1].crv, 1.0, 0, &pts[0], &rc);
		if( rc != BSSUCC ) {
			printf("BScveval() failed\n");
			goto wrapup ;
		}
		BScveval( edges->edge[i].crv, 0.0, 0, &pts[1], &rc);
		if( rc != BSSUCC ) {
			printf("BScveval() failed\n");
			goto wrapup ;
		}
		ret = MA2ptdis(&msg , pts[0] , pts[1] , &dist );
		if( dist > bs_tol ) {
			BSrev_cv(&rc, edges->edge[i].crv) ;  // return boolean
		}
	}
  }

  // get curve length and sample points for each edge, and angles between
  // two edges i-1 and i
  iner_ang = 0. ;
  for( i = 0; i < num_edge; i++ ) {

    BSarclen( &rc, &ret, 
              edges->edge[i].crv, 
              &start, &endp, &dir,
              &edges->edge[i].crvlen);
    if( rc != BSSUCC ) {
	printf("BSBSarclen() failed\n");
	goto wrapup ;
    }

    VSlikeGetCrvSamplePts( &plane, 
                           edges->edge[i].crv,
                           &edges->edge[i].num_pts,
                           edges->edge[i].pts ) ;
    if( num_edge > 1 ) {
	VSlikeGetAng2Edg( edges->edge[(i-1+num_edge)%num_edge].crv,
				edges->edge[i].crv,
				plate->planeNormal,
				&edges->angl[i] ) ;
	iner_ang = iner_ang + edges->angl[i] ;
    }
  }

  #ifdef DEBUG1
  printf(" iner_ang = %f, (num_edge - 2)*PI = %f, and before repare:\n",
           180.*iner_ang/PI, 180.*(num_edge - 2));
  for( i = 0; i < num_edge; i++ ) {
    printf("   edges->angl[%d] = %f\n", i, 180.*edges->angl[i]/PI );
  }
  #endif

  // repare angles 
  if( num_edge > 1 && iner_ang - (num_edge - 2)*PI > 0.1 ) {
    for( i = 0; i < num_edge; i++ ) {
      edges->angl[i] = 2.*PI - edges->angl[i] ;
    }
  }

  #ifdef DEBUG1
  printf(" after repare:\n" );
  for( i = 0; i < num_edge; i++ ) {
    printf("   edges->angl[%d] = %f\n", i, 180.*edges->angl[i]/PI );
  }
  #endif

  // Done
  retFlag = 1;

wrapup:
  if( neatMacOE.obj_id.objid != NULL_OBJID ) {
	__DBGpr_com("Delete neatMacOE");

	/* ---------------------------------------
	 * ah - 04 Oct 2000
	 * Don't do this, other things like the bevels depend
	 * on this macro as well
	 */
	// vdobj$Delete(objOE = &neatMacOE);
	neatMacOE.obj_id.objid = NULL_OBJID ;
  }
  
  End
  return retFlag;
}


/*--------------------------------------------------------------
 *  calculate the angle between two chords of corresponding curves
 */
IGRboolean VSlikeGetAng2Edg( TGRbsp_curve  *crv1,
                             TGRbsp_curve  *crv2,
                             IGRvector     normal,
                             IGRdouble     *angle )
{
  IGRdouble   start1, end1, start2, end2 ;
  IGRlong     msg ;
  IGRdouble   dist = 100. ;
  IGRvector   vec1, vec2, vec;
  IGRpoint    pt1[2], pt2[2];
  IGRboolean  ret = FALSE ;
  BSrc        rc ;

    SetProc( VSlikeGetAng2Edg ); Begin

    // first, find conincident point of two edges

    BScveval(crv1, 1.0, 0, pt1, &rc);
    if( rc != BSSUCC ) {
	printf("BScveval() failed\n");
	goto wrapup ;
    }

    BScveval(crv2, 0.0, 0, pt2, &rc);
    if( rc != BSSUCC ) {
	printf("BScveval() failed\n");
	goto wrapup ;
    }
    ret = MA2ptdis(&msg , pt1[0] , pt2[0] , &dist );

    if( (ret & msg & 1) && dist < bs_tol ) {
       start1 = 1. ;  end1 = 0. ;
       start2 = 0. ;  end2 = 1. ;
       goto get_angle ;
    }

    BScveval(crv2, 1.0, 0, pt2, &rc);
    if( rc != BSSUCC ) {
	printf("BScveval() failed\n");
	goto wrapup ;
    }
    ret = MA2ptdis(&msg , pt1[0] , pt2[0] , &dist );

    if( (ret & msg & 1) && dist < bs_tol ) {
       start1 = 1. ;  end1 = 0. ;
       start2 = 1. ;  end2 = 0. ;
       goto get_angle ;
    }
    BScveval(crv1, 0.0, 0, pt1, &rc);
    if( rc != BSSUCC ) {
	printf("BScveval() failed\n");
	goto wrapup ;
    }

    BScveval(crv2, 0.0, 0, pt2, &rc);
    if( rc != BSSUCC ) {
	printf("BScveval() failed\n");
	goto wrapup ;
    }
    ret = MA2ptdis(&msg , pt1[0] , pt2[0] , &dist );

    if( (ret & msg & 1) && dist < bs_tol ) {
       start1 = 0. ;   end1 = 1. ;
       start2 = 0. ;   end2 = 1. ;
       goto get_angle ;
    }

    BScveval(crv2, 1.0, 0, pt2, &rc);
    if( rc != BSSUCC ) {
	printf("BScveval() failed\n");
	goto wrapup ;
    }
    ret = MA2ptdis(&msg , pt1[0] , pt2[0] , &dist );

    if( (ret & msg & 1) && dist < bs_tol ) {
       start1 = 0. ;  end1 = 1. ;
       start2 = 1. ;  end2 = 0. ;
    }

    get_angle:

    if( (ret & msg & 1) && dist < bs_tol )  {
      BScveval(crv1, start1, 0, pt1, &rc);
      if( rc != BSSUCC ) {
	printf("BScveval() failed\n");
	goto wrapup ;
      }

      BScveval(crv1, end1,   0, pt2, &rc);
      if( rc != BSSUCC ) {
	printf("BScveval() failed\n");
	goto wrapup ;
      }

      BSmkvec (&rc, vec1, pt1[0], pt2[0]);
      if( rc != BSSUCC ) {
	printf("BSmkvec() failed\n");
	goto wrapup ;
      }
 
      BScveval(crv2, start2, 0, pt1, &rc);
      if( rc != BSSUCC ) {
	printf("BScveval() failed\n");
	goto wrapup ;
      }

      BScveval(crv2, end2,   0, pt2, &rc);
      if( rc != BSSUCC ) {
	printf("BScveval() failed\n");
	goto wrapup ;
      }

      BSmkvec (&rc, vec2, pt1[0], pt2[0]);
      if( rc != BSSUCC ) {
	printf("BSmkvec() failed\n");
	goto wrapup ;
      }

      ret = MAcrossvc( &msg, vec1, vec2, vec) ;
      ret = MAlenvc( &msg, vec, &dist );
      if( ret && (msg&1) && dist < bs_tol ) {
        *angle = PI ;
      }
      else {
        ret = MArang2vc(&msg, vec2, vec1, normal, angle) ;
      }
    }
    else {
      printf("Failed to get angle btwn edges, %s.%d\n",__FILE__,__LINE__);
      printf("ret[%d], msg[%d], dist[%f]\n", ret, msg, dist);
      ret = FALSE ;
    }

wrapup:

    End
    return ( ret );
}


/*--------------------------------------------------------------
 *  compare two plates by comparing their corresponding edges and the 
 *  angles between concatenating edges.
 */
IGRboolean  VSlikeEdgeEqual( TVSlikeEdges *e1, TVSlikeEdges *e2 )
{  
  IGRboolean    retFlag = FALSE,
                pts_eq  = FALSE,
                done    = FALSE;
  IGRint        i, j, n, m, 
                cnt, i_start, i_end,
                num_pts ;
  IGRdouble     d_len, d_ang;
  BSrc          rc;
   
  SetProc( VSlikeEdgeEqual ); Begin
   
  if( e1 == NULL || e2 == NULL || e1->count != e2->count) 
  {
     __DBGpr_com("  Curves NOT comparable at all !!!");
     goto wrapup ;
  }
    
  #ifdef DEBUG
  for(i = 0; i < e1->count; i++) {
    printf("st: e1->edge[%d]: crvlen = %f, angl = %f\n",
                i, e1->edge[i].crvlen, e1->angl[i]);
  }
  for(i = 0; i < e2->count; i++) {
    printf("st: e2->edge[%d]: crvlen = %f, angl = %f\n",
                i, e2->edge[i].crvlen, e2->angl[i]);
  }
  #endif

  cnt = e1->count ;
  i = j = 0 ;

  done = FALSE ;
  while( !done ) 
  {
    // find first match
    num_pts = e1->edge[i].num_pts ;
    for(j = 0; j < cnt; j++)
    {  
      if( num_pts == e2->edge[j].num_pts ) {
        d_len = fabs( e1->edge[i].crvlen - e2->edge[j].crvlen ) ;
        d_ang = fabs( e1->angl[i] - e2->angl[j] ) ;
       
        if( d_len < bs_tol && d_ang < bs_tol ) {
          pts_eq = VSlikePtsEq( e1->edge[i].pts,
                                e2->edge[j].pts,
                                num_pts,
                                bs_tol ) ;
          if( pts_eq ) break ;
        }
      }
    }

    // start search other matches sequentially after first one 
    i_start = i + 1 ;

    if( j >= cnt || i_start > cnt ) {
       goto wrapup ; 
    }
    i_end = i + cnt ;
  
    for(i = i_start; i < i_end; i++) 
    {
      j++;
      m = i%cnt ;
      n = j%cnt ;  
      num_pts = e1->edge[m].num_pts;
      if( num_pts != e2->edge[n].num_pts ) break ;
      d_len = fabs( e1->edge[m].crvlen - e2->edge[n].crvlen ) ;
      d_ang = fabs( e1->angl[m] - e2->angl[n] ) ;
      pts_eq = VSlikePtsEq( e1->edge[m].pts,
                            e2->edge[n].pts,
                            num_pts,
                            bs_tol ) ;

      if( d_len > bs_tol || d_ang > bs_tol || !pts_eq )
      {
        #ifdef DEBUG
        printf(" e1->edge[%d]: crvlen = %f, angl = %f\n",
                 m, e1->edge[m].crvlen, e1->angl[m]);
        print_points(e1->edge[m].pts, e1->edge[m].num_pts);
 
        printf(" e2->edge[%d]: crvlen = %f, angl = %f\n",
                 n, e2->edge[n].crvlen, e2->angl[n]);
        print_points(e2->edge[n].pts, e2->edge[n].num_pts);
        #endif

        i = i_start ;
        break ;
      }
    }
    if( i >= i_end ) done = TRUE ;

  } // while not done !

  retFlag = TRUE ;

  wrapup:

  End

  return retFlag ;
}


/*----------------------------------------------------------------------------
 *  compare two beams by comparing their center lines/curves. originally, 
 */
IGRboolean  VSlikeCrvEqual( TVSlikeCrv *CV1, TVSlikeCrv *CV2, TGRplane *pln ) {

    IGRstat        ret = 0 ;
    IGRlong        msg ;
    BSrc           rc;
    IGRint         i, num_pts ;
    IGRboolean     overlap = FALSE ;
    IGRdouble      mat[3][3] ;
    IGRdouble      m4x4[16] ;
    IGRdouble      scale, theta ;
    IGRvector      vector, rot_axis;
    IGRpoint       pts[MAX_NUM_PTS], temp[MAX_NUM_PTS] ;
    TGRbsp_curve   *curve;

    SetProc( VSlikeCrvEqual ); Begin

    curve = NULL;
    if( CV1->num_pts != CV2->num_pts ||
        CV1->crv->phy_closed != CV2->crv->phy_closed) {
      goto wrapup ;
    }

    num_pts = CV2->num_pts ;
    if( num_pts == 1 ) {              // for a arc or circule case
      if( fabs(CV1->crvlen - CV2->crvlen) < bs_tol ) {
        overlap = TRUE ;
      }
      goto wrapup ;
    }

    overlap = VSlikePtsEq( CV1->pts, CV2->pts, num_pts, bs_tol ) ;

    if( num_pts == 2 || overlap ) {
      goto wrapup ;
    }
    else { 
        rot_axis[0] = 1. ;                       // define rotating axis as x
        rot_axis[1] = rot_axis[2] = 0. ;
        theta = PI ;                             // rotation angle, 180 degree
        MArotmx(&msg, rot_axis, &theta, m4x4) ;       // get rotation matrix
        BStrfrhommx(m4x4, mat, vector, &scale, &rc) ; // extract mat from m4x4
	if( rc != BSSUCC ) {
		printf("BStrfrhommx() failed\n");
		goto wrapup ;
	}
    
        // set translation vector
        for( i = 0; i < 3; i++) {
          vector[i] = - CV2->pts[0][i] ;
        }

        // rotate points 180 degree about x axis
        for( i = 0; i < num_pts; i++ ) {
           BSptoldtnw( &rc, vector, mat, &scale, CV2->pts[i], pts[i] ) ;
	   if( rc != BSSUCC ) {
		printf("BSptoldtnw() failed\n");
		goto wrapup ;
	   }
        }

        overlap = VSlikePtsEq( CV1->pts, pts, num_pts, bs_tol ) ;
        if( CV1->crv->phy_closed ) {
          goto wrapup ;
        }
    }

    if( overlap ) { 
       goto wrapup ;
    }
    else {

        BSalloccv(CV2->crv->order,
                  CV2->crv->num_poles,
                  CV2->crv->rational,
                  CV2->crv->num_boundaries,
                  &curve,
                  &rc) ;
	if( rc != BSSUCC || curve == NULL ) {
		printf("BSalloccv() failed\n");
		goto wrapup ;
	}

        BScv_copy(&rc, CV2->crv, curve) ; // return boolean
	if( rc != BSSUCC || curve == NULL ) {
		printf("BScv_copy() failed\n");
		goto wrapup ;
	}

        BSrev_cv(&rc, curve) ;            // return boolean
	if( rc != BSSUCC ) {
		printf("BSrev_cv() failed\n");
		goto wrapup ;
	}

        ret = VSlikeGetCrvSamplePts( pln,       // return void
                                     CV2->crv, 
                                     &num_pts,
                                     pts) ;

        // rotate points 180 degree about y axis
        for( i = 0; i < num_pts; i++ ) {
           BSptoldtnw( &rc, vector, mat, &scale, pts[i], temp[i] ) ;
        }

        overlap = VSlikePtsEq( CV1->pts, temp, num_pts, bs_tol ) ;
    }
       
    if( overlap && (rc == BSSUCC) ) { 
       goto wrapup ;
    }
    else {
        rot_axis[0] = 1. ;                            // define rotating axis
        rot_axis[1] = rot_axis[2] = 0. ;
        theta = PI ;                                  // rotation angle
        MArotmx(&msg, rot_axis, &theta, m4x4) ;       // get rotation matrix
        BStrfrhommx(m4x4, mat, vector, &scale, &rc) ; // extract mat from m4x4

        for( i = 0; i < 3; i++) {
          vector[i] = -temp[0][i] ;
        }

        // rotate points 180 degree about x axis
        for( i = 0; i < num_pts; i++ ) {
           BSptoldtnw( &rc, vector, mat, &scale, temp[i], pts[i] ) ;
        }

        overlap = VSlikePtsEq( CV1->pts, pts, num_pts, bs_tol ) ;
    }

    End

  wrapup:

    if( curve != NULL ) { BSfreecv( &rc, curve ); }

    return overlap ;
}

/*----------------------------------------------------------------
 * reverse the order of edges e2 and then compare it to e1
 */
IGRboolean FurtherComp( TVSlikeEdges *e1, TVSlikeEdges *e2, TGRplane *pln) {
  TVSlikeEdges edg;
  IGRint       i, j, k, num_e, num_p;
  BSrc         rc;

  num_e = e2->count ;
  edg.count = num_e ;
  for( i = 0; i < num_e; i++ ) {
    k = (num_e-i)%num_e ;
    edg.angl[i] = e2->angl[(num_e-i+1)%num_e] ;
    edg.edge[i].crvlen = e2->edge[k].crvlen ;
    edg.edge[i].num_pts = e2->edge[k].num_pts ;

    BSalloccv(e2->edge[k].crv->order,
              e2->edge[k].crv->num_poles,
              e2->edge[k].crv->rational,
              e2->edge[k].crv->num_boundaries,
              &edg.edge[i].crv,
              &rc) ;

    BScv_copy(&rc, e2->edge[k].crv, edg.edge[i].crv) ; // return boolean

    BSrev_cv(&rc, edg.edge[i].crv) ;                   // return boolean

    VSlikeGetCrvSamplePts( pln, 
                           edg.edge[i].crv,
                           &edg.edge[i].num_pts,
                           edg.edge[i].pts ) ;

    BSfreecv(&rc, edg.edge[i].crv);
  }

  return VSlikeEdgeEqual( e1, &edg ) ;
}

/*--------------------------------------------------------------
 *  Process piece like, suppose sorting has been performed.
 */

IGRstat VSlikeCMD_PieceLike(TVSlikeInfo *info)
{
  IGRstat        retFlag = 0 ;
  IGRint         like, i, j, k, CNT, first, last, endp, num;
  IGRdouble      pts[6] ;
  TVSlikePiece   *sample, *piece ;
  TGRplane        pln ;
  
  SetProc( VSlikeCMD_PieceLike ); Begin

  pln.point = &pts[0];
  pln.normal = &pts[3];

  CNT = info->pieceCNT ;
  if( CNT == 0 ) {
	printf("No parts found or failed to get info\n");
	goto wrapup ;
  }

  like = 0 ;

  //  find first and last beam positions in the list
  first = 0;
  while(first < CNT && strcmp( info->pieceLIKEs[first].category, "beam") != 0)
     first++ ;

  last = first ;
  while(last < CNT && strcmp( info->pieceLIKEs[last].category, "beam" ) == 0)
     last++ ;

  if( first >= CNT || last > CNT || first > last ) {
	retFlag = 1 ;	// added by ylong, 12/06/99
	__DBGpr_com("No beams or what ...");
	goto plate ;
  }

  //  perform beam piece like 
  i = first ;
  while( i < last ) 
  {
    if(info->pieceLIKEs[i].pieceLike < 0) 
    {
      sample = &info->pieceLIKEs[i] ;
      sample->pieceLike = like ;

      #ifdef DEBUG1
      printf("Sample: ");
      vdobj$Print(objOE = &sample->pieceOE);
      #endif

      j = i + 1 ;
      while(j < last && VSlikePieceEqual(sample, &info->pieceLIKEs[j])) {
        j++;
      }
      endp = j - 1;
      if( endp > i )
      {
        for( j = i + 1; j <= endp; j++ ) {
          if(info->pieceLIKEs[j].pieceLike < 0) {

            #ifdef DEBUG1
            printf("Compared piece: ");
            vdobj$Print(objOE = &info->pieceLIKEs[j].pieceOE);
            #endif

            for( k = 0; k < 3; k++ ) {
              pln.point[k]  = info->pieceLIKEs[j].planePoint[k];
              pln.normal[k] = info->pieceLIKEs[j].planeNormal[k];
            }
            if(VSlikeCrvEqual(&sample->beamCL,
                              &info->pieceLIKEs[j].beamCL, &pln)) {
               info->pieceLIKEs[j].pieceLike = like ;
            }
          }
        }
      }

      like++ ;
    }
    i++ ;
  }

  //  find first and last plate positions in the list
  plate:
  first = 0;
  while(first < CNT && strcmp( info->pieceLIKEs[first].category, "plate") != 0)
     first++ ;

  last = first ;
  while(last < CNT && strcmp( info->pieceLIKEs[last].category, "plate" ) == 0)
     last++ ;

  if( first >= CNT || last > CNT || first > last ) {
	retFlag = 1 ;		// added by ylong, 12/06/99
	__DBGpr_com("No plates or what...");
	goto wrapup ;
  }

  //  perform plate piece like 
  i = first ;
  while( i < last ) {
    #ifdef DEBUG1
    printf("Sample: "); vdobj$Print(objOE = &info->pieceLIKEs[i].pieceOE);
    #endif
    if(info->pieceLIKEs[i].pieceLike < 0) {
      sample = &info->pieceLIKEs[i] ;
      sample->pieceLike = like ;
      j = i + 1;
      while(j < last && VSlikePieceEqual(sample, &info->pieceLIKEs[j])) {
        j++;
      }
      endp = j - 1;

      if( endp > i ) {
        VSlikeGetNeatEdges( sample ) ;
        for( j = i + 1; j <= endp; j++ ) {
          piece = &info->pieceLIKEs[j] ;
          if( piece->pieceLike < 0 ) {
            #ifdef DEBUG1
            printf("Compared piece: ");
            vdobj$Print(objOE = &info->pieceLIKEs[j].pieceOE);
            #endif
            VSlikeGetNeatEdges( piece ) ;

            if( VSlikeEdgeEqual( &sample->edges, &piece->edges ) ) {
              piece->pieceLike = like ;
              goto loop_continue;
            }

            for( k = 0; k < 3; k++ ) {
              pln.point[k]  = piece->planePoint[k];
              pln.normal[k] = -piece->planeNormal[k];
            }
            num = piece->edges.count;
            for( k = 0; k < num; k++ ) {
              VSlikeGetCrvSamplePts( &pln, 
                                     piece->edges.edge[k].crv,
                                     &piece->edges.edge[k].num_pts,
                                     piece->edges.edge[k].pts ) ;
            }
            if( VSlikeEdgeEqual( &sample->edges, &piece->edges ) ) {
              piece->pieceLike = like ;
              goto loop_continue;
            }

            for( k = 0; k < 3; k++ ) {
              pln.normal[k] = piece->planeNormal[k];
            }
            if( FurtherComp( &sample->edges, &piece->edges, &pln) ) {
               piece->pieceLike = like ;
               goto loop_continue;
            }

            for( k = 0; k < 3; k++ ) {
              pln.normal[k] = -piece->planeNormal[k];
            }
            if( FurtherComp( &sample->edges, &piece->edges, &pln) ) {
               piece->pieceLike = like ;
            }
          }   // if( pieceLike < 0 )
          loop_continue:
          continue;
        }     // for(j)
      }       // if( endp > i )

      like++ ;
    }
    i++ ;
  }

  retFlag = 1 ;

  wrapup:
  End
  return retFlag ;
}


/* ---------------------------------------------------------
 * sorting fuction by using qsort
 */
IGRstat  VSlikeCMD_Sorting( TVSlikeInfo *info )
{
    IGRstat		ret = 0 ;
    IGRint		i;
    TVSlikePiece	*p;

    SetProc( VSlikeCMD_Sorting ); Begin

    // get attributes from parts
    ret = VSlikeCMD_GetAttributes( info ) ;
    if ( !ret ) {
	__DBGpr_com("VSlikeCMD_GetAttributes failed");
    }

    // pre-sorting for existing parameter values
    qsort( (char *)(info->pieceLIKEs),
           info->pieceCNT, 
           sizeof(TVSlikePiece), 
           (int (*)())VSlikeCMD_PieceCmp );

    // perform geometric comparisons for beams and plates
    ret = VSlikeCMD_PieceLike( info ) ;
    if( !ret ) {
	__DBGpr_com("VSlikeCMD_PieceLike failed");
    }

    // post-sorting based on like mark
    qsort( (char *)(info->pieceLIKEs),
           info->pieceCNT,
           sizeof(TVSlikePiece),
           (int (*)())VSlikeCMD_LikeSort );

    End
    return ret ;
}

/*
 *  determine if two point arrays, pts1 and pts2, are equal within tollerance
 */
IGRboolean VSlikePtsEq( IGRpoint    *pts1,
                        IGRpoint    *pts2,
                        IGRint      num_pts,
                        IGRdouble   tol)
{

  IGRdouble        dist;
  IGRint           i;
  IGRlong          msg ;
  IGRboolean       ret ;

  for (i = 0; i < num_pts; ++i)
  {
    ret = MA2ptdis( &msg , pts1[i] , pts2[i] , &dist );
    if ( !ret || dist > tol)
    {
      ret = FALSE ;
      goto wrapup ;
    }
  }

wrapup:
    return ret ;
}
 
/* Added by Ming for like-part */
/* --------------------------------------------
** Store piece info.
*/
IGRstat VSlikePart_StoreInfo( IGRint      pieceCNT,
                              TGRobj_env  *pieceOEs,
                              TVSlikeInfo *info )
{
  IGRstat     retFlag;
  IGRint      i;


  SetProc( VSlikePart_StoreInfo ); Begin

  retFlag = 0;

  if( pieceCNT == 0 || pieceOEs == NULL || info == NULL ) goto wrapup;

  info->pieceCNT   = pieceCNT;
  info->pieceLIKEs = _CALLOC( pieceCNT, TVSlikePiece );
  if ( info->pieceLIKEs == NULL )
  {
    printf("Unable to allocate memory for like pieces\n");
    goto wrapup;
  }

  for( i = 0 ; i < pieceCNT ; i++ )
    info->pieceLIKEs[i].pieceOE = pieceOEs[i];

  retFlag = 1 ;

wrapup:
  End
  return retFlag;
} /* VSlikePart_StoreInfo */


/* --------------------------------------
 * Misc stuff
 */
#argsused
IGRstat VSlikeCMD_Init(TVSlikeInfo *info)
{
  IGRint retFlag = 0;
  IGRint msg,sts;
  IGRint i;
  
  dp$erase_hilite(msg = &msg);
  memset(info,0,sizeof(TVSlikeInfo));

  sts = gr$get_module_env(buffer = &info->env);
  if (!(sts & 1)) goto wrapup;

  retFlag = 1;

wrapup:
  return retFlag;
}

#argsused
IGRstat VSlikeCMD_Sleep(TVSlikeInfo *info)
{
  IGRint msg;
  dp$erase_hilite(msg = &msg);
  return 1;
}

#argsused
IGRstat VSlikeCMD_Wakeup(TVSlikeInfo *info)
{
  //VDsupCMDEtcNotifyHiLite(info,1);
  return 1;
}

#argsused
IGRstat VSlikeCMD_Delete(TVSlikeInfo *info)
{
  IGRint msg;
  dp$erase_hilite(msg = &msg);

  _FREE(info->pieceLIKEs);
  
  return 1;
}

/* ----------------------------------------------------
 * List of locate classes
 * Limit to just source stiffeners for now
 * Deal with boolean stiffeners later
 */
static VDclassid classListIDs[8];

IGRstat VSlikeCMD_GetClassList(OM_S_CLASSLIST *classList)
{
  IGRstat retFlag = 0;

  om$get_classid(classname = "VSbeam",
		 p_classid = &classListIDs[0]);

  om$get_classid(classname = "VSplate",
		 p_classid = &classListIDs[1]);


  classList->p_classes = classListIDs;
  classList->w_count = 2;
  classList->w_flags = OM_CLST_subclass;

  retFlag = 1;

  return retFlag;
}

end   implementation Root;
