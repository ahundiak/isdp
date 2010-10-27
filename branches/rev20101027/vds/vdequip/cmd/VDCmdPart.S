/* $Id: VDCmdPart.S,v 1.1.1.1 2001/01/04 21:08:42 cvs Exp $ pinnacle */
/* -------------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdequip/com / VDCmdPart.S
 *
 * Description:
 *
 *	Command object for the management of the selection of a part
 *	in the database, using a form.
 *
 *	The instances need to be initialised by the subclasses.
 *
 *
 * Dependencies:
 *
 *      CEO
 *
 * Revision History:
 *	$Log: VDCmdPart.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:42  cvs
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
# Revision 1.2  1995/02/16  19:51:12  pinnacle
# Replaced: vdequip/cmd/VDCmdPart* by jwfrosch r#
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
 *	12/01/93	P. Lacroix	Creation date
 *
 * -------------------------------------------------------------------------
 */

class specification VDCmdPart (1:0) of CEO;

/*+cd
 -----------------------------------------------------------------------------
  Class		VDCmdPart

  Superclass:
	CEO

  Abstract
	Command object for the management of the selection of a part
	in the database, using a form.

  Methods

	init_all		Public	Initialise the instances

	delete_all		Public	Free memory.

	VDRefreshFormPart	Public	Refresh all the fields in the form.

	VDCstQuery		Public	Construct the query from the selection
					in the form.

	VDQueryDb		Public	Query the database to retrieve all the
					parts corresponding to the select
					criteria.

	VDPlaceDbAttInList	Public	Displays the attributes
					of the current part in the form.

	VDSwitchPartDb		Public	Displays the attributes of the asking
					part in the form.

	VDKeyinPartNum		Public	Display the attributes of the part
					the user keys in the gadget g_num_part

	VDLoadSelPart		Public	Load the selected part.

	VDReadFromPdu		Public	Get the part from PDU.

	init_db			Public	Get the parts from the db_info.catalog.

	fill_attr_from_part	Public	Parse the static and dynamic attributes
					in my data me->save_att.

	VDLoadDbAttr		Public	Load the name of the static attributes
					and displays them in the form.

  Overridden Methods

	form_notification	Implements the gadgets.

  Rejected Methods
	none

  Notes/Remarks
    The instances (form and gadgets) need to be initialised by the subclasses.

 ------------------------------------------------------------------------------
-cd*/	/* data class */

#include <stdio.h>

#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "ACrg_collect.h"
#include "ACdb_info.h"
#include "SMCompForm.h"
#include "SMmsg.h"

/*+v
 -------------------------------------------------------------------------
*/

instance VDCmdPart
{
  struct ACdb_info	  db_info;	/* structure for post to database	*/

  char			**list_catalog;	/* list of all catalog (where to	*/
					/* perform the search) and their	*/
					/* description and select criteria	*/

  char			**list_descrip;
  char			**list_critsel;
  int			  nb_catalog;

  struct part_attr	 *parts;	/* parts found in the database		*/
  int			  nb_parts;

  int			  cur_part;	/* Currently number of displayed part	*/

  struct ACrg_coll	 *att_critsel;  /* Select criteria intersection		*/
					/* for family intersection of		*/
					/* list_critsel. In fact it is the	*/
					/* select criteria that is taken for	*/
					/* all the families			*/
  int			  nb_critsel;

  IGRint		  units_set_exists;

  struct temp_attr	 *name_att;	/* Name of static attributes		*/
  int			  nb_stat;	/* Number of static attributes		*/

  char			 *form_sel_part;/* ptr to the form			*/

  struct ACrg_coll	  save_att	[SM_MAX_CO_ATTR]; /* contains all dyn   */
  IGRshort		  save_att_type	[SM_MAX_CO_ATTR]; /* and stat att for   */
  int			  save_nb_att;			  /* the selected  part */

  int			  g_part_grp,	/* gadgets of the form			*/
			  g_cata_list,
			  g_db_list,
			  g_search,
			  g_reset,
			  g_plus,
			  g_minus,
			  g_num_part;
};

/*
 -------------------------------------------------------------------------
-v*/

/*---------------------
 * Messages
 */

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
	form_notification from CEO

  Abstract

 CEO.form_notification is called whenever a I/Forms form is given input
 by the user.  It is analogous to super_cmd.form_input(); however, no input
 is present in the "value" argument if the gadget type is a field.  See the
 I/Forms Forms documentation about querying a form's gadgets to get their
 values.

 It has been overriden to implement the selection of a part in the database.

  Arguments

  int		form_label;	label of form which received user  input
  int		gadget_label;   gadget label  which received user  input
  double	value;		value of gadget ( or field row # )
  char		* form_ptr ;    ptr to I/Forms form which received input

 -------------------------------------------------------------------------
-mo*/

override form_notification;

/*+me
 -------------------------------------------------------------------------
  Public Message init_all

  Abstract
	That method initialise the instances.

  Arguments
	long	*sts	O	Completion code

  Status/Return Code
      status == OM_S_SUCCESS   always

 -------------------------------------------------------------------------
-me*/

message init_all(long *sts);

/*+me
 -------------------------------------------------------------------------
  Public Message delete_all

  Abstract
	That method is called at the delete of the command. It basically
	free all the allocated arrays.

  Arguments

	long	*sts	O	Completion code

  Status/Return Code
      status == OM_S_SUCCESS   always

 -------------------------------------------------------------------------
-me*/

message delete_all(long *sts);


/*+me
 -------------------------------------------------------------------------
  Public Message VDRefreshFormPart

  Abstract
      Refresh all the fields in the form.

  Arguments
      none

  Status/Return Code
      status == OM_S_SUCCESS	always

 -------------------------------------------------------------------------
-me*/

message VDRefreshFormPart() ;


/*+me
 -------------------------------------------------------------------------
  Public Message VDCstQuery

  Abstract
      Construct the query from the selection in the form.
      name_att contains the attributes written in the form (in order)

      query is allocated in the method and must be deallocated by the user.


  Arguments

	IGRlong			 *sts;	    (O) completion code
	int			  nb_attr;  (I) nb_attribute in name_att
	struct temp_attr	 *name_att; (I) list of attributes to test
	int			 *nb_query; (O) number of query
	struct query_attr	**query     (O) constructed query

  Status/Return Code
      status == OM_S_SUCCESS	always

 -------------------------------------------------------------------------
-me*/

message VDCstQuery
(
  IGRlong		 *sts;
  int			  nb_attr;
  struct temp_attr	 *name_att;
  int			 *nb_query;
  struct query_attr	**query
);

/*+me
 -------------------------------------------------------------------------
  Public Message VDQueryDb

  Abstract
      Query the database to retrieve all the parts corresponding to the
      select criteria.
      It fills the structure me->parts which contains select attributes
      for all parts.

      The query is constructed with the selection displayed in the form
      (att op value). (For now we take the same query for each catalog,
      which is the intersection of all the select criteria).

      Then, the query is performed in the database for each catalog, and the
      selected attributes are put in me->parts.

      The last part found is displayed in the form.

  Arguments
	long		*sts		O	Completion code

  Status/Return Code
      status == OM_S_SUCCESS	always

 -------------------------------------------------------------------------
-me*/

message VDQueryDb(IGRlong *sts);

/*+me
 -------------------------------------------------------------------------
  Public Message VDPlaceDbAttInList

  Abstract
      Displays the attributes of the current part in the form.

  Arguments
	long		*sts		O	Completion code

  Status/Return Code
      status == OM_S_SUCCESS	always


 -------------------------------------------------------------------------
-me*/

message VDPlaceDbAttInList(long *sts);


/*+me
 -------------------------------------------------------------------------
  Public Message VDSwitchPartDb

  Abstract
	This message is called when the user asks for the next or preceding
	part or at the RESET_SEARCH.
	It places the attributes of the asking part in the form.

  Arguments
	long		*sts		O	Completion code
	int		label		I	label of the gadget that calls
						the method (reset,minus,plus).

  Status/Return Code
      status == OM_S_SUCCESS	always

 -------------------------------------------------------------------------
-me*/

message VDSwitchPartDb(long *sts; int label);


/*+me
 -------------------------------------------------------------------------
  Public Message VDKeyinPartNum

  Abstract
	Display the attributes of the part the user keys in the
	gadget g_num_part.

  Arguments
	long		*sts		O	Completion code

  Status/Return Code
      status == OM_S_SUCCESS	always


 -------------------------------------------------------------------------
-me*/

message VDKeyinPartNum(long *sts);


/*+me
 -------------------------------------------------------------------------
  Public Message VDLoadSelPart

  Abstract
	This message loads the selected part.
	At this level it only sets the db_info structure.
	(Need to be overriden to load the part into a given structure)

  Arguments
	long		*sts		O	Completion code

  Status/Return Code
      status == OM_S_SUCCESS	always

 -------------------------------------------------------------------------
-me*/

message VDLoadSelPart(long *sts);

/*+me
 -------------------------------------------------------------------------
  Public Message VDReadFromPdu

  Abstract
	Get the part from PDU.
	Does nothing at that level.

  Arguments
	long		*sts		O	Completion code


  Status/Return Code
      status == OM_S_SUCCESS	always

 -------------------------------------------------------------------------
-me*/

message VDReadFromPdu(long *sts);


/*+me
 -------------------------------------------------------------------------
  Public Message init_db

  Abstract
      Get the parts from the db_info.catalog.
      It fills the structure me->save_att if there is only one part.

  Arguments
	long		*sts		O	Completion code

  Status/Return Code
      status == OM_S_SUCCESS	always

 -------------------------------------------------------------------------
-me*/

message init_db ( long * sts );

/*+me
 -------------------------------------------------------------------------
  Public Message fill_attr_from_part

  Abstract
     Parse the static and dynamic attributes into me->save_att.
     Does nothing at this level.

  Arguments
	long		     *sts	O	Completion code
	int		      nb_stat	I	number of static attributes
	struct VDSatt_family *stat_att	I	the static attributes
	int		      nb_dyn	I	number of dynamic attributes
	struct VDSatt_family *dyn_att)  I	the dynamic attributes


  Status/Return Code
      status == OM_S_SUCCESS	always

 -------------------------------------------------------------------------
-me*/

message fill_attr_from_part
(
  long			*sts;
  int			 nb_stat;
  struct VDSatt_family	*stat_att;
  int			 nb_dyn;
  struct VDSatt_family	*dyn_att
);

/*+me
 -------------------------------------------------------------------------
  Public Message  VDLoadDbAttr

  Abstract
	Load the name of the static attributes and displays them in the
	form.

  Arguments
	long		*sts		O	Completion code


  Status/Return Code
      status == OM_S_SUCCESS	always

 -------------------------------------------------------------------------
-me*/

message VDLoadDbAttr ( long * sts );

end specification VDCmdPart;
