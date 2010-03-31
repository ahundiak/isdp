/*
  ABSTRACT

  This class represents the stitch state in the DPR tree in cases where
  the composite has resulted into a solid.
  All the overides at EMSsfstitch class are applicable to this class
  also.


  HISTORY

  SM	06-Oct-88	Creation.
*/

class specification EMSslstitch (1:0) of EMSsldpr, EMSsfstitch;

/*------------------ INSTANCE DATA SECTION -------------------*/

override GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

from EMSsldpr inherit 
  GRreport, 
  GRreport_defaults, 
  GRupdate_gadgets;

#endif

end specification EMSslstitch;
