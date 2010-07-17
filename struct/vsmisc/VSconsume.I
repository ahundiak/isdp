/* $Id: VSconsume.I,v 1.3 2002/02/07 00:18:26 jayadev Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsmisc/VSconsume.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSconsume.I,v $
 *	Revision 1.3  2002/02/07 00:18:26  jayadev
 *	*** empty log message ***
 *	
 *	Revision 1.2  2002/02/06 22:31:19  jayadev
 *	support function VSgetFinalChild() for COz_valFeat ppl
 *	
 *	Revision 1.1.1.1  2001/01/04 21:10:50  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  2000/04/04  21:59:18  pinnacle
# Replaced: vsmisc/VSconsume.I for:  by impd252 for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 ***************************************************************************/
/*
	I/STRUCT
*/ 
class implementation VSfeature ;

#include <stdio.h>
#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "VDobj.h"
#include "vsdpb.h"
#include "vsmiscmacros.h"

#include "vsdbgmacros.h"
#include "EMSmsgdef.h"
/*
 * Includes of function prototypes.
 */
#include "vsvirtualinf.h"

extern OMuword		OPP_ACpl_hold_class_id;
extern OMuword          OPP_VSplate_class_id;
extern OMuword          OPP_VSbeam_class_id;
extern OMuword          OPP_VSgapPlate_class_id;
extern OMuword          OPP_VSsplPlate_class_id;
/*----------------------------------------------------------------------------*/
static long VSgetConsumedFeet( consumedPart, env, count, list )

struct GRid	*consumedPart,
		list[] ;
struct GRmd_env	*env ;
int		count ; {

	long		sts ;
	int		i,
			total ;
	struct GRid	extraFoot ;

	for( i = 0 ; i < count ; i++ ) {
		sts = om$get_objid_at_index(	
				objid		= consumedPart->objid,
				osnum		= consumedPart->osnum,
				p_chanselect	= &AC_mto_graf_chns,
				index		= i,
				objidaddr	= &list[i].objid,
				osnumaddr	= &list[i].osnum ) ;
		if( !( sts & 1 ) ) {
			list[i].objid = NULL_OBJID ;
		}
	}
	/*
	 * Delete the extra feet -if any- which are not wanted, Note: we delete
	 * from the last one downwards since deleting them will collapse
	 * the owner-to-component channel.
	 */
	sts = om$get_channel_count(	objid		= consumedPart->objid,
					osnum		= consumedPart->osnum,
					p_chanselect	= &AC_mto_graf_chns,
					count		= (OMuint *) &total ) ;

	for( i = total - 1 ; i >= count ; i-- ) {
		extraFoot.objid = NULL_OBJID ;
		sts = om$get_objid_at_index(	
				objid		= consumedPart->objid,
				osnum		= consumedPart->osnum,
				p_chanselect	= &AC_mto_graf_chns,
				index		= i,
				objidaddr	= &extraFoot.objid,
				osnumaddr	= &extraFoot.osnum ) ;

		vs$bulk_delete(	grids	= &extraFoot,
				theEnv	= env ) ;

	}
	return OM_S_SUCCESS ;

} /* VSgetConsumedFeet */
/*----------------------------------------------------------------------------*/
long VSconsume( msg, ParentPart, ftEnv, nbfeet, parentFeet, ParentEnv )

/*
  Abstract :
	Interface to ACconsume.
*/

long 		*msg;
struct GRid	*ParentPart ;
int		nbfeet ;
struct GRid	parentFeet[] ;
struct GRmd_env	*ftEnv,
		*ParentEnv ; {

	long		sts ;		/* OM return code	*/
	struct GRid	virtual,	/* Virtual parent	*/
			consumed_Part ;
	short		set,
			props ;
	int 		i ;
	struct GRmd_env	parentEnv ;

	VSsetGRids( -1, nbfeet, parentFeet ) ;

	/*
	 * Get parent's module environment (for undisplay).
	 */
	if( !ParentEnv ) ParentEnv = &parentEnv ;
	sts = VSgetVirtualInfo( msg, ParentPart, ParentEnv, &virtual ) ;
	__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

	/*
	 * CAUTION ! ACconsume does not undisplay object !
	 */
	vs$bulk_display(	grids	= ParentPart,
				theEnv	= ParentEnv,
				dpmode	= GRbe ) ;

	/*
	 * `ftEnv' is the environment where we want feet to live, NOT that of
	 * the consumed object.
	 */
	sts = om$send(	msg	= message NDmacro.ACconsume(
					msg, "", TRUE, &consumed_Part, ftEnv ),
			senderid= ParentPart->objid,
			targetid= ParentPart->objid,
			targetos= ParentPart->osnum ) ;
	*msg = *msg ? MSSUCC : MSFAIL ;
	__CheckRC( sts, *msg, "NDmacro.ACconsume", wrapup ) ;

	/*
	 * We just got a root-copy of the object: strip it of its feet.
	 */
	VSgetConsumedFeet( &consumed_Part, ftEnv, nbfeet, parentFeet ) ;

	set = 0 ;
	props = GR_RIGID_RELATIONSHIP ;
	for( i = 0 ; i < nbfeet ; i++ ) {

		if( !IF_NULL_OBJID( parentFeet[i].objid ) ) {

			 if( vs$is_ancestry_valid(
				classid	= OPP_ACpl_hold_class_id,
				object	= parentFeet + i ) ) {

				/*
				 * Get rid of filler ACpl_hold objects. Note
				 * that `vs$bulk_delete' will set  parentFeet[i]
				 * to NULL_OBJID.
				 */
				vs$bulk_delete(	grids	= parentFeet + i,
						theEnv	= ftEnv ) ;
			} else {
				sts = om$send(
					msg	= message GRgraphics.GRchgprops(
	 						msg, &set, &props ),
					senderid= parentFeet[i].objid,
					targetos= parentFeet[i].osnum,
					targetid= parentFeet[i].objid);
				__CheckRC( sts, *msg, "GRgraphics.GRchgprops", wrapup ) ;
			}
		}
	}
	/*
	 * We must use Root.delete here so components will not be deleted.
	 */
	sts = om$send(	msg	= message Root.delete( 0 ),
			senderid= consumed_Part.objid,
			targetos= consumed_Part.osnum,
			targetid= consumed_Part.objid ) ;
	__CheckRC( sts, 1, "Root.delete", wrapup ) ;

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		return sts ;

} /* VSconsume */
/*----------------------------------------------------------------------------*/
long VSunconsume( msg, parentId, parentEnv, parentRep, compute )

long		*msg ;
struct GRid	*parentId ;
struct GRmd_env	*parentEnv ;
VSdspRep	parentRep ;
int		compute ; {

	long			sts ;
	struct GRid		virtual ;
	struct GRmd_env		venv ;

	SetProc( VSunconsume ); Begin

	if( parentRep != AC_NO_REP ) {
		/*
		 * Caution! Parent may be a pretend which does not understand
		 * ACput_NV_rep.
		 */
		__DBGpr_obj(" Check Pretend ", *parentId );

		sts = VSgetVirtualInfo( msg, parentId, &venv, &virtual ) ;
		__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

		__DBGpr_obj("Set-Rep ", virtual );
		sts = om$send(	msg	= message ACncpx.ACput_NV_rep(
								parentRep ),
				senderid= virtual.objid,
				targetid= virtual.objid,
				targetos= virtual.osnum ) ;
		__CheckRC( sts, 1, "NDmacro.ACput_NV_rep", wrapup ) ;
	}

	sts = om$send(	msg	= message NDmacro.ACunconsume( msg, "" ),
			senderid= parentId->objid,
			targetid= parentId->objid,
			targetos= parentId->osnum ) ;
	*msg = *msg ? MSSUCC : MSFAIL ;

	__DBGpr_int(" sts     ", sts );
	__DBGpr_int(" *msg    ", *msg );
	__DBGpr_int(" compute ", compute );

	__CheckRC( sts, *msg, "NDmacro.ACunconsume", wrapup ) ;

	if( compute ) {

		__DBGpr_obj("Compute parent ", *parentId );
		sts = om$send(	msg	= message NDnode.NDs_compute_node(
							msg, 0, parentEnv ),
				senderid= parentId->objid,
				targetid= parentId->objid,
				targetos= parentId->osnum ) ;
		__CheckRC( sts, *msg, "NDnode.NDs_compute_node", wrapup ) ;

	}
	wrapup :
		__DBGpr_int(" RET:sts     ", sts );
		__DBGpr_int(" RET:*msg    ", *msg );
		End
		return sts ;

} /* VSunconsume */
/*----------------------------------------------------------------------------*/
#if defined(__STDC__) || defined(__cplusplus)
/* ACC bug : won't accept ANSI declaration with args inside and definition
   with args outside a la K&R C when an arg has type (unsigned) short: here
   myOs causes it to choke...
 */
long VSfixIfNoRep(	VSdspRep	myRep,
			OM_S_OBJID	myId,
			OMuword		myOs,
			struct GRid	*parentId,
			VSdspRep	*myNewRep )
#else
long VSfixIfNoRep( myRep, myId, myOs, parentId, myNewRep )

VSdspRep	myRep,
		*myNewRep ;
OM_S_OBJID	myId ;
OMuword		myOs ;
struct GRid	*parentId ;
#endif

{

	long	sts ;

	if( myRep == AC_NO_REP ) {
		if( parentId ) {

		struct GRid	virtual ;
		long		rc ;

			/*
			 * CAUTION: real parent may be a pretend, get virtual
			 * one.
			 */
			sts = VSgetVirtualInfo( &rc, parentId, NULL, &virtual );
			__CheckRC( sts, rc, "VSgetVirtualInfo", wrapup ) ;

			sts = om$send(	msg	= message ACncpx.ACget_NV_rep(
								myNewRep ),
					mode	= OM_e_wrt_message,
					senderid= myId,
					targetid= virtual.objid,
					targetos= virtual.osnum ) ;
			__CheckRC( sts, 1, "ACncpx.ACget_NV_rep", wrapup ) ;

		} else {
			struct GRsymbology	esymb ;

			ac$get_def_rep(	prep	= myNewRep,
					esymb	= &esymb ) ;
		}

		sts = om$send(	msg	= message ACncpx.ACput_NV_rep(
								*myNewRep ),
				mode	= OM_e_wrt_message,
				senderid= myId,
				targetid= myId,
				targetos= myOs ) ;
	} else {
		*myNewRep = myRep ;
		sts = OM_S_SUCCESS ;
	}

	wrapup :
		return sts ;

} /* VSfixIfNoRep */
/*----------------------------------------------------------------------------*/
		
IGRlong VSgetFinalChild(
                         struct GRobj_env *parentOE,  //Input
                         struct GRobj_env *childOE,   //Output
                         IGRboolean       isPlate     //Input
                       )
{
  IGRlong          retFlag = 0;
  IGRlong          sts,msg;
  
  struct GRid      childID, parent1ID;
  IGRint           i, childFound;

  struct GRobj_env parentOEx, kidOE;
  OMuword          parClass, childClass;
  
  // Arg check
  if ((parentOE == NULL) || (childOE == NULL)) goto wrapup;
  *childOE = *parentOE;

  __DBGpr_com("Entered VSgetFinalChild ");
 
  om$get_classid(  objid           = parentOE->obj_id.objid,
                   osnum           = parentOE->obj_id.osnum,
                   p_classid       = &parClass ); 

  childFound = 0;

  // Cycle through kids
  for(i = 0; 
      (VDahGetChnObject(&parentOE->obj_id,"NDchildren.children",i,&childID) && !(childFound));
      i++) {

    __DBGpr_int("Index :", i);
    om$get_classid(  objid           = childID.objid,
                     osnum           = childID.osnum,
                     p_classid       = &childClass );


    if(!( vs$is_ancestry_valid(
                              classid = OPP_VSfeature_class_id,
                              object  = &childID ))) continue;

    if(isPlate)
    {
      // child should be the parent type
      if(!( vs$is_ancestry_valid(
                                classid = OPP_VSplate_class_id,
                                object  = &childID ))) continue;
      /*
       * if my child is a VSgapPlate or a VSsplPlate
       * make sure that i'm his first parent
       */
      if(( vs$is_ancestry_valid(
                                classid = OPP_VSgapPlate_class_id,
                                object  = &childID )))
      {
        kidOE.obj_id = childID;
        kidOE.mod_env= childOE->mod_env;

        vdobj$GetParent(objOE = &kidOE, idx = 0, parentID = &parent1ID);
        if((parent1ID.objid != parentOE->obj_id.objid) ||
           (parent1ID.osnum != parentOE->obj_id.osnum))
        {
          continue;
        }
      }
      if(( vs$is_ancestry_valid(
                                classid = OPP_VSsplPlate_class_id,
                                object  = &childID )))
      {
        kidOE.obj_id = childID;
        kidOE.mod_env= childOE->mod_env;

        vdobj$GetParent(objOE = &kidOE, idx = 0, parentID = &parent1ID);
        if((parent1ID.objid != parentOE->obj_id.objid) ||
           (parent1ID.osnum != parentOE->obj_id.osnum))
        {
          continue;
        }
      }
    }
    else
    {
      // child should be the parent type
      if(!( vs$is_ancestry_valid(
                                classid = OPP_VSbeam_class_id,
                                object  = &childID ))) continue;
    }
    childFound = 1;

    __DBGpr_obj("Parent :", parentOE->obj_id); 
    __DBGpr_obj("Child  :", childID); 

    // Got it
    childOE->obj_id = childID;
     
    // Recurse
    parentOEx = *childOE;
    VSgetFinalChild(&parentOEx,childOE,isPlate);
  }
  
wrapup:
  __DBGpr_com("coming out of VSgetFinalChild ");
  return retFlag;
}
end implementation VSfeature ;
