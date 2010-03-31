/*
  ABSTRACT

  This is DPR class for make face opeartion on a face
  of a solid object.


  HISTORY

  RC      11/2/87   Modified for version 1.1.0
  DLB     10/15/87  1.1.0 class conversion
  RC      04/24/87  Creation Date
*/

class specification EMSslmkface (1:0) of EMSsldpr, EMSsfmkface;

/*------------------ INSTANCE DATA SECTION -------------------*/

override 
  GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

from EMSsldpr inherit 
  GRreport, 
  GRreport_defaults, 
  GRupdate_gadgets, 
  EMresetSSI;

#endif

end specification EMSslmkface;
