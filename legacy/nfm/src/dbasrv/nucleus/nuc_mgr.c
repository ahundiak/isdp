/* $Revision: 1.1 $ */

#include "dba.ext"
#include "keys.def"

static int (*services[MAX_SERVICES])();
static int (*init_funcs[INIT_MAX])();

/*
    Function:	dba_register_init
    Author:	Tim A. Thompson
    Date:	3-4-93
*/

void dba_register_init (key, func)
int key;
int (*func)();
{
  init_funcs[key] = func;
}


/*
    Function:	dba_init_all
    Author:	Tim A. Thompson
    Date:	3-4-93
*/

int dba_init_all ()
{
  int istat, i;

  if (init_funcs[INIT_SCRIPT]) istat = (*init_funcs[INIT_SCRIPT])();
  if (init_funcs[INIT_ADMIN]) istat = (*init_funcs[INIT_ADMIN])();
  if (init_funcs[INIT_RUNTIME]) istat = (*init_funcs[INIT_RUNTIME])();
  if (init_funcs[INIT_DBFORMS]) istat = (*init_funcs[INIT_DBFORMS])();
  if (init_funcs[INIT_DBNUC]) istat = (*init_funcs[INIT_DBNUC])();
  if (init_funcs[INIT_DEBUG]) istat = (*init_funcs[INIT_DEBUG])();
  if (init_funcs[INIT_DLOAD]) istat = (*init_funcs[INIT_DLOAD])();
  if (init_funcs[INIT_GUI]) istat = (*init_funcs[INIT_GUI])();
  if (init_funcs[INIT_MB]) istat = (*init_funcs[INIT_MB])();
  if (init_funcs[INIT_NFM]) istat = (*init_funcs[INIT_NFM])();
  if (init_funcs[INIT_RASTER]) istat = (*init_funcs[INIT_RASTER])();
  if (init_funcs[INIT_RB]) istat = (*init_funcs[INIT_RB])();
  if (init_funcs[INIT_REPORT]) istat = (*init_funcs[INIT_REPORT])();
  if (init_funcs[INIT_SCE]) istat = (*init_funcs[INIT_SCE])();
  if (init_funcs[INIT_USTN]) istat = (*init_funcs[INIT_USTN])();
  if (init_funcs[INIT_BLD]) istat = (*init_funcs[INIT_BLD])();  
  if (init_funcs[INIT_VI]) istat = (*init_funcs[INIT_VI])();  
  if (init_funcs[INIT_DDE]) istat = (*init_funcs[INIT_DDE])();  
  if (init_funcs[INIT_NET]) istat = (*init_funcs[INIT_NET])();  

  for (i=INIT_USER; i<INIT_MAX; i++)
    if (init_funcs[i])
      istat = (*init_funcs[i])();

  return 0;
}


/*
    Function:	dba_register_service
    Author:	Tim A. Thompson
    Date:	3-4-93
*/

int dba_register_service (key, ser)
int key;
int (*ser)();
{
  services[key] = ser;
  return 0;
}


/*
    Function:	dba_inq_service
    Author:	Tim A. Thompson
    Date:	3-4-93
*/

int ((*dba_inq_service (key))())
int key;
{
  return services[key];
}
