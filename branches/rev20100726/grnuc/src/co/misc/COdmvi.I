/*
Name
        COdmv - Department of Motor Vehicles (snicker)

Description
        This session startup command requests a license for either EMS, DRAFT,
        or MDS. The command asks the license call to terminate the product if
        no license is available.  This is okay at this level, since this
        command will only be run once per session, even if switchprod is
        invoked, since switchprod does not rerun startup commands for active
        product, and all applications are built on one of the products
        licensed here.  Therefore, no loss of data can occur by exiting here.

        This command is also used as a session shutdown command to release all
        licenses allocated by the process.

Notes
        The command expects mytype to be set in the command table as shown
        below:
                EMS         0
                DRAFT       1
                MDS         2
                Shutdown    100

History
        dhm     08/25/92     creation date
        mrm     12/01/92     renamed class to "hide" it
*/

class implementation COdmv;

#include "igrtypedef.h"
#include "grlicense.h"

method execute(int *response; char *response_data; int pos)
{
    static char *product_id[] = {"SM01041", "SM01062", "SM01082"};
    static char *run_name[] =   {"Ems",     "Draft",    "Mds"};

    if (me->mytype == 100)
        GRrelease_all_licenses();
    else
    {
        gr$get_license(product_id = product_id[me->mytype],
                       run_name = run_name[me->mytype],
                       options = GRExitOnError);
    }
    *response = TERMINATE;
    return(OM_S_SUCCESS);
}

end implementation COdmv;
