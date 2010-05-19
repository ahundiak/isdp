/* $Id: SMmgr.S,v 1.1.1.1 2001/01/04 21:07:35 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smmgr / SMmgr.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMmgr.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:35  cvs
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
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
/*---------------------------------------------------------------------------
/*  SMmgr.S
/*  Chistian HERAUD
/*  13-April_92
/*
/*  Abstract:
/*	Abstract class defining the common behaviour for I/SMAN objects.
/*
/*
/*
/*  History:
/*
/*---------------------------------------------------------------------------*/

class specification SMmgr (0:1) of Root, NDmacro;

#include <stdio.h>

#include "igrtypedef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "growner.h"

#include "ACattrib.h"

#include "SMdef.h"


instance SMmgr
 {
  short SMstate;  
 };

 /* At this level, SMstate which manage the status for Seasafe extractions.
 /* 0x0001 => new object       SM_NEW
 /* 0x0002 => new object       SM_UPD
 /* 0x0004 => modified         SM_MOD
 /* (see SMdef.h) */
 /*
 /* 0xF000 is for user.
 /* */

 /*---------------------------------------------------------------------------*/

 /* SMstate management */

message SMSetState(IGRshort state);

message SMGetState(IGRshort *state);

message SMChgState(IGRshort mask, state);

 /* Get or modify the state a SMobject
 /* The SMstate and mask are:
 /*
 /*      - SM_NEW  /* new compartment */
 /*      - SM_MOD  /* Modified compartment */
 /*      - SM_UPD  /* Compartment updates */
 /*
 /*  Argument description:
 /*  ---------------------
 /*
 /*   IGRshort           mask            I : Corresponding mask.
 /*   IGRshort           state           I : Coresponding value.
 /*
 /*  Example to set the state to "modified":
 /* 
 /*  om$send(msg = message SMmgr.SMChgState(SM_STATE, SM_MOD), ...
 /*
 /* */


 /* Tag management */

message SMSetTag();

 /* 
 /* Tag a the element 
 /*
 /* */

message SMClearTag();

 /*
 /* Untag an object
 /*
 /* */

message SMIsTagged(IGRboolean *tag);

 /* 
 /* If the object is tagged, tag = TRUE
 /*
 /* */

 /* 
 /* Tag explanation:
 /*
 /* The tag is used to "mark" an object. This is used for the output seasafe
 /* file and for the on line reports.
 /*
 /* When an element is tagged, it means that it has passed the criteria and
 /* that it is a valid object. 
 /*
 /* */

 /*---------------------------------------------------------------------------*/

 message SMWhoAreYou(IGRlong *msg; IGRshort *type, *sub_type);

 /*
 /* Return the type and sub-type of an object
 /* At this level, the method return 0 for type and sub_type 
 /*
 /*  Argument description:
 /*  ---------------------
 /*
 /*   IGRlong           *msg            O : Completion code
 /*
 /*   IGRshort		*type		O : Type of the object
 /*					     (see SMdef.h).
 /*
 /*   IGRshort		*sub_type	O : Sub-type of the object
 /*					     (see SMdef.h).
 /*	

 /*---------------------------------------------------------------------------*/
 /*  				*/
 /* Seasafe data extraction 	*/

message SMFillSfFile(IGRlong *msg; FILE *p_file; IGRshort options; IGRboolean tag;
		     IGRshort out_units; struct GRmdenv_info *obj_env, *trans_env);

 /*
 /*  Add to the file the object information
 /*  Each object knows how to write its information
 /*
 /*  Argument description:
 /*  ---------------------
 /*
 /*   IGRlong           *mask            O : Completion code
 /*
 /*   File		*p_file		 I : File pointer.
 /*
 /*   IGRshort           options         I : Possible options (not yet used).
 /*	
 /*   IGRboolean	 tag		 I : TRUE => only taged objects
 /*					     are concerned.
 /*
 /*   IGRshort		 out_units	 I : Output units (SMdef.h)
 /*
 /*   struct GRmdenv_info *obj_env	 I : Object environnement.
 /*
 /*   struct GRmdenv_info *trans_env	 I : Transformation matrix.
 /*  */

 /*---------------------------------------------------------------------------*/

 /*  			*/
 /* On line reports 	*/

message SMFillRpFile(IGRlong *msg; IGRchar *DescFile; FILE *p_file; 
                     IGRshort options; IGRboolean tag; IGRshort out_units; 
		     struct GRmdenv_info *obj_env, *trans_env);

 /*
 /*  Add to the file the object information
 /*  Each object knows how to write its information
 /*
 /*  Argument description:
 /*  ---------------------
 /*
 /*   IGRlong           *mask            O : Completion code
 /*
 /*   IGRchar           *DescFile        O : File describing the output 
 /*                                          format (can be NULL).
 /*
 /*   File		*p_file		 I : File pointer.
 /*
 /*   IGRshort           options         I : Report type (see SMdef.h).
 /*	
 /*   IGRboolean	 tag		 I : TRUE => only taged objects
 /*					     are concerned.
 /*
 /*   IGRshort		 out_units	 I : Output units (SMdef.h)
 /*
 /*   struct GRmdenv_info *obj_env	 I : Object environnement.
 /*
 /*   struct GRmdenv_info *trans_env	 I : Transformation matrix.
 /*  */
 /*  */

 /*---------------------------------------------------------------------------*/

 /*  			*/
 /* Select criteria 	*/

message SMGetList(IGRlong *msg; IGRshort state, options, type, sub_type;
 		  IGRint nb_att; struct ACrg_coll *att; 
		  struct SMObjList *list; IGRboolean tag); 

 /*
 /*  Given a criteria, if the object passes the criteria, it is either
 /*  added in the list or tagged. 
 /*  The criteria is defined by an ACrg_coll structure. It allows to define 
 /*  the attribute name, the attribute type (double, string) and the 
 /*  possible value. Even if the attribute type is a double, its possible 
 /*  value will be stored as a string. This allows using compressed forms 
 /*  for multiple choises.
 /*
 /*
 /*  Argument description:
 /*  ---------------------
 /*
 /*   IGRlong           *msg             O : Completion code
 /*
 /*   IGRshort           state           I : Simple filter (SM_NEW, 
 /*  					     SM_MOD, SM_UPD)
 /*	
 /*   IGRshort           options         I : Not used.
 /*	
 /*   IGRshort		 type		 I : Type of the objects expected
 /*					     (see SMdef.h).
 /*
 /*   IGRshort		 sub_type	 I : Type of the objects expected
 /*					     (see SMdef.h).
 /*
 /*   IGRint		 nb_att		 I : Number of attributes.
 /*
 /*   struct ACrg_coll  *att             I : Structure gathering the criteria
 /*					     information.
 /*	
 /*   struct SMObjList  *list		 O : Structure gathering the lists
 /*					     of objects (see SMdef.h).
 /*
 /*   IGRboolean	 tag		 I : TRUE if tag the objects
 /*
 /*
 /* Example:  The criteria is two diameters with multiple values:
 /*     att[0].name =>  	     	"diam1"
 /*	att[0].type =>  		AC_ATTRIB_DOUBLE
 /*	att[0].desc.value.att_txt =>	"[5-7]" (from 5 to 7) 
 /*     att[1].name =>  	     	"diam2"
 /*	att[1].type =>  		AC_ATTRIB_DOUBLE
 /*	att[1].desc.value.att_txt =>	"2,4,5" 
 /*
 /* Remarks:
 /*  If list is NULL the elements are only tagged.
 /*   */



message SMIsValid(IGRlong *msg; IGRshort state, options, type, sub_type;
 		  IGRint nb_att; struct ACrg_coll *att; IGRboolean *valid); 

 /*
 /*  Given a criteria, it returns if the object passed it. The criteria are
 /*  using an ACrg_coll structure. It allows to define the attribute name,
 /*  the attribute type (double, string) and the possible value. Even if
 /*  the attribute type is a double, its possible value will be stored
 /*  as a string. This allows using compressed forms for multiple choises.
 /*
 /*
 /*  Argument description:
 /*  ---------------------
 /*
 /*   IGRlong           *msg             O : Completion code
 /*
 /*   IGRshort           state           I : Simple filter (SM_NEW, 
 /*  					     SM_MOD, SM_UPD)
 /*	
 /*   IGRshort           options         I : Not used.
 /*	
 /*   IGRshort		 type		 I : Type of the objects expected
 /*					     (see SMdef.h).
 /*
 /*   IGRshort		 sub_type	 I : Type of the objects expected
 /*					     (see SMdef.h).
 /*
 /*   IGRint		 nb_att		 I : Number of attributes.
 /*
 /*   struct ACrg_coll  *att             I : Structure gathering the criteria
 /*					     information.
 /*	
 /*   IGRboolean	*valid		 O : TRUE if valid.
 /*
 /*
 /* Example:  The criteria is two diameters with multiple values:
 /*     att[0].name =>  	     	"diam1"
 /*	att[0].type =>  		AC_ATTRIB_DOUBLE
 /*	att[0].desc.value.att_txt =>	"[5-7]" (from 5 to 7) 
 /*     att[1].name =>  	     	"diam2"
 /*	att[1].type =>  		AC_ATTRIB_DOUBLE
 /*	att[1].desc.value.att_txt =>	"2,4,5" 
 /*   */


message SMAddToList(IGRlong *msg; IGRshort options; 
		    struct SMObjList *list; IGRboolean *valid);
 /*
 /* Add an object to the list. The list.list is dynamically allocated by the 
 /* function if there is not enought space.
 /* The caller will have to free the list.list pointer. The valid argument 
 /* indicates if the objects has been added to the list.
 /*
 /*  Argument description:
 /*  ---------------------
 /*
 /*   IGRlong           *mask            O : Completion code
 /*
 /*   IGRshort           options         I : Not used.
 /*	
 /*   struct SMObjList  *list		 O : Structure gathering the lists
 /*					     of objects (see SMdef.h).
 /*	
 /*   IGRboolean	*valid		 O : TRUE object added.
 /* */


 /*  */
 /*---------------------------------------------------------------------------*/

 /* Attribute management: */

message SMGetAtt(IGRlong *msg; IGRint nb_att; struct ACrg_coll *att; 
 		 IGRshort *type);

 /* Given a list of attribute names, it returns theirs definitions.
 /*
 /*
 /*  Argument description:
 /*  ---------------------
 /*
 /*   IGRlong           *msg              O : Completion code (0 FAILED, 1 SUCC).
 /*
 /*   IGRint		 nb_att		  O : Nb attributes.
 /*
 /*   struct ACrg_coll  *att		I/O : List of attributes:
 /*						I Attribute name, 
 /*						O attribute type and value.
 /*
 /*   IGRshort		*type		  O : List of attribute types (see 
 /*					      SMdef.h). can be set to NULL.
 /*
 /*   Notes:
 /*          The default implementation is for objects having a rg collection
 /*   which is the first root. If it fails, it asks for the feet.
 /* */

message SMListAtt(IGRlong *msg; IGRint list_len;
		 IGRint *nb_att; struct ACrg_coll *att; IGRshort *type);

 /* Retreives all the attributes contained in the ACrg collection 
 /*                                                              
 /*  Argument description:
 /*  ---------------------
 /*
 /*   IGRlong *msg               O : Completion code (MSFAIL or MSSUCC).
 /*
 /*   IGRint list_len            I : lenght of list
 /*   
 /*   IGRint *nb_att             O : Nb attributes returned
 /*
 /*   struct ACrg_coll *att	 O : List of attributes: (name + value)
 /*					
 /*   IGRshort *type             O : List of attribute types (see 
 /*                                  SMdef.h). Can be set to NULL.  
 /* */	

message SMSetAtt(IGRlong *msg; IGRint nb_att; struct ACrg_coll *att; 
		 IGRshort *type);

 /* Given a list of attribute definitions :
 /* it modifies theres values if attributes already exists
 /* it creates attributes with value passed as argument if not already exists 
 /* 	
 /*
 /*
 /*  Argument description:
 /*  ---------------------
 /*
 /*   IGRlong           *msg             O : Completion code (0 FAILED, 1 SUCC).
 /*
 /*   IGRint		 nb_att		 I : Number of attributes.
 /*
 /*   struct ACrg_coll  *att		 I : List of attribute definition.
 /*
 /*   IGRshort		*type		 I : List of attribute types (see
 /*					     SMdef.h).
 /*
 /*   Notes:
 /*          The default implementation is for object having a rg collection
 /*   which is the first root.
 /* */

message SMResetAtt(IGRlong *msg; IGRint nb_att; struct ACrg_coll *att; 
		   IGRshort *type);

 /* Given a list of attribute definitions , it globaly replace all existing
 /* attributes and value with new given list
 /* 	
 /*
 /*
 /*  Argument description:
 /*  ---------------------
 /*
 /*   IGRlong           *msg             O : Completion code (0 FAILED, 1 SUCC).
 /*
 /*   IGRint		 nb_att		 I : Number of attributes.
 /*
 /*   struct ACrg_coll  *att		 I : List of attribute definition.
 /*
 /*   IGRshort		*type		 I : List of attribute types (see
 /*					     SMdef.h).
 /*
 /*   Notes:
 /*          The default implementation is for object having a rg collection
 /*   which is the first root.
 /* */

message SMGetAttDbl(IGRlong *msg; IGRchar *name; IGRdouble *value; IGRshort *type);
message SMGetAttTxt(IGRlong *msg; IGRchar *name; IGRchar   *value; IGRshort *type);

message SMSetAttDbl(IGRlong *msg; IGRchar *name; IGRdouble  value; IGRshort type);
message SMSetAttTxt(IGRlong *msg; IGRchar *name; IGRchar   *value; IGRshort type);

 /*
 /* Same functionalities as previous but it avoids using a complex structure
 /*
 /* */



message SMGetAttType(IGRlong *msg; IGRshort type; 
		     IGRint *nb_att; struct ACrg_coll **att);

 /*
 /* Given an attribute type (0xFFFF for all), it returns the corresponding
 /* number and the list of attributes. The output argument att is allocated 
 /* by the function and must be deallocated by the caller.
 /*
 /*
 /*
 /*  Argument description:
 /*  ---------------------
 /*
 /*   IGRlong           *msg             O : Completion code (0 FAILED, 1 SUCC).
 /*
 /*   IGRshort		type		 I : Attribute types (see SMdef.h).
 /*
 /*   IGRint		nb_att;		 O : Number of attributes.
 /*
 /*   struct ACrg_coll  **att		 O : List of attribute definition.
 /*
 /* Remarks:
 /* 
 /* If the "att" argument can be NULL, only the number of attributes of this
 /* type are returned.  
 /*
 /* */

message SMAddAtt(IGRlong *msg; IGRint nb_att; struct ACrg_coll *att; 
		 IGRshort *type);

 /* Given a list of attribute definitions, it adds them depending on the type.
 /*
 /*
 /*  Argument description:
 /*  ---------------------
 /*
 /*   IGRlong           *msg             O : Completion code (0 FAILED, 1 SUCC).
 /*
 /*   IGRint		 nb_att		 I : Number of attributes.
 /*
 /*   struct ACrg_coll  *att		 I : List of attribute definition.
 /*
 /*   IGRshort		*type		 I : List of attribute types (see
 /*					     SMdef.h).
 /*
 /* */

message SMGetShortName(IGRlong *msg; IGRchar *name);

 /* Get the short name (without the path).
 /*
 /*
 /*  Argument description:
 /*  ---------------------
 /*
 /*   IGRlong           *msg             O : Completion code (0 FAILED, 1 SUCC).
 /*
 /*   IGRchar		*name		 O : Short name.
 /*
 /* */



 /* The following reject messages have to be overriden by each sub_classe */

reject SMGetAtt, SMListAtt,SMSetAtt, SMResetAtt,
       SMGetAttType, SMAddAtt;

end specification SMmgr;

