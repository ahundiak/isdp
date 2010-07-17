#ifndef  VSFapimacros_included
#define  VSFapimacros_included

/* *****************************H H H H H******************************* */
/* Doc: vsf$get_mat_name

   Abstract: Given a plate/stiffener/beam, this macro gets its material type
	     and its material grade. Corresponding to these two variables,
	     it finds the materail properties from iso_mat table.
	     If any material property exists with the obtained properties,
             it returns the name of the property.  Else it creates a new
	     material property and returns.

   Arguments:
        IGRlong          *msg;   	 O   message return code
	struct GRobj_env *struct_elem;   I   Plate or Stiffener or beam
	IGRchar		 *mat_name;      O   Material Name
	IGRchar		 *new_material;  O   will return TRUE  if new
					     material is created, else FALSE.
					     = NULL, if this flag not
					     required.
   Return Status:
	OM_S_SUCCESS	Success
	OM_E_INVARG     Invalid arguments sent

   Examples:
	See the example ppl program in file "getmat.u"

*/
/* *****************************H H H H H******************************* */

extern long SFget_mat_name
	__((	IGRlong		  *msg,
		struct GRobj_env  *struct_elem,
		IGRchar		  *mat_name,
		IGRchar		  *new_material ));

#omdef 	vsf$get_mat_name(  msg,
			   struct_elem,
			   mat_name,
			   new_material = NULL  )

  SFget_mat_name( (msg), (struct_elem), (mat_name), (new_material) )

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: vsf$get_prop_name

   Abstract: Given a plate/stiffener/beam, this macro gets corresponding
	     element property name of the object.
   
	     For Plate, it is obtained in the following manner :

	     *. Plates thickness is obtained.
	     *. Check if any plate property exists with the above
		thickness.
	     *. If yes,  return the name of the property.
	     *. If no, create a plate property with the thickness and
		return the name of the property.
	
	    For stiffeners/beams :

	     *. The beam section type is obtained.
	     *. Get beam properties from prism_beam table for the section type.
	     *. Check if any beam property exists with the above
		properties.
	     *. If yes,  return the name of the property.
	     *. If no, create a beam property with the section properties and
		return the name of the property.

   Arguments:
        IGRlong          *msg;   	 O   message return code
	struct GRobj_env *struct_elem;   I   Plate or Stiffener or Beam
	IGRchar		 *prop_name;     O   Property Name
	IGRchar		 *new_property;  O   will return TRUE  if new
					     property is created, else FALSE.
					     = NULL, if this flag not
					     required.
   Return Status:
	OM_S_SUCCESS	Success
	OM_E_INVARG     Invalid arguments sent

   Examples:
	See the example ppl program in file "getprop.u"

*/
/* *****************************H H H H H******************************* */

extern long SFget_prop_name
	__((	IGRlong		  *msg,
		struct GRobj_env  *struct_elem,
		IGRchar		  *prop_name,
		IGRchar		  *new_property ));

#omdef 	vsf$get_prop_name(  msg,
			   struct_elem,
			   prop_name,
			   new_property = NULL )

  SFget_prop_name( (msg), (struct_elem), (prop_name), (new_property) )

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: vsf$convert_plates_with_all_stfs

   Abstract: Given a list of plates, for each of the plates this macro
	     does the following :

	      i.  Extracts its  base surface. It assigns materail/element 
		  property to the base surface as per the options specified
		  to the macro.
	     ii.  Finds if there are any stiffeners on the plate. If there
                  are no stiffeners it returns.
            iii.  If there are stiffeners, for each of the stiffeners
                  it extracts stiffener axis. Then it creates a non-manifold
                  object ( edge creation state ) with the base surface and
                  stiffener axes. It assigns material/element property
                  to the edges on the non-manifold object ( which correspond
                  to stiffeners ) as per the options specified to the macro.
	
             The base surface of the plate and axes of all stiffners will be
	     copied and a non-manifold object will be created with them.
	     With this macro, material/element property can be attatched.

	     Options for placing material/element property
		0  - Don't place
		1  - Place the given name
		2  - Get the name fro‚m the Database and place. ( Default )

   Arguments:
        IGRlong                 *msg;              O  message return code
	IGRint			nb_plates;	   I  Number of Plates
	struct GRobj_env        *plates;           I  List of Plates
	struct GRvg_construct   *cst;		   I  Construction List
	IGRint			pl_mat_opt;        I  Plate Material Option
	IGRchar		        plate_mat;         I  Plate Material name
			                              Will be used only when 
						      pl_mat_opt is 1 
	IGRint			pl_prp_opt;        I  Plate Property Option
	IGRchar		        plate_prop;        I  Plate Property name
			                              Will be used only when 
						      pl_prp_opt = 1 
	IGRint			st_mat_opt;        I  Stiffener Material Option
	IGRchar		        stf_mat;           I  Stiffener Material name
			                              Will be used only when 
						      st_mat_opt is 1 
	IGRint			st_prp_opt;        I  Stiffener Property Option
	IGRchar			stf_prop;          I  Stiffener Property name
			                              Will be used only when 
						      st_prp_opt is 1
	struct GRid		*nmobj_list;       O  List of NMobjects created.
						     Size of maniobj_list should
						     be as big as 'nb_plates'.
						     Memory should be provided
						     by caller of the macro.
   Return Status:
	OM_S_SUCCESS	Success
	OM_E_INVARG     Invalid arguments sent
        OM_E_NODYNMEM   No dynamic memory available
	OM_E_ABORT	Failure

   Examples:
	See the ppl program in file "plates.u"
*/
/* *****************************H H H H H******************************* */

extern long VSFmake_embedges_on_plates
	  __((  IGRlong                 *msg,
		IGRint			nb_plates,
		struct GRobj_env        *plates,
		struct GRvg_construct   *cst,
		IGRint			pl_mat_opt,
		IGRint			pl_prp_opt,
		IGRint			st_mat_opt,
		IGRint			st_prp_opt,
		IGRchar		        *plate_prop,
		IGRchar		        *plate_mat,
		IGRchar			*stf_prop,
		IGRchar		        *stf_mat,
		struct GRid		*nmobj_list ));

#omdef  vsf$convert_plates_with_all_stfs
			  ( msg,
			    nb_plates,
			    plates,
			    cst,
			    pl_mat_opt = 2,
			    plate_mat  = NULL,
			    pl_prp_opt = 2,
			    plate_prop = NULL,
			    st_mat_opt = 2,
			    stf_mat    = NULL,
			    st_prp_opt = 2,
			    stf_prop   = NULL,
			    nmobj_list        )

  VSFmake_embedges_on_plates( msg, nb_plates, plates, cst,
		pl_mat_opt, pl_prp_opt, st_mat_opt, st_prp_opt,
		plate_prop, plate_mat, stf_prop, stf_mat, nmobj_list )

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: vsf$convert_plate_and_given_stfs

   Abstract: Given a plate and list of stiffners/beams, 
	     this macro does the following :

	      i.  Extracts base surface of plate. Assigns plate material/
		  element property to the base surface as per the options
		  specified to the macro.

             ii.  If any stiffeners/beams are specified to the macro, for each
		  of the stiffeners/beams it extracts stiffener axis. Then it
                  creates a non-manifold object ( edge creation state ) with
                  the base surface and stiffener axes. It assigns 
                  material/element property to the edges on the non-manifold 
                  object ( which correspond to stiffeners/beams ) as per the 
                  options specified to the macro.

	     The base surface of the plate and axes of all stiffners/beams
             will be copied and a non-manifold object will be created with them.
	     With this macro, material/element property can be attatched to
	     surface and edges.

	     EMSsurface can be input instead of plate.
	     GRcurves can be input instead of stiffeners.

	     Options for placing ( material/property )
		0  - Don't place
		1  - Place the given name
		2  - Get the name from the Database and place. ( Default )

   Arguments:
        IGRlong                 *msg;              O  message return code
	struct GRobj_env        *plate;            I  Plate object
	IGRint			nb_stfnrs;	   I  Number of Stiffeners/Beams
	struct GRobj_env        *stfnrs_list;      I  List of Stiffeners/Beams
	struct GRvg_construct   *cst;		   I  Construction List
	IGRint			pl_mat_opt;        I  Plate Material Option
	IGRchar		        plate_mat;         I  Plate Material name
			                              Will be used only when 
						      pl_mat_opt is 1 
	IGRint			pl_prp_opt;        I  Plate Property Option
	IGRchar		        plate_prop;        I  Plate Property name
			                              Will be used only when 
						      pl_prp_opt = 1
	IGRint			st_mat_opt;        I  Stiffener Material Option
	IGRchar		        stf_mat;           I  Stiffener Material name
			                              Will be used only when 
						      st_mat_opt is 1 
	IGRint			st_prp_opt;        I  Stiffener Property Option
	IGRchar			stf_prop;          I  Stiffener Property name
			                              Will be used only when 
						      st_prp_opt is 1
	struct GRid		*nm_obj;	   O  NMobject created

   Return Status:
	OM_S_SUCCESS	Success
	OM_E_INVARG     Invalid arguments sent
        OM_E_NODYNMEM   No dynamic memory available

   Examples:
	See the ppl program in file "pl_stf.u"

*/
/* *****************************H H H H H******************************* */

extern long VSFmakeedges_on_plate_with_given_stfs
	  __((  IGRlong                 *msg,
		struct GRobj_env        *plate,
		IGRint			nb_stfnrs,
		struct GRobj_env        *stfnrs_list,
		struct GRvg_construct   *cst,
		IGRint			pl_mat_opt,
		IGRint			pl_prp_opt,
		IGRint			st_mat_opt,
		IGRint			st_prp_opt,
		IGRchar		        *plate_prop,
		IGRchar		        *plate_mat,
		IGRchar			*stf_prop,
		IGRchar		        *stf_mat,
		struct GRid		*nm_obj		));

#omdef  vsf$convert_plate_and_given_stfs
			      ( msg,
				plate,
				nb_stfnrs,
				stfnrs_list,
			       	cst,
			       	pl_mat_opt = 2,
				plate_mat  = NULL,
			       	pl_prp_opt = 2,
				plate_prop = NULL,
			       	st_mat_opt = 2,
				stf_mat    = NULL,
			       	st_prp_opt = 2,
				stf_prop   = NULL,
				nm_obj )

  VSFmakeedges_on_plate_with_given_stfs( (msg), (plate),
		(nb_stfnrs),  (stfnrs_list), (cst),
		(pl_mat_opt), (pl_prp_opt), (st_mat_opt), (st_prp_opt),
		(plate_prop), (plate_mat), (stf_prop), (stf_mat), (nm_obj) )
#endomdef

#endif
