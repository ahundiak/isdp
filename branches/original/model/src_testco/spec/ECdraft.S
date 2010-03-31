/* ###################   APOGEE COMPILED   ################## */
class specification ECdraft (1:0) of ECelement;

/*
HISTORY

12 May 1989 jBk removed wakeup override; removed mod_info
                instance variable to use previously existing
                md_env ECelement instance variable.
14 Aug 1994 scw clarified sleep method
*/

instance ECdraft
   {
   variable GRobjid     comp_ids[8];
   variable IGRdouble   ang_dis[8];
   variable IGRint      off_code[8];
   IGRpoint off_dirpt;  
   IGRpoint to_pt, from_pt;  
   IGRpoint pt_on_crv;
   IGRdouble length;
   IGRboolean fillet;
   IGRboolean right_side;
   IGRboolean is_composite;
   IGRboolean is_uniform;
   IGRboolean is_linecase;
   IGRboolean phy_closed, non_orth;
   IGRvector  vector, draft_vec;
   IGRint  num_comps;
   IGRint  next_comp;
   IGRchar fillet_def[5], uniform_def[5], code_def[5];
   IGRlong msg;
   };

override init, super_cmd.sleep, execute, wakeup;

end specification ECdraft;
