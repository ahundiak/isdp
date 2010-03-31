/*_________________
  
  FOR EMS 4.0
  Creation : Sanjay
  _________________
*/

#ifndef READDRMFEA_H
#define READDRMFEA_H 1

/* -------------------------------------------------------------------------
 *   The following structure provides the recompute information for Add /
 *   Remove material feature. All the options specified in this file are 
 *   available in $MODEL/include/.......... file.
 * ------------------------------------------------------------------------- */

struct  EMSAddRm_RecompInfo
{
   IGRulong     props;  /* Represents diff. options */   
   IGRulong     fprops; /* Future use */
};
                                 
/*
 * Solid type :
 *
 *   o Solid of Projection
 *   o Solid of Revolution
 *   o Skinning Solid
 *
 */

#define  EMSAddRm_Project                    0x1
#define  EMSAddRm_Revolve                    0x2
#define  EMSAddRm_Skinned                    0x4

/*
 * Solid extent:
 * 
 *   o Add/Remove Material till the secondary solid meets the next surface of
 *     the base solid.
 *   o Add/Remove Material between two surfaces i.e. From and To Surfaces.
 *   o Add/Remove Material by finite distance.
 *   o Add/Remove Material by finite symmetric distance.
 *   o Remove the Material all thru the base solid.
 */

#define  EMSAddRm_ToNext                     0x8
#define  EMSAddRm_FromTo                     0x10
#define  EMSAddRm_Finite                     0x20
#define  EMSAddRm_Symmetric                  0x40
#define  EMSAddRm_ThruAll                    0x80

/*
 *   o Profile is open / closed
 *   o Profile is a Composite curve / Profile
 *   o Profile Normal : the dot product of profile normal and tangent is a 
 *     vector pointing inside profile  / outside profile. 
 *   o Material addition is inside / outside.
 *   o Projection is normal to the profile plane. 
 *   o Projection is along the profile plane normal. 
 *   o FromTo, Revolved the secondary solid need to generate min. sweep angle. 
 *   o Skinning, To Next / Thru Next: secondary solid need to be generated 
 *     along the parametrization of the Trace curve / opposite to it.
 *   o If there is a move on for from surface, store the flag saying that no
 *     from surface.
 *   o If there is a move on for the to surface also, store the flag saying 
 *     that no to surface.
 */   

#define  EMSAddRm_ProfOpen                   0x100
#define  EMSAddRm_ProfComposite              0x200
#define  EMSAddRm_ProfNormalInside           0x400
#define  EMSAddRm_MatInside                  0x800
#define  EMSAddRm_ProjNormal                 0x1000
#define  EMSAddRm_ReverseTrace               0x2000 
#define  EMSAddRm_NoFromSurf                 0x4000
#define  EMSAddRm_NoToSurf                   0x8000

/*
 * The followoing structure stores the global info. necessary for the Add/Remove
 * Material functionality.
 */
/****
struct EMSAddRm_GlobalInfo
{

  IGRlong          props;

  GRrange          solid_range, prof_range, modprof_range, from_surf_range, 
                   to_surf_range;
  IGRpoint         prof_point;
  IGRvector        prof_normal;
  struct IGRplane  from_surf_plane;
  struct IGRplane  to_surf_plane;
}
*****/

#endif
