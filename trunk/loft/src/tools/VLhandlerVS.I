class implementation VLabstract;

#include	<stdio.h>
#include	"vlprototype.h"
#include	"vsmiscmacros.h"
#include	"vsgeommacros.h"
#include 	"dpmacros.h"
#include	"nddef.h"
#include	"go.h"
#include 	"vlquerydef.h"

from	VSpart		import	VSgetUserEditableAttr;
from	ACcpx_defn	import	ACgive_name;

extern GRclassid        OPP_nci_macro_class_id;
extern GRclassid        OPP_VSplate_class_id;
extern                  VLbrowseFctInTree();
extern                  VLfilterClass();
extern  int             VLgetMacrosAtStep();

/*	#define	TRACE	*/

/* ************************************************************************** */
IGRint	VLfeatureType	(	struct	GRid		*feature,
					IGRulong	*r_type,
					IGRlong		*msg	)
{
		IGRint		sts;
		IGRulong	r_attr=0;

/*
(*type) must be VS_m_PLATE or VS_m_BEAM.
Never use VS_m_STF_BEAM that match all Struct sources objects, so 
response is always TRUE.
Message VSgetUserEditableAttr send a VSforwardToSource message before
asking for type ...
*/ 

	/* Check the VSfeature element type */
	sts = om$send ( msg = message VSpart.VSgetUserEditableAttr
						( msg, r_type, &r_attr ),
			senderid = NULL_OBJID,
			targetid = feature->objid,
			targetos = feature->osnum );
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRint	VLfeatureAH (		IGRulong	*type,	/* VS_m_ in vsdef.h */
			struct	GRlc_info	*entry,
			struct	LC_action_args	*args,
			enum	GRlocate_action	*action	)
{
		IGRint		sts=LC_RELOCATE;
		IGRlong		msg;
		IGRulong	r_type=0;

	/* Check if transitional locate action */
        if( *action == start_transition || *action == end_transition ) {
                sts = LCptlocact ( (IGRchar *) type, entry, args, action ) ;
                goto wrapup ;
        }

	/* Check VSfeature type */
	sts = VLfeatureType ( &entry->located_obj, &r_type, &msg );
	if ( (sts & 1 & msg) && (r_type & (*type) ) ) {
#ifdef TRACE
printf( "VSpart.VSgetUserEditableAttr() returns r_type=%x checked with %x\n",
	r_type, *type );
#endif
               	sts = LCptlocact ( (IGRchar *) type, entry, args, action ) ;
               	goto wrapup ;
	}

	/* Reject locate */
	sts = LC_RELOCATE;
#ifdef TRACE
printf( "Locate rejected ...\n");
#endif

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRint	VLfeaturePF (	struct	GRobj_env	*object,
				VSfenceArgs	*args	)
{
		IGRint		sts;
		IGRulong	r_type=0;
		IGRlong		msg;
		IGRboolean	ret=FALSE;

	/* Check VSfeature type */
	sts = VLfeatureType ( &object->obj_id, &r_type, &msg );
	if ( (sts & 1 & msg) && (r_type & ( (IGRulong) args->value) ) ) {
#ifdef TRACE
printf( "VSpart.VSgetUserEditableAttr() returns r_type=%x checked with %x\n",
	r_type, (IGRulong) args->value );
#endif
		ret = TRUE;
	}

	return (ret);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRint	VLstrechVActHand ( char		*type,	/* VS_m_ in vsdef.h */
			   struct	GRlc_info	*entry,
			   struct	LC_action_args	*args,
			   enum	GRlocate_action	*action	)
{
long      sts = LC_RELOCATE;	
struct GRid	theMacroId;
IGRchar		*theMacroName = NULL;

        //c Check if transitional locate action

  if( *action == start_transition || *action == end_transition ) {
    sts = LCptlocact( type, entry, args, action ) ;
    goto wrapup ;
  }
  if ( vs$is_ancestry_valid ( object  = &(entry->located_obj),
                              classid = OPP_nci_macro_class_id ) ) {
    sts = om$send ( msg = message ACcpx.find_macro(&theMacroId),
                    senderid  = NULL_OBJID,
                    targetid  = entry->located_obj.objid,
                    targetos  = entry->located_obj.osnum);
    if (!(sts&1)) {
       sts = LC_RELOCATE;	
       goto wrapup;
    }

    theMacroName="";
    sts = om$send ( msg = message ACcpx_defn.ACgive_name(&theMacroName),
                    senderid  = NULL_OBJID,
                    targetid  = theMacroId.objid,
                    targetos  = theMacroId.osnum);
    if (!(sts&1)) {
       sts = LC_RELOCATE;	
       goto wrapup;
    }
    if (!(strcmp(theMacroName,"StrechVal")))
      sts = LCptlocact ( type, entry, args, action );
    else sts = LC_RELOCATE;
  }
  else sts = LC_RELOCATE;

wrapup :
  return sts;
}
/* ************************************************************************** */

/* ************************************************************************** */
int	VLhilitePlateAH ( char		*type,	/* VS_m_ in vsdef.h */
			   struct	GRlc_info	*entry,
			   struct	LC_action_args	*args,
			   enum	GRlocate_action	*action	)
{
long      sts = LC_RELOCATE;	
long		loc_msg;
enum GRdpmode   mode = GRhd;
struct GRid	theMacroId;
IGRchar		*theMacroName = NULL;
struct GRid     *lchild = NULL;
int		num_ancestors;
IGRuchar	weight=3;
struct GRsymbology symb;

        //c Check if transitional locate action

  if( *action == start_transition || *action == end_transition ) {
    sts = LCptlocact( type, entry, args, action ) ;
    goto wrapup ;
  }
  if ( vs$is_ancestry_valid ( object  = &(entry->located_obj),
                              classid = OPP_nci_macro_class_id ) ) {
    sts = om$send ( msg = message ACcpx.find_macro(&theMacroId),
                    senderid  = NULL_OBJID,
                    targetid  = entry->located_obj.objid,
                    targetos  = entry->located_obj.osnum);
    if (!(sts&1)) {
       sts = LC_RELOCATE;	
       goto wrapup;
    }

    theMacroName="";
    sts = om$send ( msg = message ACcpx_defn.ACgive_name(&theMacroName),
                    senderid  = NULL_OBJID,
                    targetid  = theMacroId.objid,
                    targetos  = theMacroId.osnum);
    if (!(sts&1)) {
       sts = LC_RELOCATE;	
       goto wrapup;
    }
    if (!(strcmp(theMacroName,"edge_att"))) {
      sts = om$send ( msg =  message NDnode.NDget_objects(
                                                ND_IN_BUF | ND_ROOT,
                                                (struct GRid *)NULL,
                                                0,
                                                &lchild,
                                                0,
                                                OM_K_MAXINT,
                                                &num_ancestors ),
                    senderid  = NULL_OBJID,
                    targetid  = entry->located_obj.objid,
                    targetos  = entry->located_obj.osnum);
      if (num_ancestors == 0) {sts = MSSUCC; goto wrapup;}
      VLdispObj(&lchild[0],&(entry->module_info),&mode,1);
     
      sts=om$send(msg = message GRvg.GRgetsymb(
                                                 &loc_msg, &symb),
                    senderid  = NULL_OBJID,
                    targetid  = entry->located_obj.objid,
                    targetos  = entry->located_obj.osnum);
        sts=om$send(msg = message GRvg.GRchgweight(
                                                 &loc_msg, &weight),
                    senderid  = NULL_OBJID,
                    targetid  = entry->located_obj.objid,
                    targetos  = entry->located_obj.osnum);
        sts=om$send(msg = message GRgraphics.GRdisplay(
                             &loc_msg,
                             &(entry->module_info.md_env.matrix_type),
                             entry->module_info.md_env.matrix,
                             &mode,
                             &(entry->module_info.md_id) ),
               targetid = entry->located_obj.objid,
               targetos = entry->located_obj.osnum,
               senderid = NULL_OBJID);
        sts=om$send(msg = message GRvg.GRchgweight(
                                         &loc_msg, &(symb.display_attr.weight)),
                    senderid  = NULL_OBJID,
                    targetid  = entry->located_obj.objid,
                    targetos  = entry->located_obj.osnum);
      sts = LCptlocact ( type, entry, args, action );
    }
    else sts = LC_RELOCATE;
  }
  else sts = LC_RELOCATE;

wrapup :
  return sts;
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRboolean	VLisSurfacePlanar
(
struct	GRid		*surfId,
struct	GRmd_env	*surfEnv
)
{
	IGRlong		msg;
	IGRboolean	pln=FALSE;

	/* Call Struct macro */
	pln = vs$is_surface_planar ( msg     = &msg,
				     surfId  = surfId,
				     surfEnv = surfEnv);

	return (pln);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRint	VLisSurfacePlanarAH
(
struct	GRmd_env	*loc_env,
struct	GRlc_info	*entry,
struct	LC_action_args	*args,
enum	GRlocate_action	*action
)
{
	IGRint		sts=LC_RELOCATE;

	/* Check if transitional locate action */
        if (*action == start_transition || *action == end_transition) {
                sts = LCptlocact ( (IGRchar *) loc_env, entry, args, action);
                goto wrapup ;
        }

	/* Check if surface is planar */
	if (VLisSurfacePlanar ( &entry->located_obj,
				&entry->module_info ) == TRUE) {
                sts = LCptlocact ( (IGRchar *) loc_env, entry, args, action);
                goto wrapup ;
	}

	/* Reject locate */
	sts = LC_RELOCATE;

wrapup:
	return (sts);
}	
/* ************************************************************************** */

/* ************************************************************************** */
IGRint	VLisSurfacePlanarPF
(
struct	GRobj_env	*Surf,	/*I	Located surface			*/
	VSfenceArgs	*args	/*I	Because of vs$process_fence()	*/
)
{
	return ( VLisSurfacePlanar ( &Surf->obj_id, &Surf->mod_env) );
}
/* ************************************************************************** */

end implementation VLabstract;
