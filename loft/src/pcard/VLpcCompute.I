/* $Id: VLpcCompute.I,v 1.12 2001/10/18 23:08:23 jayadev Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:        src/pcard/VLpcCompute.I
 *
 * Description: Definition compute function for profile card element.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLpcCompute.I,v $
 *      Revision 1.12  2001/10/18 23:08:23  jayadev
 *      fix for TR# MP5265
 *
 *      Revision 1.11  2001/10/17 22:48:39  jayadev
 *      fix for TR#5216
 *
 *      Revision 1.10  2001/03/12 21:03:51  ramarao
 *      Changes to accept ~~orientation1 && ~~orientation2.
 *
 *      Revision 1.9  2001/03/11 19:06:03  ramarao
 *      Fixed TR# 4805
 *
 *      Revision 1.8  2001/02/22 00:40:24  ramarao
 *      Fixed TR# 4460. Added GetStartPoint Function.
 *
 *      Revision 1.7  2001/02/20 01:05:27  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.6  2001/02/08 19:14:06  ramarao
 *      Fixed TR# 4448.
 *
 *      Revision 1.5  2001/01/28 18:38:36  ramarao
 *      Implemented CR# MP 4301 on Stiffner Automarking process.
 *
 *      Revision 1.2  2001/01/16 19:21:00  ramarao
 *      *** empty log message ***
 *
# Revision 1.9  2001/01/11  16:00:18  pinnacle
# Replaced: loft/src/pcard/VLpcCompute.I for:  by rchennup for Service Pack
#
# Revision 1.4  2000/12/14  20:28:08  pinnacle
# Replaced: loft/src/pcard/VLpcCompute.I for:  by rchennup for Service Pack
#
# Revision 1.2  2000/11/18  21:31:36  pinnacle
# Replaced: loft/src/pcard/VLpcCompute.I for:  by rchennup for Service Pack
#
# Revision 1.1  2000/10/14  19:46:50  pinnacle
# Created: loft/src/pcard/VLpcCompute.I by rchennup for Service Pack
#
# Revision 1.9  2000/03/28  16:25:02  pinnacle
# Replaced: src/pcard/VLpcCompute.I for:  by impd252 for loft
#
# Revision 1.8  2000/03/23  21:46:50  pinnacle
# Replaced: src/pcard/VLpcCompute.I for:  by impd252 for loft
#
# Revision 1.7  2000/03/21  14:33:14  pinnacle
# Replaced: src/pcard/VLpcCompute.I for:  by impd252 for loft
#
# Revision 1.6  2000/03/08  19:16:38  pinnacle
# Corrected the return codes in VLpcGetBeamLength()
#
# Revision 1.5  2000/03/03  21:02:54  pinnacle
# Added VLpcGetBeamLength().
#
 *
 * History:
 * MM/DD/YY   AUTHOR       DESCRIPTION
 * 04/05/94   LLC          File Creation.
 * 03/01/00   Rama Rao     Header Creation and Added getViewName function
 * 03/03/00   Rama Rao	   Added VLpcGetBeamLength() function to get the
 *			   production length of the beam.
 * 10/17/00   Jayadev      Added VLpcDoubleCutMacro() for TR# MP5216
 * 10/18/00   Jayadev      Fix for TR# MP5265
 *************************************************************************/

class implementation VLpcAbst;

#include <stdio.h>
#include "bserr.h"
#include "igrdef.h"
#include "igr.h"
#include "AS_status.h"
#include "grdpbmacros.h"
#include "vsdrwdef.h"
#include "vsdrw.h"
#include "vsdrwmacros.h"
#include "vsdrwapi.h"
#include "acrepdef.h"
#include "vsmiscmacros.h"
#include "vsdpb.h"
#include "vsslcdef.h"
#include "vsslc.h"
#include "vlsdldef.h"
#include "vlsdl.h"
#include "vlsdlmacros.h"
#include "vlpcdef.h"
#include "vlpc.h"
#include "vlpcmacros.h"
#include "vlmiscmacros.h"
#include "vlquerydef.h"
#include "stdlib.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "bstypes.h"
#include "bscrossp.h"
#include "bsdotp.h"
#include "bslenvec.h"
#include "bsarclen.h"
#include "vsbeamdef.h"
#include "vldbgmacros.h"

#define vsDEBUG 	1
#define vserrDEBUG	1

extern	GRclassid	OPP_ACncpx_class_id, OPP_ACdyn_col_class_id,
			OPP_VSsrcBeam_class_id, OPP_VSstfBeam_class_id;

from    VSfeature       import  VSforwardToSource;
from	VSbeam		import	VSextractProfile, VSgetSupportAxis,
				VSgetSegmentEnds;
from	GRgencs		import	GRgetmatrix;
from    GRcurve		import	GRtotlength;
from	ACrg_collect	import	ACadd_list_attribute;
from	ACrg_collect	import	ACmod_list_attribute;
from	ACrg_collect	import	ACget_named_attribute;

extern  IGRdouble VLgetFootValue(), VLgetMacrosAtStep();
extern            VLbrowseFctInTree();
extern  int       VLgetStepInfo();

extern  int	isWebRight;

#define VLPC_NO_LAB	-1.0

static IGRlong  VLpcGetSrcBeamLength( IGRlong              *msg,
                                      struct GRobj_env     *beam,
                                      IGRdouble            *length    )
{
  IGRlong			sts;
  struct GRobj_env 	        axis ;         /* Support axis */
  
  SetProc( VLpcGetBeamLength ); Begin
				  
  sts = *msg = MSSUCC;
  axis._objid = NULL_OBJID;
  *length = 0;

  axis.mod_env = beam->mod_env;
  sts = VSgetFinalBeamCentroidalAxis ( msg,
				       beam->_grid,
				       &beam->mod_env,
				       &axis.mod_env,
				       &axis._grid );
  __CheckRC( sts, *msg, "VSgetBeamCentroidalAxis", wrapup ) ;
  
  sts = om$send(  msg      = message GRcurve.GRtotlength(
                                             msg,
                                             &axis._matrix_type,
                                             axis._matrix,
                                             length ),
		  senderid= axis._objid,
		  targetid= axis._objid,
		  targetos= axis._osnum ) ;
  __CheckRC( sts, *msg, "GRcurve.GRtotlength", wrapup ) ;
  __DBGpr_dbl("Returning Beam Length", *length ); 
  
 wrapup:
  if( axis._objid != NULL_OBJID )
    vs$bulk_delete( objenvs = &axis );
  
  End
    return sts;
}

IGRlong VLpcGetETLengths( IGRint      nb_mac,  
                          VLmacInfo   *sortList, 
			  IGRdouble   *end_ln1, 
                          IGRdouble   *end_ln2 )
{
  IGRlong   	sts, msg;
  GRname        cmdType;
  struct GRid	foot;

  if( (nb_mac<1) || !sortList || !end_ln1 || !end_ln2 ) return MSSUCC;
  
  *end_ln1 = *end_ln2 = 0.0;
  
  cmdType[0] = '\0';
  sts = VLgetOperName( NULL, &(sortList[0].mac->obj_id),
		       VLPC_DEF_ATT_CMD, cmdType );
  if( (sts&1) && (! strcmp( VLPC_END_TREAT_CMD, cmdType )) )
  {
    sts = vl$return_foot ( msg     = &msg,
			   name    = "et_output",
			   objId   = &sortList[0].mac->obj_id,
			   footId  = &foot );
    if( !(sts&msg&1) )
    {
      sts = vl$return_foot ( msg     = &msg,
			     name    = "et_output1",
			     objId   = &sortList[0].mac->obj_id,
			     footId  = &foot );
    }
    if( (sts&msg&1) )  *end_ln1 = VLgetFootValue ( &foot, "xbase" );
  }
  
  if( nb_mac < 2 ) return MSSUCC;
  
  cmdType[0] = '\0';
  sts = VLgetOperName( NULL, &(sortList[0].mac->obj_id),
		       VLPC_DEF_ATT_CMD, cmdType );
  if( (sts&1) && (! strcmp( VLPC_END_TREAT_CMD, cmdType )) )
  {
    sts = vl$return_foot ( msg     = &msg,
			   name    = "et_output",
			   objId   = &sortList[nb_mac-1].mac->obj_id,
			   footId  = &foot );
    if( !(sts&msg&1) )
    {
      sts = vl$return_foot ( msg     = &msg,
			     name    = "et_output1",
			     objId   = &sortList[nb_mac-1].mac->obj_id,
			     footId  = &foot );
    }
    if( (sts&msg&1) )  *end_ln2 = VLgetFootValue ( &foot, "xbase" );
  }
  return  MSSUCC;
}

static IGRlong	VLpcGetBooBeamLength( IGRlong		*msg,
			   	      struct GRobj_env	*beam,
				      IGRint 		nb_mac, 
				      VLmacInfo 	*sortList,
				      IGRdouble		*length    )
{
  BSrc			  rc;
  struct GRobj_env        *stepList = NULL;
  short                   topProp = VL_Q_TOP_SOURCE;
  struct GRmd_env         loc_env;
  IGRint		  suc, four=4, nbStep;
  IGRlong		  sts, notUsed;
  IGRboolean		  is_et1, is_et2, stat;
  IGRdouble       	  loc_length, mid, x_base1, x_base2, 
                          pt[3], pt1[3], pt2[3], cs_mat[16], mat[16];
  IGRpoint        	  endpt[2];   /* End points of beam   */
  IGRchar		  footName[100];
  GRname		  cmdType;
  struct GRparms          parm[2];
  struct GRobj_env 	  axis, cs_id;
  struct ret_struct       st;
  struct  IGRbsp_curve    *axis_geom;
 
  SetProc( VLpcGetBeamLength ); Begin

  sts = *msg = MSSUCC;
  *length = 0.0;
  is_et1 = is_et2 = FALSE; x_base1 = 0.0; x_base2 = 0.0;
  axis_geom = NULL;
  parm[0].u = 0.0; parm[1].u = 1.0; loc_length = 0.0;
  nbStep    = 0;
  
  __DBGpr_obj("Beam ", beam->obj_id );
  __DBGpr_int("Number of Macros ", nb_mac );
  if( nb_mac < 2 || !sortList ) goto get_struct_length;
  
  __DBGpr_obj("First Macro ", sortList[0].mac->obj_id );
  __DBGpr_obj("Last Macro ", sortList[nb_mac-1].mac->obj_id );
  
  gr$get_module_env( buffer = &loc_env );
  // Query stiffener steps History
  VLbrowseFctInTree( beam, topProp, NULL,
		     VL_Q_DOWN_DIRECT,
		     VLgetStepInfo,
		     &nbStep, &stepList, &loc_env );
  if(nbStep == 0)
  {
    __DBGpr_com("VLbrowseFctInTree : VLgetStepInfo() failed ");
  }
  __DBGpr_int("nbStep ",nbStep);
  
  cmdType[0] = '\0';
  sts = VLgetOperName( NULL, &(sortList[0].mac->obj_id),
		       VLPC_DEF_ATT_CMD, cmdType );
  if( (sts&1) && (! strcmp( VLPC_END_TREAT_CMD, cmdType )) )
  {
    __DBGpr_com("First macro is an End-Treatment macro ");
    
    sts = VLgetOperName( "", &sortList[0].mac->obj_id,
			 "~~orientation", footName );
    
    if( !(sts&1) )
      sts = VLpcDoubleCutMacro(msg, &sortList[0].mac->obj_id,
			       stepList, nbStep, footName);
    if( !(sts&1) )
      sts = VLgetOperName( "", &sortList[0].mac->obj_id,
			   "~~orientation1", footName );
    if( !(sts&1) )
      sts = VLgetOperName( "", &sortList[0].mac->obj_id,
			   "~~orientation2", footName );
    
    sts = vl$return_foot( msg     = msg,
			  name    = footName,
			  objId   = &sortList[0].mac->obj_id,
			  footId  = &cs_id.obj_id,
			  footEnv = &cs_id.mod_env );
    __CheckRC( sts, *msg,"vl$return_foot:cs", get_struct_length );
    __DBGpr_obj("CS object for ET1", cs_id.obj_id );
    is_et1 = TRUE;
    // get cs matrix
    sts = om$send(  msg      = message GRgencs.GRgetmatrix
		                               ( msg, mat ),
		    senderid = NULL_OBJID,
		    targetid = cs_id._objid,
		    targetos = cs_id._osnum );
    __CheckRC(sts, *msg,"GRgencs.GRgetmatrix:First", get_struct_length );
    if( cs_id._matrix_type != MAIDMX )
    {
      MAmulmx( msg, &four, &four, &four, cs_id._matrix, mat, cs_mat );
    }
    else dblcpy ( cs_mat, mat, 16 );
    
    // Store the origin as point1
    pt1[0] = cs_mat[3]; pt1[1] = cs_mat[7]; pt1[2] = cs_mat[11] ;
    __DBGpr_vec("First Macro Origin ", pt1 );
    if( nb_mac == 1 ) goto skip_second_et_check;
  }
  else __DBGpr_com("First macro is NOT an End-Treatment macro ");
  
  cmdType[0] = '\0';
  sts = VLgetOperName( NULL, &(sortList[nb_mac-1].mac->obj_id),
		       VLPC_DEF_ATT_CMD, cmdType );
  if( (sts&1) && (! strcmp( VLPC_END_TREAT_CMD, cmdType )) )
  {
    __DBGpr_com("Last macro is an End-Treatment macro ");
    
    sts = VLgetOperName( "", &sortList[nb_mac-1].mac->obj_id,
			 "~~orientation", footName );
    if( !(sts&1) )
      sts = VLpcDoubleCutMacro(msg, &sortList[nb_mac-1].mac->obj_id,
			       stepList, nbStep, footName);
    if( !(sts&1) )
      sts = VLgetOperName( "", &sortList[nb_mac-1].mac->obj_id,
			   "~~orientation1", footName );
    if( !(sts&1) )
      sts = VLgetOperName( "", &sortList[nb_mac-1].mac->obj_id,
			   "~~orientation2", footName );
    
    sts = vl$return_foot( msg     = msg,
			  name    = footName,
			  objId   = &sortList[nb_mac-1].mac->obj_id,
			  footId  = &cs_id.obj_id,
			  footEnv = &cs_id.mod_env  );
    __CheckRC( sts, *msg,"vl$return_foot:cs", get_struct_length );
    __DBGpr_obj("CS object for ET1", cs_id.obj_id );
    is_et2 = TRUE;
    // get cs matrix
    sts = om$send(  msg      = message GRgencs.GRgetmatrix
		                               ( msg, mat ),
		    senderid = NULL_OBJID,
		    targetid = cs_id._objid,
		    targetos = cs_id._osnum );
    __CheckRC( sts, *msg,"GRgencs.GRgetmatrix:Last", get_struct_length );
    if( cs_id._matrix_type != MAIDMX )
    {
      MAmulmx( msg, &four, &four, &four, cs_id._matrix, mat, cs_mat );
    }
    else dblcpy ( cs_mat, mat, 16 );
    
    // Store the origin as point2
    pt2[0] = cs_mat[3]; pt2[1] = cs_mat[7]; pt2[2] = cs_mat[11] ;
    __DBGpr_vec("Second Macro Origin ", pt2 ); 
  }
  else __DBGpr_com("Last macro is NOT an End-Treatment macro ");
  
 skip_second_et_check:
  if( is_et1 == FALSE && is_et2 == FALSE ) 
  {
    __DBGpr_com("There are NO end-treatments. Going to struct length");
    goto get_struct_length;
  }
  
  sts = om$send(  msg = message VSbeam.VSgetSegmentEnds(
                                       msg, &beam->mod_env, endpt ),
		  senderid = NULL_OBJID,
		  targetid = beam->_objid,
		  targetos = beam->_osnum  );
  __CheckRC( sts, *msg, "VSbeam.VSgetSegmentEnds", get_struct_length ) ;
  __DBGpr_vec("VSbeam.VSgetSegmentEnds, Start Point ", endpt[0] );
  __DBGpr_vec("VSbeam.VSgetSegmentEnds, End Point ", endpt[1] );
  
  if( is_et1 )
  {
    if( BSdistptpt(&rc,endpt[0],pt1 ) > BSdistptpt(&rc,endpt[1],pt1 ))
    {
      /* Switch the ends */
      __DBGpr_com( "Switching Beam End Points" );
      dblcpy( pt, endpt[0], 3 );
      dblcpy( endpt[0], endpt[1], 3 );
      dblcpy( endpt[1], pt,3 );
    }
  }
  else if( is_et2 )
  {
    if( BSdistptpt(&rc,endpt[1],pt2 ) > BSdistptpt(&rc,endpt[0],pt2 ))
    {
      /* Switch the ends */
      __DBGpr_com( "Switching Beam End Points" );
      dblcpy( pt, endpt[1], 3 );
      dblcpy( endpt[1], endpt[0], 3 );
      dblcpy( endpt[0], pt,3 );
    }
  }
  
  __DBGpr_com("Getting the Beam Support Axis");
  sts = om$send(  msg = message VSfeature.VSforwardToSource(
                                          &notUsed,
                                          OM_e_wrt_object,
                        message VSbeam.VSgetSupportAxis(
                                       msg,
                                       &beam->mod_env,
                                       &axis )) ,
		  senderid = NULL_OBJID,
		  targetid = beam->_objid,
		  targetos = beam->_osnum  );
  __CheckRC( sts, *msg, "VSbeam.VSgetSupportAxis", get_struct_length ) ;
  __DBGpr_obj("Beam Axis ", axis.obj_id );
  
  if( !is_et1 )  dblcpy( pt1, endpt[0], 3 );
  else if( nb_mac == 1 )
  {
    __DBGpr_com("Checking which end is closest to the ET");
    if( BSdistptpt(&rc,endpt[0],pt1 ) > BSdistptpt(&rc,endpt[1],pt1 ))
    {
      __DBGpr_com("ET is closest to parameter 1.0, Switch the points");
      dblcpy( pt2, pt1, 3 );
      dblcpy( pt1, endpt[0], 3 );
    }
    else
    {
      dblcpy( pt2, endpt[1], 3 );
    }
  }
  
  sts = om$send(  msg      = message GRgraphics.GRptproject(
					msg, &axis._matrix_type, axis._matrix,
					pt1,
					pt,
					&parm[0] ),
		  senderid = NULL_OBJID,
		  targetid = axis._objid,
		  targetos = axis._osnum );
  __CheckRC( sts, *msg, "GRgraphics.GRptproject:ET1", get_struct_length );
  __DBGpr_dbl("Parameter at end-treatment 1", parm[0].u );
  __DBGpr_vec("Point at end-treatment 1", pt );
  
  if( (nb_mac>1)  && !is_et2 ) dblcpy( pt2, endpt[1], 3 );
  sts = om$send(  msg      = message GRgraphics.GRptproject(
                                        msg, &axis._matrix_type, axis._matrix,
                                        pt2,
                                        pt,
                                        &parm[1] ),
		  senderid = NULL_OBJID,
		  targetid = axis._objid,
		  targetos = axis._osnum );
  __CheckRC( sts, *msg, "GRgraphics.GRptproject:ET2", get_struct_length );
  __DBGpr_dbl("Parameter at end-treatment 2", parm[1].u );
  __DBGpr_vec("Point at end-treatment 2", pt );
  
  // compute length
  sts = om$send(  msg      = message GRvg.GRgenabsg(
                                      msg, &axis._matrix_type, axis._matrix,
				      (IGRchar **) &axis_geom ),
		  senderid = NULL_OBJID,
		  targetid = axis._objid,
		  targetos = axis._osnum );
  __CheckRC( sts, *msg, "GRvg.GRgenabsg: Axis ", get_struct_length );
  
  //VDdumpCurve( NULL, axis_geom, "/usr2/pcard/constr/axis_geom");
  
  mid = (parm[0].u + parm[1].u) / 2;
  __DBGpr_dbl("Mid Parameter ", mid );
  
  sts = BSarclen( &rc, &stat, axis_geom, &parm[0].u, &parm[1].u,
		  &mid, &loc_length );
  if( rc != BSSUCC )
  {
    __DBGpr_com("BSarclen FAILED");
    goto get_struct_length;
  }
  __DBGpr_dbl("Chopped Stiffener Length ", loc_length );
  
  VLpcGetETLengths( nb_mac, sortList, &x_base1, &x_base2 );
  __DBGpr_dbl("X base 1 ", x_base1 );
  __DBGpr_dbl("X base 2 ", x_base2 );
  
  *length = loc_length + x_base1 + x_base2 ;
  __DBGpr_dbl("Final Profile Length ", *length );
  
  sts = *msg = MSSUCC;
  goto wrapup;
  
 get_struct_length:
  __DBGpr_com("Getting the default struct length");
  // get struct beam length
  sts = om$send(  msg      = message NDmacro.ACgive_structure(
                                                &suc,
                                                NULL,
                                                VS_K_bmLengthAttr,
                                                &st,
                                                &beam->mod_env ),
		  senderid = NULL_OBJID,
		  targetid = beam->obj_id.objid,
		  targetos = beam->obj_id.osnum );
  __CheckRC( sts, suc, "NDmacro.ACgive_structure:BeamLength", wrapup );
  
  *length = st.var.root_pm_st.value;
  __DBGpr_dbl("Beam Length ", *length );
  sts = *msg = MSSUCC;
 wrapup:
  if( stepList )  free( stepList );
  __DBGpr_dbl("Returning ", *length );
  End
    return sts;
}

static long  VLpcCheckSpecificETs( IGRlong              *msg,
                                   struct GRobj_env     *stiff,
                                   VLsInfoForMc         *stInfo,
                                   IGRint               *inp_macroCount,
                                   VLmacInfo            *inp_macroList,
                                   struct GRmd_env      *loc_env,
                                   IGRdouble            beam_length,
                                   IGRboolean           *is_both_et,
                                   IGRboolean           *is_start_generic,
                                   IGRboolean           *is_end_generic    )
{
  IGRlong                 sts;
  IGRint                  i, j, k, suc, nbMac=0, maxMac=0,
                          openMacCount=0, nbMacroToDelete=0, nbStep = 0;
  IGRdouble               xpos, minxpos, maxxpos, ptMc[3], proj[3];
  VStktxt                 macName, footName;
  struct ret_struct       st;
  struct GRid             ptMcId, startId, endId;
  struct GRparms          PJparm;
  struct GRobj_env        *locMacList=NULL, macroToDelete[100], *stepList = NULL;

  SetProc( VLpcCheckSpecificETs ); Begin
				     
  *is_both_et = *is_start_generic = *is_end_generic = FALSE;
  
  if( !inp_macroCount || !(*inp_macroCount) || !inp_macroList ) goto wrapup;
  
  VLbrowseFctInTree( stiff, VL_Q_TOP_SOURCE, NULL, VL_Q_DOWN_DIRECT,
		     VLgetMacrosAtStep, &nbMac, &locMacList, loc_env );
  maxMac = nbMac;
  __DBGpr_int("Total number of macros on the stiffener", maxMac );
  
  // Query stiffener steps History
  VLbrowseFctInTree( stiff, VL_Q_TOP_SOURCE, NULL, VL_Q_DOWN_DIRECT,
		     VLgetStepInfo, &nbStep, &stepList, loc_env );
  if(nbStep == 0)
  {
    __DBGpr_com("VLbrowseFctInTree : VLgetStepInfo() failed ");
  }
  __DBGpr_int("nbStep ",nbStep);
  VLpcGetBothETMacCount( &openMacCount );
  __DBGpr_int("Number of Macros which have both ETs", openMacCount );
  
  for( i=0; i<openMacCount; ++i )
  {
    nbMac = 0;
    VLpcGetBothETMac( i, macName );
    __DBGpr_str( "Checking for Macro", macName );
    
    VLfilterDef( maxMac, locMacList, &nbMac, macName );
    __DBGpr_int("Number of macros", nbMac );
    
    if( nbMac > 0 )
    {
      __DBGpr_com( "Found macro. Breaking ..." );
      *is_both_et = TRUE;
      break;
    }
  }
  
  VLpcGetOpenETMacCount( &openMacCount );
  __DBGpr_int("Number of Macros which have open ETs", openMacCount );
  
  if( openMacCount )
  {
    __DBGpr_int( "Input Macro Count", *inp_macroCount );
    if( isWebRight )
    {
      minxpos = inp_macroList[(*inp_macroCount)-1].xpos;
      maxxpos = inp_macroList[0].xpos;
      
      startId = inp_macroList[(*inp_macroCount)-1].mac->obj_id;
      endId   = inp_macroList[0].mac->obj_id;
    }
    else
    {
      minxpos = inp_macroList[0].xpos;
      maxxpos = inp_macroList[(*inp_macroCount)-1].xpos;
      
      startId = inp_macroList[0].mac->obj_id;
      endId   = inp_macroList[(*inp_macroCount)-1].mac->obj_id;
    }
    __DBGpr_dbl( "Start X Position", minxpos );
    __DBGpr_dbl( "End X Position", maxxpos );
    __DBGpr_obj( "Start Macro", startId );
    __DBGpr_obj( "End Macro", endId );
  }
  else goto wrapup;
  
  for( i=0; i<openMacCount; ++i )
  {
    nbMac = 0;
    if( *is_start_generic && *is_end_generic )  break;
    
    VLpcGetOpenETMac( i, macName );
    __DBGpr_str( "Checking for Macro", macName );
    
    VLfilterDef( maxMac, locMacList, &nbMac, macName );
    __DBGpr_int("Number of macros", nbMac );
    
    for( j=0; j<nbMac; ++j )
    {
      if( *is_start_generic && *is_end_generic )  break;
      __DBGpr_obj("Checking Macro", locMacList[j].obj_id );
      sts = VLgetOperName( "", &locMacList[j].obj_id,
			   "~~orientation", footName );
      if( !(sts&1) )
	sts = VLpcDoubleCutMacro(msg, &locMacList[j].obj_id,
				 stepList, nbStep, footName);
      if( !(sts&1) )
	sts = VLgetOperName( "", &locMacList[j].obj_id,
			     "~~orientation1", footName );
      if( !(sts&1) )
	sts = VLgetOperName( "", &locMacList[j].obj_id,
			     "~~orientation2", footName );
      if( !(sts&1) ) continue;
      __DBGpr_str("Foot Name", footName );
      
      sts = om$send( msg = message NDmacro.ACgive_structure(
	                   &suc, NULL, footName, &st, &locMacList[j].mod_env ),
		     senderid = NULL_OBJID,
		     targetid = locMacList[j].obj_id.objid,
		     targetos = locMacList[j].obj_id.osnum );
      if( !(sts&suc&1) ) continue;
      
      for( k=0; k<3; k++ )    ptMc[k] = st.var.ref_st.t[(k*4)+3];
      __DBGpr_vec("Macro Origin ", ptMc );
      
      sts = om$send ( msg      = message GRgraphics.GRptproject (
	                                msg,
                                        &loc_env->md_env.matrix_type,
                                        loc_env->md_env.matrix,
                                        ptMc, proj, &PJparm ),
		      senderid = NULL_OBJID,
		      targetid = stInfo->webLeft.obj_id.objid,
		      targetos = stInfo->webLeft.obj_id.osnum );
      if( sts&(*msg)&1 )
	for( k=0; k<3; k++ )    ptMc[k] = proj[k];
      __DBGpr_vec("After projecting onto web left, Macro Origin ", ptMc );
      
      VLplPt( &msg, ptMc, &ptMcId, loc_env );
      
      sts = VLlengthAlongCv( msg, &stInfo->nf, loc_env,
			     &stInfo->origin, loc_env,
			     &ptMcId, loc_env, &xpos );
      VD_bulkDeleteByGRids( loc_env, 1, &ptMcId );
      if( !(sts&(*msg)&1) ) continue;
      __DBGpr_dbl("Macro Position", xpos );
      
      macroToDelete[nbMacroToDelete++] = locMacList[j];
      
      if( (*inp_macroCount) > 0 )
      {
	if( xpos < minxpos )      *is_start_generic = TRUE;
	else if( xpos > maxxpos ) *is_end_generic   = TRUE;
      }
      else if( xpos < beam_length/2 )  *is_start_generic = TRUE;
      else                             *is_end_generic   = TRUE;
      
      if(  startId.objid == locMacList[j].obj_id.objid &&
	   startId.osnum == locMacList[j].obj_id.osnum )
	*is_start_generic = TRUE;
      
      else if( endId.objid == locMacList[j].obj_id.objid &&
	       endId.osnum == locMacList[j].obj_id.osnum )
	*is_end_generic   = TRUE;
    }
  }
  
    if( nbMacroToDelete )
    {
      k = 0;
      for( i=0; i<(*inp_macroCount); ++i )
      {
	for( j=0; j<nbMacroToDelete; ++j )
	{
	  if( ( inp_macroList[i].mac->obj_id.objid ==
		macroToDelete[j].obj_id.objid ) &&
	      ( inp_macroList[i].mac->obj_id.osnum ==
		macroToDelete[j].obj_id.osnum ) )
	    break;
	}
	if( j == nbMacroToDelete )
	{
          // copy the whole structure - TR# MP5265
	  inp_macroList[k] = inp_macroList[i] ;
	  *(inp_macroList[k].mac) = *(inp_macroList[i].mac);
	  ++k;
	}
      }
      *inp_macroCount = k;
      __DBGpr_int( "Output Macro Count", *inp_macroCount );
    }
    
    __DBGpr_int( "Start Generic Cutter? ", *is_start_generic );
    __DBGpr_int( "End Generic Cutter? ", *is_end_generic );
    
 wrapup:
    _FREE( locMacList );
    _FREE( stepList );
    End
      return sts;
}

/* --------------------- FCT VLgetCsStiff () --------------------------	*/
/* The left side when we look the web left will be choised
/*
* */

long VLgetCsStiff(	
	struct	GRobj_env *support,	/* I  : stiffener 		*/
	double	  	  *SecMat )	/* O  : Cs of Section		*/
					/*      XY define the plane of section */
{					/*	Z defines the stiffener */
  long		sts, msg;
  double	o0[3], X0[3], Y0[3], Z0[3], v[3];
  double	o1[3], X1[3], Y1[3], Z1[3];
  double	SecMat0[16], SecMat1[16];
  BSrc		rc;
  int		i,k;
  double	dotp;

  // get Section Cs at parameter 0
  sts = VSevalBeamCS( &msg, support, 0, VS_e_BOT_LEFT , SecMat0 ); 
  if( ! (sts&msg&1)){ sts = MSFAIL; goto wrapup; }
  for( i=0; i<3; i++ ){
    k=i*4;
    X0[i]	= SecMat0[k];
    Y0[i]	= SecMat0[k+1];
    o0[i]	= SecMat0[k+3];
  }
  BScrossp( &rc, X0, Y0, Z0 );
  
  // get Section Cs at parameter 1
  sts = VSevalBeamCS( &msg, support, 1, VS_e_BOT_LEFT, SecMat1 ); 
  if( ! (sts&msg&1)){ sts = MSFAIL; goto wrapup; }
  for( i=0; i<3; i++ ){
    k=i*4;
    X1[i]	= SecMat1[k];
    Y1[i]	= SecMat1[k+1];
    o1[i]	= SecMat1[k+3];
  }
  BScrossp( &rc, X1, Y1, Z1 );
  
  // create vector
  BSmkvec( &rc, v, o0, o1 );
  
  // compare vector direction
  dotp = BSdotp( &rc, v, Z0 );
  
  if( dotp > 0 ){
    // sect mat is SecMat0	Z0
    for( i=0; i<16; i++ ) SecMat[i] = SecMat0[i];
    SecMat[2]	= Z0[0];
    SecMat[6]	= Z0[1];
    SecMat[10]	= Z0[2];
    
  } else {
    // sect mat is SecMat1	Z1
    for( i=0; i<16; i++ ) SecMat[i] = SecMat1[i];
    SecMat[2]	= Z1[0];
    SecMat[6]	= Z1[1];
    SecMat[10]	= Z1[2];
  }

  //	sts = vl$plcs( mat = SecMat );
  
  sts = MSSUCC;
  
  wrapup :
    
    return	sts;
}

/* -------------------- FCT VLgetStiffPlane () ------------------------	*/
long VLgetStiffPlane( struct GRobj_env *support, 
                      double           *secMat, 
		      double           *plMat, 
                      short            *plType, 
                      int              *viewSide,
		      char             *planeName )
{
  long	        sts;
  int	        i, k;
  double	tmp1, tmp2;
  
  if( support ){
    sts = VLgetCsStiff( support, secMat ? secMat : plMat );
    if(! (sts&1))	goto wrapup;
  }
  if( secMat ) for(i=0;i<16;i++) plMat[i] = secMat[i];
  
  if( ! strcmp( planeName, VLPC_VIEW_SIDE )){
    
    // Rotate of - PI/2 around Y : X'=Z  Y'=Y   Z'=-X
    for( i=0; i<3; i++){
      k= i*4;
      tmp1 		= plMat[k];
      plMat[k]	= plMat[k+2];	
      plMat[k+2]	= -tmp1;
    }
    
    if( viewSide )	*viewSide = 1;
    
    //		sts = vl$plcs( mat = plMat );
    
  } else
    if( ! strcmp( planeName, VLPC_VIEW_BOTTOM )){
      
      // ==>  X' = Z; Y' = X; Z' = Y;
      for( i=0; i<3; i++ ){
	k = (i*4);
	tmp1 		= plMat[k];	// X
	plMat[k]	= plMat[k+2];	// X' = Z
	
	tmp2 		= plMat[k+1];	// Y
	plMat[k+1]	= tmp1;		// Y' = X
	plMat[k+2]	= tmp2;		// Z' = Y
      }
      
      if( viewSide )	*viewSide = -1;
      
    } else { 
      printf(" Error %s unknown view \n", planeName ); 
      sts = MSFAIL;
      goto	wrapup;
    }
  
  if( plType )	MAtypemx(&sts, plMat, plType);
  
  sts = MSSUCC;
  
  wrapup :
    
    return	sts;
}

/* --------------------- FCT VLgetStiffRange () -----------------------	*/

long VLgetStiffRange( 	struct GRobj_env *support, 
                        char             *viewName, 
			IGRint           nb_mac, 
                        VLmacInfo        *sortList, 
			double           *L, 
                        double           *W )
{
  long			sts, msg;
  char			widthPath[DI_PATH_MAX];
  int			suc;
  struct    ret_struct	st;

  /* Initialization */
  *L	= 0;
  *W	= 0;
  
  if( ! strcmp( viewName, VLPC_VIEW_SIDE ))
    strcpy( widthPath, VS_K_bmHeightAttr );
  else 
    if( ! strcmp( viewName, VLPC_VIEW_BOTTOM ))
      strcpy( widthPath, VS_K_bmWidthAttr );
    else {
      printf(" unknown view : %s\n", viewName );
      return	MSFAIL;
    }
  
  if( vs$is_ancestry_valid( object  = &support->obj_id,
			    classid = OPP_VSsrcBeam_class_id ) ||
      vs$is_ancestry_valid( object  = &support->obj_id,
			    classid = OPP_VSstfBeam_class_id ) )
  {
    sts = VLpcGetSrcBeamLength( &msg, support, L );
  }
  else
  {
    sts = VLpcGetBooBeamLength( &msg, support, nb_mac, sortList, L );
  }
  
  /*
  // get length
  sts = om$send( msg = message NDmacro.ACgive_structure(
                                       &suc,
                                       NULL,
                                       VS_K_bmLengthAttr,
                                       &st,
                                       &support->mod_env ),
		       senderid = NULL_OBJID,
                       targetid = support->obj_id.objid,
                       targetos = support->obj_id.osnum );
  as$status( sts = sts );
  as$status( sts = suc );
  if( ! (sts&suc&1))	return	MSFAIL;
  *L = st.var.root_pm_st.value;
  */
  if( ! *L ){	
    printf(" Warning : Can not acces to Beam length, approx with 10000\n");
    *L = 10000;
  }
  
  // get width
  sts = om$send(	msg	 = message NDmacro.ACgive_structure(
                                                &suc,
						NULL,
						widthPath,
						&st,
						&support->mod_env ),
			senderid = NULL_OBJID,
			targetid = support->obj_id.objid,
			targetos = support->obj_id.osnum );
  as$status( sts = sts );
  as$status( sts = suc );
  if( ! (sts&suc&1))	return	MSFAIL;
  *W = st.var.root_pm_st.value;
  if( ! *W ){	
    printf(" Warning : Can not acces to Beam width, approx with 100\n");
    *W = 100;
  }
  
  return	MSSUCC;
}

/* -------------------- FCT VLcvrtPtInLocCs () ------------------------	*/

long VLcvrtPtInLocCs(	struct GRobj_env *Cs,	    // i  : Identify Cs
			double	         *CsMat,    // io : needed if Cs is not 
						    //	    defined
			double	         *InvCsMat, // o  : inverse matrix
			struct GRobj_env *Pt,	    // i  : Identify Point
			double           *gloPt,    // io : needed if Pt is not 
						    //	    defined
			double           *locPt )   // O  : local coordinates of 
						    //	    point
{
  long			sts, msg;
  double		v2[4];
  short			four = 4;
  short			one  = 1;
  int			i;
  double	        myPt[4], myMat[16], myInvMat[16], newCs[16];
  double	        *ptrMat, *ptrInvMat, *ptrGloPt;
 
  ptrMat 	  = CsMat    ? CsMat    : myMat;
  ptrInvMat = InvCsMat ? InvCsMat : myInvMat;
  ptrGloPt  = gloPt    ? gloPt    : myPt;
  
  // get Matrix
  if( Cs ){
    sts = om$send(	msg	 = message GRgencs.GRgetmatrix
						( &msg, ptrMat ),
			targetid = Cs->obj_id.objid,
			targetos = Cs->obj_id.osnum,
			senderid = NULL_OBJID );
    if( ! (sts&msg&1)){ sts = MSFAIL; goto wrapup; }
    
    if( Cs->mod_env.md_env.matrix_type != MAIDMX ){
      MAmulmx(&msg, &four, &four, &four, 
	      Cs->mod_env.md_env.matrix, ptrMat, newCs );
      for( i=0; i<16; i++ )	ptrMat[i] = newCs[i];
    }
  } else if( ! CsMat )	return	MSFAIL;
  
  // get point
  if( Pt )
    sts = VLgetPtCoord( &msg, Pt->obj_id, &Pt->mod_env, ptrGloPt );
  else 
    if( ! gloPt )	return	MSFAIL;
  
  MAinvmx( &msg, &four, ptrMat, ptrInvMat );
  
  myPt[3] = 1.;
  if( gloPt )	for( i=0; i<3; i++ )	myPt[i] = ptrGloPt[i];
  MAmulmx(&msg, &four, &four, &one, ptrInvMat, myPt , v2);
  
  for(i=0; i<3; i++)	locPt[i] = v2[i];
  
  sts = MSSUCC;
  
  wrapup :
    
    return	sts;
}

/* --------------------- FCT VLvl_LoadKeyWords () ---------------------	*/
/*	Store in strudel the key words for loft 			*/
/*									*/

long	VLvl_LoadKeyWords()
{
  char			*K[VLSDL_MAX_IDX];
  VSdrwUsrTokType	U[VLSDL_MAX_IDX];
  VSdrwAction		A[VLSDL_MAX_IDX];
  int			idx;
  long			sts;
  
  DECLARE_FUNCTION( VL, setAttributeVal )
  DECLARE_FUNCTION( VL, getAttributeVal )
  DECLARE_FUNCTION( VL, openFile )
  DECLARE_FUNCTION( VL, print )
  DECLARE_FUNCTION( VL, repeatPattern )
  DECLARE_FUNCTION( VL, skip )
  DECLARE_FUNCTION( VL, sprintf )
  DECLARE_OUTPUT( VL, placeMacro )
    
	idx	= 0;	VLSDL_CHECK_IDX

	K[idx]		= VLSDL_SET_ATTR;
	U[idx] 		= VSdrwFUNCTION;
	A[idx].function	= FUNCTION_ADDRESS( VL, setAttributeVal );
	idx++;		VLSDL_CHECK_IDX

	K[idx]		= VLSDL_GET_ATTR;
	U[idx] 		= VSdrwFUNCTION;
	A[idx].function	= FUNCTION_ADDRESS( VL, getAttributeVal );
	idx++;		VLSDL_CHECK_IDX

	K[idx]		= VLSDL_PLMACRO;
	U[idx] 		= VSdrwOUTPUT;
	A[idx].output	= OUTPUT_ADDRESS( VL, placeMacro );
	idx++;		VLSDL_CHECK_IDX

	K[idx]		= VLSDL_F_FOPEN;
	U[idx] 		= VSdrwFUNCTION;
	A[idx].function	= FUNCTION_ADDRESS( VL, openFile );
	idx++;		VLSDL_CHECK_IDX

	K[idx]		= VLSDL_F_PRINT;
	U[idx] 		= VSdrwFUNCTION;
	A[idx].function	= FUNCTION_ADDRESS( VL, print );
	idx++;		VLSDL_CHECK_IDX

	K[idx]		= VLSDL_F_PATTERN;
	U[idx] 		= VSdrwFUNCTION;
	A[idx].function	= FUNCTION_ADDRESS( VL, repeatPattern );
	idx++;		VLSDL_CHECK_IDX

	K[idx]		= VLSDL_F_SKIP;
	U[idx] 		= VSdrwFUNCTION;
	A[idx].function	= FUNCTION_ADDRESS( VL, skip );
	idx++;		VLSDL_CHECK_IDX

	K[idx]		= VLSDL_F_SPRINTF;
	U[idx] 		= VSdrwFUNCTION;
	A[idx].function	= FUNCTION_ADDRESS( VL, sprintf );
	idx++;		VLSDL_CHECK_IDX

	VSdrwAddFunctions( idx, K, U, A );

	sts = MSSUCC;

wrapup :

return	sts;
}

/* --------------------- FCT VLvl_pc_LoadKeyWords () ------------------	*/
/*	Store in strudel environment the Key words for pc.		*/

long	VLvl_pc_LoadKeyWords()
{
char			*K[VLSDL_MAX_IDX];
VSdrwUsrTokType		U[VLSDL_MAX_IDX];
VSdrwAction		A[VLSDL_MAX_IDX];
int			idx;
long			sts;
DECLARE_ISOFTYPE( VL, userBlock )
DECLARE_ISOFTYPE( VL, refMarkBlock )
DECLARE_ISOFTYPE( VL, stfPcMark )
DECLARE_FUNCTION( VL, getMcDefAttribute )
DECLARE_FUNCTION( VL, macPosition )
DECLARE_FUNCTION( VL, macAngle )
DECLARE_FUNCTION( VL, macSide )
DECLARE_FUNCTION( VL, FirstEtPos )
DECLARE_FUNCTION( VL, InterEtsLen )
DECLARE_FUNCTION( VL, viewCs )
DECLARE_FUNCTION( VL, viewEndCs )
DECLARE_FUNCTION( VL, viewMacroCs )
DECLARE_FUNCTION( VL, getStiff )
DECLARE_FUNCTION( VL, getFoot )
DECLARE_FUNCTION( VL, rotateGraphic )
DECLARE_FUNCTION( VL, brAnchorPoint )
DECLARE_FUNCTION( VL, brInstPoint )
DECLARE_FUNCTION( VL, PCbrMember )
DECLARE_FUNCTION( VL, PCsetLabel )
DECLARE_FUNCTION( VL, PCgetLabelText )
DECLARE_FUNCTION( VL, PCgetLabelRef )
DECLARE_FUNCTION( VL, setLabelOrigin )
DECLARE_FUNCTION( VL, getLabelOrigin )
DECLARE_FUNCTION( VL, PCcvrtStrToDbl )
DECLARE_FUNCTION( VL, getViewName )
DECLARE_FUNCTION( VL, getMacroList )
DECLARE_FUNCTION( VL, getMacroPositions )
DECLARE_FUNCTION( VL, isCurvedBeam )
DECLARE_FUNCTION( VL, setBorder )
DECLARE_FUNCTION( VL, setWebRight )
DECLARE_FUNCTION( VL, pcTerminate )
DECLARE_FUNCTION( VL, pcSetExtremeDim )
DECLARE_FUNCTION( VL, pcSetMacBothET )
DECLARE_FUNCTION( VL, pcSetMacOpenET )
DECLARE_FUNCTION( VL, pcGetPlateThkDir )
DECLARE_FUNCTION( VL, pcGetXBase )
DECLARE_FUNCTION( VL, pcGetStartPoint )
DECLARE_OUTPUT( VL, vlProjection )
DECLARE_OUTPUT( VL, vlMember )
DECLARE_OUTPUT( VL, placeBendLines )
DECLARE_OUTPUT( VL, placeBendTable )

	VLvl_LoadKeyWords();

	idx	= 0;	VLSDL_CHECK_IDX

	K[idx]			= VLPC_START;
	U[idx] 			= VSdrwTYPE;
	A[idx].elmQuery		= ISOFTYPE_ADDRESS( VL, userBlock );
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VLPC_END;
	U[idx] 			= VSdrwTYPE;
	A[idx].elmQuery		= ISOFTYPE_ADDRESS( VL, userBlock );
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VLPC_LAB;
	U[idx] 			= VSdrwTYPE;
	A[idx].elmQuery		= ISOFTYPE_ADDRESS( VL, userBlock );
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VLPC_START_STIFF;
	U[idx] 			= VSdrwTYPE;
	A[idx].elmQuery		= ISOFTYPE_ADDRESS( VL, userBlock );
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VLPC_END_STIFF;
	U[idx] 			= VSdrwTYPE;
	A[idx].elmQuery		= ISOFTYPE_ADDRESS( VL, userBlock );
	idx++;			VLSDL_CHECK_IDX

        K[idx]                  = VLPC_BORDER;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery         = ISOFTYPE_ADDRESS( VL, userBlock );
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = VLPC_INITIALIZE;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery         = ISOFTYPE_ADDRESS( VL, userBlock );
        idx++;                  VLSDL_CHECK_IDX

	K[idx]			= VLPC_REF_MARKING;
	U[idx] 			= VSdrwTYPE;
	A[idx].elmQuery		= ISOFTYPE_ADDRESS( VL, refMarkBlock );
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VLPC_BEND_LINES;
	U[idx] 			= VSdrwTYPE;
	A[idx].elmQuery		= ISOFTYPE_ADDRESS( VL, userBlock );
	idx++;			VLSDL_CHECK_IDX

	K[idx]                  = VLPC_STF_MARK;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery         = ISOFTYPE_ADDRESS( VL, stfPcMark );
        idx++;                  VLSDL_CHECK_IDX

	K[idx]		= VLPC_VIEW_CS;
	U[idx] 		= VSdrwFUNCTION;
	A[idx].function	= FUNCTION_ADDRESS( VL, viewCs );
	idx++;		VLSDL_CHECK_IDX

	K[idx]		= VLPC_VIEW_END_CS;
	U[idx] 		= VSdrwFUNCTION;
	A[idx].function	= FUNCTION_ADDRESS( VL, viewEndCs );
	idx++;		VLSDL_CHECK_IDX

	K[idx]		= VLPC_VIEW_MAC_CS;
	U[idx] 		= VSdrwFUNCTION;
	A[idx].function	= FUNCTION_ADDRESS( VL, viewMacroCs );
	idx++;		VLSDL_CHECK_IDX

	K[idx]		= VLPC_GET_STIFF;
	U[idx] 		= VSdrwFUNCTION;
	A[idx].function	= FUNCTION_ADDRESS( VL, getStiff );
	idx++;		VLSDL_CHECK_IDX

	K[idx]		= VLPC_GET_FOOT;
	U[idx] 		= VSdrwFUNCTION;
	A[idx].function	= FUNCTION_ADDRESS( VL, getFoot );
	idx++;		VLSDL_CHECK_IDX

	K[idx]		= VLPC_ROTATE_CS;
	U[idx] 		= VSdrwFUNCTION;
	A[idx].function	= FUNCTION_ADDRESS( VL, rotateGraphic );
	idx++;		VLSDL_CHECK_IDX

	K[idx]		= VLPC_MAC_DEF_ATTR;
	U[idx] 		= VSdrwFUNCTION;
	A[idx].function	= FUNCTION_ADDRESS( VL, getMcDefAttribute );
	idx++;		VLSDL_CHECK_IDX

	K[idx]		= VLPC_MAC_POS;	
	U[idx] 		= VSdrwFUNCTION;
	A[idx].function	= FUNCTION_ADDRESS( VL, macPosition );
	idx++;		VLSDL_CHECK_IDX

	K[idx]		= VLPC_MAC_ANGLE;	
	U[idx] 		= VSdrwFUNCTION;
	A[idx].function	= FUNCTION_ADDRESS( VL, macAngle );
	idx++;		VLSDL_CHECK_IDX

	K[idx]		= VLPC_MAC_SIDE;	
	U[idx] 		= VSdrwFUNCTION;
	A[idx].function	= FUNCTION_ADDRESS( VL, macSide );
	idx++;		VLSDL_CHECK_IDX

	K[idx]		= VLPC_ET1_POS;	
	U[idx] 		= VSdrwFUNCTION;
	A[idx].function	= FUNCTION_ADDRESS( VL, FirstEtPos );
	idx++;		VLSDL_CHECK_IDX

	K[idx]		= VLPC_INTER_ETS_LEN;
	U[idx] 		= VSdrwFUNCTION;
	A[idx].function	= FUNCTION_ADDRESS( VL, InterEtsLen );
	idx++;		VLSDL_CHECK_IDX

	K[idx]		= VLPC_BORDER_PT;
	U[idx] 		= VSdrwFUNCTION;
	A[idx].function	= FUNCTION_ADDRESS( VL, brAnchorPoint );
	idx++;		VLSDL_CHECK_IDX

	K[idx]		= VLPC_INST_PT;	
	U[idx] 		= VSdrwFUNCTION;
	A[idx].function	= FUNCTION_ADDRESS( VL, brInstPoint );
	idx++;		VLSDL_CHECK_IDX

	K[idx]		= VLPC_BORDER_MEMBER;	
	U[idx] 		= VSdrwFUNCTION;
	A[idx].function	= FUNCTION_ADDRESS( VL, PCbrMember );
	idx++;		VLSDL_CHECK_IDX

	K[idx]		= VLPC_SET_LABEL;
	U[idx] 		= VSdrwFUNCTION;
	A[idx].function	= FUNCTION_ADDRESS( VL, PCsetLabel );
	idx++;		VLSDL_CHECK_IDX

	K[idx]		= VLPC_SET_LAB_ORIG;
	U[idx] 		= VSdrwFUNCTION;
	A[idx].function	= FUNCTION_ADDRESS( VL, setLabelOrigin );
	idx++;		VLSDL_CHECK_IDX

	K[idx]		= VLPC_GET_LAB_ORIG;
	U[idx] 		= VSdrwFUNCTION;
	A[idx].function	= FUNCTION_ADDRESS( VL, getLabelOrigin );
	idx++;		VLSDL_CHECK_IDX

	K[idx]		= VLPC_GET_LAB_TEXT;
	U[idx] 		= VSdrwFUNCTION;
	A[idx].function	= FUNCTION_ADDRESS( VL, PCgetLabelText );
	idx++;		VLSDL_CHECK_IDX

	K[idx]		= VLPC_GET_LAB_REF;
	U[idx] 		= VSdrwFUNCTION;
	A[idx].function	= FUNCTION_ADDRESS( VL, PCgetLabelRef );
	idx++;		VLSDL_CHECK_IDX

	K[idx]		= "vl-pc-CvrtDouble";
	U[idx] 		= VSdrwFUNCTION;
	A[idx].function	= FUNCTION_ADDRESS( VL, PCcvrtStrToDbl );
	idx++;		VLSDL_CHECK_IDX

	K[idx]		= VLPC_PROJECTION;
	U[idx] 		= VSdrwOUTPUT;
	A[idx].output	= OUTPUT_ADDRESS( VL, vlProjection );
	idx++;		VLSDL_CHECK_IDX

	K[idx]		= VLPC_MEMBER;
	U[idx] 		= VSdrwOUTPUT;
	A[idx].output	= OUTPUT_ADDRESS( VL, vlMember );
	idx++;		VLSDL_CHECK_IDX

	K[idx]		= VLPC_PLACE_BEND;
	U[idx] 		= VSdrwOUTPUT;
	A[idx].output	= OUTPUT_ADDRESS( VL, placeBendLines );
	idx++;		VLSDL_CHECK_IDX

        K[idx]          = VLPC_GET_VIEWNAME;
        U[idx]          = VSdrwFUNCTION;
        A[idx].function = FUNCTION_ADDRESS( VL, getViewName );
        idx++;          VLSDL_CHECK_IDX

        K[idx]          = VLPC_GET_MACROLIST;
        U[idx]          = VSdrwFUNCTION;
        A[idx].function = FUNCTION_ADDRESS( VL, getMacroList );
        idx++;          VLSDL_CHECK_IDX

        K[idx]          = VLPC_GET_MACROPOSITIONS;
        U[idx]          = VSdrwFUNCTION;
        A[idx].function = FUNCTION_ADDRESS( VL, getMacroPositions );
        idx++;          VLSDL_CHECK_IDX

        K[idx]          = VLPC_IS_CURVED_BEAM;
        U[idx]          = VSdrwFUNCTION;
        A[idx].function = FUNCTION_ADDRESS( VL, isCurvedBeam );
        idx++;          VLSDL_CHECK_IDX

        K[idx]          = VLPC_SET_BORDER;
        U[idx]          = VSdrwFUNCTION;
        A[idx].function = FUNCTION_ADDRESS( VL, setBorder );
        idx++;          VLSDL_CHECK_IDX

        K[idx]          = VLPC_SET_WEBRIGHT;
        U[idx]          = VSdrwFUNCTION;
        A[idx].function = FUNCTION_ADDRESS( VL, setWebRight );
        idx++;          VLSDL_CHECK_IDX

        K[idx]          = VLPC_PLACE_BENDTABLE;
        U[idx]          = VSdrwOUTPUT;
        A[idx].output   = OUTPUT_ADDRESS( VL, placeBendTable );
        idx++;          VLSDL_CHECK_IDX

        K[idx]          = VLPC_TERMINATE;
        U[idx]          = VSdrwFUNCTION;
        A[idx].output   = FUNCTION_ADDRESS( VL, pcTerminate );
        idx++;          VLSDL_CHECK_IDX

        K[idx]          = VLPC_SETEXTREMEDIM;
        U[idx]          = VSdrwFUNCTION;
        A[idx].output   = FUNCTION_ADDRESS( VL, pcSetExtremeDim );
        idx++;          VLSDL_CHECK_IDX

        K[idx]          = VLPC_SETMACBOTHET;
        U[idx]          = VSdrwFUNCTION;
        A[idx].output   = FUNCTION_ADDRESS( VL, pcSetMacBothET );
        idx++;          VLSDL_CHECK_IDX

        K[idx]          = VLPC_SETMACOPENET;
        U[idx]          = VSdrwFUNCTION;
        A[idx].output   = FUNCTION_ADDRESS( VL, pcSetMacOpenET );
        idx++;          VLSDL_CHECK_IDX

        K[idx]          = VLPC_GETPLTTHKDIR;
        U[idx]          = VSdrwFUNCTION;
        A[idx].output   = FUNCTION_ADDRESS( VL, pcGetPlateThkDir );
        idx++;          VLSDL_CHECK_IDX

        K[idx]          = VLPC_GETXBASE;
        U[idx]          = VSdrwFUNCTION;
        A[idx].output   = FUNCTION_ADDRESS( VL, pcGetXBase );
        idx++;          VLSDL_CHECK_IDX

        K[idx]          = VLPC_GETSTARTPOINT;
        U[idx]          = VSdrwFUNCTION;
        A[idx].output   = FUNCTION_ADDRESS( VL, pcGetStartPoint );
        idx++;          VLSDL_CHECK_IDX

	VSdrwAddFunctions( idx, K, U, A );

	sts = MSSUCC;

wrapup :

return	sts;
}


/* ------------------- FCT VLpcInitStiffInfo () -----------------------	*/
#argsused
long	VLpcInitStiffInfo( VLsInfoForMc *stInfo, struct GRmd_env *env )
{
	stInfo->nf.objid	= NULL_OBJID;
	stInfo->iso0.objid	= NULL_OBJID;
	stInfo->origin.objid	= NULL_OBJID;

return	MSSUCC;
}

/* ------------------- FCT VLpcFreeStiffInfo () -----------------------	*/
long	VLpcFreeStiffInfo( VLsInfoForMc *stInfo, struct GRmd_env *env )
{
long	msg;

	if( stInfo->nf.objid != NULL_OBJID )
		om$send(msg	 = message GRgraphics.GRdelete( &msg, env ),
			senderid = NULL_OBJID,
			targetid = stInfo->nf.objid,
			targetos = stInfo->nf.osnum );

	if( stInfo->iso0.objid != NULL_OBJID )
		om$send(msg	 = message GRgraphics.GRdelete( &msg, env ),
			senderid = NULL_OBJID,
			targetid = stInfo->iso0.objid,
			targetos = stInfo->iso0.osnum );

	if( stInfo->origin.objid != NULL_OBJID )
		om$send(msg	 = message GRgraphics.GRdelete( &msg, env ),
			senderid = NULL_OBJID,
			targetid = stInfo->origin.objid,
			targetos = stInfo->origin.osnum );
return	MSSUCC;
}


/* --------------------- FCT VLcomputeGraphicPC () --------------------	*/

long VLcomputeGraphicPC(	struct GRobj_env *support,
				struct GRobj_env *plCs,
				char             *viewName,
				struct GRobj_env *rgPt,
				struct GRobj_env *border,
				int              maxCmp,
				int              *nbCmp,
				struct GRid      *cmpList,
				struct GRmd_env  *env )
{
  long			        msg, sts;
  int			        i, j, k;
  double			vector[3];
  VSdrwOutputData		*outPutInit;
  VSdrwOutputData		*outPutCur;
  VSdrwOutputData		*p;
  struct	IGRplane	view, plane;
  double			viewPl[6];
  struct	IGRlbsys	drwLbsys;
  int			        count = 0;
  struct	GRobj_env	*list;
  short			        four = 4;
  double			CsMat[16];
  double			PlaneMat[16];
  double			invMat[16];
  int			        locCmp;
  struct	GRmd_env	MOD_ENV;
  long			        NumberOfBytes,BytesReceived;
  struct	GRid		contextId[4], contextCollId;
  int			        viewSide;
  double			L, W;
  VLmacInfo		        *sortList = NULL;
  extern	int		VLorderMacXPos();
  VLsdlContext		        sdlC;
  VLpcContext		        pcCtx;
  struct	ACrg_coll	attr;
  double			viewRg[3];
  double			newCs[16];
  struct	GRid		viewCs;
  double			startPt[3];
  double			param;
  VLsInfoForMc		        stiffInfo;
  GRname			cmdType;
  int			        lowI, upI;
  double			lowO, upO;
  IGRboolean		        is_both_et, is_start_generic, is_end_generic;
 
  /* Initialization */
  outPutInit	= NULL;
  outPutCur	= NULL;
  list		= NULL;
  isWebRight	= 0;
  view.point	= &viewPl[0];	// plane associate to the web_left
  view.normal	= &viewPl[3];	// side of the stiffner	
  plane.point	= &viewPl[0];	// Projection orthogonal
  plane.normal	= &viewPl[3];	// 
  
  VLpcSetIsFromExtremeties( 0 );
  VLpcResetBothETMac();
  VLpcResetOpenETMac();
  
  vl$sdlInit( ctx = &sdlC );
  //	if( nbCmp )	maxCmp	= *nbCmp;
  NumberOfBytes = sizeof( MOD_ENV );
  gr$get_module_env(      msg     = &msg,
			  sizbuf  = &NumberOfBytes,
			  buffer  = &MOD_ENV,
			  nret    = &BytesReceived);
  viewCs.objid	= NULL_OBJID;
  VLpcInitStiffInfo( &stiffInfo, env );
  
  // get profile card plane
  sts = om$send(	msg	 = message GRgencs.GRgetmatrix
			( &msg, CsMat ),
			targetid = plCs->obj_id.objid,
			targetos = plCs->obj_id.osnum,
			senderid = NULL_OBJID );
  if( ! (sts&msg&1)){ sts = MSFAIL; goto wrapup; }
  
  if( plCs->mod_env.md_env.matrix_type != MAIDMX ){
    MAmulmx(&msg, &four, &four, &four, 
	    plCs->mod_env.md_env.matrix, CsMat,
	    newCs );
    for( i=0; i<16; i++ )	CsMat[i] = newCs[i];
  }
  
	// create View CS in local env for header or reference case
  sts = vl$plcs(	mat	= CsMat,
			env	= env,
			csId	= &viewCs );
  as$status( sts = sts );
  
  // compute view range
  sts = VLcvrtPtInLocCs( NULL, CsMat, NULL, rgPt, NULL, viewRg );
  as$status( sts = sts );
  
  /* ********** Create the Profile Card with Strudel ************	*/
  // drwLbsys == range of support
  MAidmx( &msg, drwLbsys.matrix );
  for( i=0; i<3; i++ )	drwLbsys.diag_pt1[i] = 0;
  for( i=0; i<3; i++ )	drwLbsys.diag_pt2[i] = 0;
  
  // add key word into Strudel
  VLvl_pc_LoadKeyWords();
  vl$sdlInit( ctx = &sdlC );
  // set cur_state with Initialize
  vl$sdlSetState( ctx = &sdlC, state = VLPC_INITIALIZE );
  vl$sdlGetCol(   ctx     = &sdlC,
		  colType = VLSDL_SYST_COL,
		  colId   = &contextCollId );
  
  vs$drwExecConfig(  msg             = &msg,
		     elmId           = &contextCollId,
		     elmEnv          = &MOD_ENV,
		     drwPlane        = &plane,
		     viewPlane       = &view,
		     viewVector      = vector,
		     drwEnv          = env,
		     drwLbsys        = &drwLbsys,
		     selCount        = 1,
		     selList         = &support->obj_id,
		     filename        = VLPC_GR_FILE,
		     appData         = &sdlC,
		     output          = outPutInit
		     ? &outPutCur->next
		     : &outPutInit );
  // Free memory
  VSdrwFreeOutputData( &outPutInit );     outPutInit = NULL;
  
  // get cutting macro
  count	= 0;
  sts = VLgetMacOnStiff( support, &MOD_ENV, &count, &list );
  as$status( sts = sts );
  
  // list of macro processed 
  //	printf(" nb_mac : %d\n", count );
  //	for( i=0; i<count; i++ )
  //		printf(" macId[%d] : %d/%d\n", i,
  //				list[i].obj_id.objid, list[i].obj_id.osnum );
  
  // set view vector
  sts = VLgetStiffPlane( support, NULL, PlaneMat, NULL,
			 &viewSide, viewName ); 
  if( ! (sts&1)){ sts = MSFAIL; goto wrapup; }
  
  for( i=0; i<3; i++ ){
    k=i*4;
    viewPl[i]	= PlaneMat[k+3];		// Origin
    viewPl[i+3]	= -(viewSide * PlaneMat[k+2]);	// Z
    vector[i]	= viewSide * PlaneMat[k+2];	// Z
  }
  
  // change CS of pt1
  MAinvmx(&msg, &four, PlaneMat, invMat);
  
  startPt[0]	= PlaneMat[3];
  startPt[1]	= PlaneMat[7];
  startPt[2]	= PlaneMat[11];
  param = 0.5;
  // get info on stiffener for Macro
  sts = VLpcInfoStiff( support, &MOD_ENV, param, startPt, &stiffInfo );
  as$status( sts = sts );
  
  if( count ){
    IGRdouble end_ln1=0, end_ln2=0;
    
    sortList = (VLmacInfo *) malloc( sizeof(VLmacInfo) * count );
    if( ! sortList ){ sts = MSFAIL; goto wrapup; }
    
    for( i=0; i<count; i++ ){
      sortList[i].mac	= &list[i];
      sts = VLpcMcInfo( &sortList[i], &stiffInfo, &MOD_ENV );
    }
    
    // reorder mac with xpos criteria
    qsort( sortList, count, sizeof(VLmacInfo), VLorderMacXPos );
  }
  
  // compute range
  sts = VLgetStiffRange( 	support, VLPC_VIEW_SIDE, 
				count, sortList, &L, &W );
  as$status( sts = sts );
  __DBGpr_int("isWebRight ", isWebRight );
  __DBGpr_dbl("Beam Length ", L );
  __DBGpr_int("Macro Count ", count );
  if( isWebRight )
  {
    for( i=0; i<count; ++i )
    {
      __DBGpr_dbl("Original X position ", sortList[i].xpos );
      sortList[i].xpos = L - sortList[i].xpos;
      __DBGpr_dbl("Modified X position ", sortList[i].xpos );
    }
  }
  
  // compute scale between Stiffener and view Size in the 2 directions
  pcCtx.vasCs.xSca	= viewRg[0] / L;
  pcCtx.vasCs.ySca	= viewRg[1] / W;
  pcCtx.vasCs.xView	= viewRg[0];
  pcCtx.vasCs.yView	= viewRg[1];

  // Compute transformation Matrix between Stiffener and View.
  for( i=0; i<3; i++ )	CsMat[i*4] 	*= pcCtx.vasCs.xSca;
  for( i=0; i<3; i++ )	CsMat[(i*4)+1]	*= pcCtx.vasCs.ySca;
  
  MAmulmx(&msg, &four, &four, &four, CsMat, invMat, pcCtx.vasCs.mat );
  MAtypemx(&msg,  pcCtx.vasCs.mat, &pcCtx.vasCs.type );
  
  /* --------------------------- Define context of profile card 	*/
  contextId[VLPC_IDX_BORDER]	= viewCs;
  contextId[VLPC_IDX_SUPPORT]	= support->obj_id;
  contextId[VLPC_IDX_ACHEADER]	= border->obj_id;
  
  sdlC.stateArgs 		= &pcCtx;
  pcCtx.nbMac		= count;
  pcCtx.curMac		= 0;
  pcCtx.macInfoList	= sortList;
  pcCtx.nbLabel		= 0;
  pcCtx.curLabel		= -1;
  pcCtx.stiffInfo		= &stiffInfo;
  
  // set cur_state with startPc
  vl$sdlSetState( ctx = &sdlC, state = VLPC_START );
  
  vl$sdlGetCol(	ctx	= &sdlC,
		colType	= VLSDL_SYST_COL,
		colId	= &contextId[VLPC_IDX_COL] );
  
  // set system attributes
  strcpy( attr.name, VLPC_STIFF_LEN );
  attr.desc.type = AC_ATTRIB_DOUBLE;
  attr.desc.value.att_exp = L;
  vl$sdlSetAttr(	ctx	= &sdlC,
			attr	= &attr,
			colType	= VLSDL_SYST_COL ); 
  
  strcpy( attr.name, VLPC_STIFF_WID );
  attr.desc.type = AC_ATTRIB_DOUBLE;
  attr.desc.value.att_exp = W;
  vl$sdlSetAttr(	ctx	= &sdlC,
			attr	= &attr,
			colType	= VLSDL_SYST_COL ); 
  
  // set working view
  strcpy( attr.name, VLSDL_VIEW );
  attr.desc.type = AC_ATTRIB_TEXT;
  strcpy( attr.desc.value.att_txt, viewName );
  vl$sdlSetAttr(	ctx	= &sdlC,
			attr	= &attr,
			colType	= VLSDL_SYST_COL ); 
  
  // Check extremities 
  lowO = -1.; upO = -1.;
  for( i=0, lowI=-1, upI=-1; i<count; i++ ){
    // get et macro
    cmdType[0] = '\0';
    sts = VLgetOperName( NULL, &(sortList[i].mac->obj_id), 
			 VLPC_DEF_ATT_CMD, cmdType );
    if( (sts&1) && (! strcmp( VLPC_END_TREAT_CMD, cmdType ))){
      if( isWebRight )
      {
	if( upI == -1 ){
	  upI = i;
	  upO = sortList[i].xpos;
	} else {
	  lowI = i;
	  lowO = sortList[i].xpos;
	}
      }
      else
      {
	// get origin of macro
	if( lowI == -1 ){
	  lowI = i; 
	  lowO = sortList[i].xpos;
	} else {
	  upI = i;
	  upO = sortList[i].xpos;
	}
      }
    }
  }
  
  // Order entry result
  if( lowI != -1 && lowO > L/2 ){
    if( upI != -1 )	lowI = -1;
    else {	upI = lowI; upO = lowO; lowI = -1; }
  }
  
  is_both_et = is_start_generic = is_end_generic = FALSE;
  sts = VLpcCheckSpecificETs( &msg, support, &stiffInfo, &count, sortList,
			      env, L, &is_both_et, &is_start_generic, &is_end_generic );
  pcCtx.nbMac = count; // update the count for STRUDEL TR# MP5265
  
  // set ET origin
  strcpy( attr.name, VLPC_MC_ET1_POS );
  attr.desc.type = AC_ATTRIB_DOUBLE;
  if( lowI == -1 ) lowO = 0.;
  attr.desc.value.att_exp =  lowO;
  vl$sdlSetAttr(	ctx	= &sdlC,
			attr	= &attr,
			colType	= VLSDL_SYST_COL ); 
  
  strcpy( attr.name, VLPC_MC_ETS_LEN );
  attr.desc.type = AC_ATTRIB_DOUBLE;
  if( upI == -1 )	 upO = L;
  attr.desc.value.att_exp = upO - lowO;
  vl$sdlSetAttr(	ctx	= &sdlC,
			attr	= &attr,
			colType	= VLSDL_SYST_COL ); 
  
  // execute startPc state
  vl$sdlSetState( ctx = &sdlC, state = VLPC_START );
  vs$drwExecConfig(	msg		= &msg,
			elmId		= &contextId[VLPC_IDX_COL],
			elmEnv		= &MOD_ENV,
			drwPlane	= &plane,  // same than view
			viewPlane	= &view,
			viewVector	= vector,
			drwEnv		= env,
			drwLbsys	= &drwLbsys,
			selCount	= 3,
			selList		= contextId,
			filename	= VLPC_GR_FILE,
			appData		= &sdlC,
			output		= outPutInit 
			? &outPutCur->next
			: &outPutInit );
  for( p=(outPutCur ? outPutCur : outPutInit); p; 
       p=p->next) outPutCur = p;
  
  // Call Apfel Strudel for Stiffner Side View
  vs$drwExecConfig(	msg		= &msg,
			elmId		= &support->obj_id,
			elmEnv		= &support->mod_env,
			drwPlane	= &plane,
			viewPlane	= &view,
			viewVector	= vector,
			drwEnv		= env,
			drwLbsys	= &drwLbsys,
			selCount	= 3,
			selList		= contextId,
			filename	= VLPC_GR_FILE,
			appData		= &sdlC,
			output		= outPutInit 
			? &outPutCur->next
			: &outPutInit );
  for( p=(outPutCur ? outPutCur : outPutInit); p; 
       p=p->next) outPutCur = p;
  
  if( lowI == -1 && is_start_generic == FALSE && is_both_et == FALSE ){
    
    vl$sdlSetState( ctx = &sdlC, state = VLPC_START_STIFF );
    vs$drwExecConfig(	msg		= &msg,
			elmId		= &contextId[VLPC_IDX_COL],
			elmEnv		= &MOD_ENV,
			drwPlane	= &plane,  // same than view
			viewPlane	= &view,
			viewVector	= vector,
			drwEnv		= env,
			drwLbsys	= &drwLbsys,
			selCount	= 3,
			selList		= contextId,
			filename	= VLPC_GR_FILE,
			appData		= &sdlC,
			output		= outPutInit 
			? &outPutCur->next
			: &outPutInit );
    for( p=(outPutCur ? outPutCur : outPutInit); p; 
	 p=p->next) outPutCur = p;
  }
  
  __DBGpr_int( "Macro Count", count );
  
  // Call Apfel Strudel for Macro Side View
  for( i=0; i<count; i++ ){
    
    VLprocMgrPulse();
    vs$drwExecConfig(	msg		= &msg,
			elmId		= &(sortList[i].mac->obj_id),
			elmEnv		= &(sortList[i].mac->mod_env),
			drwPlane	= &plane,  // same than view
			viewPlane	= &view,
			viewVector	= vector,
			drwEnv		= env,
			drwLbsys	= &drwLbsys,
			selCount	= 3,
			selList		= contextId,
			filename	= VLPC_GR_FILE,
			appData		= &sdlC,
			output		= outPutInit 
			? &outPutCur->next
			: &outPutInit );
    for( p=(outPutCur ? outPutCur : outPutInit); p; 
	 p=p->next) outPutCur = p;
  }// end macros
  
  if( upI == -1 && is_end_generic == FALSE && is_both_et == FALSE ){
    
    vl$sdlSetState( ctx = &sdlC, state = VLPC_END_STIFF );
    vs$drwExecConfig(	msg		= &msg,
			elmId		= &contextId[VLPC_IDX_COL],
			elmEnv		= &MOD_ENV,
			drwPlane	= &plane,  // same than view
			viewPlane	= &view,
			viewVector	= vector,
			drwEnv		= env,
			drwLbsys	= &drwLbsys,
			selCount	= 3,
			selList		= contextId,
			filename	= VLPC_GR_FILE,
			appData		= &sdlC,
			output		= outPutInit 
			? &outPutCur->next
			: &outPutInit );
    for( p=(outPutCur ? outPutCur : outPutInit); p; 
	 p=p->next) outPutCur = p;
  }
  
  // execute endPc state
  vl$sdlSetState( ctx = &sdlC, state = VLPC_END );
  vs$drwExecConfig(	msg		= &msg,
			elmId		= &contextId[VLPC_IDX_COL],
			elmEnv		= &MOD_ENV,
			drwPlane	= &plane,  // same than view
			viewPlane	= &view,
			viewVector	= vector,
			drwEnv		= env,
			drwLbsys	= &drwLbsys,
			selCount	= 3,
			selList		= contextId,
			filename	= VLPC_GR_FILE,
			appData		= &sdlC,
			output		= outPutInit 
			? &outPutCur->next
			: &outPutInit );
  
  locCmp	= 0;
  for( p=outPutInit; p; p=p->next )
    for( j=0; j<p->set.count; j++ ){
      
      if( locCmp >= maxCmp )	continue;
      cmpList[locCmp++] = p->set.list[j];
    }
  
  if( nbCmp )	*nbCmp	= locCmp;
  
  // Free memory
  VSdrwFreeOutputData( &outPutInit );	outPutInit = NULL;
  
  sts = MSSUCC;
  
  wrapup :
    
    // Free context
    vl$sdlFree( ctx = &sdlC );
  
  // remove pcard functions
  VSdrwRmFunctions();
  
  // delete tmp cs
  if( viewCs.objid != NULL_OBJID )
    om$send(msg	 = message GRgraphics.GRdelete( &msg, env ),
	    senderid = NULL_OBJID,
	    targetid = viewCs.objid,
	    targetos = viewCs.osnum );
  
  // delete stiffener Info
  VLpcFreeStiffInfo( &stiffInfo, env );
  
  if( list )	free( list );
  if( outPutInit )	VSdrwFreeOutputData( &outPutInit );
  
  return	sts;
}

/* ****************** FCT VLcomputeTxtPC () ***************************	*/

long VLcomputeTxtPC( 		struct	GRobj_env	*Cs,
				struct	GRid		*Cartouche,
				struct	GRobj_env	*support,
				int 			*nbCmp,
				struct	GRid		*cmpList,
				struct	GRmd_env	*env )

{
  long			        sts, msg;
  struct	IGRplane	view, plane;
  double			viewPl[6];
  double			CsMat[16];
  double			vector[3];
  struct	IGRlbsys	drwLbsys;
  VSdrwOutputData		*outPutInit;
  VSdrwOutputData		*outPutCur;
  VSdrwOutputData		*p;
  int			        i, j;
  int			        count = 0;
  struct	GRobj_env	*list;
  int			        maxCmp = 0;
  int			        locCmp;
  struct	GRmd_env	MOD_ENV;
  long			        NumberOfBytes,BytesReceived;
  struct	GRid		contextId[3];
  extern	int		VLInstPointCounter;
  double			sideMat[16];
  double			invMat[16];
  short			        four = 4;
  extern	int		VLorderMacXPos();
  extern	int		VLorderLabelXPos();
  VLmacInfo		        *sortList = NULL;
  struct	ACrg_coll	attr;
  VLsdlContext		        sdlC;
  VLpcContext		        pcCtx;
  struct	GRid		txtCol;
  int			        mcI, lbI, maxOper;
  double			labX;
  double			startPt[3];
  double			param;
  VLsInfoForMc		        stiffInfo;
  double			W, L;
  GRname			cmdType;
  int			        lowI, upI;
  double			lowO, upO;
  
  
  /* Initialization */
  outPutInit	= NULL;
  outPutCur	= NULL;
  count		= 0;
  list		= NULL;
  view.point	= &viewPl[0];	// plane associate to the web_left
  view.normal	= &viewPl[3];	// side of the stiffner	
  plane.point	= &viewPl[0];	// Projection orthogonal
  plane.normal	= &viewPl[3];	// 
  vl$sdlInit ( ctx = &sdlC );
  VLpcInitStiffInfo( &stiffInfo, env );
  pcCtx.nbLabel		= 0;
  
  
  if( nbCmp )	maxCmp	= *nbCmp;
  NumberOfBytes = sizeof( MOD_ENV );
  gr$get_module_env(      msg     = &msg,
			  sizbuf  = &NumberOfBytes,
			  buffer  = &MOD_ENV,
			  nret    = &BytesReceived);
  
  // create txtCol
  txtCol.osnum	= env->md_id.osnum;
  sts = om$construct(	classid	= OPP_ACdyn_col_class_id,
			osnum	= txtCol.osnum,
			p_objid = &txtCol.objid );
  
  
  MAidmx( &msg, drwLbsys.matrix );
  for( i=0; i<3; i++ )	drwLbsys.diag_pt1[i] = 0;
  for( i=0; i<3; i++ )	drwLbsys.diag_pt2[i] = 0;
  
  // get plane 
  sts = om$send(	msg	 = message GRgencs.GRgetmatrix
			( &msg, CsMat ),
			targetid = Cs->obj_id.objid,
			targetos = Cs->obj_id.osnum,
			senderid = NULL_OBJID );
  if( ! (sts&msg&1)){ sts = MSFAIL; goto wrapup; }
  
  viewPl[0]	= CsMat[3];
  viewPl[1]	= CsMat[7];
  viewPl[2]	= CsMat[11];
  
  viewPl[3]	= CsMat[2];	vector[0] 	= -CsMat[2];
  viewPl[4]	= CsMat[6];	vector[1]	= -CsMat[6];
  viewPl[5]	= CsMat[10];	vector[2]	= -CsMat[10];
  
  // add key word into Strudel
  VLvl_pc_LoadKeyWords();
  
  // Query macro attach to the support
  count = 0;
  sts = VLgetMacOnStiff( support, &MOD_ENV, &count, &list );
  as$status( sts = sts );
  
	// get Changement of CS
  sts = VLgetStiffPlane( support, NULL, sideMat, NULL, 
			 NULL, VLPC_VIEW_SIDE ); 
  as$status( sts = sts );
  
  // change CS of pt1
  MAinvmx(&msg, &four, sideMat, invMat);
  
  startPt[0]	= sideMat[3];
  startPt[1]	= sideMat[7];
  startPt[2]	= sideMat[11];
  param = 0.5;
  // get info on stiffener for Macro
  sts = VLpcInfoStiff( support, &MOD_ENV, param, startPt, &stiffInfo );
  as$status( sts = sts );
  
  if( count ){
    IGRdouble end_ln1=0, end_ln2=0;
    sortList = (VLmacInfo *) malloc( sizeof(VLmacInfo) * count );
    if( ! sortList ){ sts = MSFAIL; goto wrapup; }
    
    for( i=0; i<count; i++ ){
      sortList[i].mac	= &list[i];
      sts = VLpcMcInfo( &sortList[i], &stiffInfo, &MOD_ENV ); 
    }
    
    // reorder mac with xpos criteria
    qsort( sortList, count, sizeof(VLmacInfo), VLorderMacXPos );
  }
  
  // compute range
  sts = VLgetStiffRange( 	support, VLPC_VIEW_SIDE, count, sortList,
				&L, &W  );
  as$status( sts = sts );
  
  sdlC.stateArgs 		= &pcCtx;
  pcCtx.nbMac		= count;
  pcCtx.curMac		= 0;
  pcCtx.macInfoList	= sortList;
  pcCtx.nbLabel		= 0;
  pcCtx.curLabel		= -1;
  pcCtx.stiffInfo		= &stiffInfo;
  
  /* --------------------------- Define context of profile card 	*/
  // anchor point for macro instructions.
  VLInstPointCounter	= 1;
  
  contextId[VLPC_IDX_BORDER]	= *Cartouche;
  contextId[VLPC_IDX_SUPPORT]	= support->obj_id;
  
  // set cur_state with startPc
  vl$sdlSetState( ctx = &sdlC, state = VLPC_START );
  
  // get system context object
  vl$sdlGetCol(	ctx	= &sdlC,
		colType	= VLSDL_SYST_COL,
		colId	= &contextId[VLPC_IDX_COL] );
  
  // set system attributes
  strcpy( attr.name, VLPC_STIFF_LEN );
  attr.desc.type = AC_ATTRIB_DOUBLE;
  attr.desc.value.att_exp = L;
  vl$sdlSetAttr(  ctx     = &sdlC,
		  attr    = &attr,
		  colType = VLSDL_SYST_COL );
  
  // set working view
  strcpy( attr.name, VLSDL_VIEW );
  attr.desc.type = AC_ATTRIB_TEXT;
  strcpy( attr.desc.value.att_txt, VLPC_VIEW_UNKNOWN );
  vl$sdlSetAttr(	ctx	= &sdlC,
			attr	= &attr,
			colType	= VLSDL_SYST_COL ); 
  
  // Check extremities 
  lowO = -1.; upO = -1.;
  for( i=0, lowI=-1, upI=-1; i<count; i++ ){
    // get et macro
    cmdType[0] = '\0';
    sts = VLgetOperName( NULL, &(sortList[i].mac->obj_id), 
			 VLPC_DEF_ATT_CMD, cmdType );
    if( (sts&1) && (! strcmp( VLPC_END_TREAT_CMD, cmdType ))){
      // get origin of macro
      if( lowI == -1 ){
	lowI = i; 
	lowO = sortList[i].xpos;
      } else {
	upI = i;
	upO = sortList[i].xpos;
      }
    }
  }
  
  // Order entry result
  if( lowI != -1 && lowO > L/2 ){
    if( upI != -1 )	lowI = -1;
    else {	upI = lowI; upO = lowO; lowI = -1; }
  }
  
  
  // set ET origin
  strcpy( attr.name, VLPC_MC_ET1_POS );
  attr.desc.type = AC_ATTRIB_DOUBLE;
  if( lowI == -1 ) lowO = 0.;
  attr.desc.value.att_exp =  lowO;
  vl$sdlSetAttr(	ctx	= &sdlC,
			attr	= &attr,
			colType	= VLSDL_SYST_COL ); 
  
  strcpy( attr.name, VLPC_MC_ETS_LEN );
  attr.desc.type = AC_ATTRIB_DOUBLE;
  if( upI == -1 )	upO = L;
  attr.desc.value.att_exp =  upO - lowO;	
  vl$sdlSetAttr(	ctx	= &sdlC,
			attr	= &attr,
			colType	= VLSDL_SYST_COL ); 
  
  // execute startPc state
  vl$sdlSetState( ctx = &sdlC, state = VLPC_START );
  vs$drwExecConfig(	msg		= &msg,
			elmId		= &contextId[VLPC_IDX_COL],
			elmEnv		= &MOD_ENV,
			drwPlane	= &plane,  // same than view
			viewPlane	= &view,
			viewVector	= vector,
			drwEnv		= env,
			drwLbsys	= &drwLbsys,
			selCount	= 3,
			selList		= contextId,
			filename	= VLPC_TXT_FILE,
			appData		= &sdlC,
			output		= outPutInit 
			? &outPutCur->next
			: &outPutInit );
  for( p=(outPutCur ? outPutCur : outPutInit); p; 
       p=p->next) outPutCur = p;
  
  // extract info from support (stiffner)
  VLprocMgrPulse();
  vs$drwExecConfig(	msg		= &msg,
			elmId		= &support->obj_id,
			elmEnv		= env,
			drwPlane	= &plane,
			viewPlane	= &view,
			viewVector	= vector,
			drwEnv		= env,
			drwLbsys	= &drwLbsys,
			selCount	= 3,
			selList		= contextId,
			filename	= VLPC_TXT_FILE,
			appData		= &sdlC,
			output		= outPutInit 
			? &outPutCur->next
			: &outPutInit );
  for( p=(outPutCur ? outPutCur : outPutInit); p; 
       p=p->next) outPutCur = p;
  
  // short label with xpos criteria
  qsort( pcCtx.label, pcCtx.nbLabel, sizeof(struct GRid), 
	 VLorderLabelXPos );
  
  // set current labX
  if( pcCtx.nbLabel > 0 ){
    strcpy( attr.name, VLPC_LAB_ORIG );
    attr.desc.value.att_exp	= VLPC_NO_LAB;
    sts = om$send(	msg	 = message ACrg_collect.ACget_named_attribute
			( &msg, &attr ),
			senderid = NULL_OBJID,
			targetid = pcCtx.label[0].objid,
			targetos = pcCtx.label[0].osnum );
    labX = attr.desc.value.att_exp;
    
  } else 	labX = VLPC_NO_LAB;
  
  if( lowI == -1 ){
    
    vl$sdlSetState( ctx = &sdlC, state = VLPC_START_STIFF );
    vs$drwExecConfig(	msg		= &msg,
			elmId		= &contextId[VLPC_IDX_COL],
			elmEnv		= &MOD_ENV,
			drwPlane	= &plane,  // same than view
			viewPlane	= &view,
			viewVector	= vector,
			drwEnv		= env,
			drwLbsys	= &drwLbsys,
			selCount	= 3,
			selList		= contextId,
			filename	= VLPC_TXT_FILE,
			appData		= &sdlC,
			output		= outPutInit 
			? &outPutCur->next
			: &outPutInit );
    for( p=(outPutCur ? outPutCur : outPutInit); p; 
	 p=p->next) outPutCur = p;
  }
  
  // extract info from Macros and label
  maxOper = count + pcCtx.nbLabel;
  for( i=0, mcI=0, lbI= 0; i<maxOper; i++ ){
    
    if( mcI == count || 
	(labX > -0.01 && labX < sortList[mcI].xpos)  ){
      
      // process Label
      VLprocMgrPulse();
      vs$drwExecConfig(	msg		= &msg,
			elmId		= &(pcCtx.label[lbI]),
			elmEnv		= &MOD_ENV,
			drwPlane	= &plane,  // same than view
			viewPlane	= &view,
			viewVector	= vector,
			drwEnv		= env,
			drwLbsys	= &drwLbsys,
			selCount	= 3,
			selList		= contextId,
			filename	= VLPC_TXT_FILE,
			appData		= &sdlC,
			output		= outPutInit 
			? &outPutCur->next
			: &outPutInit );
      
      for( p=(outPutCur ? outPutCur : outPutInit); p; 
	   p=p->next) outPutCur = p;
      
      
      // set new labX
      lbI ++;
      if( lbI < pcCtx.nbLabel ){
	
	strcpy( attr.name, VLPC_LAB_ORIG );
	attr.desc.value.att_exp	= VLPC_NO_LAB;
	sts = om$send(	msg	 = message ACrg_collect.ACget_named_attribute
	                                		( &msg, &attr ),
			senderid = NULL_OBJID,
			targetid = pcCtx.label[lbI].objid,
			targetos = pcCtx.label[lbI].osnum );
	labX = attr.desc.value.att_exp;
	
      } else 	labX = VLPC_NO_LAB;
      
    } else {
      // process macro
      VLprocMgrPulse();
      vs$drwExecConfig(	msg		= &msg,
			elmId		= &(sortList[mcI].mac->obj_id),
			elmEnv		= &(sortList[mcI].mac->mod_env),
			drwPlane	= &plane,  // same than view
			viewPlane	= &view,
			viewVector	= vector,
			drwEnv		= env,
			drwLbsys	= &drwLbsys,
			selCount	= 3,
			selList		= contextId,
			filename	= VLPC_TXT_FILE,
			appData		= &sdlC,
			output		= outPutInit 
			? &outPutCur->next
			: &outPutInit );
      for( p=(outPutCur ? outPutCur : outPutInit); p; 
	   p=p->next) outPutCur = p;
      mcI++;
      
    }
  }// end macros and labels
  
  if( upI == -1 ){
    
    vl$sdlSetState( ctx = &sdlC, state = VLPC_END_STIFF );
    vs$drwExecConfig(	msg		= &msg,
			elmId		= &contextId[VLPC_IDX_COL],
			elmEnv		= &MOD_ENV,
			drwPlane	= &plane,  // same than view
			viewPlane	= &view,
			viewVector	= vector,
			drwEnv		= env,
			drwLbsys	= &drwLbsys,
			selCount	= 3,
			selList		= contextId,
			filename	= VLPC_TXT_FILE,
			appData		= &sdlC,
			output		= outPutInit 
			? &outPutCur->next
			: &outPutInit );
    for( p=(outPutCur ? outPutCur : outPutInit); p; 
	 p=p->next) outPutCur = p;
  }
  
  // call endPc
  vl$sdlSetState( ctx = &sdlC, state = VLPC_END );
  VLprocMgrPulse();
  vs$drwExecConfig(	msg		= &msg,
			elmId		= &contextId[VLPC_IDX_COL],
			elmEnv		= &MOD_ENV,
			drwPlane	= &plane,  // same than view
			viewPlane	= &view,
			viewVector	= vector,
			drwEnv		= env,
			drwLbsys	= &drwLbsys,
			selCount	= 3,
			selList		= contextId,
			filename	= VLPC_TXT_FILE,
			appData		= &sdlC,
			output		= outPutInit 
			? &outPutCur->next
			: &outPutInit );
  
  // fill txtCol with file_path
  strcpy( attr.name, VLSDL_FILE_PATH );
  sts = vl$sdlGetAttr(	ctx	= &sdlC,
			attr	= &attr,
			colType	= VLSDL_SYST_COL );
  if( sts & 1 ){
    sts = om$send(	msg	 = message ACrg_collect.ACadd_list_attribute
	                                		( &msg, 1, &attr ),
			senderid = NULL_OBJID,
			targetid = txtCol.objid,
			targetos = txtCol.osnum );
  }
  
  // return constructed element
  cmpList[0] = txtCol;
  
  for( p=outPutInit, locCmp=1; p; p=p->next )
    for( j=0; j<p->set.count; j++ ){
      
      if( locCmp >= maxCmp )	continue;
      cmpList[locCmp++] = p->set.list[j];
    }
  
  if( nbCmp )	*nbCmp	= locCmp;
  
  // Free memory
  VSdrwFreeOutputData( &outPutInit );	outPutInit = NULL;
  
  sts = MSSUCC;
  
  wrapup :
    
    // delete label collection
    for( i=0; i<pcCtx.nbLabel; i++ )
      om$send(msg	 = message GRgraphics.GRdelete( &msg, env ),
	      senderid = NULL_OBJID,
	      targetid = pcCtx.label[i].objid,
	      targetos = pcCtx.label[i].osnum );
  
  // Free context
  vl$sdlFree( ctx	= &sdlC );
  
  // remove pcard functions
  VSdrwRmFunctions();
  
  // delete stiffener Info
  VLpcFreeStiffInfo( &stiffInfo, env );
  
  if( list )		free( list );
  if( sortList )		free( sortList );
  if( outPutInit )	VSdrwFreeOutputData( &outPutInit );
  
  return	sts;
}

/* ************************ FCT VLorderMacXPos () *********************	*/
int VLorderMacXPos( const VLmacInfo *mc1, const VLmacInfo *mc2 )
{ return (mc1->xpos >  mc2->xpos) ? 1 : -1; }

/* ************************ FCT VLorderLabelXPos () *******************	*/
int VLorderLabelXPos( const struct GRid *lab1, const struct GRid *lab2 )
{
  long			        sts, msg;
  struct	ACrg_coll	at1, at2;

  strcpy( at1.name, VLPC_LAB_ORIG );
  strcpy( at2.name, VLPC_LAB_ORIG );
  
  sts = om$send(	msg	 = message ACrg_collect.ACget_named_attribute
		                                	( &msg, &at1 ),
			senderid = NULL_OBJID,
			targetid = lab1->objid,
			targetos = lab1->osnum );
  as$status( sts = sts );
  as$status( sts = msg );
  
  sts = om$send(	msg	 = message ACrg_collect.ACget_named_attribute
	                				( &msg, &at2 ),
			senderid = NULL_OBJID,
			targetid = lab2->objid,
			targetos = lab2->osnum );
  as$status( sts = sts );
  as$status( sts = msg );
  
  return (at1.desc.value.att_exp > at2.desc.value.att_exp) ? 1 : -1; 
}

end implementation VLpcAbst;

