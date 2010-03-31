/*
  ABSTRACT

  DPR class for solid lift vertex, edge and face operations.


  HISTORY

  RC     03/01/88    Creation Date
*/

class specification EMSsl_lift (1:0) of EMSsldpr, EMSsf_lift;

/*------------------ INSTANCE DATA SECTION -------------------*/

override 
  GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

from EMSsldpr inherit 
  GRreport,
  GRreport_defaults, 
  GRupdate_gadgets;

reject
  EMimpose_boundaries;
	
#endif

end specification EMSsl_lift;
