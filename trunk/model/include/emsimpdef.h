/* Following options are used during the process of imposition of boundaries
   on a surface.
*/

# ifndef emsimpdef_include
# define emsimpdef_include

#define EMImpBnd_WantStatMsg		0x0001 /* Want status messages */

#define EMImpBnd_CloseRegular		0x0002  /* Close the open loops along
						  their existing direction
						*/
#define EMImpBnd_CloseReverse		0x0004  /* Close the open loops along
						  the direction reverse to
						  their existing
						   direction.
						*/
#define EMImpBnd_SplitTopology		0x0008  /* Whenever an edge is split, 
						  make sure to split its
						  common edge and reestablish
						  topology.
						*/
#define EMImpBnd_NoInputDelete		0x0010  /* Any ipnut elements to this
						   method should not be
						   deleted.
						*/
						
#define EMImpBnd_PreciseTrim		0x0020  /* Trimming should be done
						   with maximum possible
						   precision.(This option
						   is comparitively 
						   inefficient and is 
						   recommended only in
						   cases where it is absolutely
						   required).
						*/
						
#define EMImpBnd_NoDummyEdges	       0x0040   /* In an attempt to
						   avoid duplication of edge
						   geometry, a dummy edge
						   is contructed when a
						   reversed copy of the 
						   existing edge is
						   required. However the
						   caller can supress creation
						   of dummy edges by this
						   option. In such a
					           a regular copy is
						   made by duplicating the
						   geometry.
						 */
						
#define EMImpBnd_MaintainAssoc  	0x0080    /* Speciying this option
						   ensures that when new
						   loops or edges are
						   constructed as a
						   result of trim and
						   extraction, the association
						   is maintained to the
						   original object's
						   associations.
						*/
						
#define EMImpBnd_AutoNest		0x0100  /* For imposition of clearly
						   nested boundaries
						   (which do not intersect any
						   existing element).
						   The result is the outermost
						   loop becoming P loop and
						   all other loops toggling.
						   No point in area is
						   required.
						   This option coupled with
						   EMImpBnd_CloseReverse
						   will make the outermost 
						   loop a C loop and then
						   toggle.
						*/

/**********************
#define EMImpBnd_NoPrintError		0x0200    Supress error printing

NOTE: This option is replaced by EMImpBnd_DelInvalidLoops. The users of the
      "EMImpBnd_NoPrintError" option can now achieve the same result (i.e. NOT
      have errors printed to the unix window) by setting the global variable 
      "OM_Gf_verbose_warning" to "0" temporarily in the code and then setting it
      back to its original value.  Since there was no scope for adding
      more options, this one is taking the hit.   (NP 12/08/93)
**********************/

#define EMImpBnd_DelInvalidLoops 	0x0200  /* In the process of imposing 
                                                   the loops, if it is detected
                                                   that a particular loop is
                                                   invalid, then, instead of
                                                   erroring out, the offending
                                                   loop is deleted and the  
                                                   algorithm continues on. 
                                                   Examples of invalid loops are
                                                   external C-loops, C-loops
                                                   nested under other C-loops 
                                                   etc.
                                                 */ 
 
						
#define EMImpBnd_NoFeatureUpdate	0x0400	/* After the loopset
						   modification is complete
						   do not update the feature
						   loops in that loopset
						   wrt the new state of the
						   loopset. Default is do
						   update.
						*/

#define EMImpBnd_NoStateTree		0x0800  /* This option is used by
						   EMSsubbs.EMimpose_boundaries
						   method. It supresses the
						   creation of a new state
						   representing the boundary
						   imposition and modifies 
						   the loopset.
						*/

#define EMImpBnd_DegenerateBdrys	0x1000  /* All dangling bdrys
						   (one or both ends) should
						   treated as degenerate
						   bdrys in modifying the
						   loopset. 
						*/

#define EMImpBnd_BdryIsArea		0x2000	/* While trimming
						   against the loopset consider
						   boundaries as areas, 
						   consequently keeping the
						   overlapping pieces of
						   the geometry getting
						   trimmed.
						*/

#define EMImpBnd_MaintainSplit		0x4000  /* Maintain the SPLIT property
						   of a loop being removed.
						   See emstplydel.h 
						*/

#define EMImpBnd_PlaceFeatures		0x8000  /* Instead of modifying area
						   /hole regions on the surface
						   create features out of the
						   input boundaries.
						*/

/* Following options are used by the method EMSedge.EMsplityourself. Untill
   2.4, this method used the same options as EMImpBnd... (it just supported
   a subset). Since there is a need to control the behavior of this
   method in some more ways and since no more growth is possible with the
   EMImpBnd.. options, a break is necessary. The subset of EMImpBnd.. options
   which were supported by EMSedge.EMsplityourself will continue to be
   supported, but via a different set of options. These options were -

   EMImpBnd_SplitTopology
   EMImpBnd_MaintainAssoc
*/
#define EMSplitEd_SplitTopology		0x0001 /* See EMImpBnd_SplitTopology*/

#define EMSplitEd_MaintainAssoc		0x0002 /* See EMImpBnd_MaintainAssoc*/

#define EMSplitEd_BeginDegenerateSplit	0x0004 /* A degenerate edge is being
                                                  created intentionally by 
                                                  spliting an existing edge
                                                  at its start.
                                               */                        
#define EMSplitEd_EndDegenerateSplit	0x0008 /* A degenerate edge is being
                                                  created intentionally by 
                                                  spliting an existing edge
                                                  at its stop.
                                               */
#define EMSplitEd_ClosureOnRight	0x0010 /* When causing multiple splits
                                                  at the same location, treat
                                                  topological orientation such
                                                  that closure is on right.
                                               */
#define EMSplitEd_ClosureOnLeft		0x0020 /* When causing multiple splits
                                                  at the same location, treat
                                                  topological orientation such
                                                  that closure is on left.
                                               */
#define EMSplitEd_ClosureBothSides     0x0040 /* When causing multiple splits
                                                  at the same location, treat
                                                  topological orientation such
                                                  that closure is on
                                                  both sides of the spliting 
                                                  edge.                        
                                               */
# endif
