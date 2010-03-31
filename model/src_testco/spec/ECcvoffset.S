/* ###################   APOGEE COMPILED   ################## */
class specification ECcvoffset (1:0) of ECelement;

/*
HISTORY

11 May 1989 jBk Added history;

                removed struct GRmd_env mod_info from instance
                data in favor of ECelement's pre-existing and
                unutilized struct GRmd_env md_env;

                removed override of wakeup.
*/

instance ECcvoffset
   {
   variable GRobjid     comp_ids[8];
   variable IGRdouble   comp_dis[8];
   variable IGRint      off_code[8];
   IGRpoint off_dirpt;  
   IGRpoint pt_on_crv;
   IGRboolean fillet;
   IGRboolean remove_loops;
   IGRboolean right_side;
   IGRboolean is_composite;
   IGRboolean is_uniform;
   IGRboolean is_linecase;
   IGRboolean phy_closed;
   IGRvector  vector;
   IGRint  num_comps;
   IGRint  next_comp;
   IGRchar fillet_def[5], code_def[5], uniform_def[5];
   };

override init, sleep, execute;

end specification ECcvoffset;
