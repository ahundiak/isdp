class implementation ci;

#include <stdio.h>
#define Form char *
#include "CIforms.h"

 
void ci_notification ( form_label, gadget_label, value, form )
  int	 form_label;
  int	 gadget_label;
  IGRdouble value;
  Form	 form;
{
  int	 		status, sts;
  unsigned int		cmd_oid;
  unsigned short	cmd_os;
  struct CIform_st form_st;

  extern		FIf_get_cmd_oid_os();


	/*** get the cmd's (oid, os) that the form is talking to ***/
  status = FIf_get_cmd_oid_os ( form, & cmd_oid, & cmd_os );

  if ( status )
    {
      fprintf ( stderr,
	"  ci_notification:  FIf_get_cmd_oid_os status = %d\n",
	status );
      return;
    }

  form_st.form_ptr = form;
  form_st.value = value;
  form_st.gadget_label = gadget_label;
  form_st.form_label = form_label;

  status = om$send ( targetid = cmd_oid,
		     targetos = cmd_os,
		     senderid = NULL_OBJID,
		     msg = message ci.set_value( &sts, "form_st", 
				(char *)&form_st, sizeof( struct CIform_st)));
  if ( ! ( 1 & status ) )
    {
      fprintf ( stderr,
	"  ci_notification:  ERROR in ci.set_value send to (%d,%d) = %d\n",
	cmd_oid, cmd_os, status );
      fprintf( stderr, " PPL forms files must contain a var named form_st\n");
     }
	/*** send the form_input message ***/
  status = om$send ( targetid = cmd_oid,
		     targetos = cmd_os,
		     senderid = NULL_OBJID,
		     msg = message ci.f_execute
				( &sts, "form_notification", NULL, 0 ) );
  if ( ! ( 1 & status ) )
    {
      fprintf ( stderr,
	"  ci_notification:  ERROR in ci.f_execute send to (%d,%d) = %d\n",
	cmd_oid, cmd_os, status );
    }

}

end implementation ci;

