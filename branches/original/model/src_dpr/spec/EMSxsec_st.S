/*
  ABSTRACT

  DPR class for surface and composite surface cross-section.


  HISTORY
    
  RC   08/17/88     Creation Date
*/

class specification EMSxsec_st (1:2) of EMSxscompsf, EMSsfregmod;

/*------------------ INSTANCE DATA SECTION -------------------*/

override  
  GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMget_sf_rmvd_eds
(
  IGRlong *EMmsg;
  GRobjid sf_id;
  struct GRid *rej_eds;
  IGRint num_rej_eds;
  GRobjid **rmvd_eds;
  IGRint *num_rmvd_eds;
  IGRint *eds_arrsz;
);

override
  EMgetmodinfo,
  GRdelete,
  GRcopy,                   
  EMintcopy,
  EMget_active_inactive_sfs,
  EMsavestatedelete,
  EMdeactivate,
  EMactivate,
  EMputSSI,
  EMget_associated_edges,
  EMgetSSI,
  EMgetSSIsize,
  EMgetSSIbuffer,
  EMdeact_xsection;

#endif

end specification EMSxsec_st;
