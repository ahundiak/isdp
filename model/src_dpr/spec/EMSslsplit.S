/*
  ABSTRACT

  DPR class for solid surface split


  HISTORY

  DLB   10/15/87    1.1.0 class conversion
  gupta 04/06/87    Creation Date
*/

class specification EMSslsplit (1:0) of EMSsldpr, EMSsfsplit;

/*------------------ INSTANCE DATA SECTION -------------------*/

override 
  GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

from EMSsldpr inherit 
  GRgeomprops;

#ifndef BASE_EMS

from EMSsldpr inherit 
  GRreport, 
  GRreport_defaults, 
  GRupdate_gadgets;

#endif

end specification EMSslsplit;
