/*
  ABSTRACT :
  --------

   This file constains the routines related to the index feature.
*/

class implementation DIrectory;

#define DEBUG

#include <string.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "DIdef.h"
#include "DIomac.h"
#include "DIprims.h"


DIindex ( dirname, path, synpath, index, name, p_osnum, p_objid )
          DIchar     *dirname	/* The directory to be accessed		IN  */;
          DIchar     *path	/* The search path			IN  */;
          DIint      synpath    /* linear search path synonym flag      IN  */;
          DIint      index	/* The index of the object		IN  */;
          DIchar     *name	/* The object name			OUT */;
          DIspacenum *p_osnum	/* The object (directory) os		OUT */;
          DIobjid    *p_objid   /* The object identifier		OUT */;
/* This procedure is used to find an object given a directory and an index. */
{
  DIint      status;
  DIobjid    dirid, objid;
  DIspacenum osnum;
  DIchar     l [DI_PATH_MAX];

  synpath = 0;
  if ((status = DIfind_dir ( l, &osnum, &dirid, dirname, path )) == DIR_S_SUCCESS)
  { om_send_for ( IGRdir.translate ( &status, NULL, index, name, &objid ), NULL_OBJID, dirid, osnum );
    if ((status == DIR_S_SUCCESS) || (status == DIR_W_NO_NAME))
    { if (p_objid)
        *p_objid = objid;
      if (p_osnum)
      { DIcheck_link ( osnum, dirid )
        *p_osnum = osnum; }}}

  return status;
}

#argsused

DIunindex ( dirname, path, synpath, p_index, name, objid )
            DIchar     *dirname	/* The directory to be accessed		IN  */;
            DIchar     *path	/* The search path			IN  */;
            DIint      synpath  /* linear search path synonym flag      IN  */;
            DIint      *p_index	/* The index of the object		OUT */;
            DIchar     *name	/* The object name			IN  */;
            DIobjid    objid	/* The object identifier		IN  */;
/* This procedure is used to find an index given a directory and a name. */
{
  DIint      status, index;
  DIobjid    dirid;
  DIspacenum osnum;
  DIchar     l [DI_PATH_MAX];

  if ((status = DIfind_dir ( l, &osnum, &dirid, dirname, path )) == DIR_S_SUCCESS)
  { om_send_for ( IGRdir.unindex ( &status, &index, name, objid ), NULL_OBJID, dirid, osnum );
    if (status == DIR_S_SUCCESS)
      if (p_index) *p_index = index; }

  return status;
}

#argsused

DIadd_index ( dirname, path, synpath, p_index, objid, p_osnum )
              DIchar     *dirname /* The directory to be accessed	IN  */;
              DIchar     *path	  /* The search path			IN  */;
              DIint      synpath  /* linear search path synonym flag    IN  */;
              DIint      *p_index /* The index of the object		IN  */;
              DIobjid    objid    /* The object identifier		OUT */;
              DIspacenum *p_osnum /* The object (directory) os		OUT */;
/* This procedure is used to add an object given a directory and an index. */
{
  DIint      status;
  DIobjid    dirid;
  DIspacenum osnum;
  DIchar     l [DI_PATH_MAX];

  if ((status = DIfind_dir ( l, &osnum, &dirid, dirname, path )) == DIR_S_SUCCESS)
  { om_send_for ( IGRdir.add ( &status, NULL, objid, p_index ), NULL_OBJID, dirid, osnum );
    if (status == DIR_S_SUCCESS)
      if (p_osnum)
      { DIcheck_link ( osnum, dirid )
        *p_osnum = osnum; }}

  return status;
}


#argsused

DIrm_index ( dirname, path, synpath, index )
             DIchar     *dirname /* The directory to be accessed	IN  */;
             DIchar     *path	 /* The search path			IN  */;
             DIint      synpath  /* linear search path synonym flag     IN  */;
             DIint      index    /* The index of the object		IN  */;
/* This procedure is used to remove an object given a directory and an index. */
{
  DIint      status;
  DIobjid    dirid;
  DIspacenum osnum;
  DIchar     l [DI_PATH_MAX];

  if ((status = DIfind_dir ( l, &osnum, &dirid, dirname, path )) == DIR_S_SUCCESS)
    om_send_for ( IGRdir.remove ( &status, NULL, index ), NULL_OBJID, dirid, osnum );

  return status;
}


end implementation DIrectory;
