/*
  ABSTRACT

  DPR class for solid move face, edge, or vertex.


  HISTORY

  DLB 10/15/87    1.1.0 class conversion
  AIC 04/06/87    Creation Date
*/

class specification EMSslmove (1:0) of EMSsldpr, EMSsfmove;

/*------------------ INSTANCE DATA SECTION -------------------*/

override 
  GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

from EMSsldpr inherit 
  GRgeomprops, 
  GRreport, 
  GRreport_defaults, 
  GRupdate_gadgets;
	
#endif

end specification EMSslmove;
