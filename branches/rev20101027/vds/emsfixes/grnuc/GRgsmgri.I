/* $Id: GRgsmgri.I,v 1.1.1.1 2001/01/04 21:07:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/emsfixes/grnuc / GRgsmgri.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: GRgsmgri.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:28  cvs
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
    Name GRgsmgr : sleep method

    09/29/94        rmn      Check for .deleted objects only in the 
                             context of the active design file, 
                             not in the context of reference files.
        
*/

class implementation GRgsmgr;

#include "OMerrordef.h"
#include "msdef.h"
#include "madef.h"
#include "grgsdef.h"
#include "grgsmacros.h"
#include "OMmacros.h"
#include "OMminimum.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "exmacros.h"

/*
Name
   sleep

Description
   This method will empty the graphics set when the graphics set manager
   receives a sleep method.

Arguments
   *type_sleep    IGRint     i   if 1 temp sleep, wake up will follow
                                 if 0 real sleep
*/
method global_class.sleep (int type_sleep)
{
IGRlong              om_msg;
IGRint               status;
unsigned int         count;
IGRint               delete_gs_flag;
OM_S_CHANSELECT      chansel;
IGRint               ii, find_count;
DIgrid              *grids = NULL;
DIspacenum           osnum;
DIchar               directory[DI_PATH_MAX];
struct GRmd_env      mod_env;

   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRgsmgr.select_set";

   /*
    *  Is a select set active?
    */

   om_msg = om$get_channel_count (object = me, p_chanselect = &chansel, 
            count = &count);

   if (count)
   {
      /*
       * check to see if the delete graphics set flag is set; if it is,
       * delete the graphics set
       */

      GRset_inq_gs_flag(&om_msg,FALSE,&delete_gs_flag);

      if (delete_gs_flag)
      {
         gr$gsempty (msg = &om_msg, p_chanselect = &chansel);
      }
   }

   /* 05/10/93 - JSD - Look for any object names that start with ".deleted_"
      and send that object a GRdelete message.  This is a precautionary step
      just in case the pre-delete protocall fails.
    */

   ex$get_cur_mod ( osnum = &osnum );

   /*
      09/29/94 - rmn - Execute the above stated "precautionary step" 
      only for the current os.
   */

   if( osnum != OM_Gw_current_OS )
      return( OM_S_SUCCESS );

   di$give_pathname ( osnum = osnum, pathname = directory );

   strcat ( directory, ":usr:" );

   om_msg = di$find ( start_dir = directory,
                      regexp    = ".deleted_*",
                      grids     = &grids,

/*  commented - rmn - see no purpose

                      lines     = &filename,
*/
                      ptr       = &find_count,
                      options   = OPT_ALL );

   /******************* KLUDGE *************************/
   GRfindmod(&mod_env.md_id);
   mod_env.md_env.matrix_type = MAIDMX;
   MAidmx(&om_msg,mod_env.md_env.matrix);
   /****************************************************/

   for ( ii=0; ii<find_count; ii++ )
   {
     status = om$send (msg      = message GRgraphics.GRdelete (&om_msg,
                                                               &mod_env),
                       senderid = my_id,
                       targetid = grids[ii].objid,
                       targetos = grids[ii].osnum);
   }
   if( grids )
      om$dealloc( ptr = grids );

   return (OM_S_SUCCESS);
}

end implementation GRgsmgr;
