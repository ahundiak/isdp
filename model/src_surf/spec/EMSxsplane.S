/*
  DESCRIPTION

  This class represents cross section plane.


  NOTES

  The information, needed to bring the cross_section plane to non_aligned
  orientation while updating it, is stored in its instance data
    o alignment_info_fmt
    o alignment_info

  Two kinds of format are supported,

  a) Translation vector and rotation angle.
     In this case 'alignment_info_fmt' has a value of 
     EMS_FMT_TRANS_VEC_ROT_ANG, alignment_info[0-2] has the translation
     vector and alignment_info[3] has rotation angle.

  b) Matrix by which the cross_plane need to be transformed in
     bringing it to non-aligned orientation.
     In this case 'alignment_info_fmt' has a value of EMS_FMT_MATRIX
     and alignment_info[0-15] stroes the matrix.


  HISTORY

  RC    09/18/88     Creation Date
*/

class specification EMSxsplane (1:0) of EMSxsection, EMSplane;

/*------------------ INSTANCE DATA SECTION -------------------*/

instance EMSxsplane
{
  IGRchar                alignment_info_fmt;
  variable IGRdouble     alignment_info[4];
};

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMget_alignment_matrix
(
  IGRlong *EMmsg;
  struct GRmd_env *md_env;
  IGRmatrix align_mat;
  IGRshort *align_mattyp;
);

message EMput_alignment_info
(
  IGRlong *EMmsg;
  IGRchar alignment_info_fmt;
  IGRdouble *trans_vec;
  IGRdouble rot_ang;
  IGRdouble *align_mat;
);

override
  EMget_active_inactive_sfs,
  debug,
  GRcopy,           
  GRdelete,         
  GRxform,
  EMchange_class,
  EMxsec_int_xform,
  EMintcopy,
  EMperform_xsection_update,
  EMperform_xsection,
  EMget_associated_edges,
  EMdeact_xsection,
  EMattach_vsgd,
  EMconnect_edges;
   
#endif

end specification EMSxsplane;
