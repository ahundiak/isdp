/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        COfiledef

Decription
        This function reads and writes the defaults for plotting forms.

History
        mrm     03/22/89    creation
                03/28/90    make sure all IPLOT options are read

	Satish  06/16/95    added argument & code to take care of Pen_table
*/

#ifndef STANDALONE
#include "coimport.h"
#endif
#include <stdio.h>
#include "pidef.h"

extern FILE *fopen();
extern char *fgets(), *strchr(), *strrchr();

static char *Plotfile = "Plotfile";
static char *Queue = "Queue";
static char *Colortable = "Colortable";
static char *Iplot = "IP/PLOT";
static char *RendAttr = "RenderingAttributes";
static char *Pentable = "Pentable";
static char *Window = "Window";
static char *Port = "Port";

int COfiledef (read_flag, grnucpath, plotfile, queue, ctable,
               iplot, rendattr, port, window, pentable)
int read_flag;
char *grnucpath, *plotfile, *queue, *ctable, *iplot, *rendattr, *port;
int *window;
char *pentable;
{
    int sts;
    int pfln = 0, qln = 0, ctln = 0,
	ipln = 0, raln = 0, ptln=0, wln = 0, poln = 0;
    char buf[256], *c, *s, *e;
    FILE *fp;

    sts = PI_S_SUCCESS;
    sprintf (buf, "%suserdata/plot_defaults", grnucpath);
    if (read_flag)
    {
        if ((fp = fopen (buf, "r")) == NULL)
        {
            sts = PI_F_FAIL;
        }
        else
        {
            if (plotfile)
            {
                *plotfile = NULL;
                pfln = strlen (Plotfile);
            }
            if (queue)
            {
                *queue = NULL;
                qln = strlen (Queue);
            }
            if (ctable)
            {
                *ctable = NULL;
                ctln = strlen (Colortable);
            }
            if (iplot)
            {
                *iplot = NULL;
                ipln = strlen (Iplot);
            }
            if (rendattr)
            {
                *rendattr = NULL;
                raln = strlen (RendAttr);
            }
	    if (port)
	    {
		*port = NULL;
		poln = strlen(Port);
	    }
            if (window)
            {
                *window = FALSE;
                wln = strlen (Window);
            }
            if (pentable)
            {
                *pentable = NULL;
                ptln = strlen (Pentable);
            }
            while ((fgets (buf, 256, fp)) != NULL)
            {
                if ((s = strchr (buf, ':'))  &&
                    (e = strrchr (buf, ':')) &&
                    (s != e))
                {
                    s++;
                    c = NULL;
                    *e = NULL;
                    if ((plotfile) && !(strncmp (buf, Plotfile, pfln)))
                    {
                        c = plotfile;
                    }
                    else if ((queue) && !(strncmp (buf, Queue, qln)))
                    {
                        c = queue;
                    }
                    else if ((ctable) && !(strncmp (buf, Colortable, ctln)))
                    {
                        c = ctable;
                    }
			
                    else if ((iplot) && !(strncmp (buf, Iplot, ipln)))
                    {
                        c = iplot;
                    }
                    else if ((rendattr) && !(strncmp (buf, RendAttr, raln)))
                    {
                        c = rendattr;
                    }
		    else if ((port) && !(strncmp(buf, Port, poln)))
		    {
			c = port;
		    }
                    else if ((window) && !(strncmp (buf, Window, wln)))
                    {
                        sscanf (s, "%d", window);
                    }
                    else if ((pentable) && !(strncmp (buf, Pentable, ptln)))
                    {
                        c = pentable;
                    }
                    if (c)
                    {
                        strcpy (c, s);
                    }
                }
            }
        }
    }
    else /* write */
    {
        if ((fp = fopen (buf, "w")) == NULL)
        {
            sts = PI_F_FAIL;
        }
        else
        {
            if (plotfile)   fprintf (fp, "%s:%s:\n", Plotfile, plotfile);
            if (queue)      fprintf (fp, "%s:%s:\n", Queue, queue);
            if (ctable)     fprintf (fp, "%s:%s:\n", Colortable, ctable);
            if (iplot)      fprintf (fp, "%s:%s:\n", Iplot, iplot);
            if (rendattr)   fprintf (fp, "%s:%s:\n", RendAttr, rendattr);
	    if (port)	    fprintf (fp, "%s:%s:\n", Port, port);
            if (window)     fprintf (fp, "%s:%d:\n", Window, *window);
            if (pentable)   fprintf (fp, "%s:%s:\n", Pentable, pentable);
            fclose (fp);
        }
    }

    return (sts);
}
