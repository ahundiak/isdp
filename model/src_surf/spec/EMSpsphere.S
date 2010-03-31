/*
  DESCRIPTION

  Non-associative class for a partial sphere.

  
  HISTORY

  SS  Creation     Long time ago
*/

class specification EMSpsphere (2:0) of EMSsphere;

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

override
  EMgetRuleLineTable; 

#ifndef BASE_EMS

reject
  EMsphere_by_center_radius;

override
  GRreport, 
  GRreport_defaults, 
  GRupdate_gadgets, 
  EMget_params, 
  EMget_natedge_info;

#endif

end specification EMSpsphere;

