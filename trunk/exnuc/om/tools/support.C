#include <stdio.h>
#include <stdarg.h>
#include <sys/types.h>
#include <time.h>
#if defined (NT)
#include <process.h>
#endif
#include "OMOSfilehdr.h"
#include "dros.h"

extern unsigned int                 errcnt, os_size, mode, OSflags;
extern FILE                         *errlogfp, *osfp, *outfp;
extern char                         filename[];
extern struct OM_sd_OS_filehdr_OM   filehdr;

void reportError(char *format, ...)
{
   va_list     args;
   char        /**format, */ strBuffer[1000];
   time_t      clk;

   va_start(args, format);
/*   format = va_arg(args, char *);*/
   vsprintf(strBuffer, format, args);
   va_end(args);
   format = strBuffer;

   if (errlogfp)
   {
      if (errcnt == 1)
      {
         clk = time(0);
         fprintf(errlogfp, " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n\n");
         fprintf(errlogfp, "    DROS ERRORLOG                      %s\n", ctime(&clk));
         fprintf(errlogfp, " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n");
         fprintf(errlogfp, "\n +++  File name:         %s\n", filename);
         fprintf(errlogfp, " +++  File size:         %d bytes\n", os_size);
         fprintf(errlogfp, " +++  Date written:      %s", filehdr.start_time);
         fprintf(errlogfp, " +++  Written at Node:   %s (%s)\n",
            filehdr.syst.mach_name.nodename, filehdr.syst.mach_name.machine);
         fprintf(errlogfp, " +++  Operating system:  %s, release %s %s\n",
            filehdr.syst.mach_name.sysname, filehdr.syst.mach_name.release,
            filehdr.syst.mach_name.version);
         fprintf(errlogfp, " +++  Written by image:   %s\n",
            filehdr.image_name);
         if (filehdr.i_num_appver)
         {
            OMuint   ii;
            char     stamps[33];

            fprintf(errlogfp, "\n +++  Application version stamps:\n\n");
            fseek(osfp, filehdr.fp_appver, 0);
            for (ii=0; ii<filehdr.i_num_appver; ii++)
            {
               if (32 == fread(stamps, 1, 32, osfp))
                  fprintf(errlogfp, "      %s\n", stamps);
            }
         }
         fprintf(errlogfp, "\n\n +++  Errors detected during validation:\n");
      }
      fprintf(errlogfp, "%s", format);
   }
   if (!(mode & SOFTLOGGING))
      fprintf(stdout, "%s", format);
}

void drosAbort()
{
   if (errlogfp)
   {
      if (errcnt)
         fprintf(errlogfp, "\n\n +++  End of errlog file.\n");
      fclose(errlogfp);
   }
   if (outfp) fclose(outfp);
   exit(0);
}



#include 	<malloc.h>

char	*som_malloc (size)

OMuint	size;

{
  if (size) return (malloc (size));
  else return (NULL);
}

char	*som_realloc (ptr, size)

char	*ptr;
OMuint	size;

{
  if ( size && ptr ) return (realloc (ptr, size));
  else return (NULL);
}

char	*som_calloc (number, size)

OMuint		number;
OMuint		size;

{
  if ((! number) || (! size)) return (NULL);

  return ((char *)calloc(number,size));
}


void som_dealloc (ptr)

void	*ptr;

{
  if ( ptr ) free (ptr);
}

