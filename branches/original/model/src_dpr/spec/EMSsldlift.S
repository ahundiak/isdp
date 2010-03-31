/*
  ABSTRACT

  DPR class for solid lift vertex, edge and face operations.


  HISTORY

  RC     03/01/88    Creation Date
*/

class specification EMSsldlift (1:0) of EMSsldpr, EMSsfdlift;

/*------------------ INSTANCE DATA SECTION -------------------*/

override 
  GRvg;

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

reject
  EMimpose_boundaries;

from EMSsldpr inherit 
  GRreport, 
  GRreport_defaults, 
  GRupdate_gadgets;

#endif

end specification EMSsldlift;
