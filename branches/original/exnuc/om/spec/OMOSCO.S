                                                                   /*+private*/
class specification OMOSCO (4:1) of Root;                           /*+cldesc*/

/*
----------- Class Description -------------------------------------------------

   The class OMOSCO is used to manage filed class information on a per 
  object space basis.  The OSCO holds information such as filed class id,
  class name, opp version, etc.  There will be an OSCO object for each 
  class that is represented in an object space.  There may be an OSCO 
  present and no instances of that class in the object space - this is 
  because a subclass of that class is represented in the object space.  
  The OSCO keeps a count of how many instances of the class are in the
  object space.  As objects are constructed the count is incrimented and 
  as they are deleted the count is decrimented.  When the count goes to 
  zero,  the OSCO is deleted if no subclass depends on its presence.

-------------------------------------------------------------------------------
*/                                                                  /*-cldesc*/

                                                                     /*+clrev*/
/*                                                                   
----------- Revision History --------------------------------------------------

-------------------------------------------------------------------------------
*/                                                                   /*-clrev*/

struct component_list_struct
{
   OMuword		classid;	/* filed classid */
   OMuword		offset;
};

struct sd_vla_list
{
   OMuword		elt_size;	/* size in bytes */
   OMuword		offset;
};

struct sd_chan_info 
{
   OMuword              type;           /* channel defn type */
   OMuword              offset;         /* channel offset    */
};

instance OMOSCO                                                       /*+clid*/
{
   OM_S_OSCO    OSCO;                           /*  OSCO portion          */
   channel { (many_to_one) OMObjSpace;} to_OSO; /*  channel to OS Object  */
   variable	struct component_list_struct component_list[];
   variable     struct sd_vla_list vla_list[];
   variable     struct sd_chan_info chan_info[];
   variable     char res_classname[];
   variable     OMuword res_channum[];
   int          component_size;
   OMuword	num_parents;			/* number of parent classes */
};                                                                    /*-clid*/

override delete;                                                    /*+clover*/
                                                                    /*-clover*/
message initialize ( OM_p_CLASSDEF p_ACLD; int init_cnt );           /*+clmsg*/

message set_up(); 

message add_class( char *name; OMuword classid );

message get_res_cnum ( OMuword cnum; OMuword *res_cnum );

message get_chan_info ( OMuword fil_classid; OM_S_CHANNUM channum;
                        int *p_compoff; int *p_chanoff; OMuword *p_type);

message get_vla_info ( OMuword fil_classid; int comp_offset;
                      struct OM_sd_varlenarr_defn **pp_vad; OMuword *num_vla );

message get_all_vla_info ( OMuword fil_classid; OMuint *fixed_size;
                      struct OM_sd_varlenarr_defn **pp_vad; OMuword *num_vla );

			                                             /*-clmsg*/


end specification OMOSCO;                                          /*-private*/
