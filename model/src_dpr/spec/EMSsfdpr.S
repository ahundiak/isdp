/*
  ABSTRACT

  This is an abstract class which represents the design process
  for surfaces, and composite surfaces.


  HISTORY 

  DLB    9/22/87     1.1.0 class conversion
  AIC    03/18/87    Creation Date
  dhm    02/02/89    Inherited from EMScompsurf GRgetsfsize and
                     GRloadform methods.
  SM	   15-Jun-89	override EMcompressed_copy message (defined at
	EMSsurface).
  mrm    03/26/91    override EMresetSSI
  msm    05/20/91    Inherited from EMScompsurf GRreport, GRreport_defaults,
                     GRupdate_gadgets. Removed GRloadform and GRgetsfsize 
                     from inheritance list. Changed the OM based form to 
                     C-based.
*/

class specification EMSsfdpr (1:0) of EMScompsurf, EMSdpr;

/*------------------ INSTANCE DATA SECTION -------------------*/

override GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

from EMScompsurf inherit 
  GRclip, 
  GRgeomprops;

#ifndef BASE_EMS

from EMScompsurf inherit 
  GRget_number_components,
  GRget_components,   
  GRconstruct, 
  GRcopy, 
  GRremove_components,
  EMintplane,
  GRreport, 
  GRreport_defaults,
  GRupdate_gadgets, 
  GRanalyze_element,
  GRxform;

from EMSsurface inherit 
  GRgetobjinfo;

message EMadd
(
  IGRlong *EMmsg;
  struct GRid *active_state;
  struct GRid *saved_state;
  struct GRmd_env *env;
  IGRushort *option;
);

message EMgetownerinfo
(
  IGRlong *EMmsg;
  struct GRid *ownerid;
  IGRint *ownerindex;
);

message EMgetsolidclass
(
  IGRlong *EMmsg;
  IGRchar *solidclass;
);

message EMget_component_parents
(
  IGRlong *EMmsg;
  IGRuint options;
  IGRint list_size;
  IGRint *count;
  GRobjid **component_objids;
);

reject
  EMgetsolidclass,
  EMgetownerinfo;

override 
  EMoffset,
  EMgetSurfsOfPrim,
  NDupdate,                
  EMget_construction_info, 
  EMresetSSI,              
  NDconnect,               
  NDget_objects,           
  NDcopy_graph,            
  NDcopy_to_root,          
  EMgetInGeomIds,
  EMgettreepath,
  EMcanRecompute,
  EMcheckOverlap,
  EMtoggleKDFlag,
  EMaddManager,
  EMgetInfoAboutComponents,
  EMgetprimsfromtree,
  GRdrop,
  EMisactive, 
  EMcompressed_copy, 
  EMvalidate;

#endif

end specification EMSsfdpr;
