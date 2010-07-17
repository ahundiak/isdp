
/* $Id: VCT_virt.I,v 1.2 2001/02/20 01:11:28 build Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcterm/VCT_virt.I
 *
 * Description:
 *
 *      Function to create a virtual (external) terminal counterpart
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCT_virt.I,v $
 *      Revision 1.2  2001/02/20 01:11:28  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:38  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/11/30  16:09:30  pinnacle
# Replaced: vcterm/VCT_virt.I for:  by r250_int for route
#
# Revision 1.6  1997/11/25  05:54:48  pinnacle
# Replaced: vcterm/VCT_virt.I for:  by apazhani for cabling
#
# Revision 1.5  1997/11/24  17:58:34  pinnacle
# Replaced: vcterm/VCT_virt.I for:  by apazhani for cabling
#
# Revision 1.4  1997/11/09  06:13:10  pinnacle
# Replaced: vcterm/VCT_virt.I for:  by apazhani for cabling
#
# Revision 1.3  1997/05/22  15:23:00  pinnacle
# Replaced: vcterm/VCT_virt.I for:  by hverstee for cabling
#
# Revision 1.2  1997/01/23  23:39:04  pinnacle
# Replaced: vcterm/VCT_virt.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:26:30  pinnacle
# Created: vcterm/VCT_virt.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/29/96    hv          Initial
 *      11/24/97    Alwin       Modified this function, to be compatible with
 *                              new way of Embeded Terminal Placement. With the
 *                              present way of working we don't need those cases
 *                              which were handled before. Now we need to handle
 *                              only for the Terminals present in Reference file
 *                              either embedded or not.
 *
 *************************************************************************/

class implementation VCTerm;

#include "vrdbgmacros.h"
#include "VDmem.h"

from ACrg_collect       import  ACset_list_attribute;

extern        GRclassid        OPP_VCTerm_class_id;



/****************************************************************************/
/*                                                                          */
/*D    FUNCTION NAME   -  VCT_virtualize                                    */
/*D                                                                         */
/*D    Abstract:                                                            */
/*D     This function will create a virtual connector copy of an existing   */
/*D     connector.                                                          */
/*D                                                                         */
/*D     status = VCT_virtualize (IGRlong  *msg;                             */
/*D                              IGRboolean  bCreate,                       */
/*D                       struct GRid     *Conn_in;                         */
/*D                       struct GRmd_env *In_env;                          */
/*D                       struct GRid     *Conn_out;                        */
/*D                       struct GRmd_env *md_env;                          */
/*D                                                                         */
/*D    Parameters:                                                          */
/*D                                                                         */
/*D    Name          I/O        Description                                 */
/*D    -------------------------------------------------------------------  */
/*D                                                                         */
/*D    *msg           O         Standard error message field                */
/*D     bCreate       I         Allow creation yes/no                       */
/*D    *Conn_in       I         GRid of input connector                     */
/*D    *In_env        I         environment of input terminal               */
/*D    *Conn_out      O         Created virtual connector GRid              */
/*D    *md_env        I         environment of output terminal              */
/*                                                                          */
/****************************************************************************/

IGRint   VCT_virtualize (IGRlong    *msg,
                         IGRboolean  bCreate,
                  struct GRid       *Conn_in,
                  struct GRmd_env   *In_env,
                  struct GRid       *Conn_out,
                  struct GRmd_env   *md_env)

{
   IGRint                  status=OM_S_SUCCESS;
   GRspacenum              Req_OS;
   GRspacenum              Cur_OS;

   SetProc( VCT_virtualize ); Begin

   __DBGpr_obj( " Terminal to be Virtualized ", *Conn_in );

   bCreate = TRUE; /* Just to avoid the compiler warning messages. This 
                      variable has been sent as a input before to create the
                      Associative Graphic object depending on the existence of
                      the same. Now it'e nedded any more. Later this can be
                      used some other puposes. Alwin*/

   if (Conn_in == NULL || Conn_out == NULL || md_env == NULL)
   {
      /*| ERROR -> MISSING ATTRIBUTES */
      return (OM_E_INVARG);
   }

   *msg = MSSUCC;

   Req_OS = md_env->md_id.osnum;
   Cur_OS = Conn_in->osnum;

   __DBGpr_int( "Required OS.osnum ", Req_OS );
   __DBGpr_int( "Current OS ", Cur_OS );

   if(  Req_OS != Cur_OS )
   { 
       /* Trying to virtualize the Embedded/Free terminal placed in
          Reference file.... */

       __DBGpr_com( " Entered the Req_OS 'not' = Cur_OS case " );

       /*A    find or make associative root   */
       status =
       as$make_source( go_grid      = *Conn_in,
                       mod_env      = In_env,
                       as_os        = Cur_OS,
                       as_grid      = Conn_out);
       as$status();

       __DBGpr_obj( " ObjectId to be Virtualized ", *Conn_in );
   }
   else *Conn_out = *Conn_in;

   __DBGpr_obj( " Associative Graphic Object ", *Conn_out );

   End
   return ( status );
}

end implementation VCTerm;

