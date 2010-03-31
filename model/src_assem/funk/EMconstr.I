class implementation EMconstr;
/*

Name
  EMconstr.I

Description
  This file has the the functions to create/delete
  assembly constraints.

Notes
 04/21/93 : Kapil Singh (KS): created
 09/14/93 : Krishna kumar : added NDchg_state message for the offset exp.
 */

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "OMindex.h"
#include "OMerrordef.h"
#include "OMlimits.h"
#include "exmacros.h"
#include "igrdef.h"
#include "madef.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "dpstruct.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "AS_status.h"
#include "msmacros.h"

#include "parametric.h"
#include "expression.h"
#include "expmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h" 
#include "AS_status.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "ASmessages.h"
#include "dpdef.h"


#include <assemdef.h>
#include <assem.h>
#include <assemmacros.h>
#include <assemconstr.h>

#ifdef DEBUG
#define verbose(x) x
#else
#define verbose(x)
#endif

from GRgraphics import GRchgprops;

extern GRclassid OPP_EMmate_class_id;
extern GRclassid OPP_EMalign_class_id;
extern GRclassid OPP_EMinsert_class_id;
extern GRclassid OPP_EMground_class_id;

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMput_constr                                                    |
 |                                                                           |
 | This function creates an  assembly constraint.                            |
 |                                                                           |
 | Input:                                                                    |
 |        IGRint constr_type      The type of constraint MATE, AlIGN etc.    | 
 |                                (defined in EMconstr.h)                   |     
 |        struct GRid part_one    1st part to which the constr is attached   |
 |        struct GRid part_two    2nd part to which the constr is attached   |
 |        FEATURE_INFO feature_one 1st feature on which constraint applies    |
 |        FEATURE_INFO feature_two 2nd feature on which constraint applies    |
 |        char * constr_expr      The expression entered for the value of    |
 |                                the constraint                             |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong *msg               The return status                       |
 |        struct GRid *pconstr_grid  The grid of the  newly created constr    |
 |                                                                           |
 +---------------------------------------------------------------------------*/
from FIdirform import update;

IGRlong EMput_constr (msg, constr_type, part_one, part_two, 
                          feature_one, feature_two,
                          constr_expr, pconstr_grid)
			  
IGRlong *msg;		 /* The return status */			  
IGRint constr_type;	 /*The type of constraint */
struct GRid part_one;	 /* 1st part to which the constr is attached*/
struct GRid part_two;	 /* 2nd part to which the constr is attached*/
FEATURE_INFO feature_one; /* 1st feature on which constraint applies*/
FEATURE_INFO feature_two; /* 2nd feature on which constraint applies*/
char *constr_expr;        /* The expression entered for the value of constr*/
struct GRid *pconstr_grid; /* The grid of the newly created constr */
{
  OMuword cur_mod_osnum;
  IGRlong status, msg_loc;
  GRclassid class_id;
  char constr_name[64];
  char temp_name[64];
  struct GRid constr_expr_grid, null_grid;
    
  *msg = EMS_S_Success;
  status = OM_S_SUCCESS;

  null_grid.objid = NULL_OBJID;
      
  switch (constr_type)
  {
    case MATE:
	class_id = OPP_EMmate_class_id;
	strcpy(constr_name, "M");
        break;

    case ALIGN:
        class_id = OPP_EMalign_class_id;
        strcpy(constr_name, "A");
        break;


    case GROUND:
        class_id = OPP_EMground_class_id;
        strcpy(constr_name, "G");
        break;

    default:
        status = EMS_E_Fail;
        as$status(action = RET_STATUS);        
        break;
  }

  ex$get_cur_mod ( osnum = &cur_mod_osnum );
  pconstr_grid->osnum = cur_mod_osnum;

  status = om$construct(classid = class_id,
                        osnum = cur_mod_osnum,
                        p_objid = &(pconstr_grid->objid),
                        msg = message EMconstr.EMinit_constraint(&msg_loc,
                                               part_one, part_two, 
                                               feature_one, feature_two));
  EMerr_hndlr(!(1&status&msg_loc), status, EMS_E_Fail, ret_end);
  
  if (constr_type != GROUND)
  {
    sprintf (temp_name, "%d", pconstr_grid->objid);
    strcat(constr_name, temp_name);
  
    constr_expr_grid.osnum = cur_mod_osnum;  
    status = exp$create(exp_name = constr_name,
                        exp_syntax =  constr_expr,
                        p_exp_id = &(constr_expr_grid.objid));
    if (status != EXP_S_SUCCESS)
    {
      if (status != EXP_INV_REF_FILE)
        ex$message(msgnumb = AS_S_SynErr);
  
      status = om$send(msg = message  Root.delete(1),
               targetos =  pconstr_grid->osnum,
               targetid = pconstr_grid->objid, senderid = NULL_OBJID );
      EMerr_hndlr (EMSerror (status), status, EMS_E_Fail, ret_end);
    }
    else
    {
	/*
	 * Added this change_state message, so that the expression will be
         * deleted when there are no dependents, automatically.
	 */
	IGRchar a, b;

        a = ~0 ;  b = ND_DEL_NO_CH|ND_WAIT_DEL ;
        status = om$send( msg = message NDnode.NDchg_state(a, b),
                             targetid = constr_expr_grid.objid ,
                             senderid = constr_expr_grid.objid ,
                             targetos = constr_expr_grid.osnum);

      status = om$send(msg = message NDnode.NDconnect(1, &constr_expr_grid, 
                                                       null_grid, ND_NEW),
                         senderid = NULL_OBJID,
                         targetid =  pconstr_grid->objid,
                         targetos =  pconstr_grid->osnum);
      EMerr_hndlr (EMSerror (status), status, EMS_E_Fail, ret_end);

    }
  } 
    /*
     * Set the GRprops of the incident part so that the part is not
     * located by operations such as move, rotate etc.,
     */
    {
    IGRlong  om_msg, msg;
    IGRshort action = 1; /* This means set the bits. */
    IGRshort props = GRIS_ASSOCIATIVE | GRHAS_EXTERNAL_CONSTRAINT;

       om_msg = om$send (msg = message GRgraphics.GRchgprops (&msg,
                                                              &action,
                                                              &props),
                                  senderid = part_two.objid,
                                  targetid = part_two.objid,
                                  targetos = part_two.osnum);
       if( !( om_msg & msg & 1 ))
       {
           verbose(printf("GRchgprops failed\n"));
       }
    }
 
ret_end:
  EMWRAPUP ( status, *msg, "In EMput_constraint" );
  return(status);
}

IGRint EMget_exp_info( msg, cnstr, offset, expname, expid )
IGRlong *msg;
struct GRid *cnstr, *expid;
IGRdouble *offset;
IGRchar   *expname;
{
int om_msg = OM_S_SUCCESS;
char pathname[DI_PATH_MAX];
double locoffset;

    *msg = MSSUCC;

    if( ! offset )
    {
        offset = &locoffset;
    }

    if( expid )
    {
        om_msg = om$send( msg = message EMconstr.EMget_offset( msg, offset, expid ),
                                    senderid = NULL_OBJID,
                                    targetid = cnstr->objid,
                                    targetos = cnstr->osnum );
    }
    else
    {
        om_msg = om$send( msg = message EMconstr.EMget_offset( msg, offset, NULL),
                                    senderid = NULL_OBJID,
                                    targetid = cnstr->objid,
                                    targetos = cnstr->osnum );
    }

    if( !(om_msg & *msg & 1))
    {
        verbose(printf("EMget_offset failed\n"));
        goto wrapup;
    }

    if( expname )
    {
        /* Find the name of the expression */
        if (di$untranslate (objid = expid->objid,
                            osnum = expid->osnum,
                            objname = pathname) == DIR_S_SUCCESS)
        {
             di$split (pathname = pathname,
                       name = expname);
        }
        else
        {
	    verbose(printf("di$untranslate failed, expid = %d\n", expid->objid));
            om_msg = OM_E_ABORT;
            goto wrapup;
        }
    }
                    
wrapup:
    return( om_msg );
}

end implementation EMconstr;
