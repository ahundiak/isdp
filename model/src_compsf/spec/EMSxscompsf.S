/*
  ABSTRACT

  This class represents cross_section composite surface.


  HISTORY

  RC    08/17/88      Creation date
*/

class specification EMSxscompsf (1:2) of  EMSxsection, EMScompsurf;

/*------------------ INSTANCE DATA SECTION -------------------*/

override 
  GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

override
  GRdelete,
  GRxform,
  GRcopy,
  EMchange_class,
  EMxsec_int_xform,
  EMintcopy,
  EMget_active_inactive_sfs,
  EMperform_xsection,
  EMperform_xsection_update,
  EMget_associated_edges,
  EMdeact_xsection,
  EMattach_vsgd,
  EMconnect_edges;

#endif
 
end specification EMSxscompsf;
