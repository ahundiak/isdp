#include "machine.h"
#include "CVT.h"

#define NFM_FILENAME 512   /******  YOU HAVE TO DELETE THESE **/
/*#define CVT_E_BAD_PATH 999 ******  WHEN YOU INCORPORATE IN  **/
/*#define CVT_S_SUCCESS 0    ******* NFM SOFTWARE             **/

/*main(argc,argv)
int argc;
char *argv[];
{
	char outpath[NFM_FILENAME];
	long status;
	long CVTconvert_optical_path();

	if(argc != 2)
	{
		puts("usage: cvtpath <inpath>");
		exit(-1);
	}
	
	status = CVTconvert_optical_path(argv[1], outpath); 
	
	if(status != CVT_S_SUCCESS)
	{
		printf("Inpath: <%s>\tBAD PATH\tOutpath: <%s>\n", 
			argv[1], outpath);
	}
	else
		printf("SUCCESS: Inpath: <%s>\tOutpath: <%s>\n", 
			argv[1], outpath);
	return(status);
}*/

long  CVTconvert_optical_path(inpath, outpath)
char *inpath, *outpath;
{
  char *fname = "CVTconvert_optical_path" ;
  char platter[20];
  char delim, *directory;
  long status;
  char message [512] ;
  long CVTextract_platter_name();
  
  _NFMdebug ((fname, "in path <%s>\n", inpath)) ;
  delim = inpath[0];
  if((delim != '@') && 
     (delim != ';') &&
     (delim != ':'))
    {
      sprintf (message, "Bad Delimiter <%c> in optical path",
	       delim) ;
      _NFMdebug ((fname, "%s\n", message)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", message) ;
      return (NFM_E_MESSAGE) ;
    }
  
  status = CVTextract_platter_name(inpath, platter);
  if(status != NFM_S_SUCCESS) 
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return(status); 
    }
  
  directory = (char *)strchr(inpath, '/');
  if (directory == NULL)
    {
      strcpy(outpath, "/cache/");
      strcat(outpath, platter);
    }
  else
    {
      strcpy(outpath, "/cache/");
      strcat(outpath, platter);
      strcat(outpath, directory);
    }
  
  _NFMdebug ((fname, "SUCCESSFUL : %s\n", outpath)) ;
  return (NFM_S_SUCCESS) ;
}

long CVTextract_platter_name(inpath, platter)
     char *inpath, *platter;
{
  char *fname = "CVTextract_platter_name" ;
  char delim, *other_delim_pos;
  char tmp_path[NFM_FILENAME];
  char message [512];

  _NFMdebug ((fname, "in path <%s>\n", inpath)) ;
  
  delim = inpath[0];
  
  if((delim == ':') && (inpath[1] == ':'))
    strcpy(tmp_path, &inpath[2]);
  else
    strcpy(tmp_path, &inpath[1]);
  
  other_delim_pos = (char *)strchr(tmp_path, delim);
  
  if(other_delim_pos == NULL)
    {
      _NFMdebug ((fname, "Bad Delimiter in path\n")) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Bad Delimiter in optical path") ;
      return (NFM_E_MESSAGE) ;
    }
  
  if((other_delim_pos[1] != '/') &&
     (other_delim_pos[1] != '\0'))
    {
      sprintf (message, "Bad Delimiter <%c> in optical path",
	       other_delim_pos[1]) ;
      _NFMdebug ((fname, "%s\n", message)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", message) ;
      return (NFM_E_MESSAGE) ;
    }
  
  other_delim_pos[0] = '\0';
  
  strcpy(platter, tmp_path);
  
  _NFMdebug ((fname, "SUCCESSFUL : platter <%s>\n", platter)) ;
  return (NFM_S_SUCCESS) ;
}


