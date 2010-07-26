/*\
Abstract
   The fence set is a union of GRcmpowner and Graphics Set.  This 
   class is used to represent the elements in a spatial volume.  The 
   fence set is unique because it requires special intelligence to handle
   clipping and the fence object.  The fence uses the channel inherited
   from GRcmpowner to own the fence object.

History
   Gray Winn   11/02/86    Design and Coding Date.
   Gray Winn   09/18/87    Changes for 1.1
   Gray Winn   10/07/88    Changes for 1.2
 \*/

class specification GRfcset (1:1) of GRcmpowner, GRgrset;

override 
   GScopy,              /* GRgrset  -  Special proccesing for clip      */
   GSdisplay,           /* GRgrset  -  Special proccesing for clip      */
   GSdelete,            /* GRgrset  -  Special proccesing for clip      */
   GSdissolve,          /* GRgrset  -  Special proccesing for clip      */
   GSpost_processing,   /* GRgrset  -  Special proccesing for clip      */
   GSstart_transition,  /* GRgrset  -  Special proccesing for clip      */
   GSend_transition,    /* GRgrset  -  Special proccesing for clip      */
   GSadd,               /* GRgrset  -  Special proccesing for clip      */
   GSmerge,             /* GRgrset  -  Special proccesing for clip      */
   GSinqcount,          /* GRgrset  -  Special proccesing for clip      */
   GSto_cpx,            /* GRgrset  -  Special proccesing for clip      */
   GS_and_operation,    /* GRgrset  -  Error                            */
   GSflatten_owners,    /* GRgrset  -  flatten the owners               */
   GSremove_member,     /* GRgrset  -  remove a member                  */
   GSget_object;        /* GRgrset  -  Send down the clip overlap channel */



override
   GSundo_save,         /* GRgrset  -  Special proccesing for clip      */
   GS_or_operation;     /* GRgrset  -  Error                            */

override GSupdate_path; /* GRgrset  -  update path (module env info)    */

instance GRfcset
{
   IGRint      prism_type;       /* type of prism                 */
   IGRdouble   prism_matrix[16]; /* transformation matrix from    */
                                 /* local to world coordinates    */
                                 /* (includes origin)             */
   IGRint      prism_num_poles;  /* Num of poles in prism         */
   IGRdouble   prism_height;     /* height (in local z-direction) */
                                 /* of upper prism face           */
   variable IGRdouble prism_poles[];
                                 /* variable length array         */
                                 /* bottom face definition        */
                                 /* (closed, planar polyline in   */
                                 /* x-y plane of local system     */
                                 /* (stored in local coordinates) */

   /* 
    *  The following variables are part of the bspline curve definition.
    *  If the fence is represented as a curve prism, these variables
    *  store the curve definiton.
    */

   IGRshort    prism_curve_order;
   IGRboolean  prism_curve_periodic;
   IGRboolean  prism_curve_non_uniform;
   IGRlong     prism_curve_num_knots;
   IGRboolean  prism_curve_rational;
   IGRboolean  prism_curve_planar;
   IGRboolean  prism_curve_phy_closed;
   IGRshort    prism_curve_num_boundaries;
   variable IGRdouble   prism_curve_knots[];
   variable IGRdouble   prism_curve_weights[];
   variable IGRdouble   prism_curve_bdrys[];

   struct GRid current_overlap_sv;
                              /* represents the current overlap*/
                              /* saveset during locate.        */
   channel 
   {
      (many_to_many,
       rel_ordered,
       initial=1,
       increment=1)
    } clip_overlap;           /* associates objects which      */
                              /* overlap the right prism.      */
};

/*\
Name
   GSput_prism
   
Description
   This method stores the prism.

Arguments
   *msg                 IGRlong        o   return code 
   *prism_type          IGRint         i   Prism type
                                             -  GR_RIGHT_PRISM
                                             -  GR_CURVE_PRISM
   *prism               IGRchar        i   The prism

Return Values
   MSSUCC   -  if successful.
   MSFAIL   -  if failure.
\*/
message GSput_prism (IGRlong *msg; IGRint *prism_type; IGRchar *prism);

end specification GRfcset;
