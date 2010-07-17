/* $Id: VLrolLinei.I,v 1.5 2001/03/13 19:22:45 ramarao Exp $  */
/*************************************************************************
 * I/LOFT
 *
 * File:        src/mrkLine/VLrolLinei.I
 *
 * Description: Implementation of object defining the rolLine for a plate 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLrolLinei.I,v $
 *      Revision 1.5  2001/03/13 19:22:45  ramarao
 *      Fixed TR# 4818.
 *
 *      Revision 1.4  2001/03/13 17:51:37  ramarao
 *      Fixed TR# 4818.
 *
 *      Revision 1.3  2001/02/20 01:05:17  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.2  2001/01/16 20:56:22  ramarao
 *      *** empty log message ***
 *
# Revision 1.1  2000/04/28  15:03:18  pinnacle
# Created: loft/src/mrkLine/VLrolLinei.I by rchennup for Service Pack
#
 *
 * History:
 * MM/DD/YY  AUTHOR   DESCRIPTION
 * 04/28/00  Jayadev  changes made for TR179901481
 *************************************************************************/
class implementation VLrolLine;

/*******************************************************************************

	Implementation of object defining the line around which a Struct 
		   plate is rolled during manufacture. The result is usually a
		   curve defining the roll line of the corresponding plate. 
		   
===========================================================================****/

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include <stdio.h>
#include "vlprototype.h"
#include "EMSstruct.h"
#include "bserr.h"
#include "msdef.h"
#include "expression.h"
#include "expmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "AS_status.h"
#include "ACrg_collect.h"
#include "ACattrib.h"
#include "exmacros.h"
#include "grmacros.h"
#include "dpmacros.h"
#include "growner.h"
#include "asmacros.h"
#include "graph.h"
#include "nddef.h"
#include "ndmacros.h"
#include "vsglobalmsg.h"
#include "vsplatedef.h"
#include "vsbmaxisdef.h"
#include "vsoptdef.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vscmddef.h"
#include "vsbeam.h"
#include "EMSssprops.h"
#include "vds.h"
#include "vlmsg.h"
#include "vlrolline.h"

/*********************************** DEBUG flags	***********************

#ifndef ROLLINEDEBUG

	#define ROLLINEDEBUG	1 
	#define vsDEBUG		1
	#define vserrDEBUG	1

#endif

*********************************** end DEBUG flags	***********************/

#include "vldbgmacros.h"
#include "vlrolline.h"

/*c	External Functions ****/
extern 			ASmake_source_from_env( struct GRid *,
						struct GRmd_env *,
						struct GRid *,
						int	),
			VLseekFields ( struct ACrg_coll*, int, char* );
 
//c  External Methods

from	ACrg_collect	import	AClist_attribute,
				ACadd_list_attribute;
from    expression      import  init_expr_var, create, NDgive_value;
from    EMSsubbs        import	EMreduce_range;

// External variables

extern  GRclassid
		OPP_VSplate_class_id ,
		OPP_VSfeature_class_id ,
		OPP_VSimgFeature_class_id,
		OPP_ACrg_collect_class_id,
                OPP_GR3dlinestr_class_id,
                OPP_EMScone_class_id,
                OPP_EMScylindr_class_id,
                OPP_GRgrgrp_class_id ,
		OPP_expression_class_id,
		OPP_ACpretend_class_id ;

method ACconstruct_feet (               IGRlong         *ret;
                                        IGRint          cn_type;
                                        IGRint          count;
                         struct         GRid            list[];
                         struct         GRmd_env        *md_env;
                                        IGRint          *fcount;
                         struct         GRid            *feet_list )

{

  IGRboolean RollDirection		=	FALSE;
  IGRlong			msg	=	MSFAIL,
				l_sts	=	MSFAIL;

  IGRint			sts	=	OM_E_INVARG,
				numRollObj =	0,
				num_att	   =	0,
				posn	   =	-1;

  int				TypeSide   =	0; // top/bot of plate
  IGRchar		*	sidename   =	0; // name of side to roll

  GRclassid			TEMP_cl;	// classid for obj typing
  GRobjid			new_objid;
  IGRvector			shipsAxis;  // world axis that ship lies along
  struct GRobj_env		plateObj,   // the parent plate
				plateSideObj,  // the surface to calc the roll
				cp_obj,      // for images
				rollLineObj[VLRolNumFeet],//the roll lines objs
                                GO,
			*	rollLinePtr =	NULL;

  struct GRvg_construct		vg_cnst;	// data used to construct roll
  struct BendingLineInfo	rollLineInfo[VLRolNumFeet];//data require for bending lns
  struct GRid			rollObj	,	// the roll line obj+os
				boiteObj;	// the input parameter box

 struct ACrg_coll       list_att[VLRolMinAtt]; // input from rg collection

 int			i,k,jj,ii,nb_bend_line;
 double			proc_type;
 struct  GRvg_construct  cst;
 struct IGRpolyline    geom;


  if ( !ret || !md_env || !list || !fcount || !feet_list ) {
	__DBGpr_int( " Problem with arguments ret ", ret );
	__DBGpr_int( " Problem with arguments md_env ", md_env );
	__DBGpr_int( " Problem with arguments list ", list );
	__DBGpr_int( " Problem with arguments fcount ", fcount );
	__DBGpr_int( " Problem with arguments feet_list ", feet_list );
	goto wrapup;
  }


  *ret			=	MSFAIL;
  plateSideObj.mod_env	=	*md_env;
  rollObj.objid		=	NULL_OBJID;
  *fcount		=	0;
  VLinitCnst( &vg_cnst );


  boiteObj		= list[0];	// box of parameters
  plateObj.obj_id	= list[1];	// the plate to be rolled
  for (ii=0;ii<VLRolNumFeet;ii++)
    rollLineObj[ii].obj_id.objid = NULL_OBJID;
  
  __DBGpr_obj( "Roll got ACrg_collect object id ",  boiteObj );

  sts = om$send(msg = message ACrg_collect.AClist_attribute( &msg,
							     VLRolMinAtt,
							     list_att,
							     &num_att ),
	    targetid = list[VLRolCollIndex].objid,
	    targetos = list[VLRolCollIndex].osnum);

  __CheckRC( sts, msg, "Roll: ACrg_collect.AClist_attribute", wrapup ) ;
  __DBGpr_int( "ACrg_collect gave attributes",  num_att );
  sts = OM_E_ABORT ;

  if ( num_att < VLRolMinAtt ) goto wrapup;

  if ( (posn = VLseekFields( list_att, num_att, VLTypeSide) ) != -1 ) 
	TypeSide = list_att[TypeSideIndex].desc.value.att_exp;
  else {  __DBGpr_str( "Couldn't find attribute ", VLTypeSide); goto wrapup;}

  if ( (posn = VLseekFields( list_att, num_att, VLRolDirection ) ) != -1 ) 
	RollDirection = list_att[RollDirnIndex].desc.value.att_exp;
  else {__DBGpr_str( "Couldn't find attribute ", VLRolDirection );goto wrapup;}

  if ( (posn = VLseekFields( list_att, num_att, VLRolShipX ) ) != -1 ) 
	shipsAxis[0] = list_att[RollShipXDirnIdx].desc.value.att_exp;
  else {__DBGpr_str( "Couldn't find attribute ", VLRolShipX );goto wrapup;}

  if ( (posn = VLseekFields( list_att, num_att, VLRolShipY ) ) != -1 ) 
	shipsAxis[1] = list_att[RollShipYDirnIdx].desc.value.att_exp;
  else {__DBGpr_str( "Couldn't find attribute ", VLRolShipY );goto wrapup;}

  if ( (posn = VLseekFields( list_att, num_att, VLRolShipZ ) ) != -1 ) 
	shipsAxis[2] = list_att[RollShipZDirnIdx].desc.value.att_exp;
  else {__DBGpr_str( "Couldn't find attribute ", VLRolShipZ );goto wrapup;}

  if ( (posn = VLseekFields( list_att, num_att, VLNbRolLn ) ) != -1 ) {
	nb_bend_line = list_att[VLNbRolLnIdx].desc.value.att_exp;
        if (nb_bend_line > (VLRolNumFeet/2)) nb_bend_line = VLRolNumFeet/2;
  }
  else {__DBGpr_str( "Couldn't find attribute ", VLNbRolLn );goto wrapup;}

  __DBGpr_obj( "Roll got plate object id ",  plateObj.obj_id );
  __DBGpr_int( "Roll got direction",  RollDirection );

        //c  get objects class, if pretend find underlying object

  om$get_classid(	osnum		= plateObj._osnum ,
			objid		= plateObj._objid ,
			p_classid	= &TEMP_cl	) ;

  if( 
    (om$is_ancestry_valid( superclassid  = OPP_ACpretend_class_id, 
                            subclassid    = TEMP_cl ) == OM_S_SUCCESS ) ||
    (om$is_ancestry_valid( superclassid  = OPP_VSimgFeature_class_id, 
                            subclassid    = TEMP_cl ) == OM_S_SUCCESS ) ||
    ( om$is_ancestry_valid( superclassid  = OPP_VSplate_class_id ,
                            subclassid    = TEMP_cl ) == OM_S_SUCCESS ) ) {


  	// should have the plate to be rolled, by now in plateObj

                        /*c
                         * Get side of plate.
                         */

   if( TypeSide == VS_K_baOnTopOfPlate ) sidename        = VS_K_plTopSfPathABS ;
               
   else					sidename        = VS_K_plBotSfPathABS ;
               

   __DBGpr_str( "Plate Type of side wanted", sidename ) ;
   __DBGpr_obj( "Roll got plate object id ",  plateObj.obj_id );

   sts = om$send( msg = message NDmacro.ACreturn_foot(
                                        &msg,
                                        sidename,
                                        &plateSideObj.obj_id,
                                        &plateSideObj._matrix_type,
                                        plateSideObj._matrix ),
                 senderid = NULL_OBJID,
                 targetid = plateObj._objid,
                 targetos = plateObj._osnum ) ;

   __CheckRC( sts, msg, "Roll: Plate NDmacro.ACreturn_foot", wrapup ) ;
   __DBGpr_obj( "Roll: got plateSide object id ",  plateSideObj.obj_id );
   __DBGpr_com( "Roll: trying Alg1" );

   if ( plateSideObj._osnum != md_env->_MD_OS ) {  //if ref obj don't pass md_id
	plateSideObj._md_id = NULL_OBJID ;
	plateSideObj._md_os = plateSideObj._osnum ;
   }

   sts = OM_E_ABORT ;		// set back to failure

  }
  else {
    plateSideObj.obj_id = list[1];
    l_sts = om$send( msg      = message NDnode.ASreturn_go(
                                     &(GO.obj_id),
                                     &(GO.mod_env.md_env.matrix_type),
                                     GO.mod_env.md_env.matrix),
                senderid = NULL_OBJID,
                targetid = list[1].objid,
                targetos = list[1].osnum );
  }

  sts = om$send(msg = message GRgraphics.GRcopy(
                                    &msg,
                                    &plateSideObj.mod_env,
                                    md_env,
                                    &cp_obj.obj_id.objid ),
                     senderid = NULL_OBJID,
                     targetid = plateSideObj.obj_id.objid,
                     targetos = plateSideObj.obj_id.osnum );
  cp_obj.obj_id.osnum = md_env->md_id.osnum;
  cp_obj.mod_env = *md_env;
  if( ! (sts&msg&1)){
       printf( "Error in GRgraphics.GRcopy() ...\n");
       goto wrapup;
  }

  sts = om$send(  msg     = message EMSsubbs.EMreduce_range( &msg,
                               md_env, &new_objid, 1.0 ),
                  senderid = NULL_OBJID,
                  targetid = cp_obj.obj_id.objid,
                  targetos = cp_obj.obj_id.osnum );
  if( ! (sts&msg&1)){
       printf( "Error in EMSsubbs.EMreduce_range() ...\n");
       goto wrapup;
  }
  cp_obj.obj_id.objid = new_objid;
  
  // should take care of rolllines constructed without the proc_type option 
  if(count >2){
  sts = om$send ( msg = message expression.NDgive_value ( &proc_type ),
                       targetid = list[VLRolProcessIndex].objid,
                       targetos = list[VLRolProcessIndex].osnum );
  }
  else proc_type = 2; //TR179901481
  // check the process type here
  if(proc_type == 0 && count > 3 ) // pick graphics option
  {
     IGRint		ind1, ind2;
     struct GRobj_env  	curveObj[VLRolMaxNumTemplates];

     for( i=3; i<count; ++i )
     {
        sts = om$send(msg = message NDmacro.ACreturn_foot(
                                        &msg, "", &curveObj[i-3].obj_id,
                                        &curveObj[i-3]._matrix_type,
                                        curveObj[i-3]._matrix           ),
                targetid = list[i].objid,
                targetos = list[i].osnum  );
        __CheckRC( sts, msg, "NDmacro.ACreturn_foot", wrapup );
        __DBGpr_obj( " Original Curve in model ", curveObj[i-3].obj_id );
        curveObj[i-3]._md_os = curveObj[i-3]._osnum;
        ex$get_modid(   mod_osnum = curveObj[i-3]._md_os,
                        mod_id    = &curveObj[i-3]._md_id ) ;
     }

     for( i=0; i<count-3; ++i )
     {
	if( i ==0 ) {  ind1 = 0;     ind2 = 2; }
	else	    {  ind1 = 2*i+1; ind2 = 2*(i+1); }

        __DBGpr_obj("Copying the curve to foot", curveObj[i]._grid );
        sts = vs$grCopy(msg     = &msg,
                        frEnv   = &curveObj[i].mod_env,
                        frObj   = &curveObj[i]._grid,
                        toEnv   = md_env,
                        toObj   = &feet_list[ind1] ) ;
	__CheckRC( sts, msg, "vs$grCopy", wrapup );

	sts = exp$create( exp_syntax = "dummy",
			  p_exp_id   = &feet_list[ind2].objid,
			  p_osnum    = &feet_list[ind2].osnum,
			  type_rq    = EXP_TEXT );
        __CheckRC( sts, 1, "exp$create", wrapup );
     }

     *fcount = 2*(count-3) + 1;
     // create a feet rg_collection
     feet_list[ VLRolContsIndex].objid = NULL_OBJID;
     feet_list[ VLRolContsIndex].osnum = md_env->md_id.osnum;
     l_sts = om$construct(classid    = OPP_ACrg_collect_class_id,
                       osnum   = feet_list[ VLRolContsIndex].osnum,
                       p_objid = &feet_list[ VLRolContsIndex].objid ,
                       msg = message ACrg_collect.ACadd_list_attribute
                                          (&msg, num_att , list_att ) );
     *ret = sts = OM_S_SUCCESS;
     goto wrapup;
  }
  else if(proc_type == 1)
  {
      l_sts = VLfindBendLine(  &cp_obj,
                               &vg_cnst,
                               RollDirection,
                               &nb_bend_line,
                               shipsAxis,
                               rollLineInfo,
                               rollLineObj,
                               &msg );
      __CheckRC(l_sts, msg, "Roll: VLfindBendLine", wrapup );
  }
  else if(proc_type == 2)
  {
      l_sts = VLfindNewBendLine(  &cp_obj,
                                  &vg_cnst,
                                  RollDirection,
                                  &nb_bend_line,
                                  shipsAxis,
                                  rollLineInfo,
                                  rollLineObj,
                                  &msg );
      __CheckRC(l_sts, msg, "Roll: VLfindBendLine", wrapup );
  }

  VLinitCnst(&cst);
  cst.env_info  = md_env;
  cst.properties        &=  ~(GRIS_DISPLAYABLE | GRIS_LOCATABLE);
  geom.num_points = 1;
  cst.geometry = (char *)&geom;

  // create a feet rg_collection
  feet_list[ VLRolContsIndex].objid = NULL_OBJID;
  feet_list[ VLRolContsIndex].osnum = md_env->md_id.osnum;
  l_sts = om$construct(classid    = OPP_ACrg_collect_class_id,
                       osnum   = feet_list[ VLRolContsIndex].osnum,
                       p_objid = &feet_list[ VLRolContsIndex].objid ,

                       msg = message ACrg_collect.ACadd_list_attribute
                                          (&msg, num_att , list_att ) );
  if (!(l_sts&msg&1)) goto wrapup;

  (*fcount)++;
  for (jj=VLRolIndex,ii=0;ii<nb_bend_line;ii++)
  {
   if (
       (vs$is_ancestry_valid( object   = &(GO.obj_id),
                              classid = OPP_EMScone_class_id )
                  == FALSE) &&
       (vs$is_ancestry_valid( object   = &(GO.obj_id),
                              classid = OPP_EMScylindr_class_id )
                  == FALSE)
      ) {
    if (rollLineObj[ii].obj_id.objid != NULL_OBJID) 
       rollLinePtr = &rollLineObj[ii];
    else rollLinePtr = NULL;
    l_sts = VLdrawBendLine(	&cp_obj,
				&rollLineInfo[ii],
                                rollLinePtr, 
				&vg_cnst,
				NULL,
				&rollObj,
				&numRollObj,
				&msg );
    __CheckRC(l_sts, msg, "Roll: draw failed", wrapup );
   } 
   else {
     rollObj = rollLineObj[ii].obj_id;
   }

  // if rollObj is a graphic group, we get its components and we drop it.
    if ((vs$is_ancestry_valid( object   = &(rollObj),
                              classid = OPP_GRgrgrp_class_id )
                  == TRUE)) {
    int NumComp = 0,numRet = 0;
    int kk;
    struct GRid *ListIds = NULL;

       l_sts = om$send( msg = message GRowner.GRget_number_components(
                                                            &msg,
                                                            &NumComp ),

                         senderid = NULL_OBJID,
                         targetid = rollObj.objid,
                         targetos = rollObj.osnum );
       ListIds = (struct GRid *) 
                    om$malloc( size =  NumComp * sizeof( struct GRid ) );
       if (ListIds == NULL) goto wrapup;

       l_sts = om$send( msg = message GRowner.GRget_components(
                                        &msg,
                                        md_env,
                                        ListIds,
                                        NumComp,
                                        &numRet,
                                        (IGRint) 0,
                                        OM_K_MAXINT ),

                         senderid = NULL_OBJID,
                         targetid = rollObj.objid,
                         targetos = rollObj.osnum );
       if( !(l_sts&(msg)&1) ){
                printf("GRowner.GRget_components: Failde\n");
                goto wrapup;
        }

        l_sts = om$send( msg = message GRowner.GRdrop(
                                        &msg,
                                        md_env),
                         senderid = NULL_OBJID,
                         targetid = rollObj.objid,
                         targetos = rollObj.osnum );
        if( !(l_sts&msg&1) ){
                printf("GRowner.GRdrop: Failde\n");
                goto wrapup;
        }

        geom.points     = rollLineInfo[ii].normal;
        for (kk=0;kk<numRet;kk++)
        {
         feet_list[jj] = ListIds[kk];
         // construct vector feet
         if (jj==VLRolIndex) k=jj+2;  /* because the second feet position
                                         is reserved to the rg_collection
                                         to be compatible with genlines */
         else k=jj+1;
         feet_list[k].osnum = md_env->md_id.osnum;
         feet_list[k].objid = NULL_OBJID;
         sts = om$construct(classid = OPP_GR3dlinestr_class_id,
                            p_objid = &feet_list[k].objid,
                            osnum   = feet_list[k].osnum,
                            msg     = message GRgraphics.GRaltconstruct(&cst) );
         if (jj==VLRolIndex) jj += 3; /* because the second feet position
                                         is reserved to the rg_collection
                                         to be compatible with genlines */
         else jj += 2;
        }
        *fcount += 2*numRet;
        if (ListIds != NULL) {om$dealloc(ptr=ListIds); ListIds = NULL;}
    }
    else {
      feet_list[jj] = rollObj;

     // construct vector feet
      geom.points     = rollLineInfo[ii].normal;
      if (jj==VLRolIndex) k=jj+2;     /* because the second feet position
                                         is reserved to the rg_collection
                                         to be compatible with genlines */
      else k=jj+1;
      feet_list[k].osnum = md_env->md_id.osnum;
      feet_list[k].objid = NULL_OBJID;
      sts = om$construct( classid = OPP_GR3dlinestr_class_id,
                          p_objid = &feet_list[k].objid,
                          osnum   = feet_list[k].osnum,
                          msg     = message GRgraphics.GRaltconstruct(&cst) );

      if (jj==VLRolIndex) jj += 3; /* because the second feet position
                                         is reserved to the rg_collection
                                         to be compatible with genlines */
      else jj += 2;
      (*fcount) += 2;
    }
  }
  *ret = sts = OM_S_SUCCESS;

wrapup:				// ******  WRAPUP HERE		***************

   if (
       (vs$is_ancestry_valid( object   = &(GO.obj_id),
                              classid = OPP_EMScone_class_id )
                  == FALSE) &&
       (vs$is_ancestry_valid( object   = &(GO.obj_id),
                              classid = OPP_EMScylindr_class_id )
                  == FALSE)
      ) {
      for (ii=0;ii<nb_bend_line; ii++) 
      { 
        if (rollLineObj[ii].obj_id.objid != NULL_OBJID) 
          om$send( msg      = message GRgraphics.GRdelete
                                            ( &msg, md_env),
                               senderid = NULL_OBJID,
                               targetid = rollLineObj[ii].obj_id.objid,
                               targetos = rollLineObj[ii].obj_id.osnum);
      }
   }
     om$send( msg      = message GRgraphics.GRdelete
                                            ( &msg, md_env),
                               senderid = NULL_OBJID,
                               targetid = cp_obj.obj_id.objid,
                               targetos = cp_obj.obj_id.osnum);
  	return sts;

}  // end ACconstruct_feet

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*

method VLplaceRollLine(
               IGRlong	*	ret;		// standard return code
               int		TypeSide;	// which side of plate to mark
	       int		ProcessType;	// Process Type
               int		Direction;	// direction of surface to roll
               IGRvector	shipsAxis;	// central axis of the ship
               IGRint		nb_rol_line;	// number of roll line required
               struct GRobj_env list[];		// list of templates
               struct GRmd_env  *md_env;	// module of current file
	       IGRint		*nbCrvs;
	       struct GRobj_env Crvs[]
              )
{
  int		i, nb_temp;
  char		syntax[200];
  struct GRid	temp[VLRolMaxNumTemplates];	// templates for this object

  struct	ACrg_coll ACrg[VLRolMinAtt];   // collections for param templ

  IGRlong	l_msg	= MSFAIL;		// long return from methods

  IGRint	sts	= OM_E_INVARG,		// status from messages
		i_msg   = MSFAIL,		// int  return from methods
		paramIndex;			// index of param in collectn

  if ( !ret || !md_env || !list || !nb_rol_line || !shipsAxis ) {
	__DBGpr_int( " Problem with arguments? ret ", ret );
	__DBGpr_int( " Problem with arguments? md_env ", md_env );
	__DBGpr_int( " Problem with arguments? list", list );
	__DBGpr_int( " Problem with arguments? nb_rol_line", nb_rol_line );
	__DBGpr_int( " Problem with arguments? shipsAxis ", shipsAxis );
	goto wrapup;
  }

  *ret = MSFAIL;

  paramIndex = 0;
  strcpy( ACrg[paramIndex].name, VLTypeSide );
  ACrg[paramIndex].desc.type = AC_ATTRIB_DOUBLE;
  ACrg[paramIndex].desc.value.att_exp = TypeSide;
  paramIndex++;

  strcpy(ACrg[paramIndex].name, VLRolDirection );
  ACrg[paramIndex].desc.type = AC_ATTRIB_DOUBLE;
  ACrg[paramIndex].desc.value.att_exp = Direction;
  paramIndex++;

  strcpy(ACrg[paramIndex].name, VLRolShipX );
  ACrg[paramIndex].desc.type = AC_ATTRIB_DOUBLE;
  ACrg[paramIndex].desc.value.att_exp = shipsAxis[0];
  paramIndex++;

  strcpy(ACrg[paramIndex].name, VLRolShipY );
  ACrg[paramIndex].desc.type = AC_ATTRIB_DOUBLE;
  ACrg[paramIndex].desc.value.att_exp = shipsAxis[1];
  paramIndex++;

  strcpy(ACrg[paramIndex].name, VLRolShipZ );
  ACrg[paramIndex].desc.type = AC_ATTRIB_DOUBLE;
  ACrg[paramIndex].desc.value.att_exp = shipsAxis[2];
  paramIndex++;

  strcpy(ACrg[paramIndex].name, VLNbRolLn );
  ACrg[paramIndex].desc.type = AC_ATTRIB_DOUBLE;
  ACrg[paramIndex].desc.value.att_exp = nb_rol_line;
  paramIndex++;

  temp[VLRolCollIndex].osnum = md_env->md_id.osnum;
  sts = om$construct(classid	= OPP_ACrg_collect_class_id,
                        osnum   = temp[VLRolCollIndex].osnum,
                        p_objid = &temp[VLRolCollIndex].objid);

  __CheckRC( sts, 1, "Roll: OMconstruct ACrg_collect ", wrapup ) ;

  sts = om$send( msg = message NDnode.NDchg_state(
						(IGRchar) ND_DONT_MVRT,
                                                (IGRchar) ND_DONT_MVRT),
           targetid = temp[VLRolCollIndex].objid,
           targetos = temp[VLRolCollIndex].osnum );

  __CheckRC( sts, 1, "Roll: NDchg_state for ACrg_collect ", wrapup ) ;

  sts = om$send(msg = message ACrg_collect.ACadd_list_attribute
                   				     (&l_msg, paramIndex, ACrg),
              targetid = temp[VLRolCollIndex].objid,
              targetos = temp[VLRolCollIndex].osnum);
  __CheckRC( sts, l_msg, "Roll: ACrg_collect.ACadd_list ", wrapup ) ;

  /* Create expression for Process Type */
  temp[VLRolProcessIndex].osnum = md_env->md_id.osnum ;
  sts = om$construct(classid = OPP_expression_class_id,
                        osnum = md_env->md_id.osnum,
                        p_objid = &temp[VLRolProcessIndex].objid,
			msg     = message expression.init_expr_var () );

  sprintf ( syntax, "%d", ProcessType );
  sts = om$send(msg = message expression.create( NULL, syntax, &l_msg ),
                   senderid = NULL_OBJID,
                   targetid =  temp[VLRolProcessIndex].objid,
                   targetos = temp[VLRolProcessIndex].osnum );

  if( ProcessType == 0 && nbCrvs && Crvs && (*nbCrvs)>0 )
  {
    for( i=0; i<(*nbCrvs); ++i )
    {
	sts = as$make_source( 	go_grid =  Crvs[i].obj_id,
				mod_env = &Crvs[i].mod_env,
				as_os   = md_env->md_id.osnum,
				as_grid = &temp[3+i]  		);	
    }
    nb_temp = 3+(*nbCrvs);
  }
  else nb_temp = 3;

  sts = as$make_source(	go_grid	= list[0].obj_id,
              		mod_env	= &list[0].mod_env,
               		as_os	= md_env->md_id.osnum,
               		as_grid	= &temp[VLRolPlateIndex]);
  __CheckRC( sts, 1, "Roll: make source ", wrapup ) ;

  sts = om$send(  msg  = message VLrolLine.ACmplace(
                                          &i_msg,
                                          AChdr_noprotect | AChdr_nodisplay, 
					  0,
                                          VLMacroRolLn,
                                          nb_temp,
                                          temp,
                                          md_env ),
                 targetid = my_id );

  __CheckRC( sts, i_msg, "Roll: ACncpx.ACmplace ", wrapup ) ;

  *ret = OM_S_SUCCESS;

wrapup:			// ******  WRAPUP HERE		*************

  return sts;

} 		// end place Roll Line

method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

        long            sts ;   /* OM return code       */

        /*
         * name.
         */
        myDef->info             = VL_I_ObjRollLine;
        myDef->type             = 0 ;

        sts     = OM_S_SUCCESS ;
        *msg    = MSSUCC ;

        return sts ;
} /* method VDgetObjdDef */
/*----------------------------------------------------------------------------*/

end implementation VLrolLine;
