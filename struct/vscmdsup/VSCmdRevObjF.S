/* $Id: VSCmdRevObjF.S,v 1.2 2001/02/27 18:22:53 ramarao Exp $  */
/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:       struct/vscmdsup/VSCmdRevObjF.S
 *
 * Description: Command Class for "Review Structural Objects" command.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSCmdRevObjF.S,v $
 *      Revision 1.2  2001/02/27 18:22:53  ramarao
 *      Modifications to add object id search.
 *
 *      Revision 1.1  2001/02/25 19:21:02  ramarao
 *      Created "Review Structural Objects" command.
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      02/25/01        Rama Rao        File Creation.
 * -------------------------------------------------------------------*/

class specification VSCmdRevObjF (1:0) of VDS_LOCATE;

#include "OMminimum.h"

instance VSCmdRevObjF
{
    IGRint			SearchType;
    IGRlong			options;
    struct GRid			MainWindow;
    struct GRid			ChildWindow;
    IGRint			CurrentIndex;
    IGRint			TotalObjectCount;
    variable struct GRobj_env  	TotalObjects[0];
    IGRint			FoundObjectCount;
    variable struct GRobj_env	FoundObjects[0];
    IGRint			ChildObjectCount;
    variable struct GRid   	ChildObjects[0];
    IGRint			ChildFoundObjectCount;
    variable struct GRid   	ChildFoundObjects[0];
};

message do_form(        IGRlong *msg;
                        IGRint form_label;
                        IGRint gadget_label;
                        IGRdouble value );

message init_form();

message CollectObjects();

message SearchList( IGRchar             *search_txt;
		    IGRint		*count;
		    struct GRobj_env	*list );

message FillFoundObjectsInForm( IGRchar         *search_text );

message CollectChildObjects();

message FillChildObjectsInForm();

end specification VSCmdRevObjF;
