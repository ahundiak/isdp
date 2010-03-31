/*
  ABSTRACT

  This class represents a solid right angle wedge.


  HISTORY

  msm 06/05/91    Override GRreport, GRreport_defaults, GRupdate_gadgets.
                  Removed override GRloadform and GRgetsfsize.
  dhm 05/16/88    Overrode GRgetsfsize and GRloadform.
  JBK 13-May-1987 Added EMextract_vtx_hwd message
  AIC 12/28/86    Creation date
*/

class specification EMSwedge (2:0) of EMSpolyhdrn;

/*------------------ INSTANCE DATA SECTION -------------------*/

override 
  GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMextract_vtx_hwd
(
  IGRlong *EMmsg;
  struct GRmd_env *env;
  IGRpoint vertex;
  IGRvector height;
  IGRvector width;
  IGRvector depth;
);
 
message EMrtwedge
(
  IGRlong *EMmsg;
  struct GRvg_construct *construct_list;
  IGRpoint pt;
  IGRvector height;
  IGRvector width;
  IGRvector depth;
);

override
  GRreport,
  GRreport_defaults, 
  GRupdate_gadgets;

#endif

end specification EMSwedge;
