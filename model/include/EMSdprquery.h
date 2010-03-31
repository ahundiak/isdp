#ifndef EMSdprquery_include
#define EMdprquery_include

/*Defines follow:
*/

#define DPR_BUFF_INCR 20    /*For dpr messages that return malloc'd
                             * and realloc'd arrays, this defines the
                             * initial and extend count.
                             */

/*Structures follow
*/
typedef GRobjid EMSedge_pair[2];

struct EMSadjoin_info
{
  GRobjid      adjoining_surf_id;       /*Adjoining surface id.*/
  IGRint       num_edge_pairs;          /*Number of edge pairs that make up
                                         * the joint.  If num_edge_pairs > 1
                                         * then 'other_edge_pairs' will be
                                         * an array of the 2 thru 
                                         * num_edge_pairs pairs.
                                         */
  EMSedge_pair first_edge_pair;     
  EMSedge_pair *other_edge_pairs;       /*Array of edge pairs (used only if
                                         * num_edge_pairs > 1).
                                         */
};

struct EMScomponent_info
{
  GRobjid               surf_id;        /*Surf id that has adjoining surfs*/
  IGRint                num_adjoin_info;/*Number of adjoining surfs and
                                         * their edge pair list.
                                         */
  struct EMSadjoin_info *adjoin_info;   /*Array of adjoining info.*/
};  

#endif
