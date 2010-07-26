/* #######################    APOGEE COMPILED   ######################## */
#include "grimport.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMindex.h"
#include "OMDB.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "dp.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "dpstruct.h"
#include "lcpriv.h"
#include "lcmacros.h"
#include "msdef.h"

static struct LCroot LC_root_check = {0,0};

IGRint LC_check_id (rc, objid, osnum, mode)

IGRlong    *rc;
OM_S_OBJID objid;
OMuword    osnum;
IGRint     mode;

{
    struct LCcheck *temp, *temp1;

    *rc = MSSUCC;
    switch (mode)
    {
    case LC_CHECK:
        *rc = LC_ID_NOT_FOUND;
        if (LC_root_check.num_id)
        {
            temp = LC_root_check.next;
        }
        else
        {
            break;
        }
        while (temp)
        {
            if (temp->objid == objid && temp->osnum == osnum)
            {
	        *rc = LC_ID_FOUND;
		break;
            }
	    else if (temp->next)
            {  
                temp = temp->next;
            }
            else {
                temp = NULL;
            }
        }
	break;

    case LC_DELETE:
        if (LC_root_check.num_id)
        {
            temp = LC_root_check.next;
        }
        else
        {
            break;
        }
        while (LC_root_check.num_id)
        {
            temp1 = temp->next;
	    free (temp);
            temp = temp1;
            LC_root_check.num_id--;
        }
        LC_root_check.next = NULL;
	break;

    case LC_ADD:
        temp = (struct LCcheck *)malloc (sizeof (struct LCcheck));
        temp->objid = objid;
        temp->osnum = osnum;
        temp->next = LC_root_check.next;
        LC_root_check.next = temp;
        LC_root_check.num_id++;
	break;

    case LC_ADD_CHECK:
        *rc = LC_ID_NOT_FOUND;
        if (LC_root_check.num_id)
        {
            temp = LC_root_check.next;
        }
        else
        {
            LC_check_id (rc, objid, osnum, LC_ADD);
            break;
        }
        while (temp)
        {
            if (temp->objid == objid && temp->osnum == osnum)
            {
	        *rc = LC_ID_FOUND;
		break;
            }
	    else if (temp->next)
            {  
                temp = temp->next;
            }
            else {
                temp = NULL;
            }
        }
        if (*rc == LC_ID_NOT_FOUND)
        {
            LC_check_id (rc, objid, osnum, LC_ADD);
        }
        break;

    /*
     * Check to see if the given object is already in the
     * list. If so, delete that specific node in the list
     * containing the object.
     */

    case LC_DEL_CHECK:
        *rc = LC_ID_NOT_FOUND;
        if (LC_root_check.num_id)
        {
            temp = LC_root_check.next;
	    temp1 = NULL;
        }
        else
        {
            break;
        }
        while (temp)
        {
            if (temp->objid == objid && temp->osnum == osnum)
            {
	        *rc = LC_ID_FOUND;
		break;
            }
	    else 
            {  
		temp1 = temp;
                temp = temp->next;
            }
        }
        if (*rc == LC_ID_FOUND)
        {
	    if (temp1)
            {
                temp1->next = temp->next;
            }
            else
            {
                LC_root_check.next = temp->next;
            }
            free (temp);
            LC_root_check.num_id--;
        }
        break;
    }
    return (1);
}
