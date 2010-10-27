/* $Id: SMcomp.S,v 1.3 2002/04/08 17:11:15 ylong Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        SMcomp/SMcomp.S
 *
 * Description:
 *
 *      Class defining the behavior of the compartments.
 *
 * Dependencies:
 *
 *      VDSroot
 *
 * Revision History:
 *	$Log: SMcomp.S,v $
 *	Revision 1.3  2002/04/08 17:11:15  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/11/05 21:00:32  ylong
 *	Overwrite GRdelete. We need to enable it when pload.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:33  cvs
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
# Revision 1.2  1995/02/22  21:14:30  pinnacle
# Replaced: smcomp/imp/SMcomp.S by rmanem r#
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *
 *      04/24/92        Ch. Heraud      Creation date.
 *      06/01/94        P. Lacroix      subclass under VDSroot.
 *	06/15/94	P. Lacroix	override GRgetrang (get the range of
 *					the foot "solid") because of a bug at
 *					GRowner level.
 *      08/15/94        Radhai Manem    override VDSgetUsrAttributes and
 *                                      VDSmodUsrAttributes
 *	02/16/95	R. Manem	override VDgetParameters
 * -------------------------------------------------------------------------
 */

class specification SMcomp (0:1) of SMAttMgr, VDSroot;


/*+cd
 -------------------------------------------------------------------------

  Class	SMcomp

  Superclass:
	SMAttMgr, VDSroot

  Abstract
      
	This class has been created to implement the compartment object.

  Design Reference
      none

  Methods

      SMGetVolInfo	Public	Return the list of root volumes, volume types, 
				rg collection ids of the compartment.

      SMSetDwSymb	Public	Set the symbology of the compartment to the 
				one associated with the attribute choosen to
				drive the symbology.

      SMGetDw		Public	Get the dead weight object id and name.

      SMGetGrp		Public	Get the group object id and name and the 
				subgroup name and index.

      SMGetCalSect	Public	Get the calculation section depending on the
				compartment.

      SMAddRoots	Public	Add new roots to the compartment (collection
				and volume).

      SMDiscRoots	Public	Disconnect roots from the compartment.

      SMModPtTxt	Public	Modifies the parameters linked to the cog
				foot (point text).

  Overridden Methods

       ACmplace_from_def 	Place an occurence of the macro in the design 
				file.

       ACconstruct_feet		Generates the feet.

       ACgive_path		Give the path of the graphic object.

       ACreturn_foot		return the foot corresponding to a footname.

       GRgetobjinfo		Displays the type of the compartment when it is
				located.

       GRputname		Displays of the name at the cog.

       GRchgname		Modifies the display of the name at the cog.

       SMWhoAreYou		Returns type and subtype of the compartment.

       NDparent_deleted		Keep the associativity if it is a volume that
				has been deleted.

       SMFillSfFile		Adds the compart info to the given file.
				(Seasafe data extraction )

       SMFillRpFile		Adds the compart info to the given file.
				(Seasafe data extraction )

       NDdrawing_copy_geom	Generate the drawing for compartment.

       NDcompute_node		Call a ppl file for computed attributes.

       GRgetrang		send the message to the foot volume.    

       VDSgetUsrAttributes      Define the method that was rejected in VDSroot.

       VDSmodUsrAttributes      Define the method that was rejected in VDSroot.

       VDgetObjDef              Get Object Specific information.	

  Rejected Methods
       none

  Notes/Remarks
       none

 -------------------------------------------------------------------------
-cd*/	/* data class */




/*---------------------
 * Messages
 */



/*+me
 -------------------------------------------------------------------------

  Public Message SMGetVolInfo

  Abstract

    	Return the list of root volumes, volume types, rg collection ids of
	the compartment.
  	The size must be allocated by the user (max volumes = SM_MAX_ALLOW_VOL).
  	If NULL is passed for volume, rg_coll or type they will not be taken
  	into account.

  	About the volume, it is the graphic objects which are returned.

  	The rg collection gather information on the volume, the type specify
  	if it is a compartment or a regular volume.


  Arguments

  IGRlong		*msg		O : Completion code.
  IGRint		list_size	I : Size of volume, rg_col, md_env
					    if they are not NULL.
  IGRint		*nb_vol		O : Number of returned elments
  IGRint		*tt_number	O : Total number of elements.
  struct GRid		*volume		O : List of root volume (can be 
					    NULL if not needed).
  struct GRid		*rg_coll	O : List of rg collections (can be 
					    NULL if not needed).
  IGRshort		*type		O : List of volume type (SM_VOLUME,
					    SM_COMPARTMENT).
  struct GRmdenv_info 	*md_env		O : list of env  (can be 
					    NULL if not needed).


  Status/Return Code
      OM_S_SUCCESS    if success.
      OM_E_ABORT      if not	

 -------------------------------------------------------------------------
-me*/


message SMGetVolInfo(IGRlong *msg; IGRint list_size, *nb_vol, *tt_number; 
		    struct GRid *volume, *rg_col; IGRshort *type;
		    struct GRmdenv_info *md_env);


/*+me
 -------------------------------------------------------------------------

  Public Message SMSetDwSymb

  Abstract

   	Set the symbology of the compartment to the one associated with the 
	attribute choosen to drive the symbology .
  
	For instance if this attribut name was "SW", look if a path "SW" 
	exists and if it exists get its symbology and modify the compartment 
	symbology.

  Arguments

  IGRlong		*msg		O : Completion code.


  Status/Return Code
      OM_S_SUCCESS	if success;
      OM_W_ABORT	if fails

 -------------------------------------------------------------------------
-me*/

message SMSetDwSymb(IGRlong *msg);


/*+me
 -------------------------------------------------------------------------

  Public Message SMGetDw

  Abstract

   	Get the dead weight object id and name.

  Arguments

  IGRlong		*msg		O : Completion code.

  struct GRid		*dw		O : Dead weight id (can be NULL).

  IGRchar		*name		O : Dead weight name (can be NULL).


  Status/Return Code

      OM_S_SUCCESS	if success;
      OM_W_ABORT	if fails

 -------------------------------------------------------------------------
-me*/

message SMGetDw(IGRlong *msg; struct GRid *dw; IGRchar *name);


/*+me
 -------------------------------------------------------------------------

  Public Message SMGetDw

  Abstract

   	Get the group object id and name and the sub group name and index.

  Arguments

  IGRlong		*msg		O : Completion code.

  struct GRid		*grp		O : group id (can be NULL).

  IGRchar		*grp_name	O : group name (can be NULL).

  IGRchar		*sub_name	O : sub group name (can be NULL).

  IGRint		*ind_sub_grp	O : Sub group index (can be NULL).


  Status/Return Code
      OM_S_SUCCESS	if success;
      OM_W_ABORT	if fails

 -------------------------------------------------------------------------
-me*/

message SMGetGrp(IGRlong *msg; struct GRid *grp; IGRchar *grp_name, *sub_name;
		 IGRint *ind_sub_grp);

/*+me
 -------------------------------------------------------------------------

  Public Message SMGetCalSect

  Abstract

    Return the calculation section object depending on the compartment.
    Only one calculation section must depend on a compartment.

    If no calculation section is found CalSect is set to NULL_OBJID.


  Arguments



  IGRlong		*msg		O : Completion code.

  struct GRid		*CalSect	O : calculation section id 
					    (can be NULL).

  struct GRmdenv_info 	*md_env		O : env of the cal section 
					    (can be NULL).
  Status/Return Code
      OM_S_SUCCESS	if success;
      OM_E_ABORT	if fails


 -------------------------------------------------------------------------
-me*/


message  SMGetCalSect(IGRlong *msg; struct GRid *CalSect;
		      struct GRmdenv_info *md_env);


/*+me
 -------------------------------------------------------------------------

  Public Message SMAddRoots

  Abstract

    Add new roots (SMcoll and volume/compart) to an existing compartment.
    The NewRoots argument is a list of (collection and graphic objects). 
    The graphic objects must already be an associative object.


  Arguments

  IGRlong		*msg		O : Completion code.

  IGRint              	NbRoots         I : Number of roots to be added.

  struct GRid		*NewRoots  	I : List of roots objects.

  Status/Return Code
      OM_S_SUCCESS	if success;
      OM_E_ABORT	if fails

 -------------------------------------------------------------------------
-me*/

message SMAddRoots(IGRlong *msg; IGRint NbRoots; struct GRid *NewRoots);

/*+me
 -------------------------------------------------------------------------

  Public Message SMDiscRoots

  Abstract

    Disconect root objects (volume/compart) of an existing compartment.
    If no more graphic root object exist the output argument valid
    is set to FALSE and it is the caller who decides to delete or
    not the compartment.
    If a given DiscRoots does not match a real root, nothing is perform
    and the completion code is set to MSFAIL.


  Arguments

  IGRlong		*msg		O : Completion code. 

  IGRint              	NbRoots         I : Number of roots to be added.

  struct GRid		*DiscRoots  	I : List of roots objects.

  IGRshort            	*Valid          O : True if it remains at least
                                          one graphic objects as root.

  Status/Return Code
      OM_S_SUCCESS	if success;
      OM_E_ABORT	if fails

 -------------------------------------------------------------------------
-me*/

message SMDiscRoots(IGRlong *msg; IGRint NbRoots; struct GRid *DiscRoots; 
                    IGRshort *Valid);

/*+me
 -------------------------------------------------------------------------

  Public Message SMModPtTxt

  Abstract

  This message modifies the parameters linked to the point text (cog foot). 
  This avoid a full recompute of the macro when modifying only display 
  attributes.

  Arguments

  IGRlong		*msg		O : Completion code. 

  IGRshort            	*x_offset       I : x offset (window) in pixels
                                          (NULL if no modification).

  IGRshort            	*y_offset       I : y offset (window) in pixels
                                          (NULL if no modification).

  IGRshort            	*props          I : Point text properties
                                          (NULL if no modification).

  IGRchar             	*text           I : New text definition.


  Status/Return Code
     OM_S_SUCCESS	if success;
     OM_E_ABORT		if fails

 -------------------------------------------------------------------------
-me*/

message SMModPtTxt(IGRlong *msg; IGRshort *x_offset, *y_offset, *props;
                   IGRchar *text);


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

        ACgive_path from ASnode

  Abstract


  Arguments
      IGRint 		*suc              O 	Completion code

      struct GRid	*go_obj		  I	
 
      char 		*name         	  I 	


  Status/Return Code
     OM_S_SUCCESS	if success;
     OM_E_ABORT		if fails

 -------------------------------------------------------------------------
-mo*/

override	ACgive_path;


/*+mo
 -------------------------------------------------------------------------

  Overridden Message

        ACreturn_foot from NDmacro

  Abstract

   Given a foot name returns the object corresponding in the current
   occurence.
   If the foot is a graphic object then this object is returned instead of the source
   one. 
   If the foot is a ACcomplex, then it is returned.

   It has been overriden to connect to a face .

  Arguments

   IGRlong 	*msg          	O : 0 failure 1 succes

   char 	*footname       I : the foot to find (if virtual parent is 
				    required give "" as footname)

   struct GRid 	*foot_obj 	O : the found object.

   IGRshort 	mat_type     	O : matrix type to used with the found object
                           	NULL pointer if not required

   IGRdouble 	*matrix     	O : matrix to used with the found object
                           	NULL pointer if not required


  Status/Return Code
     OM_S_SUCCESS	if success;
     OM_E_ABORT		if fails

 -------------------------------------------------------------------------
-mo*/

override	ACreturn_foot; 

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
       GRgetobjinfo from GRgraphics

  Abstract

	Reports information about the object. 
	It has been overriden to display the type of the compartment when it
	is located (status field).

  Arguments


      IGRlong		*msg             O   	completion code
      struct GRobj_info	*info            O	structure for information about
                                 		the object


  Status/Return Code
     OM_S_SUCCESS	if success;
     OM_E_ABORT		if fails



 -------------------------------------------------------------------------
-mo*/

override	GRgetobjinfo;

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
       GRputname from GRgraphics

  Abstract

	Stores the name of the object.

  Arguments


      IGRlong		*msg             O   	completion code
      IGRchar		*name		 I	The name of the object.

  Status/Return Code
     OM_S_SUCCESS	if success;
     OM_E_ABORT		if fails

 -------------------------------------------------------------------------
-mo*/

override 	GRputname;

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
       GRchgname from GRgraphics

  Abstract

	Changes the name of the object.

  Arguments


      IGRlong		*msg             O   	completion code
      struct GRmd_env	*env		 I	environment of the object.
      IGRchar		*name		 I	The name of the object.

  Status/Return Code

      OM_S_SUCCESS	if success;
      OM_E_ABORT	if fails


 -------------------------------------------------------------------------
-mo*/

override	GRchgname; 

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
       GRdelete from VDSroot

  Abstract

	Delete CACHE attribute when delete myself.

  Arguments


      IGRlong		*msg             O   	completion code
      struct GRmd_env	*env		 I	environment of the object.

  Status/Return Code

      OM_S_SUCCESS	if success;
      OM_E_ABORT	if fails


 -------------------------------------------------------------------------
-mo*/

override	GRdelete; 

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
       SMWhoAreYou from SMmgr

  Abstract

	Returns the type and subtype of the object (See SMdef.h)

  Arguments

   IGRlong           *msg            O : Completion code

   IGRshort          *type           O : Type of the object
                                          (see SMdef.h).

   IGRshort          *sub_type       O : Sub-type of the object
                                          (see SMdef.h).

  Status/Return Code
     OM_S_SUCCESS	if successfull
     OM_E_ABORT 	if not



 -------------------------------------------------------------------------
-mo*/

override	SMWhoAreYou;

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        NDparent_deleted from NDnode

  Abstract

     This message tells the element that some of the parents it depends
     upon are deleted.

     Default implementation at NDnode level is to transform the element
     to non associative by sending it the message NDnode.NDmove_to_root
     (described bellow).

     The element can check which of its roots are deleted and decide to
     rebind to non deleted roots.

     It has been overriden to keep the element associative if it is the
     cs that has been deleted (only set the internal matrix to cs matrix).


  Arguments

      IGRlong		 *msg             O 	completion code MSSUCC MSFAIL
      IGRint		count_deleted     I	number of deleted elements
      struct GRid	list_deleted[]    I 	list of deleted elements
      struct GRid	*new_obj          O 	new id of the element if it 
						changes
      struct GRmd_env	*md_env           I	module env info

  Notes/Remarks

     NB : If the element change id, it is up to it to transfer its
     children/root channel connection to the new object.



  Status/Return Code
      OM_S_SUCCESS	if success;
      OM_E_ABORT	if fails

 -------------------------------------------------------------------------
-mo*/

override	NDparent_deleted;

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
       SMFillSfFile from SMmgr

  Abstract

	Adds the object information to the given file.
	Each object knows how to write its own info.

  Notes/Remarks

	That was implemented for Seasafe data extraction.

  Arguments

   IGRlong           	*mask            O : Completion code

   File              	*p_file          I : File pointer.

   IGRshort           	options          I : Possible options (not yet used).

   IGRboolean         	tag              I : TRUE => only taged objects
                                             are concerned.

   IGRshort           	out_units        I : Output units (SMdef.h)

   struct GRmdenv_info 	*obj_env         I : Object environnement.

   struct GRmdenv_info 	*trans_env       I : Transformation matrix.

  Status/Return Code
    OM_S_SUCCESS	if successfull
    OM_E_ABORT 		if not



 -------------------------------------------------------------------------
-mo*/

override	SMFillSfFile;

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
       SMFillRpFile from SMmgr

  Abstract

	Adds the object information to the given file.
	Each object knows how to write its own info.

  Notes/Remarks

	That was implemented to generate on line reports

  Arguments

   IGRlong           	*mask            O : Completion code

   IGRchar		*DescFile	 O : File describing the output format
					     (can be NULL).

   File              	*p_file          I : File pointer.

   IGRshort           	options          I : Report type (see SMdef.h)

   IGRboolean         	tag              I : TRUE => only taged objects
                                             are concerned.

   IGRshort           	out_units        I : Output units (SMdef.h)

   struct GRmdenv_info 	*obj_env         I : Object environnement.

   struct GRmdenv_info 	*trans_env       I : Transformation matrix.

  Status/Return Code
      OM_S_SUCCESS	if successfull
      OM_E_ABORT 	if not



 -------------------------------------------------------------------------
-mo*/

override	SMFillRpFile;

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        NDdrawing_copy_geom from NDnode

  Abstract

  Whence elements entring a drawing sheet have been selected (by the
  logical selection above or by some other selection), this message is sent to
  selected elements.


  Arguments


  struct GRid	  *seletected_elements 	I 	elements selected for the 
						drawing sheet.

  int		  nb_elements         	I 	number of selected elements.

  struct GRid	  **drawing_elements    O 	list of elements created in 
						the drawing file by the target 
						of the message.
                          			Space deallocated by the caller.

  int		  *nb_drawing_elem     	O  	number of created elements

  double	  *vector              	O 	vector perpendicular to the 
						drawing plane.

  double	  * point               O 	point on the drawing plane.

  int		  *level               	I 	displayable levels. Only the
						components passing the test 
						DPlevel_check(me->level,level)

  struct IGRlbsys *lbsys		I	coord. system of the view plane.

  struct GRmd_env *from_env		I	modele environment.
  struct GRmd_env *to_env     		I 	
						drawing environnement.
						(!= MAIDMX to describe drawing 
						projection)


  Status/Return Code
      OM_S_SUCCESS	if success;
      OM_E_ABORT	if fails


 -------------------------------------------------------------------------
-mo*/

override	NDdrawing_copy_geom; 

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        NDcompute_node from NDnode

  Abstract

     	this method is designed to recompute a node after a change of the
     	elements whose the node is depending upon.

	It has been overriden to call a ppl file for the computed
	attributs.

  Arguments

     IGRlong		*msg		 O 	 completion code
     IGRint		cn_type		 I	 reserved for future use
     IGRint		count		 I	 nb of roots
     struct GRid	list[]		 I	 list of roots of the object.
     struct GRmd_env	*md_env		 I	 Environment info.

  Status/Return Code
      OM_S_SUCCESS	if success;
      OM_E_ABORT	if fails

 -------------------------------------------------------------------------
-mo*/

override        NDcompute_node;      

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        GRgetrang from GRgraphics

  Abstract

     	this method retrieves the range of the object.

	It has been overriden because of a bad behavior at GRowner level.
	Here, it sends the message to the foot solid.

  Arguments

     IGRlong		*msg		 O 	 completion code

     IGRshort		*matrix_type	 O	type of environment matrix
     IGRmatrix		matrix		 O	environment matrix.
     IGRboolean		*world           O	indicator of whether the range 
						should be computed in world or 
						local coordinates.
                                  		1 : apply the environment matrix
                                  		0 : do not apply the 
						    environment matrix
     GRrange		range            O 	range of the object.

  Status/Return Code
      OM_S_SUCCESS	always


 -------------------------------------------------------------------------
-mo*/

override        GRgetrang;

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


end specification SMcomp;
