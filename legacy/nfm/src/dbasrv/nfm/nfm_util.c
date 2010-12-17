/* $Revision: 1.1 $ */
#include "dba.ext"

/*
    Function:	dba_util_nfm_add_user_item
    Author:	Tim A. Thompson
    Date:	3-30-94
*/

int dba_util_nfm_add_user_item (catalog, name, rev, desc, aclno, vers, cisano,
    filename)
char *catalog, *name, *rev, *desc, *filename;
int aclno, vers, cisano;
{
  return dba_nfm_add_user_item (catalog, name, rev, desc, aclno, vers, cisano,
    filename, (char *) 0, (char *) 0);
}

/*
    Function:	dba_util_nfm_add_item
    Author:	Tim A. Thompson
    Date:	3-30-94
*/

int dba_util_nfm_add_item (catalog, name, rev, desc, aclno, vers, cisano,
    filename)
char *catalog, *name, *rev, *desc, *filename;
int aclno, vers, cisano;
{
  return dba_nfm_add_item (catalog, name, rev, desc, aclno, vers, cisano,
    filename, (char *) 0, (char *) 0);
}

/*
    Function:	dba_util_nfm_add_file
    Author:	Tim A. Thompson
    Date:	9-20-93
*/

int dba_util_nfm_add_file (catalog, name, rev, filename, storage)
char *catalog, *name, *rev, *filename, *storage;
{
  return dba_nfm_add_file (catalog, name, rev, 
                           filename, storage, (char*)0, (char *)0);
}


/*
    Function:	dba_util_nfm_copy_new_item
    Author:	Tim A. Thompson
    Date:	9-20-93
*/

int dba_util_nfm_copy_new_item (catalog, name, rev, new_catalog, new_name,
    new_rev)
char *catalog, *name, *rev, *new_catalog, *new_name, *new_rev;
{
  return dba_nfm_copy_new_item (catalog, name, rev, new_catalog, new_name,
      new_rev, (char *) 0, (char *) 0, (char *) 0);
}


/*
    Function:	dba_util_nfm_add_storage_area
    Author:	Tim A. Thompson
    Date:	9-20-93
*/

int dba_util_nfm_add_storage_area (storage, node, user, passwd, path, type)
char *storage, *node, *user, *passwd, *path, *type;
{
  return dba_nfm_add_storage_area (storage, node, user, passwd, path, type,
      (char *) 0, (char *) 0);
}
