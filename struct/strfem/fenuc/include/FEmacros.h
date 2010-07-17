#ifndef  FEmacros_included
# define  FEmacros_included

#include	"FEformats.h"
#include	"FEfdstruct.h"
#include	"APpardef.h"
#include 	"MHpardef.h"
#include 	"MHfdsymbols.h"
#include	"FEfdsymbols.h"
#include	"igr.h"
# include	<stdio.h>

/* *****************************H H H H H******************************* */
/* Doc: fe$create_beam_property

   Abstract:
   	This macro creates a beam element property group with the given name.

   Arguments:
   	char	name[]		i - Name of the Beam property group
   	
   	int	relative_area	i - For shear area, TRUE if relative
   	
   	double	beam_props[]	i - Array of Beam property values
				BM_AREA    cross section area
				BM_IZZ	   moment of inertia about major axis
				BM_IYY     moment of inertia about minor axis
				BM_IYZ	   product moment of inertia
				BM_JXX	   polar moment of inertia
				BM_SHRAZ   shear area/factor along (Z)
				BM_SHRAY   shear area/factor along (Y)
				BM_REC1Z   Z-coord of stress rec point 1
				BM_REC1Y   Y-coord of stress rec point 1
				BM_REC2Z   Z-coord of stress rec point 2
				BM_REC2Y   Y-coord of stress rec point 2
				BM_REC3Z   Z-coord of stress rec point 3
				BM_REC3Y   Y-coord of stress rec point 3
				BM_REC4Z   Z-coord of stress rec point 4
				BM_REC4Y   Y-coord of stress rec point 4
				BM_SHCTZ   Z-coord of shear center
				BM_SHCTY   Y-coord of shear center
				BM_WARP    Warping coefficient
				BM_TORCON  Torsional constant of section

   Return Status:
	1	-	SUCCESS

   Examples:
	#include "FEmacincl.h"

	main()
	{	
	long sts ;
	int  i;
	char propty_name[FE_MAX_MPNAME_SIZE] ;
	double	bm_val[MAX_BM_VAR] ;

	    strcpy(propty_name,"prop_3");

	    for ( i = 0; i < MAX_BM_VAR; i = i + 1)
    		bm_val[i] = 1.0;

	    sts = fe$create_beam_property (name = propty_name, 
	    				   beam_props = bm_val);
	}

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
	7-2-92	jc	2.0	Creation

*/
/* *****************************H H H H H******************************* */

extern 	int	FE_create_bm_prop();

#omdef 	fe$create_beam_property ( name,
				  relative_area = TRUE,
				  beam_props )

	FE_create_bm_prop( name, relative_area, beam_props) 	

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$create_rod_property

   Abstract:
   	This macro creates a rod element property group with the given name.

   Arguments:
   	char	name[]		i - Name of the rod property group
   	
   	double	area		i - Rod element area
   	
   	double	torsion_const	i - Torsional constant of section


   Return Status:
	1	-	SUCCESS

   Examples:
	#include "FEmacincl.h"

	main()
	{	
	long sts ;
	char propty_name[FE_MAX_MPNAME_SIZE] ;
	double	rod_area, tor_con;

	    strcpy(propty_name,"prop_6");

	    rod_area = 1.0;
	    tor_con = 1.0;

	    sts = fe$create_rod_property (name = propty_name, 
				area = rod_area, torsion_const = tor_con );
	}

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
	7-2-92	jc	2.0	Creation

*/
/* *****************************H H H H H******************************* */

extern 	int	FE_create_rod_prop();

#omdef 	fe$create_rod_property ( name,
				 area,
				 torsion_const )

	FE_create_rod_prop( name, area, torsion_const ) 	

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$create_spring_property

   Abstract:
   	This macro creates a spring element property group with the given name.

   Arguments:
   	char	name[]		i - Name of the spring property group
   	
   	double	axial_stiff	i - Spring axial stiffness
   	
   	double	torsional_stiff	i - Spring torsional stiffness


   Return Status:
	1	-	SUCCESS

   Examples:
	#include "FEmacincl.h"

	main()
	{	
	long sts ;
	char propty_name[FE_MAX_MPNAME_SIZE] ;
	double	ax_stiff, tor_stiff;

	    strcpy(propty_name,"prop_7");

	    ax_stiff = 1.0;
	    tor_stiff = 1.0;

	    sts = fe$create_spring_property ( name = propty_name,  
		      axial_stiff = ax_stiff, torsional_stiff = tor_stiff );
	}

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
	7-2-92	jc	2.0	Creation

*/
/* *****************************H H H H H******************************* */

extern 	int	FE_create_spg_prop();

#omdef 	fe$create_spring_property ( name,
				    axial_stiff,
				    torsional_stiff )

	FE_create_spg_prop( name, axial_stiff, torsional_stiff ) 	

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$create_plate_property

   Abstract:
   	This macro creates a plate element property group with the given name.

   Arguments:
   	char	name[]		i - Name of the Plate property group
   	
   	double	thickness	i - plate thickness
   	
   	int	str_rec_dis_rel	i - TRUE if stress recovery distance is relative
   	
   	double	top_str_rec_dis	i - top stress recovery distance
   	
   	double	bot_str_rec_dis	i - bottom stress recovery distance
   	
   	long	plate_behavior	i - 1 = membrane, 2 = bending,
   				    3 = both, 4 = in plane shear
   	
   	double 	shear_thk_ratio	i - shear thickness ratio
   	
   	double	in_plane_stiff	i - fictitious in-plane stiffness


   Return Status:
	1	-	SUCCESS

   Examples:
	#include "FEmacincl.h"

	main()
	{	
	long 	sts;
	char 	propty_name[FE_MAX_MPNAME_SIZE] ;
	double	thk;

	    strcpy(propty_name,"prop_1");
	    thk = 0.1;

	    sts = fe$create_plate_property (name = propty_name, 
	    				    thickness = thk);
	}

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
	7-2-92	jc	2.0	Creation

*/
/* *****************************H H H H H******************************* */

extern int FE_create_pan_prop();

#omdef 	fe$create_plate_property ( name,
   				   thickness,
   				   str_rec_dis_rel = TRUE,
   				   top_str_rec_dis = 1.0,
   				   bot_str_rec_dis = 1.0,
   				   plate_behavior = 3,
   				   shear_thk_ratio = 0.833333,
   				   in_plane_stiff = 0.02 )

	FE_create_pan_prop( name, plate_behavior, str_rec_dis_rel, thickness, top_str_rec_dis,
			     bot_str_rec_dis, shear_thk_ratio,in_plane_stiff  )

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$create_hook_or_gap_property

   Abstract:
   	This macro creates a hook or gap element property group with the given name.

   Arguments:
   	char	name[]		i - Name of the gap property group
   	
	int	gap_type	i - TRUE if gap, FALSE if hook 

   	double	opening		i - initial opening
   	
   	double	open_stiff	i - stiffness when open
   	
   	double 	closed_stiff	i - stiffness when closed

	double	trans_stiff	i - transverse stiffness

	double	preload		i - preload of gap element

	double	fric_y		i - coefficient of friction in y

	double	fric_z		i - coefficient of friction in z

	int	uni_sp_type	i - FALSE = unidirectional , TRUE = spherical 
   	

   Return Status:
	1	-	SUCCESS

   Examples:
	#include "FEmacincl.h"

	main()
	{	
	long sts ;
	char propty_name[FE_MAX_MPNAME_SIZE] ;
	double	open, op_st, cl_st, pre_ld, fr_y, fr_z, tr_st;

	    strcpy(propty_name,"prop_4");

	    open = 1.0;
	    op_st = 1.0;
	    cl_st = 1.0;
	    pre_ld = 1.0; fr_y = 1.0; fr_z = 1.0; tr_st = 1.0;

	    sts = fe$create_hook_or_gap_property (name = propty_name,
						  opening = open, 
						  open_stiff = op_st, 
						  closed_stiff = cl_st,
						  trans_stiff = tr_st, 
						  preload = pre_ld, 
						  fric_y = fr_y, 
						  fric_z = fr_z);
	}

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
	7-2-92	jc	2.0	Creation

*/
/* *****************************H H H H H******************************* */

extern	int	FE_create_gap_prop();

#omdef 	fe$create_hook_or_gap_property ( name,
					 gap_type = FALSE,
   					 opening,
   					 open_stiff,
   					 closed_stiff,
   					 trans_stiff,
   					 preload,
   					 fric_y,
   					 fric_z,
   					 uni_sp_type = FALSE )

	FE_create_gap_prop ( name, gap_type, opening, open_stiff, closed_stiff,
				trans_stiff, preload, fric_y, fric_z, uni_sp_type )

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$create_rigid_bar_property

   Abstract:
   	This macro creates a rigid bar element property group with the given name.

   Arguments:
   	char	name[]		i - Name of the rigid bar property group
   	
   	int	rotation	i - TRUE if indep node rotation
   				    affects the motion of dep node
   	
   	int	x_dof		i - TRUE if X dof derived from ind node

   	int	y_dof		i - TRUE if Y dof derived from ind node

   	int	z_dof		i - TRUE if Z dof derived from ind node

   	int	rx_dof		i - TRUE if RX dof derived from ind node

   	int	ry_dof		i - TRUE if RY dof derived from ind node

   	int	rz_dof		i - TRUE if RZ dof derived from ind node
   	

   Return Status:
	1	-	SUCCESS

   Examples:
	#include "FEmacincl.h"

	main()
	{	
	long sts ;
	char propty_name[FE_MAX_MPNAME_SIZE] ;

	    strcpy(propty_name,"prop_5");

	    sts = fe$create_rigid_bar_property (name = propty_name, 
	    		x_dof = TRUE, y_dof = TRUE,z_dof = TRUE, 
		 	rx_dof = FALSE, ry_dof = FALSE, rz_dof = FALSE);
	}

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
	7-2-92	jc	2.0	Creation

*/
/* *****************************H H H H H******************************* */

extern 	int	FE_create_rig_prop ();

#omdef 	fe$create_rigid_bar_property ( name,
   				       rotation = TRUE,
   				       x_dof,
   				       y_dof,
   				       z_dof,
   				       rx_dof,
   				       ry_dof,
   				       rz_dof )

	FE_create_rig_prop ( name, rotation, x_dof, y_dof, z_dof, rx_dof, ry_dof, rz_dof)

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$delete_property

   Abstract:
   	This macro deletes an element property group with the given name.

   Arguments:
   	char	name[]		i - Name of the property group
   	
   Return Status:
	1	-	SUCCESS

   Examples:
	#include "FEmacincl.h"

	main()
	{	
	long sts;
	char propty_name[FE_MAX_MPNAME_SIZE] ;

	    strcpy(propty_name,"prop_7");

	    sts = fe$delete_property ( name = propty_name );
	}

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
	7-2-92	jc	2.0	Creation

*/
/* *****************************H H H H H******************************* */

extern	int	FE_delete_prop ();

#omdef 	fe$delete_property ( name )

	FE_delete_prop ( name )	

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$place_property

   Abstract:
   	This macro places an element property on a set of elements.

   Arguments:
   	char		name[]		i - Name of the property group
   	
   	long		el_uids[]	i - Array of uids     OR
   	
	struct GRid	el_grids[]	i - Array of Grids 
	
	long		num_elem	i - Number of elements in the list
   	
   Return Status:
	1	-	SUCCESS

   Examples:
	#include "FEmacincl.h"

	main()
	{	
	long 	sts, uids[4];
	char 	propty_name[FE_MAX_MPNAME_SIZE] ;

	    strcpy(propty_name,"prop_1");

	    uids[0] = 1;
	    uids[1] = 2;
	    uids[2] = 3;
	    uids[3] = 4;

	    sts = fe$place_property (name = propty_name, 
	    			     el_uids = uids, num_elem = 4);
	}

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
	7-2-92	jc	2.0	Creation

*/
/* *****************************H H H H H******************************* */

extern 	int	FE_place_prop ();

#omdef 	fe$place_property ( name,
			    el_uids = NULL ^ 
			    el_grids = NULL,
			    num_elem)

	FE_place_prop ( name, el_uids, el_grids, num_elem )	

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$get_mat_prop_names

   Abstract:
   	This macro gets the names of material and property for a given element.

   Arguments:
   	long		el_uid		i - uid of element    OR
   	
	struct GRid	el_grid		i - Grid of element 
   	
   	char		mat_name[]	o - Name of the material
   	
   	char		prop_name[]	o - Name of the property
   	
   Return Status:
	1	-	SUCCESS

   Examples:
	#include "FEmacincl.h"

	main()
	{	
	long sts, uid;
	char propty_name[FE_MAX_MPNAME_SIZE], matrl_name[FE_MAX_MPNAME_SIZE];

	    uid = 1;

	    sts = fe$get_mat_prop_names ( el_uid = uid, 
	    			          mat_name = matrl_name, 
	    			          prop_name = propty_name );
	}

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
	7-2-92	jc	2.0	Creation

*/
/* *****************************H H H H H******************************* */

extern int FE_get_mat_prop();

#omdef 	fe$get_mat_prop_names ( el_uid = NULL ^ el_grid = NULL, 
   				mat_name,
   				prop_name )

	FE_get_mat_prop ( el_uid, el_grid, mat_name, prop_name )

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$create_axi_sym_property

   Abstract:
   	This macro creates an axisymmetric element property group with the given name.

   Arguments:
   	char	name[]		i - Name of the axisymmetric property group
   	
   	int	str_rec_dis_rel	i - TRUE if stress recovery distance is relative
   	
   	double	thickness	i - thickness
   	
   	double	top_str_rec_dis	i - top stress recovery distance
   	
   	double	bot_str_rec_dis	i - bottom stress recovery distance
   	
   Return Status:
	1	-	SUCCESS

   Examples:
	#include "FEmacincl.h"

	main()
	{	
	long sts ;
	char propty_name[FE_MAX_MPNAME_SIZE] ;
	double	thk;

	    strcpy(propty_name,"prop_2");

	    thk = 0.1;

	    sts = fe$create_axi_sym_property (name = propty_name, 
	    				      thickness = thk);
	}

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
	7-2-92	jc	2.0	Creation

*/
/* *****************************H H H H H******************************* */

extern	int	FE_create_axi_prop ();

#omdef 	fe$create_axi_sym_property ( name,
   				     str_rec_dis_rel = TRUE,
   				     thickness,
   				     top_str_rec_dis = 1.0,
   				     bot_str_rec_dis = 1.0 )

	FE_create_axi_prop ( name, str_rec_dis_rel, thickness,
			    top_str_rec_dis, bot_str_rec_dis )	

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$place_material

   Abstract:
   	This macro places an element material on a set of elements.

   Arguments:
   	char		name[]		i - Name of the material group
   	
   	long		el_uids[]	i - Array of uids     OR
   	
	struct GRid	el_grids[]	i - Array of Grids 
	
	long		num_elem	i - Number of elements in the list
   	
   Return Status:
	1	-	SUCCESS

   Examples:
	#include "FEmacincl.h"

	main()
	{	
	long 	sts, uids[4];
	char 	matrl_name[FE_MAX_MPNAME_SIZE];

	    strcpy(matrl_name,"mat_1");

	    uids[0] = 1;
	    uids[1] = 2;
	    uids[2] = 3;
	    uids[3] = 4;

	    sts = fe$place_material ( name = matrl_name, 
	    			      el_uids = uids, num_elem = 4 );
	}

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
	7-2-92	jc	2.0	Creation

*/
/* *****************************H H H H H******************************* */

extern	int	FE_place_mat ();

#omdef 	fe$place_material ( name,
			    el_uids = NULL ^ 
			    el_grids = NULL,
			    num_elem)

	FE_place_mat ( name, el_uids, el_grids, num_elem )	

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$delete_material

   Abstract:
   	This macro deletes an element material group with the given name.

   Arguments:
   	char	name[]		i - Name of the material group
   	
   Return Status:
	1	-	SUCCESS

   Examples:
	#include "FEmacincl.h"

	main()
	{	
	long 	sts ;
	char 	matrl_name[FE_MAX_MPNAME_SIZE];

	    strcpy(matrl_name,"mat_3");

	    sts = fe$delete_material ( name = matrl_name );
	}

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
	7-2-92	jc	2.0	Creation

*/
/* *****************************H H H H H******************************* */

extern	int	FE_delete_mat ();

#omdef 	fe$delete_material ( name )

	FE_delete_mat ( name )	

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$create_iso_material

   Abstract:
   	This macro creates an isotropic material group with the given name.

   Arguments:
   	char	name[]		i - Name of the isotropic material group
   	
   	double	iso_data[]	i - Array of isotropic material values
				ISO_E	   Elastic Modulus
				ISO_V	   Poisson Ratio   
				ISO_G	   Shear Modulus
				ISO_ALPH   Thermal Expansion Coefficient
				ISO_DENS   Density
				ISO_MAXT   Maximum Tension
				ISO_MAXC   Maximum Compression
				ISO_MAXS   Maximum Shear
				ISO_FY     Yield Stress	
				ISO_FU	   Ultimate Stress
				ISO_DAMP   Damping Coefficient
				ISO_COST   Cost per unit mass

   Return Status:
	1	-	SUCCESS

   Examples:
	#include "FEmacincl.h"

	main()
	{	
	long 	sts ;
	int  	i;
	char 	matrl_name[FE_MAX_MPNAME_SIZE] ;
	double	isomat_val[MAX_ISO_VAR] ;

	    strcpy(matrl_name,"mat_1");
	
	    for ( i = 0; i < MAX_ISO_VAR; i = i + 1)
	    	isomat_val[i] = 1.0;

	    sts = fe$create_iso_material (name = matrl_name, 
	    				  iso_data = isomat_val);
	}

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
	6-23-92	jc	2.0	Creation

*/
/* *****************************H H H H H******************************* */

extern 	int	FE_create_iso_mat();

#omdef 	fe$create_iso_material ( name,
				 iso_data )

	FE_create_iso_mat( name, iso_data) 	

#endomdef


/* *****************************H H H H H******************************* */
/* Doc: fe$create_aniso_material

   Abstract:
   	This macro creates an anisotropic material group with the given name.

   Arguments:
   	char	name[]		i - Name of the anisotropic material group
   	
   	double	aniso_data[]	i - Array of anisotropic material values
				ANISO_D11   Material Matrix entry
				ANISO_D21   Material Matrix entry
				ANISO_D22   Material Matrix entry
				ANISO_D31   Material Matrix entry
				ANISO_D32   Material Matrix entry
				ANISO_D33   Material Matrix entry
				ANISO_D41   Material Matrix entry
				ANISO_D42   Material Matrix entry
				ANISO_D43   Material Matrix entry
				ANISO_D44   Material Matrix entry
				ANISO_D51   Material Matrix entry
				ANISO_D52   Material Matrix entry
				ANISO_D53   Material Matrix entry
				ANISO_D54   Material Matrix entry
				ANISO_D55   Material Matrix entry
				ANISO_D61   Material Matrix entry
				ANISO_D62   Material Matrix entry
				ANISO_D63   Material Matrix entry
				ANISO_D64   Material Matrix entry
				ANISO_D65   Material Matrix entry
				ANISO_D66   Material Matrix entry
				ANISO_A1    Th. expn. coeff. vector entry
				ANISO_A2    Th. expn. coeff. vector entry
				ANISO_A3    Th. expn. coeff. vector entry
				ANISO_A4    Th. expn. coeff. vector entry
				ANISO_A5    Th. expn. coeff. vector entry
				ANISO_A6    Th. expn. coeff. vector entry
				ANISO_DENS  Density
				ANISO_MAXT  Maximum Tension
				ANISO_MAXC  Maximum Compression
				ANISO_MAXS  Maximum Shear
				ANISO_FY    Yield Stress
				ANISO_FU    Ultimate Stress
				ANISO_DAMP  Damping Coefficient
				ANISO_COST  Cost per unit mass

   Return Status:
	1	-	SUCCESS

   Examples:
	#include "FEmacincl.h"

	main()
	{	
	long 	sts ;
	int  	i;
	char 	matrl_name[FE_MAX_MPNAME_SIZE] ;
	double	anisomat_val[MAX_ANISO_VAR] ;

	    strcpy(matrl_name,"mat_3");
	
	    for ( i = 0; i < MAX_ANISO_VAR; i = i + 1)
	    	anisomat_val[i] = 1.0;

	    sts = fe$create_aniso_material (name = matrl_name, 
	    				    aniso_data = anisomat_val);
	}

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
	6-23-92	jc	2.0	Creation

*/
/* *****************************H H H H H******************************* */

extern 	int	FE_create_aniso_mat();

#omdef 	fe$create_aniso_material ( name,
				   aniso_data )

	FE_create_aniso_mat( name, aniso_data) 	

#endomdef


/* *****************************H H H H H******************************* */
/* Doc: fe$create_ortho_material

   Abstract:
   	This macro creates an orthotropic material group with the given name.

   Arguments:
   	char	name[]		i - Name of the orthotropic material group
   	
   	double	ortho_data[]	i - Array of orthotropic material values

   Return Status:
	1	-	SUCCESS

   Examples:
	#include "FEmacincl.h"

	main()
	{	
	long 	sts ;
	int  	i;
	char 	matrl_name[FE_MAX_MPNAME_SIZE] ;
	double	orthomat_val[MAX_ORTHO_VAR] ;

	    strcpy(matrl_name,"mat_2");
	
	    for ( i = 0; i < MAX_ORTHO_VAR; i = i + 1)
	    	orthomat_val[i] = 1.0;

	    sts = fe$create_ortho_material (name = matrl_name, 
	    				ortho_data = orthomat_val);
	}

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
	6-23-92	jc	2.0	Creation

*/
/* *****************************H H H H H******************************* */

extern 	int	FE_create_ortho_mat();

#omdef 	fe$create_ortho_material ( name,
				   ortho_data )

	FE_create_ortho_mat( name, ortho_data) 	

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$uids_to_grids

   Abstract:
   	This macro gets the grids corresponding to uids for a set of nodes or elements.

   Arguments:
	long		ndel		i - NODE or ELEM as in APdef.h

   	long		ndel_uids[]	i - Array of uids
   	
	struct GRid	**ndel_grids	o - List of node/element GRids 
	
	long		num_ndel	i - Number of nodes/elements in the list
   	
   Return Status:
	1	-	SUCCESS

   Examples:
	#include "FEmacincl.h"

	extern	char *malloc();
	extern	int  free();

	main()
	{	
	long 	sts, uids[2];
	struct	GRid	*nd_gid;
	int	i;

	    nd_gid = NULL;
	
	    uids[0] = 1;
	    uids[1] = 2;

	    nd_gid = (struct GRid *) malloc ( sizeof(struct GRid) * 2);

	    sts = fe$uids_to_grids ( ndel = ELEM, ndel_uids = uids, 
					ndel_grids = &nd_gid, num_ndel = 2);

	    if (nd_gid) free (nd_gid); 
	}

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
	6-23-92	jc	2.0	Creation

*/
/* *****************************H H H H H******************************* */

extern	int	AP_ndel_uids_to_grids ();

#omdef 	fe$uids_to_grids ( ndel,
			   ndel_uids ,
			   ndel_grids ,
			   num_ndel )

	AP_ndel_uids_to_grids ( ndel, ndel_uids, ndel_grids, num_ndel )	

#endomdef

/* *****************************H H H H H******************************* */

/* Doc: fe$model_to_file

   Abstract:
   	This macro creates an output ASCII file of the model
	information such as nodes, elements and boundary conditions.
	A part of the model may be written by creating a list
	(el_uids) with the element uids of the elements to be
	written out.

   Arguments:
	char		outfile[]	i - File to write to

	long		format		i - See FEformats.h

	char		title[]		i - Title to print at header

	long		sort_mode	i - TRUE if sorting needed

	long		el_uids[]	i - List of element_uids  	OR
	
	struct GRid	el_grids[]	i - Array of Grids 

	long		num_elem 	i - Number of elements 

   Return Status:
	1	-	SUCCESS

   Notes:
   	To translate all elements in the model set el_grids = NULL

   Examples:
	#include "FEmacincl.h"

	main()
	{	
	long	sts;
	char 	file_name[12] ;

	    strcpy(file_name,"neutest.neu");

	    sts = fe$model_to_file(outfile = file_name, el_grids = NULL );
	}

   History:

	Date		Who		Why
	---------	------		----------------------------------
	6-30-92		jc		Creation

  *****************************H H H H H******************************* */

extern  int FE_model_to_file();

#omdef  fe$model_to_file ( outfile,
			   format = NEUFILE,
			   title  = "",
			   sort_mode = TRUE,
			   el_uids = NULL ^
			   el_grids = NULL,
			   num_elem = 0
			 )

	FE_model_to_file ( outfile, format, title, sort_mode, el_uids, el_grids, num_elem )

#endomdef


/* *****************************H H H H H******************************* */

/* Doc: fe$file_to_model

   Abstract:
  	This macro translates a neutral file into a model. 

   Arguments:

	char		infile[]  	i - File to read from

	char 		center		i - center views to incoming data flg

	char		size_syms	i - set symbol size flag

	char		apply_to_model	i - apply files contents to model

	short		ntrans_meth	i - node translation method (FEneutdefs.h)

	short		etrans_meth	i - elem translation method (FEneutdefs.h)

	long		input_node_var	i - node uid modifier as per ntrans_meth
					    TRANS_UID	n/a
					    USE_START	user selected starting uid
					    ADD_INCR	offset to be added to each
							uid in neutral file

	long		input_elem_var	i - elem uid modifier as per etrans_meth
					    TRANS_UID	n/a
					    USE_START	user selected starting uid
					    ADD_INCR	offset to be added to each
							uid in neutral file

   Return Status:
	1	-	SUCCESS

   Examples:
	#include "FEmacincl.h"

	main()
	{	
	long 	sts ;
	char 	file_name[12] ;

	    strcpy(file_name,"neutest.neu");

	    sts = fe$file_to_model ( infile = file_name );
	}

   History:

	Date		Who		Why
	---------	------		----------------------------------
	6-26-92		jc		Creation

  *****************************H H H H H******************************* */

extern  int FE_file_to_model();

#omdef  fe$file_to_model ( infile,
			   center = TRUE,
			   size_syms = TRUE,
			   apply_to_model = FALSE,
			   ntrans_meth = TRANS_UID,
			   etrans_meth = TRANS_UID,
			   input_node_var = 0,
			   input_elem_var = 0
			 )

	FE_file_to_model ( (char *) infile, (char) center, (char) size_syms, (char) apply_to_model,
			   	(short) ntrans_meth, (short) etrans_meth, (long) input_node_var,
			   	(long) input_elem_var )

#endomdef


/* *****************************H H H H H******************************* */
/* Doc: fe$create_aux_coord_sys

   Abstract:
   	This macro constructs a coordinate system object.

   Arguments:
	char	*name		i - Name of coord sys

	char	*desc		i - Coord sys description 

	long	type		i - See csdef.h

	double	matrix[4][4]	i - Transformation matrix

	double	points[3][3]	i - Origin, X-axis, XZ-plane

   Return Status:
	1	-	SUCCESS

   History:

	Date		Who		Why
	---------	------		----------------------------------
	08/15/91	aea		Creation

  *****************************H H H H H******************************* */

extern  int FE_construct_cs();

#omdef  fe$create_aux_coord_sys( name,
			      	 desc = NULL,
			  	 type = RECTANGULAR,
			  	 matrix = NULL ^
			  	 points = NULL )

	FE_construct_cs ( (name), (desc), (type), (matrix), (points) )

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$place_force_on_node

   Abstract:
   	This macro places a force/moment on a set of nodes.

   Arguments:
   	char		name[]		i - Name of the load case
   	
	double		magnitude	i - Magnitude of the force
	
	double		direction[3]	i - Direction vector of the force
	
	char		type		i - Load type ( see FEfdstruct.h )
	
	char		pull		i - TRUE: Pull, FALSE: Push
	
   	long		nd_uids[]	i - Array of uids     OR
   	
	struct GRid	nd_grids[]	i - Array of Grids 
	
	long		num_node	i - Number of nodes in the list

	struct GRid	*cs_grid	i - pointer to coord. sys. GRid
   	
   Return Status:
	1	-	SUCCESS

   Examples:
	#include "FEmacincl.h"

	main()
	{	
	long 	sts, uids[4];
	char 	load_case_name[18] ;
	double	vec[3] ;

	    strcpy(load_case_name,"LOAD_CASE_1");

	    uids[0] = 1;
	    uids[1] = 2;
	    uids[2] = 3;
	    uids[3] = 4;
	    
	    vec[0] = 0.0;
	    vec[1] = 0.0;
	    vec[2] = 1.0;

	    sts = fe$place_force_on_node (name = load_case_name, 
	    				  magnitude = 10.0, direction = vec,
	    			          nd_uids = uids, num_node = 4);
	}

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
	7-7-92	jc	2.0	Creation

*/
/* *****************************H H H H H******************************* */

extern 	int	FE_place_node_force ();

#omdef 	fe$place_force_on_node ( name,
			      magnitude,
			      direction,
			      type = FE_FORCE,
			      pull = TRUE,
			      nd_uids = NULL ^ 
			      nd_grids = NULL,
			      num_node = 0,
			      cs_grid = NULL )

	FE_place_node_force ( name, magnitude, direction, type, pull, 
				nd_uids, nd_grids, num_node, cs_grid )	

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$place_constraint_on_node

   Abstract:
   	This macro places a constraint on a set of nodes.

   Arguments:
   	char		name[]		i - Name of the constraint set
   	
   	int		x_dof		i - TRUE if X dof is constrained

   	int		y_dof		i - TRUE if Y dof is constrained

   	int		z_dof		i - TRUE if Z dof is constrained

   	int		rx_dof		i - TRUE if RX dof is constrained

   	int		ry_dof		i - TRUE if RY dof is constrained

   	int		rz_dof		i - TRUE if RZ dof is constrained
	
   	long		nd_uids[]	i - Array of uids     OR
   	
	struct GRid	nd_grids[]	i - Array of Grids 
	
	long		num_node	i - Number of nodes in the list

	struct GRid	*cs_grid	i - pointer to coord. sys. GRid
   	
   Return Status:
	1	-	SUCCESS

   Examples:
	#include "FEmacincl.h"

	main()
	{	
	long 	sts, uids[3];
	char 	cons_set_name[18] ;

	    strcpy(cons_set_name,"CONST_SET_1");

	    uids[0] = 1;
	    uids[1] = 2;
	    uids[2] = 3;
	    
	    sts = fe$place_constraint_on_node (name = cons_set_name, 
	    			               nd_uids = uids, num_node = 3);
	}

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
	7-9-92	jc	2.0	Creation

*/
/* *****************************H H H H H******************************* */

extern 	int	FE_place_node_const ();

#omdef 	fe$place_constraint_on_node ( name,
			      x_dof = TRUE,
			      y_dof = TRUE,
			      z_dof = TRUE,
			      rx_dof = TRUE,
			      ry_dof = TRUE,
			      rz_dof = TRUE,
			      nd_uids = NULL ^ 
			      nd_grids = NULL,
			      num_node = 0,
			      cs_grid = NULL )

	FE_place_node_const ( name, x_dof, y_dof, z_dof, rx_dof, ry_dof, rz_dof,
				nd_uids, nd_grids, num_node, cs_grid )	

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$place_spdisp_on_node

   Abstract:
   	This macro places a specified displacement on a set of nodes.

   Arguments:
   	char		name[]		i - Name of the spdisp set
   	
   	double		x_disp		i - Specified displacement in X 

   	double		y_disp		i - Specified displacement in Y

   	double		z_disp		i - Specified displacement in Z

   	double		rx_disp		i - Specified displacement in RX

   	double		ry_disp		i - Specified displacement in RY

   	double		rz_disp		i - Specified displacement in RZ
	
   	long		nd_uids[]	i - Array of uids     OR
   	
	struct GRid	nd_grids[]	i - Array of Grids 
	
	long		num_node	i - Number of nodes in the list

	struct GRid	*cs_grid	i - pointer to coord. sys. GRid
   	
   Return Status:
	1	-	SUCCESS

   Examples:
	#include "FEmacincl.h"

	main()
	{	
	long 	sts, uids[3];
	char 	spd_set_name[18] ;

	    strcpy(spd_set_name,"SPDISP_SET_1");

	    uids[0] = 1;
	    uids[1] = 2;
	    uids[2] = 3;
	    
	    sts = fe$place_spdisp_on_node (name = spd_set_name, 
	    				   nd_uids = uids, num_node = 3);
	}

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
	7-9-92	jc	2.0	Creation

*/
/* *****************************H H H H H******************************* */

extern 	int	FE_place_node_spdisp ();

#omdef 	fe$place_spdisp_on_node ( name,
			      x_disp = AP_UNDEFINED_DBL,
			      y_disp = AP_UNDEFINED_DBL,
			      z_disp = AP_UNDEFINED_DBL,
			      rx_disp = AP_UNDEFINED_DBL,
			      ry_disp = AP_UNDEFINED_DBL,
			      rz_disp = AP_UNDEFINED_DBL,
			      nd_uids = NULL ^ 
			      nd_grids = NULL,
			      num_node = 0,
			      cs_grid = NULL )

	FE_place_node_spdisp ( name, x_disp, y_disp, z_disp, rx_disp, ry_disp, rz_disp,
				nd_uids, nd_grids, num_node, cs_grid )	

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$place_mass_on_node

   Abstract:
   	This macro places a masses on a set of nodes.

   Arguments:
	double		mx 		i - x translational mass

	double		my 		i - y translational mass

	double		mz 		i - z translational mass

	double		ixx 		i - rotational mass about x axis

	double		iyy 		i - rotational mass about y axis

	double		izz 		i - rotational mass about z axis

	double		ixy 		i - Product of Inertia

	double		iyz 		i - Product of Inertia

	double		izx 		i - Product of Inertia
   	
   	long		nd_uids[]	i - Array of uids     OR
   	
	struct GRid	nd_grids[]	i - Array of Grids 
	
	long		num_node	i - Number of nodes in the list

   	
   Return Status:
	1	-	SUCCESS

   Examples:
	#include "FEmacincl.h"

	main()
	{	
	long 	sts, uids[3];

	    uids[0] = 1;
	    uids[1] = 2;
	    uids[2] = 3;

	    sts = fe$place_mass_on_node ( mx = 1.0, my = 1.0, mz = 1.0,
	    			nd_uids = uids, num_node = 3);
	}

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
	7-7-92	jc	2.0	Creation

*/
/* *****************************H H H H H******************************* */

extern 	int	FE_place_node_mass ();

#omdef 	fe$place_mass_on_node (  mx = 0.0,
			      my = 0.0,
			      mz = 0.0,
			      ixx = 0.0,
			      iyy = 0.0,
			      izz = 0.0,
			      ixy = 0.0,
			      iyz = 0.0,
			      izx = 0.0,
		      	      nd_uids = NULL ^ 
			      nd_grids = NULL,
			      num_node = 0 )

	FE_place_node_mass ( mx, my, mz, ixx, iyy, izz, ixy, iyz, izx, 
				nd_uids, nd_grids, num_node )	

#endomdef
/* *****************************H H H H H******************************* */
/* Doc: fe$place_temp_on_node

   Abstract:
   	This macro places temperatures on a set of nodes.

   Arguments:
   	char		name[]		i - Name of the temp set

	double		ref_temp 	i - Reference Temperature

	double		node_temp 	i - Node Temperature

   	long		nd_uids[]	i - Array of uids     OR
   	
	struct GRid	nd_grids[]	i - Array of Grids 
	
	long		num_node	i - Number of nodes in the list

   	
   Return Status:
	1	-	SUCCESS

   Examples:
	#include "FEmacincl.h"

	main()
	{	
	long 	sts, uids[3];
	char 	temp_set_name[18] ;

	    strcpy(temp_set_name,"TEMP_SET_1");

	    uids[0] = 1;
	    uids[1] = 2;
	    uids[2] = 3;

	    sts = fe$place_temp_on_node ( name = temp_set_name, 
	    				  ref_temp = 100.0, 
	    				  node_temp = 110.0, 
	    				  nd_uids = uids, num_node = 3);
	}

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
	7-9-92	jc	2.0	Creation

*/
/* *****************************H H H H H******************************* */

extern 	int	FE_place_node_temp ();

#omdef 	fe$place_temp_on_node (  name,
			      ref_temp = 0.0,
			      node_temp = 0.0,
		      	      nd_uids = NULL ^ 
			      nd_grids = NULL,
			      num_node = 0 )

	FE_place_node_temp ( name, ref_temp, node_temp,  
				nd_uids, nd_grids, num_node )	

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$grids_to_uids

   Abstract:
   	This macro gets the uids corresponding to grids for a set of nodes or elements.

   Arguments:

   	long		ndel_uids[]	o - Array of uids
   	
	struct GRid	ndel_grids[]	i - Array of GRids 
	
	long		num_ndel	i - Number of nodes/elements in the list
   	
   Return Status:
	1	-	SUCCESS

   Examples:
	#include "FEmacincl.h"

	extern	char *malloc();
	extern	int  free();

	main()
	{	
	long 	sts;
	struct	GRid	nd_gid[4];
	long	uids[4];
	int	i;

		nd_gid[0].objid = 480;
		nd_gid[0].osnum = 2;
		nd_gid[1].objid = 481;
		nd_gid[1].osnum = 2;
		nd_gid[2].objid = 489;
		nd_gid[2].osnum = 2;
		nd_gid[3].objid = 490;
		nd_gid[3].osnum = 2;

		sts = fe$grids_to_uids ( ndel_uids = uids, 
					ndel_grids = nd_gid, num_ndel = 4);

	}

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
	1-21-93	jc	2.2	Creation

*/
/* *****************************H H H H H******************************* */

extern	int	AP_ndel_uids_by_grids();

#omdef 	fe$grids_to_uids ( ndel_uids ,
			   ndel_grids ,
			   num_ndel )

	AP_ndel_uids_by_grids( ndel_uids, ndel_grids, num_ndel )	

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$create_runner_property

   Abstract:
   	This macro creates a runner property group with the given name.

   Arguments:
   	char	name[]		i - Name of the runner property group
   	
   	double	diameter	i - diameter of the runner
   	
	char	runner_temp	i - Runner Temperature conditon (defaults to Hot)
					0 - Hot 
					1 - Cold

   Return Status:
	1	-	SUCCESS

   Examples:
	#include "FEmacincl.h"

	main()
	{	
	long sts ;
	char propty_name[FE_MAX_MPNAME_SIZE];
	double	diameter;

	    strcpy(propty_name,"runner_prop");

	    diameter = 1.0;

	    sts = fe$create_runner_property (name = propty_name, 
				diameter = diameter);
	}

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
     19 Mar 93  Manyam	2.2.0	Creation

*/
/* *****************************H H H H H******************************* */

extern 	int	FE_create_runner_prop();

#omdef 	fe$create_runner_property ( name,
				     diameter,
				      runner_temp = 0)

	FE_create_runner_prop( name, diameter, runner_temp ) 	

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$place_injpt_on_node

   Abstract:
   	This macro places injection point feature on a set of nodes.

   Arguments:
   	char		name[]		i - Name of the load case

   	long		nd_uids[]	i - Array of uids     OR
   	
	struct GRid	nd_grids[]	i - Array of Grids 
	
	long		num_node	i - Number of nodes in the list

   	
   Return Status:
	1	-	SUCCESS

   Examples:
	#include "FEmacincl.h"

	main()
	{	
	long 	sts, uids[3];
	char 	injpt_set_name[18] ;

	    strcpy(injpt_set_name,"LC1");

	    uids[0] = 1;
	    uids[1] = 2;
	    uids[2] = 3;

	    sts = fe$place_injpt_on_node ( name = injpt_set_name, 
	    				  nd_uids = uids, num_node = 3);
	}

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      22 Mar 93 Manyam	2.2.0	Creation

*/
/* *****************************H H H H H******************************* */

extern 	int	FE_place_node_injpt();

#omdef 	fe$place_injpt_on_node (  name,
		      	      nd_uids = NULL ^ 
			      nd_grids = NULL,
			      num_node = 0 )

	FE_place_node_injpt ( name, nd_uids, nd_grids, num_node )	

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$place_force_on_element

   Abstract:
   	This macro places a force on a set of 2D or 3D elements. 

   Arguments:
   	char		name[]		i - Name of the load case
   	
	double		magnitude	i - Magnitude of the force
	
	double		direction[3]	i - Direction vector of the force (
					    required in the case VECTOR and 
					    TRACTION loads ) Pass NULL in case 
					    of PRESSURE loads.

	char		type		i - Load type ( FE_NORMAL or FE_TRACTION
					    or FE_VECTOR ) defaults to FE_NORMAL
	
	char		pull		i - TRUE: Pull, FALSE: Push( defaults to
					    TRUE 0

	char		tot_or_dist	i - TRUE: Total FALSE: distributed 
					    ( defaults to FALSE )

	char		dimension	i - dimension of the element 
					    	2:2D  3:3D

	char		face_num	i - face_num to load ( Used in case of
					       3D elements only ) defaults to 0

   	long		el_uids[]	i - Array of uids     OR
   	
	struct GRid	el_grids[]	i - Array of Grids 
	
	long		num_elem	i - Number of elems in the list

	struct GRid	*cs_grid	i - pointer to coord. sys. GRid
   	
   Return Status:
	1	-	SUCCESS

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      6 Jan 93  Manyam	2.2.0	Creation
      09/14/93	jc	3.0	moved from FEqkmacros.h

*/
/* *****************************H H H H H******************************* */

extern 	int	FE_place_elem_force ();

#omdef 	fe$place_force_on_element ( name,
			      magnitude,
			      direction = NULL,
			      type = FE_NORMAL,
			      pull = TRUE,
			      tot_or_dist = FALSE,
			      dimension = 2,
		              face_num = 0,
			      el_uids = NULL ^ 
			      el_grids = NULL,
			      num_elem = 0,
			      cs_grid = NULL )
	FE_place_elem_force ( name, magnitude, direction, type, pull,tot_or_dist,
		dimension, face_num, el_uids, el_grids, num_elem, cs_grid )

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$place_beam_force

   Abstract:
   	This macro places a beam force on a set of 1-D elements. This also
	checks whether beam property exists on the given set of elements.
	It places force only if beam property is found on the set of elems.

   Arguments:
   	char		name[]		i - Name of the load case
   	
	double		magnitude[]	i - Magnitudes  1 & 2 
	
	double		distance[]	i - start and end distances of loading

	char		type		i - Load type ( FE_UNIF_LOAD or
					    FE_CONC_LOAD or FE_TRAP_LOAD )
	
	char		abs_or_rel	i - TRUE: absolute  FALSE: relative

	char		ref_frame 	i - beam ref frame for force direction
				            FE_GLOBAL or FE_LOCAL

	char		beam_dir	i - direction X or Y or Z or RX or RY or RZ
					    ( as defined in FEfdstruct.h)
	
   	long		el_uids[]	i - Array of uids     OR
   	
	struct GRid	el_grids[]	i - Array of Grids 
	
	long		num_elem	i - Number of elems in the list
   	
   Return Status:
	1	-	SUCCESS

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      6 Jan 93  Manyam	2.2.0	Creation
      09/14/93	jc	3.0	moved from FEqkmacros.h

*/
/* *****************************H H H H H******************************* */
extern int	FE_place_beam_force();

#omdef 	fe$place_beam_force ( name,
			      magnitude,
			      distance,
			      type = FE_UNIF_LOAD,
			      abs_or_rel = FALSE,
			      ref_frame = FE_GLOBAL,
			      beam_dir = 1,
			      el_uids = NULL ^ 
			      el_grids = NULL,
			      num_elem = 0 )

	FE_place_beam_force ( name, magnitude, distance, type, abs_or_rel,
		ref_frame, beam_dir, el_uids, el_grids, num_elem )

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$place_heatsource_on_node

   Abstract:
   	This macro places a heat source on a set of nodes.

   Arguments:
   	char		name[]		i - Name of the Heat case
   	
	double		ht_src_val      i - Heat source (this value will
					    get converted in to dbase units 
					    while storing in the instance data)
	
   	long		nd_uids[]	i - Array of uids     OR
   	
	struct GRid	nd_grids[]	i - Array of Grids 
	
	long		num_node	i - Number of nodes in the list

   Return Status:
	1	-	SUCCESS

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      8 Jan 93  Manyam	2.2.0	Creation
      09/14/93	jc	3.0	moved from FEqkmacros.h

*/
/* *****************************H H H H H******************************* */

extern 	int	FE_place_node_htsrc ();

#omdef 	fe$place_heatsource_on_node ( name,
			      ht_src_val = 0.0,
			      nd_uids = NULL ^ 
			      nd_grids = NULL,
			      num_node = 0 )

	FE_place_node_htsrc ( name, ht_src_val, nd_uids, nd_grids, num_node )

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$set_symbol_sizes

   Abstract:
   	This macro sets symbol sizes for various feature descriptor types.

   Arguments:
	double	model_size	i - model size

	char	fd_cat		i - FD category	(MAT or PROP or NONMP or MESHFD )
				    defaults to NONMP_CATEGORY

	char	fd_type		i - FD type as defined in FEfddef.h and MHfddef.h
				    defaults to FORCE_TYPE

	double	*nom_size	i - nominal maximum force or specified 
				    displacement type, used
				    only in case of FORCE_TYPE and
				    SPECDISP_TYPE, pass NULL in other 
				    cases
   Return Status:
	1	-	SUCCESS

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      9 Jan 93  Manyam	2.2.0	Creation
      09/14/93	jc	3.0	moved from FEqkmacros.h

*/
/* *****************************H H H H H******************************* */

extern	int	FEset_symbol_size();

#omdef 	fe$set_symbol_sizes( model_size,
			      fd_cat = NONMP_CATEGORY,
			      fd_type = FORCE_TYPE,
				nom_size = NULL)

	FEset_symbol_size( model_size, fd_cat, fd_type, nom_size)

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$set_active_pars

   Abstract:
   	This macro sets active parameters for FEM attributes in the database.

   Arguments:
   	char	par_type	i - parameter type for FEM attribute as follows:

		CONST_PAR	constraint parameters
		CONVEC_PAR	convection parameters
		EDGE_PAR	edge parameters
		ELEM_PAR	element parameters
		FORCE_PAR	force  parameters
		HEAT_PAR	heat source parameters
		INJ_PAR		injection point parameters
		INTEMP_PAR	initial temperature parameters	
		MASS_PAR	mass parameters
		MATL_PAR	material parameters
		MESHD_PAR	mesh density parameters
		NODE_PAR	node parameters
		PROP_PAR	property parameters
		RAD_PAR		radiation parameters
		SPEC_PAR	specified displacement parameters
		TEMP_PAR	temperature parameters
		SACRIF_PAR	sacrificial element parameters
		BMOFS_PAR	beam end offset parameters
		BMREL_PAR	beam end release parameters

   	char	*par_struct	i - pointer to structure for FEM attribute as follows:

		struct APel_par     el_par;   elements			(see APpardef.h)
		struct APnd_par     nd_par;   nodes			(see APpardef.h)
		struct GRsymbology  edg_par;  edges			(see go.h)
		struct msdens_parms mesh_par; mesh density		(see MHfdsymbols.h)
		struct mp_parms	    mp_par;   materials, properties	(see FEfdsymbols.h)
		struct fd_parms	    fd_par;   constraints, mass,
					      temperature, initial temp,
					      heat source, convection,
					      radiation,injection point,
					      sacrificial element,
		struct frc_parms    frsp_par; force,			(see FEfdsymbols.h)
					      specified displacement



   Return Status:
	1	-	SUCCESS

   Examples:
	#include "FEmacincl.h"
	#include "FEparamtype.h"

	main()
	{	
	long sts ;
	struct frc_parms    frsp_par;

	   frsp_par.symbology.display_attr.style = 0;
	   frsp_par.symbology.level = 105;
	   frsp_par.symbology.display_attr.color = 2;
	   frsp_par.symbology.display_attr.weight = 1;
	   frsp_par.arrow.f1 = 0.0;
	   frsp_par.arrow.f2 = 100.;
	   frsp_par.arrow.s1 = 0.5;
	   frsp_par.arrow.s2 = 1.;
	   frsp_par.arrow.hwid_to_len = 0.5;

	   sts = fe$set_active_pars (par_type = FORCE_PAR, 
	  					par_struct = (char *)&frsp_par );
	}

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      11-08-93	smt	3.0.0	Creation
      11-18-93	smt	3.0.0	Added support for beam releases and offsets.

*/
/* *****************************H H H H H******************************* */

extern 	int	FE_set_active_symparms();

#omdef 	fe$set_active_pars ( par_type, par_struct )

	FE_set_active_symparms( par_type, par_struct ) 	

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$get_active_pars

   Abstract:
   	This macro gets active parameters for FEM attributes in the database.

   Arguments:
   	char	par_type	i - parameter type for FEM attribute as follows:

		CONST_PAR	constraint parameters
		CONVEC_PAR	convection parameters
		EDGE_PAR	edge parameters
		ELEM_PAR	element parameters
		FORCE_PAR	force  parameters
		HEAT_PAR	heat source parameters
		INJ_PAR		injection point parameters
		INTEMP_PAR	initial temperature parameters	
		MASS_PAR	mass parameters
		MATL_PAR	material parameters
		MESHD_PAR	mesh density parameters
		NODE_PAR	node parameters
		PROP_PAR	property parameters
		RAD_PAR		radiation parameters
		SPEC_PAR	specified displacement parameters
		TEMP_PAR	temperature parameters
		SACRIF_PAR	sacrificial element parameters
		BMOFS_PAR	beam end offset parameters
		BMREL_PAR	beam end release parameters

   	char	*par_struct	i - pointer to structure for FEM attribute as follows:

		struct APel_par     el_par;   elements			(see APpardef.h)
		struct APnd_par     nd_par;   nodes			(see APpardef.h)
		struct GRsymbology  edg_par;  edges			(see go.h)
		struct msdens_parms mesh_par; mesh density		(see MHfdsymbols.h)
		struct mp_parms	    mp_par;   materials, properties	(see FEfdsymbols.h)
		struct fd_parms	    fd_par;   constraints, mass,
					      temperature, initial temp,
					      heat source, convection,
					      radiation,injection point,
					      sacrificial element,
		struct frc_parms    frsp_par; force,			(see FEfdsymbols.h)
					      specified displacement


   Return Status:
	1	-	SUCCESS

   Examples:
	#include "FEmacincl.h"
	#include "FEparamtype.h"

	main()
	{	
	long sts ;
	struct frc_parms    frsp_par;

	   sts = fe$get_active_pars (par_type = FORCE_PAR, 
	  					par_struct = (char *)&frsp_par );
	}

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      11-08-93	smt	3.0.0	Creation
      11-18-93	smt	3.0.0	Added support for beam releases and offsets.

*/
/* *****************************H H H H H******************************* */

extern 	int	FE_get_active_symparms();

#omdef 	fe$get_active_pars ( par_type, par_struct )

	FE_get_active_symparms( par_type, par_struct ) 	

#endomdef

#endif

