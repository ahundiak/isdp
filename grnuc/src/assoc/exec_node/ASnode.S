/*
  ABSTRACT

  This abstract class is the parent class of all the associative objects
  owning rigidly graphic component(s). 

  The super class GRowner already redirects to the graphic objects a good part 
  of the message the associative element is not interested in .

  Some additionnal override are necessary because :
  - Doesn't want to put the associative header in the range tree
  - Need to intercept message as copy,delete,xform or modify to perform 
    additionnal operation in the graph of dependency

 
  HISTORY

  Unknown    
*/

class specification ASnode (0:1) of NDnodein, GRowner;

/*------------------ INSTANCE DATA SECTION -------------------*/

override 
  GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

override
  GRgetrang,
  GRgetsymb,
  GRgenabsg,
  GRgetattr,
  GRgetgeom,
  GRgetsize;

#ifndef BASE_EMS

message ACgive_path
(
  IGRint *suc;
  struct GRid *go_obj;
  IGRchar *footname;
);

message ACconnect_pretend
(
  IGRint *rc;
  IGRchar *down_scan;
  struct GRid *pret_GRid;
);

message ACconnect_pretendin
(
  IGRint *rc;
  IGRchar *down_scan;
  struct GRid *pret_GRid;
  struct GRid *context;
);

message ASconstruct_go
(
  struct GRas *asso_lis;
  struct GRmd_env *md_env;
  IGRchar *go_cnst_lis;
  GRclassid go_classid;
  IGRboolean altconstruct;
);

message ASpossible_parent
(
  IGRint ifrom;
  IGRint ito;
  IGRint *geom_code;
  IGRint *option_code;
  IGRint *track_point;
  IGRint *ref;
  IGRint *plan;
  IGRint *nb_return;
  IGRint *nb_tot;
);

message ASget_opt_ind
(
  IGRint index0;
  IGRint *index_track;
  IGRint *index_ref;
  IGRint *index_plane;
);

message ASadd_opt
(
  struct GRid opt;
  IGRint flag;
  struct GRmd_env *md_env;
);

message ASpoststr
(
  IGRlong *msg;
  struct GRmd_env *md_env;
  struct GRpost_info *info;
  IGRshort nb_obj;
  IGRchar **str;
  struct GRid *newobjid;
);

reject 
  ASpoststr;

override 
  NDmove_to_root,  
  NDcopy_graph,    
  NDrm_assoc,	    
  NDcopy,          
  NDcopy_to_root,  
  NDdelete,        
  NDdisplay,	    
  NDgive_structure,
  NDupdate,	    
  NDmake_source,   
  ASreturn_go,     
  NDprint_root,    
  NDdrawing_copy_geom,
  ACcompute_node,
  ACreturn_foot,
  NDattach_to_cs,   
  NDdetach_from_cs, 
  NDattach_to_track_pt,   
  NDdetach_from_track_pt,
  GRlocaldp, 
  GRgetobjinfo,
  GRcopy,      
  GRdelete,    
  GRxform,     
  GRconstruct, 
  GRdisyourself, 
  GRclip,
  GRclipto,
  GRcoplanar,
  GRdetplane,
  GRgetexgeom,
  GRgetexsize,
  GRinplane,
  GRputattr,
  GRchgprops,
  GRdynmod,
  GRfragment,
  EMpratpt,
  EMptatpr,
  EMintplane,
  EMgetpoles,
  GRchgcolor,	
  GRchgdp,	
  GRchglevel,	
  GRchgstyle,	
  GRchgweight,	
  GRmodify,     
  GRkeypoint,   
  GRget_channel_type,     
  GRget_locate_properties,
  GRanalyze_element,
  GRdrop;

#endif

end specification ASnode;
