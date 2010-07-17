/* $Id: VSfeconst.I,v 1.1.1.1 2001/01/04 21:10:36 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsfeature/VSfeconst.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSfeconst.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:36  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.4  1998/01/21  17:48:42  pinnacle
# TR179702512
#
# Revision 1.3  1997/09/29  15:36:54  pinnacle
# TR179700969
#
 *
 * History:
 *      MM/DD/YY AUTHOR	DESCRIPTIO
 *      09/26/97 ah     added header
 *      09/29/97 ah	TR179700969 Cardinal Point 
 *      01/21/98 ah     TR179702512 Web Alignment Problem
 ***************************************************************************/

/*
	I/STRUCT

	At this level, this method is implemented as:
		VScpx.VSpre_construct	sent to self
	then	VSpart.VSput_part_attr	sent to self
	then	VScpx.VSevaluate	sent to self

Note
	The `class_attr' field of the construction list should contain a
	pointer to a `struct VScnst_list'. The `feature_att' field of this
	struct should contain the address of a part-related structure.
	(See GRvg.S for further details on GRconstruct)
	The objects deletes itself if the construction failed.
*/ 
class implementation VSfeature ;

#include <stdlib.h>
#include "EMSmsgdef.h"
#include "vsjntmacros.h"
#include "vsoptdef.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsvirtualinf.h"

/*----------------------------------------------------------------------------*/
method GRconstruct( struct GRvg_construct *cl ) {

  long                *msg,     /* Completion code	*/
		       sts ;    /* OM return code	*/
  struct GRid         *src ;    /* Source objects	*/
  struct VScnst_list  *attr ;   /* Class attributes	*/
  unsigned long	      myType ;  /* Structural type	*/
  VSpartAttr	      *part ;

  msg = cl->msg ;

  attr = (struct VScnst_list *) cl->class_attr ;

  if( !( src = _MALLOC( attr->parent_count, struct GRid ) ) ) {
    vs$mem_fail() ;
  }

  sts = om$send(
    msg = message VScpx.VSpre_construct( cl, src ),
    targetid= my_id
  );
  __CheckRC( sts, *msg, "VScpx.VSpre_construct", wrapup ) ;

  if( attr ) {
    /*
     * Sending wrt message to avoid a possible bubble-up
     * from features overriding ACput_NV_rep.
     */
    sts = om$send(
      msg = message ACncpx.ACput_NV_rep(attr->representation ),
      mode  = OM_e_wrt_message,
      targetid= my_id 
    ) ;
    __CheckRC( sts, *msg, "ACncpx.ACput_NV_rep", wrapup ) ;

    if( attr->feature_att ) {
      part = ( VSpartAttr *) attr->feature_att ;
      {
/* -----------------------------------------------
 * TR179702512 ah
 * This get_STATE may not be correct since forware to source is
 * not being used.
 * However, the state is not used anywhere so just keep for not
 */

        int state ;

        sts = om$send(
          msg = message ACncpx.ACget_STATE(&state),
          targetid = my_id 
        );
      }

      if(! ( part->Iwant & VS_m_detCard  ) ) {

	// TR179700969 
        sts = om$send(
          msg = message ACncpx.ACchg_STATE(VS_m_NdState,VS_m_NdState),
          targetid = my_id 
        );
        part->Iwant |=  VS_m_detCard ;

        sts = om$send(
          msg = message GRvg.GRputattr(msg,attr->feature_att),
          targetid= my_id 
        );
        __CheckRC( sts, *msg, "GRvg.GRputattr", wrapup ) ;

        part->Iwant &= ~VS_m_detCard ;

      }
      else {
        sts = om$send(
          msg = message GRvg.GRputattr(msg,attr->feature_att),
          targetid= my_id 
        );
        __CheckRC( sts, *msg, "GRvg.GRputattr", wrapup ) ;
      }
    }
  }
	
  if( !cl->newflag ) {
    sts = om$send(
      msg = message VScpx.VSevaluate(
        msg,
        attr->parent_count,
        src,
        cl->env_info,cl->level,cl->display 
      ),
      targetid= my_id 
    );
    __CheckRC( sts, *msg, "VScpx.VSevaluate", wrapup ) ;

    sts = om$send(
      msg = message GRgraphics.GRputname(msg, cl->name ),
      targetid= my_id 
    );
    __CheckRC( sts, *msg, "GRgraphics.GRputname", wrapup ) ;
  }

  sts = om$send(
    msg = message VSfeature.VSgetResultType(msg, &myType ),
    targetid= my_id 
  );

  if(    ( myType & VS_m_MOD_generic ) == VS_m_MOD_generic
    && !(( myType & VS_m_DIV_generic ) == VS_m_DIV_generic )
    && !(( myType & VS_m_JOINT       ) == VS_m_JOINT       ) ) {

    /*
     * If I am a modified feature (but not a joint: we do not join
     * joints !), but not a divided feature: they have a special
     * joining process (they joint their sub-features to their
     * parent, but not themselves), result of an operation,
     * then my parent #VS_K_ConsumedIx is the operand of the
     * operation.
     * CAUTION: it may be a pretend, we must get the virtual parent.
     */
    struct GRobj_env  elBfOp, elAfOp ;

    elAfOp._objid   = my_id ;
    elAfOp._osnum   = OM_Gw_current_OS ;
    elAfOp.mod_env  = *cl->env_info ;

    sts = VSgetVirtualInfo(
      msg,
      &attr->parent_list[VS_K_ConsumedIx]._grid,
      &elBfOp.mod_env,
      &elBfOp._grid
    );
    sts = vs$rejoin(	
      msg = msg,
      type    = VS_m_MOD_generic,
      elBfOp  = &elBfOp,
      elAfOp  = &elAfOp
    );
		
    /*
     * Do not be too hard on failure ...
     */
    if( !( sts & 1 & *msg ) ) {
      sts = OM_S_SUCCESS ; *msg= EMS_I_Fail ;
    }
  }

wrapup :
  _FREE( src ) ;
  if( sts & 1 & *msg ) {
    *cl->msg = MSSUCC ;
  } 
  else {
    om$send(
      msg = message VSfeature.NDdelete(cl->env_info ),
      mode  = OM_e_wrt_message,
      targetid = my_id
    ) ;
    if( *msg & 1 ) *msg = MSFAIL ;
  }

  return sts ;

} /* method GRconstruct */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;
