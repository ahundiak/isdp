/* $Id: SMMainSf.S,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        SMMainSf/SMMainSf.S
 *
 * Description:
 *
 *      Class defining the behavior of the main (or structural) surfaces.
 *
 * Dependencies:
 *
 *      VDSroot
 *
 * Revision History:
 *	$Log: SMMainSf.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:38  cvs
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
# Revision 1.2  1995/02/22  21:18:20  pinnacle
# Replaced: smstrsf/imp/SMMainSf.S by rmanem r#
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
 *      02/01/93        P. Lacroix      Creation date.
 *      08/15/94        Radhai Manem    Override VDSgetUsrAttributes and
 *                                      VDSmodUsrAttributes
 *	02/16/95	R. Manem	Override VDgetParameters
 *
 * -------------------------------------------------------------------------
 */


class specification SMMainSf (0:1) of SMAttMgr, VDSroot;


/*+cd
 -------------------------------------------------------------------------

  Class	SMMainSf

  Superclass:
	SMAttMgr, VDSroot

  Abstract
      
	This class has been created to define the behavior of the main 
	(or structural) surfaces.

  Design Reference
      none

  Methods

      SMModPtTxt	Public	Modifies the parameters linked to the cog
				foot (point text).

      SMcreate		Public	Fills the parameters of the macro and place it.

      SMModify		Public	Modifies the parameters of an existing macro.

      SMGetParameters	Public	Return the list of attributes of the surface.

      SMIsPointOnSf	Public	Determines if the given point lies on the
				surface.


  Overridden Methods

       ACmplace_from_def 	Place an occurence of the macro in the design 
				file.

       ACconstruct_feet		Generates the feet.

       GRgetobjinfo		Displays the type of the surface
				when it is located.

       GRputname		Displays of the name at the cog.

       GRchgname		Modifies the display of the name at the cog.

       NDdelete			Unconsume the surface.

       SMWhoAreYou		Returns type of the surface.


       SMFillSfFile		Adds the main surface info to the given file.
				(Seasafe data extraction )

       SMFillRpFile		Adds the main surface info to the given file.
				(Seasafe data extraction )

       VDSgetUsrAttributes      Define the method that was rejected in VDSroot.

       VDSmodUsrAttributes      Define the method that was rejected in VDSroot.

       VDgetObjDef		Get Object specific onformation.


  Rejected Methods
       none

  Notes/Remarks
       none

 -------------------------------------------------------------------------
-cd*/	/* data class */




/*---------------------
 * Messages
 */


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

override        ACmplace_from_def;

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

override 	ACconstruct_feet;

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
       GRgetobjinfo from GRgraphics

  Abstract

	Reports information about the object. 
	It has been overriden to display the type of the main surface when it
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

override 	GRgetobjinfo; 

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

override        GRputname;

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
        NDdelete from NDnode

  Abstract

     This message is used to delete an element of the graph.
     It has been overriden to unconsume the surface.


  Arguments

      struct GRmd_env	*md_env           I	module env info


  Status/Return Code
      OM_S_SUCCESS	if success;
      OM_E_ABORT	if fails

 -------------------------------------------------------------------------
-mo*/

override 	NDdelete; 



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
override        SMWhoAreYou; 

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

override        SMFillSfFile; 


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

override        SMFillRpFile; 


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

/*+me
 -------------------------------------------------------------------------

  Public Message SMcreate

  Abstract

  	This message fills all the parameters of the macro and 
	place it.

  Arguments

  IGRlong             *msg		O : Completion code.

  IGRint            	nb_att		I : nb attributes in the ACrg_coll

  struct ACrg_coll	*ACrg		I : the attributes 

  IGRshort           	*att_type	I : type of each attribute

  struct GRid		*surface	I : the surface 

  Status/Return Code
     OM_S_SUCCESS	if success;
     OM_E_ABORT		if fails

 -------------------------------------------------------------------------
-me*/

message SMcreate( 	IGRlong *msg;IGRint nb_att; struct  ACrg_coll *ACrg;
			IGRshort *att_type; struct GRid *surface);


/*+me
 -------------------------------------------------------------------------

  Public Message SMModify

  Abstract

  	This message modifies all the parameters of an existing macro .
	

  Arguments

  IGRlong               *msg		O : Completion code.

  IGRint            	nb_att		I : nb attributes in the ACrg_coll

  struct ACrg_coll	*ACrg		I : the attributes 

  IGRshort           	*att_type	I : type of each attribute

  struct GRid		*surface	I : the surface 

  Status/Return Code
     OM_S_SUCCESS	if success;
     OM_E_ABORT		if fails

 -------------------------------------------------------------------------
-me*/

message SMModify( 	IGRlong *msg;IGRint nb_att; struct  ACrg_coll *ACrg;
			IGRshort *att_type; struct GRid *surface)	;


/*+me
 -------------------------------------------------------------------------

  Public Message SMGetParameters

  Abstract

     This method get the parameters of an existing macro.
     A NULL pointer can be given if a parameter is not needed.
	

  Arguments

  IGRlong               *msg		O : Completion code.

  IGRint            	*nb_att		O : nb attributes in the ACrg_coll

  struct ACrg_coll	*ACrg		O : the attributes 

  IGRshort           	*att_type	O : type of each attribute

  struct GRid		*surface	O : the surface 

  Status/Return Code
     OM_S_SUCCESS	if success;
     OM_E_ABORT		if fails

 -------------------------------------------------------------------------
-me*/

message SMGetParameters( IGRlong *msg;IGRint *nb_att; struct  ACrg_coll *ACrg;
			IGRshort *att_type; struct GRid *surface);


/*+me
 -------------------------------------------------------------------------

  Public Message SMIsPointOnSf

  Abstract

     This method determines if the given point lies on the surface	
     The point can be given by its geometry or by its object.
	

  Arguments

  IGRlong                  *msg		 O : Completion code.

  IGRdouble                *pt_geom	 I : point geometry 

  struct GRobj_env	   *pt_object    I : point object 

  IGRint		   *on_surface	 O : 1 = the point is on the surface

  Status/Return Code
     OM_S_SUCCESS	if success;
     OM_E_ABORT		if fails

 -------------------------------------------------------------------------
-me*/

message SMIsPointOnSf( 	IGRlong *msg; IGRdouble *pt_geom; 
			struct GRobj_env *pt_object;IGRint *on_surface)	;


/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        VDSgetUsrAttributes from VDSroot

  Abstract

        This method retrieves the user attributes of the structural surface

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

  Status/Return Code
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

override	VDgetObjDef;

end specification SMMainSf;



