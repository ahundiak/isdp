/*
  DESCRIPITON

  DPR class for 'delete surface boundary' state on solids.

 
  HISTORY

  AMD : August, 1991 : Creation
*/

class specification EMSslrembnd (1:0) of EMSsldpr,EMSsfrembnd;

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

from EMSsldpr inherit 
  GRreport,
  GRreport_defaults,
  GRupdate_gadgets;

#endif

end specification EMSslrembnd;                  
