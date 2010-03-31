/*
  ABSTRACT

  DPR class for rounding edge and vertices.


  HISTORY

  gupta 10/09/87    Creation Date
*/

class specification EMSslround (1:0) of EMSsldpr, EMSsfround;

/*------------------ INSTANCE DATA SECTION -------------------*/

override 
  GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

from EMSsldpr inherit 
  EMintplane_saveside, 
  GRreport, 
  GRreport_defaults, 
  GRupdate_gadgets;

#endif

end specification EMSslround;
