/*
  ABSTRACT

  This is a constructed class which represents the DPR-state produced
  by a "shelling" operation. It is a special kind of a Boolean.


  HISTORY

  Sudhakar :  07Oct'93  :  Override of EMcheckOverlap method added.
  Sudhakar :  23Apr'93  :  Override of EMdim and EMdimparam methods.
  Sudhakar :  03/10/93  :  Modified args. of 'EMshellsolid' message
                           to include multiple thicknesses.
  SS     :  03/09/92  :  Creation
*/

class specification EMSshslbool (2:0) of EMSslboolean;

/*------------------ INSTANCE DATA SECTION -------------------*/

override
  GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMshellsolid
(
  IGRlong *msg;
  IGRushort options;
  IGRshort *mattyp;
  IGRmatrix matrix;
  struct GRvg_construct *const_args;
  GRobjid solidobj;
  IGRdouble inward_thickness;
  IGRdouble outward_thickness;
  IGRint num_mult_thickness;
  IGRdouble *vals_mult_thickness;
  IGRint *num_sfs_per_mult_thickness;
  GRobjid *mult_thickness_sf_sets;
  IGRint num_opensfs;
  GRobjid *opensfs;
  IGRchar status_str[];
  IGRint *display_count;
  GRobjid **display_ids;
);

reject 
  EMadd;

from EMSsurface inherit 
  GRgetobjinfo;

override
  EMconstruct_associative,
  EMgetInGeomIds, 
  EMdeactivate,
  EMdim, 
  EMdimparam,
  EMcheckOverlap;

#endif

end specification EMSshslbool;
