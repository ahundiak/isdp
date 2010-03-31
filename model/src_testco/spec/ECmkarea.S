/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This command locates a set of non-ordered curves and outputs the implied
    area(s) bounded by these curves. The areas are implied by the user
    by giving points which are known to lie within the area. The enclosed area
    is computed after projecting the curves onto any arbitrary plane (including
    the apparent view plane). A composite curve (or a single curve) is output
    for each area that has been indicated.

  NOTES

    Currently, the implementation only asks for a single point (hence a 
    single area).

  HISTORY

    SS  :  05/10/89  :  Creation
*/
   
class specification ECmkarea (1:3) of ECelements;

instance ECmkarea
  {
  IGRboolean delete_cvs;
  IGRboolean natural_plane;
  IGRpoint plnpt;
  IGRvector plnnor;
  IGRint numareas;
  variable IGRpoint areapts[2];
  variable GRobjid areacvs[2];
  };

override init, delete, execute, get_locate_criteria;

end specification ECmkarea;


