/*
  ABSTRACT

  This class represents partial cylinders.


  HISTORY

  05/31/91    msm     Override GRreport, GRreport_defaults, GRupdate_gadgets.
                      Removed override GRloadform and GRgetsfsize.
  08/10/88    dhm     Override GRgetsfsize and GRloadform.
  01 Aug 99   RV      Removed EMsurfintgrl override.
  05 May 88   PP      Remove inheritance of EMget_natedgeinfo and added
                      override
  20 Apr 88   AIC     Inherit EMgetRuleLineTable from EMSpcone.
  03 Feb 88   gk      override EMsurfintgrl method
  13 Oct 87   AIC     Creation Date
*/

class specification EMSpcylindr (1:0) of EMSpcone, EMScylindr;

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

from EMSpcone inherit 
  EMgetRuleLineTable;

#ifndef BASE_EMS

override
  GRreport,
  GRreport_defaults,
  GRupdate_gadgets,
  EMget_params,
  EMget_natedge_info;
    
#endif

end specification EMSpcylindr;
