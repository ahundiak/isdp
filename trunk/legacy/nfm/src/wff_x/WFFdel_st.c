#include "machine.h"
#include "WFF.h"
#include "WFFlist.h"

/*  Global WFF structure  */

extern struct WFFglobal_st WFFglobal;

long WFFdelete_state (workflowname, statename)
  char	*workflowname;
  char  *statename;
  {
	long	status;
	char	prompt1[120];
	char	prompt2[120];

	static	char *fname = "WFFdelete_state";

	/*  External functions  */

	int UMSGetByNum ();

	void _WFFmain_set_wf ();
	long _WFFconfirm ();

	long WFGdelete_workflow ();

	_NFIdebug ((fname, "workflow = <%s>\n", workflowname));

        if (strcmp (workflowname, "") == 0)
         {
            status = NFI_E_NO_WF;
            _NFIdebug ((fname, "No workflow selected : status = <0x%.8x>\n",
                        status));
            ERRload_struct (NFI, status, NULL);
            return (status);
         }
        else if (strcmp (statename, "") == 0)
         {
            status = NFI_E_NO_WF;
            _NFIdebug ((fname, "No workflow selected : status = <0x%.8x>\n",
                        status));
            ERRload_struct (NFI, status, NULL);
            return (status);
         }

	/*  Get the command prompts from UMS  */

	if ((status = (long) UMSGetByNum
		(prompt1, NFI_P_CONFIRM_DELETE, NULL)) != UMS_S_SUCCESS)
	  {
		_NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
		_NFIdebug ((fname, "defaulting prompt ...\n"));
		strcpy (prompt1, "Are you sure you want to delete");
	  }

	if ((status = (long) UMSGetByNum
		(prompt2, NFI_P_CONFIRM_STATE, "%s", statename)) != UMS_S_SUCCESS)
	  {
		_NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
		_NFIdebug ((fname, "defaulting prompt ...\n"));
		sprintf (prompt2, "State \"%s\" ?", statename);
	  }

	/*  Set the working message  */

	WFFglobal.working_no = NFI_I_DELETE_STATE;

	/*  Set the WFF function  */

	WFFglobal.NFMfunction[0] = WFGdelete_workflow;

	if ((status = _WFFconfirm (workflowname, "", "", prompt1, prompt2,
		WFF_LIST_WORKFLOWS, _WFFmain_set_wf, NULL)) != NFI_S_SUCCESS)
	  {
		_NFIdebug ((fname, "_WFFconfirm = <0x%.8x>\n", status));
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (status);
	  }

	_NFIdebug ((fname, " returning SUCCESS\n"));
	return (NFI_S_SUCCESS);
  }
