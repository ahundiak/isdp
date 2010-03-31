/* 
  DESCRIPTION

  This DPR class si for objects that perform the unite-surface op. For
  solids.


  HISTORY

  AMD : 11/11/91 : Creation
*/
class specification EMSslunitesf (1:0) of EMSsldpr,EMSsfunitesf;

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

from EMSsldpr inherit 
  GRreport, 
  GRreport_defaults,
  GRupdate_gadgets;

#endif

end specification EMSslunitesf;                  
