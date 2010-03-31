#include <stdio.h>

main ()
   {
   FILE *vp, *sp, *fp, *fopen ();
   char prod[32], namepath[132], key1[32], key2[32], stuff[132];
   char version[32], date[32];
   int v1, v2, v3, v4, i;
   long clock, time ();
   char *dt, *ctime ();

   /* Get in ascii form, the current date and time */

   clock = time ((long *) 0);
   dt = ctime (&clock);
   for (i = 0; i < 26; i++)
      if (dt[i] == 10)
         dt[i] = 0;

   /* Get the current HSplot version.  If the version file does not exist,
    * ask for an initial version, else read the file and incriment.  Last,
    * re-write the file */

   if ((fp = fopen ("HSplot.version", "r")) != NULL)
      {
      fscanf (fp, "%d %d %d %d", &v1, &v2, &v3, &v4);
      v4++;
      fclose (fp);
      }
   else
      {
      printf ("Enter initial version -> ");
      scanf ("%d %d %d %d", &v1, &v2, &v3, &v4);
      }

   fp = fopen ("HSplot.version", "w");
   fprintf (fp, "%1d %1d %1d %1d\n", v1, v2, v3, v4);
   fclose (fp);

   /* Create the version source file.  Write the header and version/date
    * print */

   sp = fopen ("../hplot/HPversion.c", "w");

   fprintf (sp, "#include <stdio.h>\n");
   fprintf (sp, "\n");
   fprintf (sp, "/*---HPversion---------------------------------------------*/\n");
   fprintf (sp, "\n");
   fprintf (sp, "/*\n");
   fprintf (sp, "NAME\n");
   fprintf (sp, "	HPversion\n");
   fprintf (sp, "	\n");
   fprintf (sp, "KEYWORD\n");
   fprintf (sp, "	HSplot\n");
   fprintf (sp, "	version\n");
   fprintf (sp, "	\n");
   fprintf (sp, "DESCRIPTION\n");
   fprintf (sp, "	Displays version information for the current HSplot build\n");
   fprintf (sp, "	\n");
   fprintf (sp, "GLOBALS USED\n");
   fprintf (sp, "\n");
   fprintf (sp, "FUNCTIONS CALLED\n");
   fprintf (sp, "\n");
   fprintf (sp, "HISTORY\n");
   fprintf (sp, "	%s	M. Lanier\n", dt);
   fprintf (sp, "		Created\n");
   fprintf (sp, "		\n");
   fprintf (sp, "*/\n");
   fprintf (sp, "\n");
   fprintf (sp, "HPversion()\n");
   fprintf (sp, "\n");
   fprintf (sp, "	{\n");
   fprintf (sp, "	printf( \"HSplot: %1d\\n\" );\n", v1 );
   fprintf (sp, "	printf( \"\\n\" );\n");

   if ((fp = fopen ("version.info", "r")) != NULL)
      {
      fprintf (sp, "	printf( \"    Built Using\\n\" );\n");
      fprintf (sp, "	printf( \"\\n\" );\n");

      while (fscanf (fp, "%s %s %s %s", prod, namepath, key1, key2) >= 0)
         {
         if ((vp = fopen (namepath, "r")) != NULL)
            {
            fprintf (sp, "	printf( \"        %-12s", prod);

            while (fscanf (vp, "%s", stuff) >= 0)
               {
               if (strcmp (stuff, key1) == 0)
                  {
                  fscanf (vp, "%s", version);
                  fprintf (sp, "%-15s", version);
                  }
               /* if( strcmp( stuff, key2 ) == 0 ) { fscanf( vp, "%s", date
                * ); if( date[0] == ':' ) fscanf( vp, "%s", date ); fprintf(
                * sp, "%-15s", date ); } */
               }

            fprintf (sp, "\\n\" );\n");
            fclose (vp);
            }
         }

      fclose (fp);
      }

   fprintf (sp, "	printf( \"\\n\" );\n");
   fprintf (sp, "	printf( \"\\n\" );\n");
   fprintf (sp, "	printf( \"\\n\" );\n");
   fprintf (sp, "	}\n");
   fclose (sp);
   }
