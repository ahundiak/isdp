#include <stdio.h>
#include "NFMdate.h"
#include "NFMversion.h"

void _NFMprint_copyright (label)
  char    *label;
  {
	fputs ("\nI/NFM ", stderr);

	if ((strcmp (label, "")) != 0)
	  {
		fputs (label, stderr);
		fputs (" Version ", stderr);
	  }
	else
	  {
		fputs ("Version ", stderr);
	  }

	fputs (NFMversion, stderr);
	fputs (" - ", stderr);
	fputs (NFMdate, stderr);

    fputs ("\nCopyright 1993 Intergraph Corporation\n", stderr);
    fputs ("All Rights Reserved\n", stderr);
    fputs ("\n", stderr);
    fputs ("Including software, file formats, and audio-visual displays; \
may only be\n", stderr);
    fputs ("used pursuant to applicable software license agreement; contains \
confidential\n", stderr);
    fputs ("and proprietary information of Intergraph and/or third parties \
which is\n", stderr);
    fputs ("protected by copyright and trade secret law and may not be \
provided or\n", stderr);
    fputs ("otherwise made available without proper authorization.\n", stderr);
    fputs ("\n", stderr);
    fputs ("RESTRICTED RIGHTS LEGENDS\n", stderr);
    fputs ("Use, duplication, or disclosure by the U.S. Government is \
subject to\n", stderr);
    fputs ("restrictions as set forth in subparagraph (c) (1) (ii) of \
The Rights in\n", stderr);
    fputs ("Technical Data and Computer Software clause at DFARS \
252.227-7013 or\n", stderr);
    fputs ("subparagraphs (c) (1) and (2) of Commercial Computer \
Software -- Restricted\n", stderr);
    fputs ("Rights at 48 CFR 52.227-19, as applicable.\n", stderr);
    fputs ("\n", stderr);
    fputs ("Unpublished -- rights reserved under the Copyright Laws of the \
United States.\n", stderr);
    fputs ("\n", stderr);
    fputs ("Intergraph Corporation\n", stderr);
    fputs ("Huntsville, Alabama   35894-0001\n\n", stderr);
/*
	fputs ("\nCopyright (c) 1990 ", stderr);
	fputs ("Intergraph Corporation; All Rights Reserved\n", stderr);
	fputs ("Including Application Programs, File Formats, ", stderr);
	fputs ("and Visual Displays.\n\n", stderr);
*/
	return;
  }
