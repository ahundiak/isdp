/* This class represents the loop which is a collection of NMpartedges, created
   as edge features. This loop is not nested inside any region but
   overlaps the boundary of a region. The 'nesting_parent' instance data
   field inherited from NMfeaturelp is used to store the GRobjid of the
   overlapping region.
*/
class specification NMedflp (1:0) of NMfeaturelp;

override 
	NMflpinit; 		/* Nesting parent is the region_edge*/

end specification NMedflp;
