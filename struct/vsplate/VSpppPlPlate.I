/* $Id: VSpppPlPlate.I,v 1.3 2001/02/14 20:53:09 jayadev Exp $ */

/******************************************************************************
 * I/STRUCT
 *
 * File:   struct/vsplate/VSpppPlPlate.I
 *
 * Description:
 *
 *      This file contains function VSppp_post_place_plate which is called by
 *      the post_placement function in struct/ppl/bin/VSpppPlPlate.u.
 *
 *      This function gets the feet of the structural detail macro that are
 *      needed as input to vs$place_plate which creates and places the plate.
 *	If the feet don't contain all the inputs then the values are obtained
 *	from tables or the last placed plate (Default Parameter Block value).
 *
 *	Inputs:
 *	   plate surface
 *         thickness
 *         grade
 *         material
 *         family
 *         part number
 *
 *      Naming Convention (expected):
 *         "plt", "plt1", "plt2", etc for plate surface (can start with either
 *                                "plt" or "plt1")
 *         "thk"(default thickness value for all plates to be placed), "thk1", 
 *              "thk2", etc
 *         "matl"(material), "grade"(grade), "fam"(family of plates) follow
 *              thickness naming convention
 *         "partNum" is the only name for part number since it is retrieved
 *              from the database, not the macro
 *         
 * Note:
 *      User needs to be logged into database to prevent an error message from
 *      being printed to the screen. A plate can still be placed without being
 *	logged in - used hardcoded input, but, still got the error messages,
 *	"Error in VdsRisSelect: Cannot open Ris Schema" and "place plate ERROR:
 *	Query of type for '0.1875 in' failed". The extract routines also require
 *	access to the database.
 *
 * Note:
 *	File, vdmisc/VDfndftinmc.I, module VD_findMatchFtNameSlSfInMacro, had
 *	to be modified to accept macro feet created through the VSselector 
 *	class for this CR.
 *
 * Note:
 *	The macro definition needs a placement option of "~~post_placement"  
 *	and a value of "VSpppPlPlate", the PPL function and PPL file,
 *	respectively.
 *
 * Revision History:
 *	$Log: VSpppPlPlate.I,v $
 *	Revision 1.3  2001/02/14 20:53:09  jayadev
 *	fix for etl#6459
 *	
 *	Revision 1.2  2001/01/17 00:16:22  ramarao
 *	*** empty log message ***
 *	
# Revision 1.2  2000/11/15  17:46:48  pinnacle
# Replaced: struct/vsapis/VSpppPlPlate.I for:  by jpulapar for Service Pack
#
# Revision 1.1  2000/10/26  16:18:56  pinnacle
# Created: struct/vsplate/VSpppPlPlate.I by jpulapar for Service Pack
#
# Revision 1.1  2000/05/18  18:42:08  pinnacle
# Created: struct/vsapis/VSpppPlPlate.I by rchennup for Service Pack
#
# Revision 1.5  2000/04/03  17:54:48  pinnacle
# Replaced: vsplate/VSpppPlPlate.I for:  by impd252 for struct
#
# Revision 1.4  1999/10/13  13:55:44  pinnacle
# tr179900763
#
# Revision 1.3  1999/03/30  19:59:12  pinnacle
# tr179900374
#
# Revision 1.2  1999/02/25  22:11:08  pinnacle
# TR_179900374: Process a set of macros, too
#
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.5  1998/04/26  14:22:32  pinnacle
# ah
#
# Revision 1.4  1998/03/05  16:58:20  pinnacle
# Replaced printf("Constructed plate") with UI_status
#
# Revision 1.3  1998/02/17  19:42:20  pinnacle
# TR_179800356: Added capability to delete existing plates
#
 *	
 * History:
 *      08/20/97    ejm     CR179701702: Generate code to automatically
 *                          provide post placement of non-parametric 
 *			    plate(s) to structural detail macros. Created
 *			    this file.
 *      02/11/98    ejm     TR179800356: recoded retrieval of family value: if
 *			    RDB values do not match, first, foot value, or,
 *			    second, active value, then first RDB plate family
 *			    value is used in placing a plate.
 *			    Added capability to delete existing plates.
 *      04/26/98    ah      Still getting error messages even though plate 
 *			    places, dpbmsg needed initing
 *      02/25/99    ejm     TR179900374: Allow a set of macros to be processed.
 *			    Replace an existing plate if attribute info has 
 *			      been updated; keep count of new plates.
 *      03/30/99    ah      TR179900374: Suppressed the plate deletion, always
 *                            keep an existing plate per Cameron's request 
 *      08/20/99    ah      TR179900763: Attach plate to actual EMSplane object
 *			      instead of to the pla_encomp macro. Extra pla_
 *			      encomp generated when plate was recomputed.
 *	04/03/00    adz	     TR179901287: Inform when no 'plt' are found.
 *      05/18/00    Rama Rao Called VSget_actual_go() to get the actual
 *                           surface graphics.
 *      10/26/00    Jayadev Problem finding cached data for usage -
 *			    prompt the user to plate a plate manually
 *      02/14/00    Jayadev etl#6459 RDB thickness for post placement plates 
 **************************************************************************** */


class implementation Root;

#include <stdio.h>
#include "OMerrordef.h"    /* OM_S_SUCCESS                                    */
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"         /* struct IGRdisplay                               */
#include "gr.h"		   /* GRid                                            */
#include "growner.h"       /* GRobj_env, requires igrtypedef,igetypedef,gr.h  */
#include "asmacros.h"      /* as$make_source				      */
#include "vs.h"            /* for vsAPImacros.h                               */
#include "vsdpb.h"         /* VS_e_dpb_P_thkname                              */
#include "vsgeommacros.h"  /* vs$get_components                               */
#include "vsmiscmacros.h"  /* vs$is_ancestry_valid, vs$bulk_delete            */
#include "vsdpbmacros.h"   /* vs$get_act_pm, default parameter block macros   */
#include "vsRDBmacros.h"   /* extract_materials_from_RDB                      */
#include "msdef.h"         /* MSSUCC,  MS_MAX_MSG_LENGTH [512]                */
#include "expression.h"    /* EXP_MAX_LEN [128]                               */
#include "parametric.h"    /* struct ret_struct, double_type, text_type       */
#include "VDmem.h"	   /* _LOOPFREE					      */
#include "v_fndslsinmc.h"  /* prototype of VD_findMatchFtNameSlSfInMacro      */

#define  NAM_LEN 7 	   /* macro foot name length, appears in vsppltproto.h*/
#include "vsppltproto.h"   /* prototypes of functions in this module          */
#include "vselmsonsupp.h"  /* VSgetElementsOnSupport prototype		      */

#include "VDobj.h"

/*
#define  vsDEBUG
*/

#include "vsdbgmacros.h"   /* __DBGpr_com                                     */
#include "vsAPImacros.h"   /* vs$get_plate_attributes, vs$place_plate	      */


extern	    OMuword  OPP_VSselector_class_id ;
extern void UI_message();
extern void UI_status ();
extern int  VSisLoggedIntoRDB();
extern      VSfreeList();

from  expression   import  list;
from  NDnode       import  NDgive_structure;




/* -------------------------------------------------------------------------- */
/* Support routine to obtain macro foot value				      */
/* O: msg,      Internal routine message returned			      */
/* I: ftCount,	Number of macro feet					      */
/* I: ftList, 	List of feet with same name found in macro		      */
/* O: obj_type, Expression type (text or double) returned		      */
/* O: txtInfo,  Foot value if textual, else NULL			      */
/* O: dbInfo,   Foot value if double,  else NULL			      */

IGRlong VSpp_get_feetInfo( IGRlong		*msg,
			   IGRint		ftCount,
			   struct GRobj_env	*ftList,
			   IGRint		obj_type,
			   IGRchar		*txtInfo,
			   IGRdouble		*dbInfo )
{
	struct	GRid		*Comps = NULL ;
	struct	GRid		footId ;
	struct  ret_struct	rs;       /* union of different data types */
	IGRint			count = 0 ;
	IGRint			sts = MSFAIL ;

	SetProc( VSpp_get_feetInfo ); Begin

	*msg = MSFAIL ;

	if( ftCount == 0 )	return sts ;

        if( vs$is_ancestry_valid(
                                object  = &ftList[0]._grid,
                                classid = OPP_VSselector_class_id )){

	  sts = vs$get_components( msg        = msg,
				   grobjId    = &ftList[0].obj_id,
				   grobjEnv   = &ftList[0].mod_env,
				   number     = &count,
				   components = &Comps );
	  if( !(sts&*msg&1) ){
	    __DBGpr_com("VSpp_get_feetInfo: vs$get_components failed");
	    sts = MSFAIL;
	    goto wrapup;
	  }

	  __DBGpr_int(" VSselector Component Count ", count );

	  footId = Comps[0] ;
	}
	else{
	  footId = ftList->obj_id ;
	}  
	__DBGpr_obj(" Object ", footId );

	sts =
	om$send(msg = message NDnode.NDgive_structure(msg,&rs,NULL),
                senderid = NULL_OBJID,
                targetid = footId.objid,
                targetos = footId.osnum );

	if( rs.type != obj_type) {
	  __DBGpr_com("VSpp_get_feetInfo: Object has unexpected output type");
	  sts = MSFAIL;
	  goto wrapup;
	}

	if( obj_type == text_type ){
          __DBGpr_com("TEXTUAL expression found");
	  strcpy( txtInfo, rs.var.text_st.text_string );
	  *msg = MSSUCC ; sts = OM_S_SUCCESS ;
	}

	if( obj_type == double_type) {
          __DBGpr_com("DOUBLE expression found");
	  *dbInfo = rs.var.root_pm_st.value;
	  *msg = MSSUCC ; sts = OM_S_SUCCESS ;
	}

wrapup:
	if(Comps) {free(Comps); Comps=NULL;}
	End
	return sts ;

} /* VSpp_get_feetInfo */

/* -------------------------------------------------------------------------- */
/* Look for foot name in macro, return count and object environment of each   */
/* O: msg,	message status         */
/* I: MACRO_ID, id of macro selected   */
/* I: MACRO_ENV,env of macro selected  */
/* I: ftName,   macro foot name        */
/* O: ftList,   list of feet with name */
/* O: ftCount,  value found flag       */

IGRlong VSpp_findMatch ( IGRlong	 *msg,
		 	struct GRid      MACRO_ID,
		 	struct GRmd_env  MACRO_ENV,
		 	IGRchar          ftName[NAM_LEN],
		 	struct GRobj_env **ftList,
		 	IGRint 		 *ftCount )
{
  IGRboolean	ans=0;
  IGRlong	i, sts=MSSUCC;


  SetProc(VSpp_findMatch); Begin

  *msg = MSSUCC ;

  sts = VD_findMatchFtNameSlSfInMacro( msg,
 				       &MACRO_ID, &MACRO_ENV,
				       ftName,
				       1,
				       ftList,
				       ftCount );

  if( !(sts&*msg&1) ){
    __DBGpr_str("VD_findMatchFtNameSlSfInMacro did not work for", ftName);
    goto wrapup;
  }

  if( *ftCount == 0 )
  {
    /* Remove digits to get default name */
    for( i=0; i<NAM_LEN; i++ )
    {
       ans = isdigit(ftName[i]);
       if( ans ){
	 ftName[i] = '\0';
	 break;
       }
    }

    sts = VD_findMatchFtNameSlSfInMacro( msg,
                                         &MACRO_ID, &MACRO_ENV,
                                         ftName,
                                         1,
                                         ftList,
                                         ftCount );

    if( !(sts&*msg&1) ){
      __DBGpr_str("VD_findMatchFtNameSlSfInMacro did not work for", ftName);
      goto wrapup;
    }
  }

wrapup:

  End

  return sts;

} /* VSpp_findMatch */

from NDnode import ASreturn_go;

/* -------------------------------------------------------------------------- */
/* Routine called for automatically placing a plate after a macro has been    */
/* placed.								      */
/* I: MACRO_ID,		id of macro selected				      */
/* I: MACRO_MOD_ENV	module environment of macro selected		      */
/* O: ctPlates		count of plates placed			              */	
IGRlong   VSppp_post_place_plate( struct GRid     MACRO_ID, 
			          struct GRmd_env MACRO_MOD_ENV,
				  IGRint 	 *ctPlates )
{
  long			msg, dpbmsg;
  IGRlong		sts, i, j,
			numsurfs;	/* Number of surfaces found           */
  IGRint                ftCount;        /* Number of feet of item in macro    */
  int 			p_count,	/* Count of extracted RDB items       */
			pltcnt;
  struct  GRobj_env    *ftList ;        /* List of macro feet objects         */
  struct  GRid		plateId;	/* Id of plate placed		      */
  struct  GRid		surfaceId;
  struct  GRid         *pltList;	/* List of existing plates on surface */
  struct  GRid		as_grid;	/* Source id of existing plates       */
  struct  GRmd_env      surfaceEnv;

  char    num[NAM_LEN],
          plt[NAM_LEN], 
          thk[NAM_LEN],
          grade[NAM_LEN],
          matl[NAM_LEN],
          fam[NAM_LEN];

  char    id_str[NAM_LEN];

  char    *actAttr=NULL, *thkname=NULL;
  char    Material[EXP_MAX_LEN],
	  Grade[EXP_MAX_LEN],
	  partNum[EXP_MAX_LEN],
	  Family[EXP_MAX_LEN],
	  famFoot[EXP_MAX_LEN];
  char	  pltType[EXP_MAX_LEN],
	  pltGrade[EXP_MAX_LEN],
	  pltFam[EXP_MAX_LEN],
	  pltNum[EXP_MAX_LEN];
  double  pltThk;
  double  Thickness, p_Thickness;

  char    **p_materials;    /* List of materials */
  char    **p_plates;       /* List of plates    */
  char    errStr[MS_MAX_MSG_LENGTH];

  TGRobj_env goOE;
  
  SetProc( VSppp_post_place_plate ); Begin

  // Init
  msg = MSSUCC ;
  sts = OM_S_SUCCESS;
  dpbmsg = 1;

  Thickness   = 0.0;
  p_Thickness = 0.0;
  pltThk      = 0.0;

  ftCount  = 0 ;
  ftList   = NULL ; 
  p_count  = 0 ;
  p_plates = NULL ;
  pltcnt   = 0;
 *ctPlates = 0;


  /* check to see if the user is logged into PDM */
  if(!VSisLoggedIntoRDB())
  {
          UI_status("You need to log in to PDM");
          printf("You need to log in to PDM\n");
          sts = -1;
          goto wrapup;
  }

  /* Determine number of plate surfaces (not expecting "plt0") */
  numsurfs = 0;

  sts = VD_findMatchFtNameSlSfInMacro( &msg,
 		         &MACRO_ID, &MACRO_MOD_ENV,
		         "plt",
		         1,
		         &ftList,
		         &ftCount );

  if( !(sts&msg&1) ){
    __DBGpr_com("VD_findMatchFtNameSlSfInMacro did not work for plt");
    sprintf(errStr, "%s %d", "Missing surface with 'plt' in macro,", MACRO_ID.objid);
    UI_status(errStr);
    printf("%s\n", errStr );
    goto wrapup;
  }

  if( ftCount > 0 ) numsurfs++;

  for(i=1;;i++)
  {
    plt[0] = '\0';
    strcpy(plt, "plt");
    sprintf(num,"%d",i);
    strcat(plt, num);

    sts = VD_findMatchFtNameSlSfInMacro( &msg,
 				         &MACRO_ID, &MACRO_MOD_ENV,
				         plt,
				         1,
				         &ftList,
				         &ftCount );

    if( !(sts&msg&1) ){
      __DBGpr_str("VD_findMatchFtNameSlSfInMacro did not work for ", plt);
      goto wrapup;
    }

    if( ftCount == 0 ) break;
    else numsurfs++;
  }

  __DBGpr_int("Number of plate surfaces in macro", numsurfs);

  if( numsurfs == 0 ){

    sprintf(errStr, "%s %d", "Missing surface with 'plt' or 'plt0' in macro,", MACRO_ID.objid);
    UI_status(errStr);
    printf("%s\n", errStr );
    goto wrapup;
  }

  /* Place a plate for each surface */
  for(i=1; i<numsurfs+1; i++)
  {
    for(j=0;j<EXP_MAX_LEN;j++){
	partNum[j]  = '\0';
	Family[j]   = '\0';
	famFoot[j]  = '\0';
	Material[j] = '\0';
	Grade[j]    = '\0';
    }

/* ************************  plate number  ********************************** */

    plt[0] = '\0';
    strcpy(plt, "plt");
    sprintf(num,"%d",i);
    strcat(plt, num);

    ftCount=0;
    sts = VSpp_findMatch(&msg, MACRO_ID, MACRO_MOD_ENV, plt, &ftList, &ftCount);

    if( !(sts&msg&1) ){
      __DBGpr_com("VDpp_findMatch: failed");
      goto wrapup;
    }

    /* Expecting(!) a plate */
    surfaceId  = ftList->obj_id;
    surfaceEnv = ftList->mod_env;

    if(ftList) {free(ftList); ftList=NULL;}

    __DBGpr_int("\n\tsurfaceId.objid", surfaceId.objid);

    /* Delete any existing plate on the surface */
    as$make_source( go_grid         = surfaceId,
                    mod_env         = &surfaceEnv, 
		    as_grid         = &as_grid ) ;

    /* vdobj$Print(objID = &as_grid); */
    
    /*
     * See if there is a plate among children.
     */
    sts = VSgetElementsOnSupport( &msg, &as_grid, VS_m_SRC_PLATE,
                                  FALSE, &pltcnt, &pltList) ;
    if( !(sts&msg&1) ){
      __DBGpr_com("VSgetElementsOnSupport: failed");
      goto wrapup;
    }

    /* ONLY one plate per surface! */
    if (pltcnt > 0) goto wrapup;  // TR1799000374 ah Suppress this, keep plate
    
    if( pltcnt > 0 )
    {
      pltThk = 0.0;
      for(j=0;j<EXP_MAX_LEN;j++){
	pltType[j]  = '\0';
	pltGrade[j] = '\0';
	pltFam[j]   = '\0';
	pltNum[j]   = '\0';
      }

      /* Get plate attributes to compare further down with RDB info. If */
      /*   plate attributes are up-to-date, this plate will be kept,    */
      /*   else, it will be replaced.					*/
	 
      vs$get_plate_attributes(	msg	  = &msg,
				plateId   = &pltList[0],
				matType   = &pltType[0],
				matGrade  = &pltGrade[0],
				partFam   = &pltFam[0],
				partNum   = &pltNum[0],
				thickness = &pltThk );

      __DBGpr_int("Existing plate attributes on surface", surfaceId.objid);
      __DBGpr_str("  pltType ", pltType);
      __DBGpr_str("  pltGrade", pltGrade);
      __DBGpr_str("  pltFam  ", pltFam);
      __DBGpr_str("  pltNum  ", pltNum);
      __DBGpr_dbl("  pltThk  ", pltThk);
    }

/* *************************  thickness  ************************************ */

    thk[0] = '\0';
    strcpy(thk, "thk");
    sprintf(num,"%d",i);
    strcat(thk, num);

    ftCount=0;
    sts = VSpp_findMatch(&msg, MACRO_ID, MACRO_MOD_ENV, thk, &ftList, &ftCount);

    if( !(sts&msg&1) ){
      __DBGpr_com("VDpp_findMatch: failed");
      goto wrapup;
    }

    if( ftCount > 0 )
    {
	sts = VSpp_get_feetInfo( &msg, ftCount, ftList,
				 double_type, NULL, &Thickness  );
	if( !( sts & msg & 1 )){
          __DBGpr_com("Thickness expression is not text");
          goto wrapup;
	}
    }
    else  /* Expecting an active value */
    {
      vs$get_act_pm(  msg     = &dpbmsg,
                      param   = VS_e_dpb_P_thickness,
                      p_arg   = &Thickness ) ;

      if( !( dpbmsg & 1 ) ){
        __DBGpr_com("vs$get_act_pm failed retrieving Thickness");
        goto wrapup ;
      }
    }

    if(ftList) {free(ftList); ftList=NULL;}

    __DBGpr_dbl("Thickness", Thickness );

/* ***************************  grade  ************************************** */

    grade[0] = '\0';
    strcpy(grade, "grade");
    sprintf(num,"%d",i);
    strcat(grade, num);

    ftCount=0;
    sts = VSpp_findMatch(&msg, MACRO_ID, MACRO_MOD_ENV, grade, &ftList, &ftCount);

    if( !(sts&msg&1) ){
      __DBGpr_com("VDpp_findMatch: failed");
      goto wrapup;
    }

    if( ftCount > 0 )
    {
	sts = VSpp_get_feetInfo( &msg, ftCount, ftList,
				 text_type, Grade, NULL );
	if( !( sts & msg & 1 )){
          __DBGpr_com("Thickness expression is not text");
          goto wrapup;
	}
    }
    else  /* Expecting an active value */
    {
      vs$get_act_pm(  msg     = &dpbmsg,
                      param   = VS_e_dpb_P_grade,
                      p_arg   = &actAttr ) ;

      if( !( dpbmsg & 1 ) ){
        __DBGpr_com("vs$get_act_pm failed retrieving grade");
        goto wrapup ;
      }
    }

    if(ftList) {free(ftList); ftList=NULL;}

    __DBGpr_str("Grade", Grade );

/* **************************  material  ************************************ */

    matl[0] = '\0';
    strcpy(matl, "matl");
    sprintf(num,"%d",i);
    strcat(matl, num);

    ftCount=0;
    sts = VSpp_findMatch(&msg, MACRO_ID, MACRO_MOD_ENV, matl, &ftList, &ftCount);

    if( !(sts&msg&1) ){
      __DBGpr_com("VDpp_findMatch: failed");
      goto wrapup;
    }

    if( ftCount > 0 )
    {
	sts = VSpp_get_feetInfo( &msg, ftCount, ftList,
				 text_type, Material, NULL );
	if( !( sts & msg & 1 )){
          __DBGpr_com("Material expression is not text");
          goto wrapup;
	}
    }
    else if( ftCount == 0 )
    {
      vs$extract_materials_from_RDB(   msg          = &msg,
                                       errStr       = errStr,
                                       p_count      = &p_count,
                                       p_materials  = &p_materials );
      if( !(msg&1) ){
        __DBGpr_str("vs$extract_materials_from_RDB had an error", errStr);
        VSfreeList( p_count, p_materials );
        goto wrapup;
      }

      __DBGpr_int("Number of materials from RDB",  p_count );

      if( p_count == 1 )
        strcpy( Material, p_materials[0] );
      else{
        vs$get_act_pm(    msg     = &dpbmsg,
                          param   = VS_e_dpb_P_material,
                          p_arg   = &actAttr ) ;

        if(   !( dpbmsg & 1 ) ) goto wrapup ;
        if(actAttr[0] == '\0')
	{
	  UI_status("cached data missing - Place Plate manually");
	  sleep(4);
	  dpbmsg = 0; msg = 0; // just to inform failure at wrapup
	  goto wrapup;
	}
        strcpy(Material, actAttr);
      }
      VSfreeList( p_count, p_materials );
    } /* if ftCount = 0 */ 

    if(ftList) {free(ftList); ftList=NULL;}

    __DBGpr_str("Material", Material );

/* ***************************  family  ************************************* */

    fam[0] = '\0';
    strcpy(fam, "fam");
    sprintf(num,"%d",i);
    strcat(fam, num);


    vs$extract_plates_from_RDB(   msg       = &msg,
                                  errStr    = errStr,
                                  material  = Material,
                                  p_count   = &p_count,
                                  p_plates  = &p_plates );

    if( !(msg&1) ){
      __DBGpr_str("vs$extract_plates_from_RDB error", errStr);
      VSfreeList( p_count, p_plates );
      goto wrapup;
    }

    __DBGpr_int("Number of plate families from RDB",  p_count );

    ftCount=0;
    sts = VSpp_findMatch(&msg, MACRO_ID, MACRO_MOD_ENV, fam, &ftList, &ftCount);

    if( !(sts&msg&1) ){
      __DBGpr_com("VDpp_findMatch: failed");
      goto wrapup;
    }

    if( ftCount > 0 )
    {
	sts = VSpp_get_feetInfo( &msg, ftCount, ftList,
				 text_type, famFoot, NULL );
	if( !( sts & msg & 1 )){
          __DBGpr_com("Material expression is not text");
          goto wrapup;
	}
    }

    if( famFoot[0] != '\0' )
    {
      for( j=0; j<p_count; j++ )
      {
	if( strcmp( p_plates[j], famFoot ) == 0 )
	  strcpy( Family, p_plates[j] );
      }
    }

    if( Family[0] == '\0' )
    {
      vs$get_act_pm(  msg     = &dpbmsg,
                      param   = VS_e_dpb_P_type,
                      p_arg   = &actAttr ) ;

      if( !( dpbmsg & 1 ) ){
	__DBGpr_com("vs$get_act_pm did not work for family");
	goto wrapup ;
      }
      else{
	for( j=0; j<p_count; j++ ){
	  if( strcmp( p_plates[j], actAttr ) == 0 )
	    strcpy( Family, p_plates[j] );
	}
      } 
    }

    /* If no matches, take first plate family in RDB list */
    if( Family[0] == '\0' ){
      strcpy( Family, p_plates[0] ); 
    }

    if(ftList) {free(ftList); ftList=NULL;}

    __DBGpr_str("Family", Family );

/* **************************  part number  ********************************* */

    vs$find_thickness_in_RDB(   msg          = &msg,
                                errStr       = errStr,
                                material     = Material,
                                family       = Family,
                                value        = Thickness,
                                p_thkname    = &thkname,
                                p_thickness  = &p_Thickness );

    if( !(msg&1) ){
      __DBGpr_str("vs$find_thickness_in_RDB error", errStr);
      goto wrapup;
    }
    else{
      strcpy(partNum, thkname);
      __DBGpr_str("Part number found in RDB", partNum);
    }

/* **************************  place plate  ********************************* */

    /* If a plate is already on this surface, see if it's attribute	*/
    /*   info matches current RDB info.					*/

    if( pltcnt > 0 )
    {
      if( strcmp( pltType,  Material ) == 0	&&
	  strcmp( pltGrade, Grade )    == 0	&&
	  strcmp( pltFam,   Family )   == 0	&&
	  strcmp( pltNum,   partNum )  == 0	&&
	  ( pltThk == Thickness )	   )
	goto wrapup;  /* Keep current plate */
      else
	vs$bulk_delete( count   = pltcnt,
			grids   = &pltList[0],
			theEnv  = &surfaceEnv );
    }

    //printf("Post Plate Placing on ");
    //vdobj$Print(objID = &surfaceId);

    // Get the actual graphics object
    VSget_actual_go( &surfaceId, &surfaceEnv,
                     &goOE.obj_id, &goOE.mod_env );
/*
    sts = om$send(msg	= message NDnode.
		  ASreturn_go(&goOE.obj_id,
			      &goOE.mod_env.md_env.matrix_type,
			       goOE.mod_env.md_env.matrix),
		  senderid = NULL_OBJID,
		  targetid = surfaceId.objid,
		  targetos = surfaceId.osnum);

    goOE.mod_env.md_id.osnum = goOE.obj_id.osnum;
    sts = ex$get_modid(mod_osnum =  goOE.mod_env.md_id.osnum, 
		       mod_id    = &goOE.mod_env.md_id.objid);
*/
    // vdobj$Print(objOE = &goOE);
    
    sts = vs$place_plate(     msg               = &msg,
                              surfaceId         = &goOE.obj_id,
                              surfaceEnv        = &goOE.mod_env,
                              representation    = AC_3D_REP,
                              basename          = "P",
                              matType           = Material,
                              matGrade          = Grade,
                              partFam           = Family,
                              partNum           = partNum,
                  //etl#6459  thickness         = Thickness,
                              thickness         = p_Thickness,
                              plateId           = &plateId ) ;

    if( !( sts & 1 & msg ) )
    {
       UI_message("Error in plate placement");
       __DBGpr_com("Error in placement of plate");
    }
    else
    {
      errStr[0] = '\0';
      sprintf(errStr, "%s%d", "Constructed plate, objid = ",plateId.objid);
      UI_status( errStr ); /* info, not an error */
      *ctPlates = *ctPlates + 1;
      if( pltcnt > 0 )
      {
	printf("\tPlate on macro, %d, replaced with new plate, %d,\n\t  \
because attributes have been updated.\n", MACRO_ID.objid, plateId.objid);
      }
    }

  } /* for each surface */

wrapup:
	
        if( !(sts&msg&dpbmsg&1) )
	{
          UI_status(" Plate post placement failed");
	  sleep(1);
	  sts=MSFAIL;
	}
	else
          UI_status(" Plate post placement completed");

        if (thkname) { free (thkname); thkname = NULL; }

        if(ftList) {free(ftList); ftList=NULL;}

        VSfreeList( p_count, p_plates );

	return (sts);

} /* end of post_place_plate */


end implementation Root;
