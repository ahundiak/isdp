/* $Id: SMCGivePath.I,v 1.1.1.1 2001/01/04 21:07:33 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        SMcomp/SMCGivePath.I
 *
 * Description:
 *
 *      Implements the ACgive_path method.
 *
 * Dependencies:
 *
 *      VDSroot
 *
 * Revision History:
 *	$Log: SMCGivePath.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:33  cvs
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
 *
 *      04/24/92        Ch. Heraud      Creation date.
 *      06/01/94        P. Lacroix      subclass under VDSroot.
 *
 * -------------------------------------------------------------------------
 */

class implementation SMcomp;

#include "OMmacros.h"
#include "OMprimitives.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "asbox.h"

/*+mo
 -------------------------------------------------------------------------

  Overridden Message

        ACgive_path from ASnode

  Abstract

	Given a graphic object, returns the corresponding path.

  Arguments
      IGRint 		*suc              O 	Completion code

      struct GRid	*go_obj		  I	graphic object
 
      char 		*name         	  O	path name	


  Status/Return Code
      OM_S_SUCCESS	if success;
      OM_E_ABORT	if fails

 -------------------------------------------------------------------------
-mo*/

method ACgive_path(IGRint *suc;struct GRid *go_obj;char *foot_name)
{
        int i,sts;
        struct GRid pied;
        OM_S_CHANSELECT chansel;

        chansel.type = OM_e_name;
        chansel.u_sel.name = "GRcmpowner.to_components";

        /**** must find pied see give_foot ****/

        pied.objid = NULL_OBJID;
        sts = om$get_objid_at_index
                             ( object =         me,
                               p_chanselect =   &chansel,
                               index =          0,
                               objidaddr =      &pied.objid,
                               osnumaddr =      &pied.osnum);

        if( (1&sts) && pied.objid != NULL_OBJID ){
            /*| get the index of the object go_obj*/
            get_index_of_surf(pied, &i, *go_obj );
            if( i != -1 ){
                sprintf(foot_name,"$%d", i );
                /*"ACgivepath, foot_name created: %s\n ",foot_name */
                return ( OM_S_SUCCESS );
            }
        }

        /*"ACgivepath failed, call normal message \n"*/
        return om$send(msg= message ACncpx.ACgive_path
                                                (suc,go_obj,foot_name),
                        targetid=my_id,
                        mode = OM_e_wrt_message);
}


/*+mo
 -------------------------------------------------------------------------

  Overridden Message

        ACreturn_foot from NDmacro

  Abstract

   Given a foot name returns the object corresponding in the current
   occurence.
   If the foot is a graphic object then this object is returned instead of the source
   one. 
   If the foot is a ACcomplex, then it is returned.

  Arguments

   IGRlong 	*msg          	O : 0 failure 1 succes

   char 	*footname       I : the foot to find (if virtual parent is 
				    required give "" as footname)

   struct GRid 	*foot_obj 	O : the found object.

   IGRshort 	mat_type     	O : matrix type to used with the found object
                           	NULL pointer if not required

   IGRdouble 	*matrix     	O : matrix to used with the found object
                           	NULL pointer if not required


  Status/Return Code
      OM_S_SUCCESS	if success;
      OM_E_ABORT	if fails

 -------------------------------------------------------------------------
-mo*/

method ACreturn_foot(long *msg;char *foot_name; struct GRid *foot_GRid;
                     IGRshort *mat_type; IGRdouble *matrix)
{
        int ix;         /* index */
        int sts,loc_msg;
        OM_S_CHANSELECT chansel;
        struct GRid pied;

        *msg = 0;

        if( foot_name[0] != '$' ){
                return om$send( msg = message ACncpx.ACreturn_foot
                                        ( msg, foot_name, foot_GRid,
                                          mat_type, matrix),
                         targetid = my_id,
                         mode = OM_e_wrt_message);
        }
        chansel.type = OM_e_name;
        chansel.u_sel.name = "GRcmpowner.to_components";

        /**** must find real feet
        /**** we assume this is the 1st one on the channel to_component
        /* */
        pied.objid = NULL_OBJID;
        sts = om$get_objid_at_index
                             ( object =         me,
                               p_chanselect =   &chansel,
                               index =          0,
                               objidaddr =      &pied.objid,
                               osnumaddr =      &pied.osnum);
        if(!(1&sts) )
                return sts;
        if( pied.objid == NULL_OBJID )
                return *msg = 0;

        ix = -1;
        sscanf(&foot_name[1],"%d", &ix );
        if( !get_surf_at_index(pied, ix, foot_GRid ) )
                return *msg = 0;
        /*"ci_mac_bib.ACgive_foot, foot:%d %d\n",foot_GRid->objid,
                                foot_GRid->osnum */

        if(mat_type) *mat_type = MAIDMX;
        if(matrix) MAidmx(&loc_msg,matrix);

        *msg = 1; /*return real graphic object */

        return(sts);
}


end implementation SMcomp;
 

