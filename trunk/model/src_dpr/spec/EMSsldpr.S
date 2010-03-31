/*
  ABSTRACT

  This is an abstract class which represents the design process
  for solids.


  HISTORY

  PP  10/13/87  Removed EMalt_cnscpsld from reject list, because the
                message is not declared any more at EMSsolid class
  DLB 9/22/87   Mod for new class struct.
  gk  21-may-87 override EMmassprop
  AIC     03/09/87        Creation Date
*/

class specification EMSsldpr (1:0) of EMSsolid, EMSsfdpr;

/*------------------ INSTANCE DATA SECTION -------------------*/

override 
  GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

from EMSsolid inherit 
  GRgeomprops;

#ifndef BASE_EMS

reject
  EMesttplgy,
  EMproj_4_bnd_on_plane,
  EMcount_vertices;

from EMSsolid inherit 
  GRreport, 
  GRreport_defaults,
  GRupdate_gadgets;

#endif

end specification EMSsldpr;
