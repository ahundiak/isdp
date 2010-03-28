/*
  ABSTRACT

  This class is the parent class for all the elements with
  associations built into the design as constraints.

 
  HISTORY

  Unknown
*/

class specification NDnodein (0:1) of NDnode, NDmacro, NDfather, NDchildren;

/*------------------ INSTANCE DATA SECTION -------------------*/

instance NDnodein
{
  short state; 
};                                    


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

override 
  NDget_objects,  
  NDconnect,
  NDdisconnect,
  NDchange_connect,
  NDmove_to_tmp_clone,
  NDget_state,    
  NDchg_state,
  ACin_macro_def,
  ACcompute_node, 
  ACreturn_foot,  
  ACcopy_to_Groot,
  ACconsume,          
  ACunconsume;        

#endif

end specification NDnodein;
