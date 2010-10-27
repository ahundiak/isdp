class specification VDCmdUsrAtt (1:0) of VDS_LOCATE;



/*+cmd
/* -------------------------------------------------------------------------

  Command Object Class VDCmdUsrAtt

  Superclass
      VDS_LOCATE

  Abstract
        The Command Object provides a form interface for modifying the user
        attributes of elements. A collection of elements can be selected 
        using input generators or a single element can be selected for 
        modifying the user attributes.
        The CO also implements the dynamic tracking of the mouse on the form.

  Methods

      process_locate         Public     Processes the elements located by
                                        vds_locate filter

      get_attributes         Public     Copies attributes from a selected object
					to the multicolumn field on the Copy
					User Attributes subform.

      wrap_up                Public     Wraps up the CO.

      dspAttrs               Public     Displays the user attributes of
                                        the specified element on the form

      delFromList            Public     Deletes an object from the list of
                                        located objects 

      operation              Public     Modifies the attributes of all
                                        located objects

  Overridden Methods

     mouse              Implemented to track the mouse position on the user 
                        attributes form, and display suitable messages in 
                        the message field on the form.
    
     form_notification  Notification routine for the VDmodUsrAtt form

  Forms

     User Attributes    VDmodUsrAtt     User interface for the CO
     First Subform      VDdflValues.fm  Lists names and values from file 
     Second Subform     VDKyInFilNm.fm  Used to search for attribute file

  History:
    MM/DD/YY   AUTHOR  DESCRIPTION
    06/10/97   EJM     CR#179527294  Add "Read from File" capability; added
				     instance data, modAttrForm, dfltInfo,
				     defaultValues
    07/28/97   EJM     CR#179602470  Add "Copy Attributes" capability; added
				     method, get_attributes, variable, 
				     cpAttrForm
    04/15/99   EJM     CR#179900526  Need higher attribute limit, inactivate
				     use of me->defaultValues, allocate
				     memory in VDCmdUsrAtti.I to
				     me->dfltInfo.defaultValues (MX_ATTR_DFLTS).
 -------------------------------------------------------------------------

-cmd*/

#include "VDmsg.h"
#include "VDusrAtt.h"
#include "vddfltvalsfm.h"
#define MX_ATTR_DFLTS  200      /* Max. # of attributes accepted        */


/*+v
 -------------------------------------------------------------------------
  Abstract


  Notes/Remarks

*/

instance VDCmdUsrAtt
{
      IGRint                    nbLocObjs;       /* No. of located objects */
      IGRint                    curObjIndex;     /* Current object whose
                                                    attributes are displayed */
      variable struct VDusrAtt  usrAttrs[0];     /* Array of user attributes */

      /* Next three variables from struct code to read attributes from a file */

      char            		*modAttrForm ;	 /* control Read From Form */
      char            		*cpAttrForm ;	 /* control Copy Attr Form */

      VDdfltValsInfo  dfltInfo ;                /* vddfltvalsfm.h */
      VDdefaultValues defaultValueX[30] ;	/* vddefltvalue.h */
      };

message process_locate ( long * sts );

message get_attributes ( long * sts );

message wrap_up ( long * sts );

message dspAttrs ( int elmNo );

message delFromList ( long *sts; int elmNo );

message operation ( long * sts );

override mouse;

override form_notification;

end specification VDCmdUsrAtt;
