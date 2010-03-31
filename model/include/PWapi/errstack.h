#ifndef _errstack_include
#define _errstack_include

PWboolean pwPushError 
(
  PWresult retcode
);

PWboolean pwPushErrorId 
(
  PWresult retcode,
  PWobjid id
);

PWboolean pwPushErrorIdVal 
(
  PWresult retcode,
  PWobjid id,
  double val
);

PWboolean pwPushErrorIdId 
(
  PWresult retcode,
  PWobjid id1,
  PWobjid id2
);

PWboolean pwGetFirstError 
(
  struct PWerrentry *p_errentry
);

int pwGetFirstInfoError 
(
  struct PWerrentry *p_errentry
);

PWboolean pwGetErrorAtInx 
(
  int inx,
  struct PWerrentry *p_errentry
);

void pwInitErrorStack
(
);

#endif

