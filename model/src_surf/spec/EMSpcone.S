/*
  ABSTRACT

  This class represents partial cones.


  HISTORY
  05/29/91        msm     Override GRreport, GRreport_defaults, 
                          GRupdate_gadgets. Removed override GRloadform and
                          GRgetsfsize.
  08/10/88        dhm     Override GRgetsfsize and GRloadform.
  23 Mar 88       AIC     Override EMgetRuleLineTable
  13 October 87   AIC     Creation Date
*/

class specification EMSpcone (1:0) of EMScone;

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

override
  EMgetRuleLineTable;

#ifndef BASE_EMS

override
  GRreport,
  GRreport_defaults,
  GRupdate_gadgets,   
  EMget_params,
  EMget_natedge_info;

#endif
    
end specification EMSpcone;
