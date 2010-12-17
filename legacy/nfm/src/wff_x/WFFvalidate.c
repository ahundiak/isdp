#include "machine.h"
#include "WFF.h"
#include "WFFlist.h"

/*  Global WFF structure  */

extern struct WFFglobal_st WFFglobal;

long WFFvalidate_workflow (workflow)
  char	*workflow;
  {
	long	status;

	static	char *fname = "WFFvalidate_workflow";

	_NFIdebug ((fname," workflow = <%s>\n", workflow));

	_WFFmessage (NFI_I_VALIDATE, NULL);

	_NFIdebug ((fname, "calling WFGvalidate_workflow ...\n"));
	if ((status = WFGvalidate_workflow (workflow)) != NFM_S_SUCCESS)
	  {
		_NFIdebug ((fname,"WFGvalidate_workflow = <0x%.8x>\n", status));
		_WFFerase_message ();
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (status);
	  }
	_NFIdebug ((fname, "returned from WFGvalidate_workflow\n"));

	_WFFerase_message ();

	_NFIdebug ((fname, " returning SUCCESS\n"));
	return (NFI_S_SUCCESS);
  }

