/*
  ABSTRACT

  Recorder of operations inserted in the tree.


  HISTORY

  TAPADIA 12/06/90  Fix for TR 90n2138
  DLB 10/15/87  1.1.0 class conversion
  DLB 04/xx/87  creation.
*/

class specification EMSslhist (1:0) of EMSsldpr, EMSsfhist;

/*------------------ INSTANCE DATA SECTION -------------------*/

override 
  GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

from EMSsldpr inherit 
  GRgeomprops;

#ifndef BASE_EMS

reject
    EMadd;   

from EMSsldpr inherit 
  GRreport, 
  GRreport_defaults,
  GRupdate_gadgets;

#endif

end specification EMSslhist;
