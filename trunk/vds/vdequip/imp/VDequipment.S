/* $Id: VDequipment.S,v 1.1.1.1 2001/01/04 21:08:43 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdequip/imp / VDequipment.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDequipment.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:43  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.5  1995/02/22  21:09:06  pinnacle
# Replaced: vdequip/imp/VDequipment.S by rmanem r#
#
# Revision 1.4  1995/02/09  17:45:54  pinnacle
# Replaced: vdequip/imp by azuurhou r#
#
# Revision 1.3  1995/01/10  14:40:44  pinnacle
# Replaced: vdequip/imp by azuurhou r#
#
# Revision 1.2  1994/12/14  21:59:14  pinnacle
# Replaced:  vdequip/imp r#
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	09/15/94	llc		creation date.
 *	11/12/94	adz		add NDdrawing_copy_geom.
 *	02/16/95	rmn		override VDgetParameters
 *
 * -------------------------------------------------------------------*/
/*---------------------------------------------------------------------------*/

class specification VDequipment (0:1) of VDSroot;

instance VDequipment
{
	variable	IGRchar		graph_mac[];
};

/*+cd
 ----------------------------------------------------------------------------

  Class VDequipment

  Superclass:
	VDSroot

  Abstract
	New class for occurence of equipment.

	Equipment support two parameters box in templates following
	by graphics templates.
	Equipment manage the relation with the data base and the
	graphic who it represent in dgn file.

  Design reference
	none.

  Methods
	none.

  Overridden Methods

	ACmplace_from_def	Place an occurence of the macro in design file.

	ACconstruct_feet	Generates the feets.

	ACgive_structure	

	GRgetobjinfo		Display of the name of equipment.

	NDdrawing_copy_geom	Generate the drawing for the equipment.

	VDSgetUsrAttributes	Define method to get user attributes.

	VDSmodUsrAttributes	Define method to modify user attributes.

	VDgetObjDef		Get Object Specific Information.

	VDGetGraphMac   Public  Get the instance graph_mac of equipment object.


  Rejected Methods
	none

  Notes/Remarks

 -----------------------------------------------------------------------------
-cd*/ 	/* data class */


/*---------------------
 * Messages
 */

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
       GRgetobjinfo from GRgraphics

  Abstract

        Reports information about the object.
        It has been overriden to display the type of the compartment when it
        is located (status field).

  Arguments

      IGRlong           *msg             O      completion code
      struct GRobj_info *info            O      structure for information about
                                                the object

  Status/Return Code
     OM_S_SUCCESS       if success;
     OM_E_ABORT         if fails

 -------------------------------------------------------------------------
-mo*/

override        GRgetobjinfo;

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        ACmplace_from_def from ACncpx

  Abstract
	Place an occurence of the macro in the design file.

  Arguments
      int 		*suc       	O 	0 FAILED 1 SUCCESS
      int		prop            I 	see macro.h
      char		rep             I 	navsea representation
      char 		*macro_name	I 	the macro to place
      int 		numb_obj	I 	the number of real template
      struct GRid 	*uplist     	I 	the list of templates
      struct GRid 	*def_occ    	I 	transfer context has to be 
						performed from this default 
						occurence
      struct GRmd_env	*mod_env	I	module env

  Status/Return Code
     OM_S_SUCCESS	if success;
     OM_E_ABORT		if fails

 -------------------------------------------------------------------------
-mo*/

override	ACmplace_from_def;

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        ACconstruct_feet from ACncpx

  Abstract
	Generates the resultant feet set, given the compute parameters.
    	A NULLOBJID or a short list in feet_list are considered as temporary
 	missing feet. A corresponding error is given to give foot access.


  Arguments

	IGRlong 	*rc; 		 O	MSSUCC if success, MSFAIL 
						if not.
	IGRint 		cn_type; 	 I	reserved for future use
        IGRint 		count; 		 I	number of roots
	struct GRid 	list[];	         I    	list of roots the element is
						depending.
	struct GRmd_env *md_env;	 I	current md_env
	IGRint 		*fcount; 	 O	Number of feet (can be less
						than declared)
	struct GRid 	*feet_list	I/O	This array array is initialized
						at input to the nb of declared 
						feet. The method fills the 
						array.

  Status/Return Code
     OM_S_SUCCESS	if success;
     OM_E_ABORT		if fails

 -------------------------------------------------------------------------
-mo*/

override	ACconstruct_feet;

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        NDdrawing_copy_geom from NDnode

  Abstract
	Whence elements entring a drawing sheet have been selected (by the
	logical selection above or by some other selection), this message is
	sent to selected elements.

  Arguments

	struct GRid	*seletected_elements I	elements selected for the 
						drawing sheet.
	int		nb_elements	I 	number of selected elements.
	struct GRid	**drawing_elements   O 	list of elements created in 
						the drawing file by the target 
						of the message.
                          			Space deallocated by the caller.

	int		*nb_drawing_elem     O 	number of created elements
	double		*vector		O 	vector perpendicular to the 
						drawing plane.
	double		*point		O 	point on the drawing plane.
	int		*level		I 	displayable levels. Only the
						components passing the test 
						DPlevel_check(me->level,level)

	struct IGRlbsys *lbsys		I	coord. system of the view plane.
	struct GRmd_env *from_env	I	modele environment.
	struct GRmd_env *to_env     	I 	drawing environnement.
						(!= MAIDMX to describe drawing 
						projection)


  Status/Return Code
	M_S_SUCCESS	if success;
	OM_E_ABORT	if fails

override	NDdrawing_copy_geom; 

 -------------------------------------------------------------------------
-mo*/


/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        ACgive_structure from NDmacro

  Abstract
	ACgive_structure carry names to index in the ACcomplexes.
	When sent to virtual parents (i.e. parents that
        can have ASsource ASsourcein ACpretend ACpretendin supporting
        reference file connects or indexing into a complex). They
        return the real parent or structure. 

  Arguments
	int		*suc       	O 	0 FAILED 1 SUCCESS
	int		*direct_index   O/I	Very dangeous used only by
						symbol macros
	char		*footname	I	the foot to find
	struct ret_struct *ptr_rst      O	the found struct.
	struct GRmd_env	*mod_env	I	module env

  Status/Return Code
     OM_S_SUCCESS	if success;
     OM_E_ABORT		if fails

 -------------------------------------------------------------------------
-mo*/

override	ACgive_structure;

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        VDSgetUsrAttributes from VDSroot

  Abstract
        This method retrieves the user attributes of the compartment object.

  Arguments

     IGRlong            *msg             O       completion code
     IGRint             *nbAttrs         O       No of user attributes
     struct ACrg_coll   **att            O       List of attributes
     struct GRmd_env    *md_env          I       Module environment of object

  Status
      OM_S_SUCCESS      if success
      OM_E_NODYNMEM     not enough dynamic memory
      OM_W_ABORT        if some other error


 -------------------------------------------------------------------------
-mo*/

override        VDSgetUsrAttributes;

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        VDSmodUsrAttributes from VDSroot

  Abstract

        Adds user attributes to the object, modifies user attributs of the
        object, and deletes user attributes from the object according to the
	following logic :

               If the type of the attribute is VD_ATTRIB_DELETE, it is deleted.
               otherwise,
                   If the attribute exists, it is modified to reflect
                   the new type and value.
                   If the attribute does not exist, it is created with the
                   new type and value.


  Arguments

     IGRlong            *msg             O       completion code
     IGRint             nbAttrs          I       No of user attributes to be
                                                 modified
     struct ACrg_coll   *att             I       List of attributes to be
                                                 modified
     struct GRmd_env    *md_env          I       Module environment of object


   Notes
        - the type of an attribute (att[i].desc.type) can have the following 
          values :

              VD_ATTRIB_DELETE
              AC_ATTRIB_TEXT
              AC_ATTRIB_DOUBLE

  Status
      OM_S_SUCCESS      if success
      OM_E_NODYNMEM     not enough dynamic memory
      OM_W_ABORT        if some other error

 -------------------------------------------------------------------------
-mo*/

override        VDSmodUsrAttributes;

/*+me
  Public Message VDgetParameters

  Abstract
        Returns the list of all parameters for the object.

  Arguments
        IGRlong           *msg      O      Completion code.
        IGRint            *nbParams O      Number of parameters
        struct ACrg_coll  **parList O      List of parameters
        struct GRmd_env   *md_env   I      Module environment of object

  Notes/Remarks
        - nbParams is the total number of parameters for the object : 0 or more.
        - Memory will be allocated for the list of ACrg_coll structures
          in the method implementation.  Needs to be freed by the caller.

  Status/Return Code
        OM_S_SUCCESS    : if success
        OM_E_NODYNMEM   : not enough dynamic memory available
        OM_W_ABORT      : if some other error
-me*/

override VDgetParameters;

/*+mo
  Overriden Message
	VDgetObjDef from VDSroot

  Abstract
        Returns the definition of an object: name of templates and feet, etc.
  Arguments
        OUT     long            *msg            Completion code.
        IN      VDobjDef        *objDef         Object definition.
  Note
        The fields of `objDef' point to static buffers and therefore should
        not be freed.
-mo*/

override VDgetObjDef;

/*+mo
  Overriden Message
	VDGetGraphMac from VDSroot

  Abstract
        Returns the graphical macro name of object.

  Arguments
        OUT     long            *msg            Completion code.
        OUT     char        	*MacName        Found Graphical Macro.
  Note
	none.
-mo*/

override VDGetGraphMac;

end specification VDequipment;
