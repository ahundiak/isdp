/*
  DESCRIPTION

  Class that defines macro-DPRs for solids.


  HISTORY

  Probably PP, long time ago
*/

class specification EMSslmacro (1:0) of EMSsldpr, EMSsfmacro;

/*------------------ INSTANCE DATA SECTION -------------------*/

override 
  GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

from EMSsldpr inherit 
  GRreport, 
  GRreport_defaults, 
  GRupdate_gadgets;

#endif

end specification EMSslmacro;
