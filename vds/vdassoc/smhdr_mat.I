/* $Id: smhdr_mat.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc / smhdr_mat.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: smhdr_mat.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:41  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*

 Correction for display of image when we attaching/deattaching file.
 llc 

 */

class implementation GRsmhdr;

#include "grimport.h"
#include "gocmacros.h"
#include "msdef.h"
#include "grerr.h"
#include "dpmacros.h"
#include "grownerdef.h"
#include "grownmacros.h"

#include "OMerrordef.h"
#include "madef.h"

method GRget_context (IGRlong *msg; struct GRmd_env *mod_env;
                      struct GRmd_env *cmp_mod_env)
{
    IGRint           i;                  /* index for GRgetabsg      */
    struct IGRlbsys  *absgptr;           /* pointer to abstract geom */

    *msg = MSSUCC;

    *cmp_mod_env = *mod_env;
    GRgetabsg (msg, &mod_env->md_env.matrix_type, mod_env->md_env.matrix,
               (IGRchar **)&absgptr, i);   

    if( ! (*msg&1)) return OM_W_ABORT;

    for (i = 0; i < 16; ++i)
    {
        cmp_mod_env->md_env.matrix[i] = absgptr->matrix[i];
    }
    MAtypemx (msg, cmp_mod_env->md_env.matrix,
              &cmp_mod_env->md_env.matrix_type);
    return (OM_S_SUCCESS);
}

method GRget_matrix (IGRlong *msg; IGRshort *matrix_type; 
                     IGRmatrix matrix; IGRshort *cmp_matrix_type;
                     IGRmatrix cmp_matrix)
{
    IGRint           i;                  /* index for GRgetabsg      */
    struct IGRlbsys  *absgptr;           /* pointer to abstract geom */

    *msg = MSSUCC;
    GRgetabsg (msg, matrix_type, matrix, (IGRchar **)&absgptr, i);

    if( ! (*msg&1)) return OM_W_ABORT;

    for (i = 0; i < 16; ++i)
    {
        cmp_matrix[i] = absgptr->matrix[i];
    }
    MAtypemx (msg, cmp_matrix, cmp_matrix_type);
    return (OM_S_SUCCESS);
}

method GRgenabsg (IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix;
                  IGRchar **absgptr)
{
IGRlong           om_msg;
IGRboolean        world;
GRrange           range;
OM_S_CHANSELECT   chansel;

//   *msg = MSSUCC;
   *msg = MSFAIL;
   world = FALSE;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";

   /*
    *  Get the extents of symbol definition header  Note: must do this
    *  before filling in abstract geometry buffer since this will write
    *  in the buffer
    */

   om_msg = om$send(
            msg = message GRgraphics.GRgetrang (msg, NULL, NULL,
            &world, range),
            p_chanselect = &chansel, from = NULL, to = NULL);

   if (om_msg & *msg & 1)
   {
      om_msg = GR3dlbvigenabsg (msg, matrix_type, matrix,
               (me->properties & GRIS_VIEW_INDEP) ? 1 : 0, 
               me->matrix, me->origin, range, &range[3], my_id, 
               OM_Gw_current_OS, absgptr);
   }
   return(om_msg);
}

end implementation GRsmhdr;
