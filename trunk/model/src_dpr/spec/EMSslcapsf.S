/*
  ABSTRACT

  Class that defines the DPR for capping of a surface object and becoming
  a solid.

 
  HISTORY
 
  10/21/92  : AMD : Creation 
*/

class specification EMSslcapsf (1:0) of EMSsldpr,EMSsfcapsf;

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

from EMSsldpr inherit 
  GRreport, 
  GRreport_defaults,
  GRupdate_gadgets;

#endif

end specification EMSslcapsf;                  
