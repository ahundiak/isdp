
/* $Id: VDSroot.S,v 1.1.1.1 2001/01/04 21:09:12 cvs Exp $  */
/* I/VDS
 *
 * File:        VDSroot.S
 *
 * Description:
 *      Super class of all associative objects of products 
 *      I/VDS, I/SMAN, I/STRUCT, I/ROUTE and I/LOFT.
 *
 *
 * Revision History:
 *	$Log: VDSroot.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:12  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.7  1998/02/03  22:50:16  pinnacle
# Replaced: vdroot/VDSroot.S for:  by rchennup for vds
#
# Revision 1.6  1997/12/30  15:41:08  pinnacle
# Replaced: vdroot/VDSroot.S for:  by kddinov for vds
#
# Revision 1.5  1997/12/12  23:49:28  pinnacle
# Replaced: vdroot/VDSroot.S for:  by yzhu for vds
#
# Revision 1.4  1997/11/25  06:32:24  pinnacle
# Replaced: vdroot/VDSroot.S for:  by rchennup for vds
#
# Revision 1.2  1997/10/23  21:44:02  pinnacle
# Replaced: vdroot/VDSroot.S for:  by v250_int for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.5  1997/02/28  10:54:56  pinnacle
# Replaced: vdroot/VDSroot.S for:  by ksundar for vds.241
#
# Revision 1.4  1997/02/28  10:25:30  pinnacle
# Replaced: vdroot/VDSroot.S for:  by ksundar for vds.241
#
# Revision 1.3  1996/11/02  16:04:42  pinnacle
# Replaced: vdroot/VDSroot.S for:  by v241_int for vds.241
#
# Revision 1.2  1996/09/08  17:49:42  pinnacle
# Replaced: vdroot/VDSroot.S for:  by msmanem for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.10  1996/03/22  23:19:26  pinnacle
# Replaced: vdroot/VDSroot.S for:  by v240_int for vds.240
#
# Revision 1.9  1995/08/07  18:37:32  pinnacle
# Replaced: vdroot/VDSroot.S for:  by azuurhou for vds.240
#
# Revision 1.8  1995/07/11  20:18:36  pinnacle
# Replaced: vdroot/VDSroot.S for:  by azuurhou for vds.240
#
# Revision 1.7  1995/05/31  20:09:34  pinnacle
# Replace: vdroot/VDSroot.S by hverstee for OPE
#
# Revision 1.6  1995/03/02  22:52:04  pinnacle
# Replaced: vdroot by azuurhou r#
#
# Revision 1.5  1995/02/22  21:04:28  pinnacle
# Replaced: vdroot/VDSroot.S by rmanem r#
#
# Revision 1.4  1995/02/09  17:44:04  pinnacle
# Replaced: vdroot/VDSroot.S by azuurhou r#
#
# Revision 1.3  1995/01/10  14:45:22  pinnacle
# Replaced: vdroot by azuurhou r#
#
# Revision 1.2  1994/12/22  22:03:46  pinnacle
# Replaced: vdroot/VDSroot.S by azuurhou r#
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *      04/15/94        Eric FAIVRE      Creation Date
 *      08/10/94        R. Manem         Added messages VDSgetUsrAttributes,
 *                                       VDSmodUsrAttributes, and VDSgetCompDesc
 *      09/08/94        R. Manem         Added message VDGetModel
 *	12/22/95	adz		 ADd drawing_copy_geom method.
 *	02/15/95	rmn		 Added methods VDgetParameters and
 *					 VDreviewParameters
 *	03/02/95	adz		 Add VDrtcompute - VDrtcreate.
 *	03/22/96	adz		 Add ACgive_structure for SMAttrMgr.
 *	11/03/96	adz		 Add VDGenCenterLine message.
 *	02/28/97	sundar		 Add VDgetAttrDrivenSymb &
 *					 VDputAttrDrivenSymb  messages.
 *      11/20/97        Rama Rao         Add VDExecutePpl message.
 *      12/05/97        yzhu             Add VDprod_info message.
 *	12-97		kdd		 VDGetParamsId. Virtual method to 
 *					 get IDs of ACrg_coll parents.
 *	02/03/97	Rama Rao	 Override ACcontext_compute_feet method
 *					 to let the feets to control their
 *					 own symbology.
 */

/*+cd

  Class VDSroot

  Superclass:
        ACncpx

  Abstract
        Class created as a super class of all associative objects of products 
        I/VDS, I/SMAN, I/STRUCT, I/ROUTE and I/LOFT.

  Design Reference
      none

  Methods

    VDget_trans_table_entries     Public     get entries of the trans table

    VDget_prefix_name             Public     get the prefix name of the object
                                             to be named

    VDSgetUsrAttributes           Public     get the user attributes of 
                                             the object


    VDSmodUsrAttributes           Public     modify the user attributes of 
                                             the object

    VDSgetParameters              Public     get the list of parameters of
                                             the object

    VDSreviewParameters           Public     review object parameters 

    VDSgetCompDesc                Public     Get the named parameter from the
                                             component database attributes

    VDGetModel                    Public     Get the route component's cache

    VDgetObjDef			  Public     Get object specific information.

    VDGetGraphMac		  Public     Get the graphical Macro of Objects.

    VDcreate                      Public     Fill the parameters of the macro
                                             and place the macro.

    VDprint                       Public     Instance print-out of object.

    VDcompute                     Public     Compute the object.

    VDGetProduct                  Public     Retrieve product name/number
                                              (cf. route)

    VDGetCenterLine		  Public     Method for getting centerlines
					     of piping components.

    VDgetAttrDrivenSymb           Public     Gets Attribute driven symbology.
 
    VDputAttrDrivenSymb           Public     Puts Attribute driven symbology.

    VDdescribeOutput		  Public     Create output name of attributes.

    VDGetParamsId		  Public     Gets IDs of ACrg_coll parents.

  Overridden Methods

     NDconnect_graph              Use message 'VDget_trans_table_entries' and 
                                  'VDget_prefix_name' to put symbology coming 
                                  from the Trans Table and try to name the 
                                  copied element.

     NDdrawing_copy_geom          Generate the drawing fro the equipment.

     DIgive_output		  Allows the type of the object to be output
				  next to its name (if object is named) in the
				  "Directory Command" form.

     find_macro			  Find the macro from VDSroot subclass objects.

     ACgive_structure		  Overwritten to guide SMAttrMgr objects.


  Rejected Methods

     VDget_trans_table_entries     

     VDget_prefix_name            

     VDSgetUsrAttributes         

     VDSmodUsrAttributes        

     VDSgetCompDesc                 

     VDGetModel                 

     VDGetGraphMac

     VDprint

     VDGetCenterLine

     VDGetParamsId

  Notes/Remarks
       none

-cd*/   /* data class */


class specification VDSroot(0:0) of ACncpx ;

#include	"vds.h"
#include	"v_slc.h"
#include	"vdprocinfo.h"

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        NDdrawing_copy_geom from NDnode

  Abstract
        Whence elements entring a drawing sheet have been selected (by the
        logical selection above or by some other selection), this message is
        sent to selected elements.

  Arguments

        struct GRid     *seletected_elements I  elements selected for the
                                                drawing sheet.
        int             nb_elements     I       number of selected elements.
        struct GRid     **drawing_elements   O  list of elements created in
                                                the drawing file by the target
                                                of the message.
                                                Space deallocated by the caller.
        int             *nb_drawing_elem     O  number of created elements
        double          *vector         O       vector perpendicular to the
                                                drawing plane.
        double          *point          O       point on the drawing plane.
        int             *level          I       displayable levels. Only the
                                                components passing the test
                                                DPlevel_check(me->level,level)

        struct IGRlbsys *lbsys          I       coord. system of the view plane.
        struct GRmd_env *from_env       I       modele environment.
        struct GRmd_env *to_env         I       drawing environnement.
                                                (!= MAIDMX to describe drawing
                                                projection)


  Status/Return Code
        M_S_SUCCESS     if success;
        OM_E_ABORT      if fails

override        NDdrawing_copy_geom;
 -------------------------------------------------------------------------
-mo*/

/*+mo

  Overridden Message
        ACgive_structure

  Abstract

	Control the SMAttrMgr give_structure.
-mo*/

override ACgive_structure;

/*+mo

  Overridden Message
        find_macro

  Abstract

	Find macro for VDSroot subclass objects.
-mo*/


override find_macro ;

/*+mo

  Overridden Message
        NDconnect_graph

  Abstract

	Use message 'VDget_trans_table_entries' and 'VDget_prefix_name' to
	put symbology coming from the Trans Table and try to name the copied
	element.

-mo*/


override NDconnect_graph ;

/*+mo
  Overridden Message
	DIgive_output	from	ACncpx

  Abstract
        Allows the type of the object to be output next to its name (if object
        is named) in the "Directory Command" form.
-mo*/

override DIgive_output;

/*+mo
  Overridden Message
	NDdelete	from	ACncpx

  Abstract
	Overiding NDdelete to take care of deletion of PME data.
        
-mo*/
override NDdelete;

/*+mo
  Overridden Message
	NDupdate	from	ACncpx

  Abstract
	Overriding NDupdate to do  PME update
-mo*/
override NDupdate;

/*+mo
  Overridden Message
        ACcontext_compute_feet   from    ACncpx

  Abstract
        Overriding to let the feets to control their own symbology
-mo*/
override ACcontext_compute_feet;

/*+me
  Public Message VDget_trans_table_entries

  Abstract
	Returns entries of the trans table.

  Algorithm
      <Optional Description>

  Arguments
        long            *msg       O      Completion code
        struct GRid     *main_root O      Main root of object.
        char            *cmd_name  O      Command name of object.

  Notes/Remarks

	MESSAGE ONLY USED WITH THE 'Copy Graph' COMMAND.

	- If the object doesn't have to use the trans table, 'msg' should be
	  MSFAIL and the message should return OM_E_ABORT.

	- 'main_root' could be NULL_OBJID, in this case the main root
	  of the trans table is the first parent of the object.

-me*/

message VDget_trans_table_entries( long 	*msg ;
				   struct GRid	*main_root ;
				   char 	*cmd_name ) ;
reject VDget_trans_table_entries ;

/*+me
  Public Message VDget_prefix_name

  Abstract
	Returns the prefix name of the object to be named.

  Arguments
      <Data Type>       <Name>  <I/O>   <Description>
        long            *msg       O      Completion code.
        char            *directory I      Directory to put object in.
        int             *real_name O      TRUE/FALSE, see note.
        char            *prefix    O      Prefix.

  Notes/Remarks

	MESSAGE ONLY USED WITH THE 'Copy Graph' COMMAND.

	- If the object doesn't have to be named, 'msg' should be
	  MSFAIL and the message should return OM_E_ABORT.

	- 'real_name' could be TRUE or FALSE :
		- TRUE :
			the returned prefix is the real name.
		- FALSE :
			the returned prefix is not the real name, the real
			name will be the prefix followed by a number.
-me*/

message VDget_prefix_name( long 	*msg ;
			   char 	*directory ;
			   int		*real_name ;
			   char 	*prefix ) ;
reject VDget_prefix_name ;

/*+me
  Public Message VDSgetUsrAttributes

  Abstract
        Returns the list of user attributes of the object.

  Arguments
        IGRlong           *msg      O      Completion code.
        IGRint            *nbAttrs  O      Number of user attributes
        struct ACrg_coll  **att     O      List of attributes
        struct GRmd_env   *md_env   I      Module environment of object

  Notes/Remarks
        - nbAttrs is number of user attributes for the object : 0 or more.
        - Memory should be allocated for the list of ACrg_coll structures to 
          return the attributes, in the method implementation.

  Status/Return Code
        OM_S_SUCCESS    : if success
        OM_E_NODYNMEM   : not enough dynamic memory available 
        OM_W_ABORT      : if some other error
-me*/

message VDSgetUsrAttributes( IGRlong          *msg ;
                             IGRint           *nbAttrs;
                             struct ACrg_coll **att;
                             struct GRmd_env  *md_env );

reject VDSgetUsrAttributes;

/*+me
  Public Message VDSmodUsrAttributes

  Abstract

        Adds user attributes to the object, modifies user attributes of the
        object, and deletes user attributes from the object according to the
        following logic :

               If the type of the attribute is VD_ATTRIB_DELETE, it is deleted.
               otherwise,
                   If the attribute exists, it is modified to reflect
                   the new type and value.
                   If the attribute does not exist, it is created with the
                   new type and value.

  Arguments
        IGRlong           *msg     O       Completion code.
        IGRint            nbAttrs  I       Number of user attributes 
                                           to be modified
        struct ACrg_coll  *att     I       List of attributes 
        struct GRmd_env   *md_env  I       Module environment of object

  Notes/Remarks
        - the type of an attribute (att[i].desc.type) can have the following 
          values :

              VD_ATTRIB_DELETE
              AC_ATTRIB_TEXT
              AC_ATTRIB_DOUBLE

  Status/Return Code
        OM_S_SUCCESS    : if success
        OM_E_NODYNMEM   : not enough dynamic memory available 
        OM_W_ABORT      : if some other error
-me*/

message VDSmodUsrAttributes( IGRlong          *msg ;
                             IGRint           nbAttrs;
                             struct ACrg_coll *att;
                             struct GRmd_env  *md_env );

reject VDSmodUsrAttributes;

/*+me
  Public Message VDreviewParameters

  Abstract
        Returns the types and values of the parameters specified in the parList
	filled in by the caller.

  Arguments
        IGRlong           *msg        O      Completion code.
        IGRint            nbParams    I      Number of parameters initialized
					     in the list
        struct ACrg_coll  *parList   I/O     List of parameters
					     	Input  : names of parameters
					     	Output : types and values
        struct GRmd_env   *md_env     I      Module environment of object

  Notes/Remarks 
	msg = MSFAIL, 	when any one of the parameters is not valid for the
			object. However other parameter values are output.
			Type for invalid parameters is set to 
			AC_ATTRIB_TYPE_NOT_DEF.

  Status/Return Code
        OM_S_SUCCESS    : if success (*msg may be MSFAIL)
        OM_W_ABORT      : if some other error
-me*/

message VDreviewParameters( 	IGRlong			*msg;
		 	 	IGRint			nbParams;
			 	struct ACrg_coll	*parList;
				struct GRmd_env		*md_env );

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
	- IMPORTANT NOTE : the names of the parameters must be the complete
          --------------
	  names (for eg : stat_attr:macro_name, or attributes:op_pres )

  Status/Return Code
        OM_S_SUCCESS    : if success
        OM_E_NODYNMEM   : not enough dynamic memory available
        OM_W_ABORT      : if some other error
-me*/

message VDgetParameters(	IGRlong			*msg;
				IGRint			*nbParams;
				struct ACrg_coll	**parList;
				struct GRmd_env		*md_env );

/*+me
  Public Message VDSgetCompDesc

  Abstract
         Returns the named parameter from the component database attributes.

  Arguments
        struct ACrg_coll   *Param    I/O     Pointer to the parameter structure;
                                             The name field is used as input 
                                             and the desc field as output.
        struct GRmd_env    *md_env    I      pointer to module environment.
        IGRlong            *msg       O      Completion code.

  Notes/Remarks

        This message has been introduced at the VDSroot level, to support the
        vd$ReviewParameters macro. The macro implementation sends this message
        VDSgetCompDesc to a VRGeneric subclassed Route object. The message is
        rejected in VDSroot and is implemented in VRGeneric.

-me*/

message VDSgetCompDesc(IGRlong          *msg;
                       struct ACrg_coll *Param;
                       struct GRmd_env  *md_env );

reject VDSgetCompDesc;

/*+me
  Public Message VRGetModel

  Abstract
        Returns the component's cache stored in the design based on its
        attributes

  Arguments
        IGRlong              *msg            O : MSSUC if success 
                                                 MSFAIL if not.
        struct GRid          *ModelId        O : Pointer to the model 
                                                 identifier structure
        struct GRmd_env      *md_env         I : pointer on module env



  Notes/Remarks

        This message has been introduced at the VDSroot level, to support the
        vd$get_parameters macro. The macro implementation sends this message
        to a VRGeneric subclassed Route object. The message is
        rejected in VDSroot and is implemented in VRGeneric.

-me*/

message VDGetModel( IGRlong          *msg;
                    struct GRid      *ModelId ;
                    struct GRmd_env  *md_env);

reject VDGetModel;


/*+me
  Public Message VDGetGraphMac

  Abstract
      Set the macro name of the graphic object inside the complex object.
      This returns the graphical equipment macro and the the graphical
      symbol macro for piping components.

  Arguments
        IGRlong          *msg            O      MSSUC if success and
                                                MSFAIL if not.
        IGRchar          *MacName        I      macro name

  Status/Return Code
      status == OM_S_SUCCESS if success else OM_E_ABORT.

 -------------------------------------------------------------------------
-me*/
message VDGetGraphMac(	IGRlong	*msg;
			IGRchar	*MacName );

reject	VDGetGraphMac ;

/*+me
  Public Message VDPostYourselfToDb

  Abstract
	 Posts attributes of the target object into appropriate dynamic
	 table.

  Arguments
	long	*msg;		O	completion code
					MSSUCC or MSFAIL

	char	*key;		I	REG_CHECKIN or DWG_CHECKIN

	int	to_sql;		I	0 - post to database
					1 - write to sql file

	char	*catalog;	I	catalog name

	char	*partid;	I	part name

	char	*revision;	I	revision

	char	*designRep;	I	"model"		- post a model file
					"schematic"	- post a drawing file

	int	*delete		I/O	should be set to DELETE_Y for the
					first call and should not be tampered
					with after that.
  Notes/Remarks

-me*/

message VDPostYourselfToDb( long	*msg;
			    char	*key;
			    int		to_sql;
			    char	*catalog;
			    char	*partid;
			    char	*revision;
			    char	*designRep;
			    int		*delete );

/*+me
  Public Message VDgetObjDef

  Abstract
        Returns the definition of an object: name of templates and feet, etc.
  Arguments
        OUT     long            *msg            Completion code.
        IN      VDobjDef        *objDef         Object definition.
  Note
        The fields of `objDef' point to static buffers and therefore should
        not be freed.
-me*/
message VDgetObjDef(    long            *msg ;
                        VDobjDef        *objDef ; ) ;

/*+me
 -------------------------------------------------------------------------

  Public Message VDcreate

  Abstract
  	This message fills all the parameters of the macro and 
	place it.

  Arguments
	IGRlong        	*msg		O : Completion code.
	IGRint        	nbAttr		I : nb attributes in the ACrg_coll
	struct ACrg_coll *Attr		I : the attributes 
	IGRchar		*macroName	I : Name of macro.
	IGRint		prop		I : Compute properties.
	IGRint		nbParents	I : number of graphical parent objects
	struct GRid	*parents	I : the surface 

  Status/Return Code
	OM_S_SUCCESS	if success;
	OM_E_ABORT	if fails

 -------------------------------------------------------------------------
-me*/

message VDcreate( 	IGRlong			*msg;
			IGRint			nbAttr;
			struct  ACrg_coll	*Attr;
			IGRchar			*macroName;
			IGRint			prop;
			IGRint			nbParents;
			struct	GRid		*parents );


/*+me
 -------------------------------------------------------------------------

  Public Message VDprint

  Abstract
  	This message prints info on screen

  Arguments
	IGRlong        	*msg		O : Completion code.

  Status/Return Code
	OM_S_SUCCESS	if success;

 -------------------------------------------------------------------------
-me*/

message VDprint( long * sts );

reject	VDprint ;


/*+me
 -------------------------------------------------------------------------

  Public Message VDcompute

  Abstract
  	This messsage will compute or recompute myGRid.

  Arguments
	IGRlong        	*msg		O : Completion code.
	IGRshort	*type		I : Compute Type.

  Status/Return Code
	OM_S_SUCCESS	if success;

 -------------------------------------------------------------------------
-me*/

message VDcompute(	long	*msg;
			int	*type	);

/*+me
 -------------------------------------------------------------------------

  Public Message VDGetProduct

  Abstract
        This messsage will return the product code/name of myGRid.

  Arguments
        IGRshort        *Pcode          O : numeric product code
        IGRchar         *Pname          O : char product name

  Status/Return Code
        OM_S_SUCCESS    if success;

 -------------------------------------------------------------------------
-me*/

message VDGetProduct (IGRshort     *Pcode;
                      IGRchar      *Pname);

/*+me
 -------------------------------------------------------------------------

  Public Message VDGetCenterLine

  Abstract
        This messsage will return the centerline of PIPE/HVAC/RWAY.

  Arguments
	IGRlong		*msg		O : Return code.
	struct GRmd_env	*md_env		I : Object mod environment.
	IGRint		*count		O : Number of objects found.
	struct GRid	**list		O : List of centerline objects.

  Notes/Remarks

        This message has been introduced at the VDSroot level, to support the
	possibility to get the centerlines from I/ROUTE components.
        The message is rejected in VDSroot and is implemented in VRGeneric.

  Status/Return Code
        OM_S_SUCCESS    if success;

 -------------------------------------------------------------------------
-me*/

message VDGetCenterLine(	IGRlong			*msg;
				struct GRmd_env		*md_env;
				IGRint			*count;
				struct GRid		**list);

reject	VDGetCenterLine ;

/*+me
 -------------------------------------------------------------------------
 
  Public Message VDgetAttrDrivenSymb
 
  Abstract
        This messsage will return the Attribute Driven Symbology.
 
  Arguments
        IGRlong         *msg            O : return code
        IGRchar         *fileName       I : file name
        struct GRmd_env *md_env         I : pointer on module env
        struct GRsymbology      *symb   O : pointer to symbology
 
  Status/Return Code
        OM_S_SUCCESS    if success;
 
 -------------------------------------------------------------------------
-me*/
message VDgetAttrDrivenSymb( long *msg;
                        char *fileName;
                        struct GRmd_env *md_env;
                        struct GRsymbology *symb );
 
/*+me
 -------------------------------------------------------------------------
 
  Public Message VDputAttrDrivenSymb
 
  Abstract
        This messsage will put the Attribute Driven Symbology.
 
  Arguments
        IGRlong         *msg            O : return code
        struct GRmd_env *md_env         I : pointer on module env
        IGRchar         *fileName       I : file name
 
  Status/Return Code
        OM_S_SUCCESS    if success;
 
 -------------------------------------------------------------------------
-me*/
 
message VDputAttrDrivenSymb( long *msg;
                        struct GRmd_env *md_env;
                        char *fileName);
 
/*+me
 -------------------------------------------------------------------------
 
  Public Message	VDdescribeOutput
        Sent by a pretend to this object, used to pretty-print an output in
        the "Directory Command" form.
 
  Arguments
        OUT     long            *msg            Completion code.
        IN      char            *nameOfOutput   Name of output to describe.
        OUT     char            *description    Description of output.
 
  Status/Return Code
        OM_S_SUCCESS    if success;
 
 -------------------------------------------------------------------------
-me*/
 
message VDdescribeOutput(	long *msg ;
				char *nameOfOuput;
				char *description ) ;

message VDExecutePpl(   IGRlong         *msg;
                        IGRchar         *file_name;
                        IGRchar         *func_name;
			struct GRmd_env *md_env;
                        IGRint          IN_count;
                        VD_execRes      *IN_args;
			IGRint		*OUT_count;
			VD_execRes	**OUT_args   );

/*+me
 -------------------------------------------------------------------------

  Public Message        VDprocAttr
	Get product information like, weight, center of gravity, mass and range
  Arguments
        OUT     long            *msg            Completion code.
        IN      struct GRmd_env *md_env.
        IN      int             flag 		see vdprodinfo.h.
        OUT     VDprcAttr       *prcAttr.       see vdprodinfo.h

  Status/Return Code
        OM_S_SUCCESS    if success;

 -------------------------------------------------------------------------
-me*/

message VDprocAttr(  long   		*msg; 
		     struct GRmd_env 	*md_env;
                     int 		flag;  
                     VDprcAttr		*prcAttr );


/*-------------------------------------------------------------------------
  Public message 		VDGetParamsId
	Gets the IDs of ACrg_coll parents, which hold the attributes. 

  Arguments

 IGRlong              *msg           O : MSSUC if success and MSFAIL if not.

 struct GRid          *SysParamId    O : Returns the system parameters ID .
 struct GRid          *UsrParamId    O : Returns the user parameters ID.
 struct GRid          *AddParamId    O : Returns the added parameters ID.

  Status/Return Code
        OM_S_SUCCESS    if success;

  NOTE: This method comes from Route.
	AddParamId holds the list of various parameters. 
	For example DB parameters have text value of "DB_default".
	Thus VDS Dynamic attributes are AddParamId, with value "DB_default",
		but their updated values are in UsrParamId.
	VDS User Attributes are = UsrParamId - AddParamId.
-------------------------------------------------------------------------*/
message VDGetParamsId( IGRlong *msg;    struct GRid *SysParamId;
                                        struct GRid *UsrParamId;
                                        struct GRid *AddParamId );
reject VDGetParamsId;


end specification VDSroot ;
