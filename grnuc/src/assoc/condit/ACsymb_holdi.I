class implementation ACsymb_hold;

#include "msdef.h"
#include "msmacros.h"
#include "AS_status.h"
#include "OMprimitives.h"

#include "gocmacros.h" /* for NOTIFY_LIS */

#define AS_DEBUG

method GRdisyourself(IGRlong *msg; IGRshort *mx_type; IGRmatrix
                        matrix;  enum GRdpmode *mode;
			struct IGRaltdisplay *alt_symb;
			struct DP_information *sp_info;
                        OM_p_KEY_DESC range_key)
{
*msg = MSSUCC;
return(OM_S_SUCCESS);
}


method GRaddwrng(IGRlong *msg; struct GRmd_env *md_env)

{
  *msg = MSSUCC;
  return(OM_S_SUCCESS);
}



method GRremwrng(IGRlong *msg;struct  GRmd_env *md_env)
 {
  *msg = MSSUCC;
  return(OM_S_SUCCESS);
 }

method GRcopy( IGRlong *msg; struct GRmd_env *obj_dsenv;
     	       struct GRmd_env *new_dsenv; GRobjid *newobjid)
{
 int status;
 IGRshort my_props;
 *msg = MSFAIL;
 
 my_props = me->properties;
 me->properties = me->properties & (~GR_RIGID_RELATIONSHIP) | GRIS_NEW;

 status = om$construct_and_copy(object = me,
				osnum  = new_dsenv->md_id.osnum,
				p_objid = newobjid);
 me->properties = my_props;
 as$status(action = RET_STATUS);
 /*"--> %d\n",*newobjid */
 *msg = MSSUCC;
 return(status);
}

method GRdelete( IGRlong *msg; struct GRmd_env *md_env)
{
 int status;
 status = om$send(msg = message Root.delete(1),
		  targetid = my_id);
 as$status(action = RET_STATUS);
 *msg=MSSUCC;
 return(OM_S_SUCCESS);
}

method GRchgprops(IGRlong *msg; IGRshort *action; IGRshort *mask)

{
IGRlong OMmsg;
/*
   the message to change properties in GRgraphics is declared in GRgraphics
   but implementented in GRvg !!!!!!!!
*/

       if(*action)
         {
            if ( *action == 1)                  /* set bits             */
            {
                me->properties = me->properties | *mask;
            }
            else if (*action == -1)             /* replace properties  */
            {
                me->properties = *mask;
            }
            else
            {
                *msg = MSINARG;
                OMmsg = OM_E_ABORT;
            }
        }
        else                            /* clear bits           */
        {
            me->properties = me->properties &  ~*mask;
        }

        GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_ATTR_MODIFIED);
        *msg = MSSUCC;
        OMmsg = OM_S_SUCCESS;

 return(OMmsg);
}

method GRgetprops(IGRlong *msg; IGRshort *props)

{
IGRlong OMmsg;
/*
   the message to change properties in GRgraphics is declared in GRgraphics
   but implementented in GRvg !!!!!!!!
*/
        *props=me->properties ;
        *msg = MSSUCC;
        OMmsg = OM_S_SUCCESS;

 return(OMmsg);
}

method GRlnproject(IGRlong *msg; IGRshort *matrix_type;
        IGRmatrix matrix; struct IGRline *line;
        IGRpoint ln_pt,proj_pt; IGRdouble *t;
        struct GRparms *proj_parms)
{*msg = MSSUCC;return(OM_S_SUCCESS);}


method GRxform( IGRlong *msg; struct GRmd_env *md_env;
                IGRshort *matrix_type; IGRmatrix matrix; GRobjid *newobjid)
{*msg = MSSUCC;return(OM_S_SUCCESS);}

end implementation ACsymb_hold;

