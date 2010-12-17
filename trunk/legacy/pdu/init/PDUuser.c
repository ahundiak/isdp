#include	<PDUuser.h>
#include	<PDUintdef.h>
#include	<PDUproto.h>

extern struct PDUuser     *user;

void PDUuser_init()
  {

  if (user == NULL)
    user = (struct PDUuser *) malloc (sizeof(struct PDUuser));

  user->username = NULL;
  user->environment = NULL;
  user->server = NULL;
  user->passwd = NULL;
  user->user_id = NULL;
  user->storage_name = NULL;

  user->wrkst_username = NULL;
  user->wrkst_passwd = NULL;
  user->wrkst_cwd = NULL;
  user->wrkst_node = NULL;

  }

