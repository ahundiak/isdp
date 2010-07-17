/* $Id: VSpltopbotmp.I,v 1.4 2001/04/02 22:03:33 ramarao Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsplate/VSpltopbotmp.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VSpltopbotmp.I,v $
 * Revision 1.4  2001/04/02 22:03:33  ramarao
 * Fixed TR# 4985.
 *
 * Revision 1.3  2001/02/02 00:00:39  ramarao
 * BSmdistsfsf() checks against offset tolerance instead of 0.01
 *
 * Revision 1.2  2001/01/17 00:00:02  ramarao
 * *** empty log message ***
 *
# Revision 1.3  2000/10/24  14:53:46  pinnacle
# Replaced: struct/vsplate/VSpltopbotmp.I for:  by jpulapar for Service Pack
#
 # Revision 1.2  2000/06/30  15:53:16  pinnacle
 # Replaced: struct/vsplate/VSpltopbotmp.I for:  by rchennup for Service Pack
 #
 # Revision 1.1  2000/06/29  21:16:58  pinnacle
 # Created: struct/vsplate/VSpltopbotmp.I by rchennup for Service Pack
 #
 # Revision 1.2  2000/01/29  13:16:38  pinnacle
 # Replaced: vsplate/VSpltopbotmp.I for:  by impd252 for struct
 #
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 01/29/00  adz     179900956 Get the object surface to evaluate if planar.
 * 06/28/00  Jayadev offset surface is not always the last one in the list
 * 10/24/00  Jayadev TR179902138 - offset surface fix fine tuned
 * 04/02/01  RR	     TR# 4985
 ******************************************************************************/
class implementation VSplate ;

#include <stdio.h>
#include <string.h>
#include <math.h>

#include "VDgeom.h"
#include "VDsa.h"
#include "vspart.h"
#include "vsipthmacros.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "maidmx.h"
#include "bssfeval.h"
#include "bssfevaln.h"
#include "bsdotp.h"
#include "bsnorvec.h"
#include "bsmdarptsfo.h"

extern OMuword	OPP_EMSplane_class_id, OPP_VSbooPlate_class_id;

/* 
 * Find the plate offset surface by geometry checking
 * opposite surface normals is the base->offset surfaces criteria
 * Changed the algo to get quicker results. - RR TR# 4985.
 */
IGRboolean VScheckSolFaces(struct GRid 		plate,
			   struct GRid 		*bfList,
			   int         		bfCount,
			   struct GRmd_env 	*env,
			   int 	       		*index )
{
BSrc			rc;
IGRlong			sts, msg;
IGRint			i, numNormals;
IGRboolean		all_on_surf;
IGRdouble		plt_thk, parms[2], point[3], normal[3], ptI[3],
			bsdotp, testVec[3], offtol;
struct IGRbsp_surface   *srfGeom=NULL;

   sts = msg = MSFAIL;

   /*
    * Argument Check.
    */
   if((!bfList) || (bfCount == 0)) goto wrapup;

   parms[0] = 0.45;   parms[1] = 0.45;

   /*
    * First Surface is always base surface. Get its geometry.
    */
   sts = vs$get_normal( msg = &msg, sfId = &bfList[0], sfEnv = env,
			parm = parms, normal = normal );
   __CheckRC( sts, msg, "vs$get_normal", wrapup ) ;
   BSnorvec( &rc, normal );

   /*
    * Get point on the surface.
    */
   sts = vs$get_geometry( msg = &msg, grobjId = &bfList[0],
                          grobjEnv = env, geometry = &srfGeom );
   __CheckRC( sts, msg, "vs$get_geometry", wrapup ) ;

   BSsfeval( srfGeom, parms[0], parms[1], 0, (IGRpoint *) point, &rc ) ;
   if( BSERROR( rc ) ) vs$error( msg = &msg ) ;

   /*
    * Add thickness to the base surface normal.
    */
   vdsa$GetStruct( objID = &plate, name = VS_K_plThcknsAttr, dbl = &plt_thk );

   for( i=0; i<3; ++i )
      point[i] += ( normal[i] * plt_thk );

   /*
    * We need to check against the offset tolerance.
    */
   vdgeom$GetTolerance( offset = &offtol );

   /*
    * Check all surfaces from the other end.
    */
   for( i=(bfCount-1); i>0; --i )
   {
      /*
       * Get each surface geometry.
       */
      _FREE( srfGeom );
      sts = vs$get_geometry( msg = &msg, grobjId = &bfList[i],
                             grobjEnv = env, geometry = &srfGeom );
      __CheckRC( sts, msg, "vs$get_geometry", wrapup ) ;

      /*
       * Evaluate the normal and normalize it.
       */
      BSsfevaln( srfGeom, parms[0], parms[1], 1, &numNormals, 
		 ptI, (IGRvector *) testVec, &rc );
      if( BSERROR( rc ) ) vs$error( msg = &msg );

      BSnorvec( &rc, testVec );
      if( BSERROR( rc ) ) vs$error( msg = &msg );

      /*
       * Evaluate the dot product between base surface normal and the current
       * surface normal. If it is less than certain value, there is no need
       * to proceed further.
       */
      bsdotp = BSdotp( &rc, normal, testVec );
      if( BSERROR( rc ) ) vs$error( msg = &msg );

      if( fabs((fabs(bsdotp)-1.0)) > 0.01 ) continue;

      /*
       * Check if the check point really lies on the surface.
       */
      BSmdarptsfo( 1, (IGRpoint *)point, srfGeom, 2*offtol, FALSE, FALSE, FALSE,
		   FALSE, TRUE, NULL, NULL, NULL, NULL, &all_on_surf, &rc );
      if( BSERROR( rc ) ) vs$error( msg = &msg ) ;

      /*
       * If the check point lies on the surface, this is the index we are
       * looking for and goto wrapup.
       */
      if( all_on_surf )
      {
         *index = i;
         sts = MSSUCC;
         goto wrapup;
      }
   }

wrapup:
   _FREE( srfGeom );
   return sts;
}

method VStopBottomMapping( long *msg ; int count, index[2] ; GRname name[2] ) {
  
  
  long		sts ;		/* OM return code	*/
  VSsuppList	mySupport ;	/* My support objects	*/
  int		suppCount ;	/* Number of Supports	*/
  int		isPlanar ;	/* Check if planar	*/
  struct GRid	sub_cmp ;	/* Sub component of part*/
  struct GRid	myGRid ;	/* moi ... 		*/
  struct GRmd_env	modEnv ;
  VSixPath	rpath ;		/* Real Index path of sub-component */
  IGRboolean      retStat = 0 ;
  int             ii,stat,comp_count = 0,ind;
  struct GRid     result, *Comps = NULL ;
  
#define	BOT	0
#define TOP	1
  sub_cmp.objid = NULL_OBJID ;
  MAidmx( msg, modEnv._MATRIX ) ;
  modEnv._MATRIX_TYPE	= MAIDMX ;
  modEnv._MD_ID		= NULL_OBJID ;
  modEnv._MD_ID		= OM_Gw_current_OS ;
  /*
   * The indexing of component bottom or top surfaces in the general
   * solids DEPENDS upon the way the solid got generated, which are
   * different whether the support surface is planar or not.
   *
   *	TYPE		INDEX of BOTTOM SURF	INDEX of TOP SURF
   *	------------------------------------------------------------
   *	Planar		        1	              0
   *	------------------------------------------------------------
   *	Non-planar              0                   count-1
   *	------------------------------------------------------------
   */
  
  /*
   * Get the first face of the plate solid. This will be either the 
   * base or offset face of the plate. The face wilbe be sufficient
   * to determine if plate is planar or not.
   */
  myGRid.objid    = my_id ;
  myGRid.osnum    = OM_Gw_current_OS ;
  
  rpath.sz = 2 ;
  rpath.ls[0] = 0 ;
  rpath.ls[1] = 0 ;
  
  sts = vs$getCmpIdFromIpath(     msg             = msg,
				  owner           = &myGRid,
				  size            = rpath.sz,
				  ipath           = rpath.ls,
				  component       = &sub_cmp ) ;
  if( !( sts & *msg & 1 )){
    
    sts = om$send(msg	= message VSpart.VSgetSupports(
						       msg, &modEnv, &suppCount, mySupport ),
		  targetid= my_id ) ;
    if( suppCount ) sub_cmp = mySupport[0]._grid ;
  }
  
  isPlanar = FALSE ;
  if( !( sts & 1 & *msg ) ) {
    /*
     * Message failed: plate probably cannot get its support, eg.
     * if it is an output of a macro occurrence. Assume planarity:
     * this will be the case in most practical cases.
     */
    isPlanar = TRUE ;
  } else {
    isPlanar = vs$is_ancestry_valid(
				    object	= &sub_cmp,
				    classid	= OPP_EMSplane_class_id ) ;
    
    /*
     * Solid construction only test on EMSplane.
     *
     * Assuming that the plate is planar but not a EMSplane,
     * can be a criteria in which the solid construction will
     * switched. (adz: 01/29/99 )
     * if( !isPlanar ){
     *	isPlanar = vs$is_surface_planar(
     *				msg = msg,
     *				surfId	= &sub_cmp,
     *				surfEnv = &modEnv );
     * }
     */
  }
  
  strcpy( name[BOT], VS_K_plBotSfName ) ;
  strcpy( name[TOP], VS_K_plTopSfName ) ;
  
  if( isPlanar ) {
    index[BOT]	= 1 ;
    index[TOP]	= 0 ;
    /* USE TO BE THESE VALUES IN EMS 1.4.5 - and a few times in 2.0 ...
       index[BOT]	= 0 ;
       index[TOP]	= count - 1 ;
    */
  } else {
    if(vs$is_ancestry_valid(object	= &myGRid,
			    classid	= OPP_VSbooPlate_class_id )){
      
      sts = om$send(  msg     = message ACncpx.ACreturn_foot(
							     msg, VS_K_plGrCmpName, &result,
							     NULL, NULL ),
		      targetid= my_id ) ;
      
      if(!(sts&*msg&1)){
	sts = OM_W_ABORT;
	*msg = MSFAIL;
	return sts;
      }	
      stat = vs$get_components( msg = msg,
				grobjId    = &result,
				grobjEnv   = &modEnv,
				number     = &comp_count,
				components = &Comps );
      if( (!(sts&*msg&1))||(comp_count ==0) ){
	sts = OM_W_ABORT;
	*msg = MSFAIL;
	_FREE(Comps); Comps = NULL;
	return sts;
      }
      retStat = VScheckSolFaces(myGRid,Comps,comp_count,&modEnv,&ind);
      if(retStat)
      {
	index[BOT]	= 0 ;
	index[TOP]	= ind ;
      }
      else
      {
	  index[BOT]	= 0 ;
	  index[TOP]	= count - 1 ;
      }
    }
    else
      {
	index[BOT]	= 0 ;
	index[TOP]	= count - 1 ;
      }
  }
  
  *msg	= MSSUCC ;
  sts	= OM_S_SUCCESS ;
  _FREE(Comps); Comps = NULL;
  
  return sts ;
  
} /* method VStopBottomMapping */
/*----------------------------------------------------------------------------*/

end implementation VSplate ;

