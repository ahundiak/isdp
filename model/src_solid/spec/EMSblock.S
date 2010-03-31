/*
  ABSTRACT

  This class represents a solid box. Instantiable.


  HISTORY

  msm 06/04/91    Override GRreport, GRreport_defaults, GRupdate_gadgets.
                    Removed override GRloadform and GRgetsfsize.
  PP  07/12/88    Removed override for debug
  dhm 05/16/88    Overrode GRgetsfsize and GRloadform.
  JBK 13-May-1987 Added EMextract_vtx_hwd message
  PP  03/19/87    Major revision due to changes in class
                    structure
  AIC 12/28/86    Creation date
*/

class specification EMSblock (2:0) of EMSpolyhdrn;

/*------------------ INSTANCE DATA SECTION -------------------*/

override GRvg;


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

message EMboxbyhwd
(
  IGRlong *EMmsg;
  struct GRvg_construct *construct_list;
  IGRpoint pt;
  IGRvector height;
  IGRvector width;
  IGRvector depth;
);

message EMboxby2pt
(
  IGRlong *EMmsg;
  struct GRvg_construct *construct_list;
  IGRpoint pt0;
  IGRpoint pt1;
);


override
  GRreport,
  GRreport_defaults,
  GRupdate_gadgets;

#endif

end specification EMSblock;
