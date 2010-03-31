#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h" 
#include "PWapi/os.h"
#include "PWapi/clsid.h"
#include "PWapi/ommisc.h"
#include "PWapi/msgsend.h"

#define MATCH 0

main (argc, argv)
int argc;
char *argv[];
{
  PWboolean exitloop=FALSE;
  int choice;
  PWosnum osnum=NULL;
  PWobjid osobjid=PW_K_NullObjid;
  PWresult result;
  void cmd_construct_os(), cmd_write_os();

  /*
   * Initialize OM
   */

  result = omRuntimeInit();
  if (IsError (result))
  {
    fprintf (stderr, "Error in runtime init\n");
    omReportError(result);
    goto wrapup;
  }

  /*
   * Command loop
   */

  while (!exitloop)
  {
    printf("\n");
    printf(" 1) Construct an Object Space\n");
    printf(" 2) Write an Object Space\n");
    printf(" 3) PMS\n");
    printf(" 4) Exit\n");
    printf("\nEnter choice _: ");
    scanf("%d",&choice);

    /*
     * Process individual choice
     */

    switch (choice) 
    {
      case 1:
      {
        cmd_construct_os (&osnum, &osobjid);
        break;
      }

      case 2:
      {
        cmd_write_os (osnum, osobjid);
        break;
      }

      case 3:
      {
        OM_PMS();
        break;
      }

      case 4:
      {
        exitloop = TRUE;
        break;
      }

      default:
      {
        printf("Invalid choice...try again\n");
        break;
      }
    }
  }

wrapup:
  exit (0);
}


/*
 * The individual commands
 */

void cmd_construct_os (osnum, osobjid)
PWosnum *osnum;
PWobjid *osobjid;
{
  char filename[PW_K_MaxStringLen];
  int numobjs;
  PWresult result=PW_K_Success;

  printf ("Enter file name_: ");
  scanf ("%s", filename);
  result = omConstructOS (filename, osobjid, osnum, &numobjs);
  OnErrorCode (result, wrapup);

  printf ("OS number = %d\nOS objid = %d\nNum objects constructed = %d\n",
   *osnum, *osobjid, numobjs);

wrapup:
  PW_Wrapup (result, "cmd_construct_os");
  return;
}


void cmd_write_os (osnum, osobjid)
PWosnum osnum;
PWobjid osobjid;
{
  char answer[40], new_filename[PW_K_MaxStringLen], *p_name=NULL;
  PWresult result=PW_K_Success;
  struct PWommsg write_messg;
  struct {char *osname;} write_args;
   
  printf ("New file name? [y/n] _: ");
  scanf ("%s", answer);  
  if (strcmp (answer, "y") == MATCH)
  {
    printf ("Enter new file name _: ");
    scanf ("%s", new_filename);
    p_name = new_filename;
  }

  write_args.osname = p_name;
  result = omMakeMessage ("OMFiledOS", "write", (void *) &write_args, 
            sizeof (write_args), &write_messg);
  OnErrorCode (result, wrapup);

  result = omSend (&write_messg, osobjid, osnum, PW_K_NullObjid, FALSE);
  OnErrorCode (result, wrapup);

wrapup:
  PW_Wrapup (result, "cmd_write_os");
  return;
}
