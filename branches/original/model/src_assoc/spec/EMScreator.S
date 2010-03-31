/*
  DESCRIPTION

  This class defines the message protocol for creators in EMS. A creator
  is an object who permits associative relationships to the components
  whom he has created through an indexing/key mechanism.

  No functionality has been provided at this class.


  HISTORY

  07/16/91 : PP : Creation 
*/

class specification EMScreator (1:0) of Root;

#include <igrtypedef.h>

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMtranslate_id_key
(
  long *EMmsg;
  unsigned int options;
  struct GRmd_env *md_env;
  OM_S_OBJID *component_objid;
  int *key_size;
  char **key;
);

message EMgive_noncount_based_key
(
  long *EMmsg;
  int options;
  OM_S_OBJID *component;
  IGRuint *type;
  IGRuint *key_size;
  unsigned char **key;
);

message EMgive_count_based_key
(
  long *EMmsg;
  int options;
  struct GRid *pointer_id;
  IGRuint *key_size;
  char *key;
);

reject
  EMtranslate_id_key,
  EMgive_noncount_based_key, 
  EMgive_count_based_key;

#endif

end specification EMScreator;
