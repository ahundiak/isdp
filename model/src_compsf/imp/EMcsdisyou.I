/*
Name

    GRdisyourself

Abstract

        This method will create pointers (class EMSpointer) for each
    component object that is subclassed from EMSsubbs if a flag indicates
    this should be done.  The element is then displayed via feature display,
    if indicated, else it's displayed normally.

Synopsis

        Type                   Name           I/O       Description
 --------------------- ---------------------- --- --------------------------
 IGRlong               *EMmsg                  O  Return code.
 IGRshort              *mx_type                I  Type of matrix.
 IGRmatrix             matrix                  I  Environment matrix of the
                                                  element to be displayed.
 enum GRdpmode         *mode                   I  A mode indicating how the
                                                  element is to be displayed.
 struct IGRaltdisplay  *alt_symb               I  Alternate display
                                                  attributes.
 struct DP_information *sp_info                I  Special display
                                                  information.
 OM_p_KEY_DESC         range_key               I  Element's range key;
                                                  send NULL pointer if it's
                                                  unknown.

Description

        This method displays its object by doing a feature display, if
    indicated, else it does a regular display.  This method also checks to
    see if the flag that indicates pointers (and model space counterparts)
    are to be created is set, and if it is then it creates pointers
    (class EMSpointer) for each component of its object, and each of the
    component's components on down to the lowest component, if the component
    is subclassed from EMSsubbs.

Keywords

    display
    features
    method

History

    ??/??/??  :  ???  :  Creation date.
    06/11/93  :  WBC  :  Create pointers if requested.
    06/21/94  :  WBC  :  Before creating MSCs, put in check to make sure the
                         object is not in a read-only object space.
    07/18/94  :  WBC  :  Removed code to create EMSpointers; we are no longer
                         trying to create these on the fly.  Users must
                         explicitly use the command "Enable Read-Only Detailing"
                         to create EMSpointers and MSCs for read-only detailing
                         (TRs 119420413 and 119419323).
Justification

        Inherited display method does not handle feature display or
    creation of pointers.
*/


class implementation EMScompsurf;

#include "emsdef.h"
#include "msdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

method GRdisyourself(IGRlong *EMmsg; IGRshort *mx_type; 
                     IGRmatrix matrix;  enum GRdpmode *mode;
                     struct IGRaltdisplay *alt_symb; 
                     struct DP_information *sp_info; 
                     OM_p_KEY_DESC range_key)
{
  IGRint               EFmake_pointers();

  IGRlong              OM_stat=OM_S_SUCCESS;
  extern unsigned char EMS_locate_features;

  *EMmsg = MSSUCC;

  if (EMS_locate_features)
  {
    OMuint ii;
    IGRint comp_cnt=0;
    struct GRid *comp_lst=NULL;

    (void) EFgetcomponents(EMmsg, my_id, my_id, OM_Gw_current_OS,
                           &comp_cnt, &comp_lst);
    if (!(1 & *EMmsg)) goto wrapup;

    for(ii=0; ii<comp_cnt; ii++)
    {
      om$send(msg = OPPmargs,
              senderid = comp_lst[ii].objid,
              targetid = comp_lst[ii].objid);
    }

    if (comp_lst)
    {
      om$dealloc(ptr = comp_lst);
      comp_lst = NULL;
      comp_cnt = 0;
    }
  }    
  else
  {
    OM_stat = om$send(mode = OM_e_wrt_message,
                      msg = message EMScomposite.GRdisyourself(EMmsg, mx_type, 
                                    matrix, mode, alt_symb, sp_info,
                                    range_key),  
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    
  }

wrapup:
  EMWRAPUP (*EMmsg, OM_stat, "csf.disyours");
  return(OM_stat);
}
end implementation EMScompsurf;
