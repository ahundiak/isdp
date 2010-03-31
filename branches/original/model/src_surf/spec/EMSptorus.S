/*
  DESCRIPTION

  Non-associative class for a partial torus.

  
  HISTORY

  SS  Creation     Long time ago
*/

class specification EMSptorus (2:0) of EMStorus;

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

override
  EMgetRuleLineTable;

#ifndef BASE_EMS

reject
  EMtorus_by_axis_center_rad;

override
  GRreport,
  GRreport_defaults, 
  GRupdate_gadgets,
  EMget_params,
  EMget_natedge_info;

#endif

end specification EMSptorus;
