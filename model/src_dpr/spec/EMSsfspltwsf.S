/*
  ABSTRACT

  This is a constructed class which represents the splitting operation of
  a surface/solid by another surface. The resultant of the split are two
  independent state trees. 

  The class name stands for 'split surface with a surface', not to be confused
  with EMSsfsplit (splitting a surface along an iso parameter).

  The original piece and its complementary are connected across the 
  'to_mirror_image' channel after the operation. If either of them are
  independently modified (e.g move, or local mod on a surf causing reexecute)
  this connection willbe broken and the class changed to appropriate boolean
  class.

 
  HISTORY
 
  SM	06-Jan-89	Design date.
*/

class specification EMSsfspltwsf (1:0) of EMSsfboolean;

/*------------------ INSTANCE DATA SECTION -------------------*/

channel mirror_image_channel
{
  (one_to_one)
  EMSsfspltwsf.to_mirror_image;
};

instance EMSsfspltwsf
{
 channel mirror_image_channel	to_mirror_image;
 IGRushort 		splt_props; 
};

override 
  GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMsplit_with_surface
(
  IGRlong *EMmsg;
  struct GRvg_construct *cons_list;
  GRobjid to_split;
  GRobjid split_with;
  IGRushort bool_options;
  IGRushort splt_options;
  struct GRmd_env *env;
  IGRchar *status_str;
  GRobjid *intobj;
  GRobjid *auxobj;
  GRobjid **display_ids;
  IGRint *display_count;
);

from EMSsurface inherit 
  GRgetobjinfo;

override
    EMchangeClass, 
    EMundo,
    GRxform,		
    GRdelete, 		
    EMgetsolidclass,
    EMdeactivate, 	
    EMactivate,
    EMreexecute; 	

#endif
		
end specification EMSsfspltwsf;
