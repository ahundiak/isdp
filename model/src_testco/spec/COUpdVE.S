class specification COUpdVE (1:0) of VEcheform;
/**************************************************************************

DESCRIPTION :

 This is the specification class for  Update Visible Edges functionality

 CR Update Visible Edges

HISTORY

 16/7/97 Creation  Sp.Balamurugan and T.Ashok kumar
 28/11/97 Override delete method added - Ashok

**************************************************************************/



instance COUpdVE
{
  struct GRevent locate_event, acc_event,sp_event;
  struct GRlc_stack locate_stack;
  OM_S_CHANSELECT located_chansel;
};

override init,wakeup,delete,execute;

end specification COUpdVE;
