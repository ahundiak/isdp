/*
  ABSTRACT

  This is an abstract class which represents regional modifications to
  surfaces and composite surfaces by removing and adding regions and/or
  edges.


  HISTORY

  DLB    9/22/87    1.1.0 class redesign
  AIC    03/06/87   Creation Date
*/

class specification EMSsfregmod (2:0) of EMSsfdpr;

/*------------------ INSTANCE DATA SECTION -------------------*/

instance EMSsfregmod
{
  variable IGRushort in_out[1]; 
  IGRushort   num_surfaces;    
};

override GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMprepare_ssi
(
  IGRlong *EMmsg;
  struct EMSsfintedpar **loops_trim_info;
  IGRint num_trim_info;
  IGRint num_new_lps_added;
  GRobjid *new_lps_added;
  struct EMSownercomp *sf_lps_removed;
  IGRint num_srf_GRid;
  struct GRid *srf_GRid;
  union EMSssi_table **ssi_table;
);

override
  EMresetSSI,
  EMgetmodinfo,
  EMgetSSIsize,
  EMgetSSIbuffer,
  EMgetSSI,
  EMputSSI,
  EMsavestatedelete;

#endif

end specification EMSsfregmod;
