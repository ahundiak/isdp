class implementation TRret;

#include <stdio.h>
#include <ctype.h>
#include <sys/types.h>
#include <dirent.h>
#include "OMlimits.h"
#include "OMminimum.h"
#include "exdef.h"
#include "expriv.h"
#include "XCerror.h"
#include "TRprod_type.h"
%safe
#include "TRprod_name.h" /* Initializes TRprod_name[] and  TRprod_load[] */
%endsafe
#include "UMS.h"
#include "TR_msg.h"

#define	TRRET_SUCCESS	0
#define TRRET_ERROR	1

extern int EX_getpath();
extern int EX_findmod();
extern int EX_get_super();
extern int som_dload_class();
extern char *find_file();
extern int GRTRget_product_data_field();

%safe
char   pwd[256];
%endsafe


extern int trans_ret_function();
extern int (*prev_function)();
extern char        *getenv();

void TRRET_errmsg_handler( msgstr, severity )
char *msgstr;
int  severity;
{
/****	We still want to see error messages though 
 ****   we don't want to see verbose warnings
  if ( severity != ERR_INFO && severity != ERR_WARNING )
****/

  if ( severity != ERR_WARNING )
    fprintf( stderr, "%s\n", msgstr );

}

method execute( IGRint *response; IGRchar *response_data; IGRint pos )
{
  int   (*prev_function)();
  char	msg_file[256];

/********
  With version 2.2.0.11 of EXNUC it is no longer necessary to replace 
  the error message handler routine with our own, since they have suppressed
  the warning messages during dynamic load
 
  trap_errors(TRRET_errmsg_handler);
********/

  /*
   * Initialize UMS message system 
   */
	 
  GRTRget_product_data_field ("Grnuc", 5, msg_file);
  strcat ( msg_file, "/config/english/messages/TR_msg.msg" );
  UMSInitMsg ( msg_file, UMS_INDEX );

  ex$retrieve_function ( function = trans_ret_function,
                          previous_function = &prev_function );

quit:
  *response = TERMINATE;

  return OM_S_SUCCESS;
}


/*+++++++++++++++++++++++++++++++++++++++++++++++++++++ GRTRload_directory */
int GRTRload_directory(directory, prod_type)
char *directory;
int  prod_type;
{
  FILE  *fp;
  DIR   *fd=NULL;
  struct dirent *dlink;
  char	str[256], trans_prod[256], c[5][128], path[250];
  int   ret, num_file, i;
  IGRchar	*filelist[10];
  IGRchar	*prodlist[2];
  IGRchar  	*pathlist[2];

  ret = TRRET_ERROR;

  fd = (DIR *)opendir(directory);
  if (fd == NULL)
      goto quit;

  num_file = 0;

  while(dlink = readdir(fd))
  {
    if ((dlink->d_ino != 0) && (dlink->d_name[0] != '.'))
    {
      sprintf(str, "%s/%s", directory, dlink->d_name);
      filelist[num_file] = (char *)malloc(strlen(str)+1);
      strcpy(filelist[num_file++], str);
    }
  }

  if (num_file)
  {
    sprintf ( path, "%s/", directory);
    ret = TRRET_SUCCESS;
    filelist[num_file] = 0;
    prodlist[0] = TRprod_name[prod_type];
    prodlist[1] = 0;
    pathlist[0] = path;
    pathlist[1] = 0;
    som_dload_class(filelist,prodlist,pathlist);

    for (i = 0; i < num_file; i++)
      if (filelist[i]) free(filelist[i]);
  }

  closedir(fd);

quit:
  return(ret);
}

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++ GRTRload_prod */
int GRTRload_prod(prod)
char *prod;
{
  FILE  *fp;
  DIR   *fd=NULL;
  struct dirent *dlink;
  char	str[256], trans_prod[256], trans_prod_name[80], c[5][128];
  int   prod_type, ret, num_file, i;
  char	*filelist[10];
  char	*prodlist[2];
  char	msgbuf[500];

  GRTR_find_prod_type(prod, &prod_type);
  if (prod_type < 0)
    goto quit;
  
  GRTRget_product_data_field (prod, 5, trans_prod);
  if (trans_prod[0] == '\0')
    goto quit;

  GRTRget_product_data_field (prod, 2, trans_prod_name);
  if (trans_prod_name[0] == '\0')
    goto quit;
  UMSGetByNum (msgbuf, TR_I_LoadProd, "%s", trans_prod_name);
  UI_status(msgbuf);

  /*--------------------------------------
   * Load init directory (translator code)
   *--------------------------------------*/
  strcpy(str, trans_prod);
  strcat(str, "/config/dload/init");
  ret = GRTRload_directory(str, prod_type);

  /*-----------------------------------------
   * If CGM load raster component and object 
   * file(s) in cmds directory as well
   *----------------------------------------*/
  if (!strcmp ( prod, "Cgm"))
  {
     IMload_raster_component();

     strcpy(str, trans_prod);
#ifdef CLIX
     strcat(str, "/config/dload/cmds/cgm.o");
#else
     strcat(str, "/config/dload/cmds/cgm.so");
#endif 
     ret = om$dynamic_load( filename = str );

     if ( ret  == OM_S_SUCCESS )
        TRprod_load[prod_type] = 1;
  }
  else
  {
     if ( ret == TRRET_SUCCESS )
        TRprod_load[prod_type] = 1;
  }

  /*---------------------------------------
   * Load form code for interactive form
   *--------------------------------------*/
  strcpy(str, trans_prod);
#ifdef CLIX
  strcat(str, "/config/dload/cmds/fsrc.o");
#else
  strcat(str, "/config/dload/cmds/fsrc.so");
#endif 
  if ((access( str, 0 ) == 0))
     om$dynamic_load( filename = str );

  /*---------------------------------------
   * Load the patch directory
   *--------------------------------------*/
  strcpy(str, trans_prod);
  strcat(str, "/config/dload/patch");
  ret = GRTRload_directory(str, prod_type);

  UI_status(" ");

quit:
  return(TRRET_SUCCESS);
}


/*++++++++++++++++++++++++++++++++++++++++++ GRTR_find_prod_type */
int GRTR_find_prod_type(prod_str, prod_type)
char *prod_str;
int  *prod_type;
{
  int i;

  *prod_type = -1;
  for (i = 0; i < NUM_TR_PROD; i++)
  {
    if (strcmp(TRprod_name[i], prod_str) == 0)
    {
      *prod_type = i;
      return(TRRET_SUCCESS);
    }
  }
  return(TRRET_SUCCESS);
}

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++ IGESdummy */
/* switch to different function according to the dummyType.
 * dummyType: 1, IGESmain
 *            2, IGESform_in_options
 *            3, IGESform_in_getopt_string
 *	      4, IGESform_out_options
 *            5, IGESform_out_getopt_string
 */
IGESdummy(product, dummyType, argc, argv, batch, init, accepted)
char *product;
int dummyType; 
int *argc;
char *argv[];
int batch;
int init;
int *accepted;
{
 return(0);
}

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++ DXFdummy */
/* switch to different function according to the dummyType.
 * dummyType: 1, DXFmain
 *            2, DXFform_in_options
 *            3, DXFform_in_getopt_string
 *	      4, DXFform_out_options
 *            5, DXFform_out_getopt_string
 */
DXFdummy(dummyType, argc, argv, batch, init, accepted)
int dummyType; 
int *argc;
char *argv[];
int batch;
int init;
int *accepted;
{
  return(0);
}

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++ VDAFSdummy */
/* switch to different function according to the dummyType.
 * dummyType: 1, VDAFSmain
 *            2, VDAFSform_in_options
 *            3, VDAFSform_in_getopt_string
 *	      4, VDAFSform_out_options
 *            5, VDAFSform_out_getopt_string
 */
VDAFSdummy(dummyType, argc, argv, batch, init, accepted)
int dummyType; 
int *argc;
char *argv[];
int batch;
int init;
int *accepted;
{
  return(0);
}

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++ FSTdummy */
/* switch to different function according to the dummyType.
 * dummyType: 1, FSTmain
 *            2, FSTform_in_options
 *            3, FSTform_in_getopt_string
 *	      4, FSTform_out_options
 *            5, FSTform_out_getopt_string
 */
FSTdummy(dummyType, argc, argv, batch, init, accepted)
int dummyType; 
int *argc;
char *argv[];
int batch;
int init;
int *accepted;
{
  return(0);
}

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++ CGMdummy */
/* switch to different function according to the dummyType.
 * dummyType: 1, CGMmain
 *            2, CGMform_in_options
 *            3, CGMform_in_getopt_string
 *	      4, CGMform_out_options
 *            5, CGMform_out_getopt_string
 */
CGMdummy(dummyType, argc, argv, batch, init, accepted)
int dummyType; 
int *argc;
char *argv[];
int batch;
int init;
int *accepted;
{
  return(0);
}

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++ TVdummy */
/* switch to different function according to the dummyType.
 * dummyType: 1, TVmain
 *            2, TVform_in_options
 *            3, TVform_in_getopt_string
 *	      4, TVform_out_options
 *            5, TVform_out_getopt_string
 */
TVdummy(dummyType, argc, argv, batch, init, accepted)
int dummyType; 
int *argc;
char *argv[];
int batch;
int init;
int *accepted;
{
  return(0);
}

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++ EMSMSdummy */
EMSMSdummy(dummyType, argc, argv, batch, init, accepted)
int dummyType; 
int *argc;
char *argv[];
int batch;
int init;
int *accepted;
{
  return(0);
}
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++ CADDSdummy */
CADDSdummy(dummyType, argc, argv, batch, init, accepted,set_export,prod)
int dummyType; 
int *argc;
char *argv[];
int batch;
int init;
int *accepted;
char *set_export;
int   prod;
{
  return(0);
}
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++ CATIAdummy */
CATIAdummy(dummyType, argc, argv, batch, init, accepted,set_export,prod)
int dummyType; 
int *argc;
char *argv[];
int batch;
int init;
int *accepted;
char *set_export;
int  prod;
{
  return(0);
}
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++ EMSDDNdummy */
EMSDDNdummy(dummyType, argc, argv, batch, init, accepted)
int dummyType; 
int *argc;
char *argv[];
int batch;
int init;
int *accepted;
{
  return(0);
}

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++ EMSSTEPdummy */
EMSSTEPdummy(dummyType, argc, argv, batch, init, accepted)
int dummyType; 
int *argc;
char *argv[];
int batch;
int init;
int *accepted;
{
  return(0);
}

end implementation TRret;
