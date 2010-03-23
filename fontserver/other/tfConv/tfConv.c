/* This program converts a Bitstream compressed font file to a Font	*/
/* Server typeface file.						*/

/* Link with FSWriteTF.o and an archive Font Server library.		*/


#include <stdio.h>
#include <ctype.h>
#include "../hfiles/FSTypes.h"
#include "../hfiles/FSLoadTF.h"

char *GetString ();

main (argc, argv)
int	argc;
char	*argv[];
{
    int		i, vNum, numWords, offset;
    FILE	*file;
    TFStruct	tf;

    if (argc < 3)
    {
	printf("Usage: tfConv oldTF newTF [layoutNumber] [noPolysFlag] [customerNotice] [userId] [userData]\n");
	exit (-1);
    }
    if ((file = fopen (argv[1], "r")) == NULL)
    {
	printf ("Cannot open %s for reading.\n", argv[1]);
	exit (-1);
    }

    if (_FSCFTLoad (file, &tf))
    {
	printf ("\nError while reading the typeface file.\n");
	exit (-1);
    }
    fclose (file);

    /** Calculate version number **/
    vNum = 100 * (tf.info.outlFmtNr[1] - '0') +
	    10 * (tf.info.outlFmtNr[3] - '0');
    if (isdigit (tf.info.outlFmtNr[4]))
	vNum += (tf.info.outlFmtNr[4] - '0');

    if (vNum == 232)
    {
	/** Up to date **/
    }
    else if ((vNum == 231) || (vNum == 230))
    {
	if (vNum == 230)
	{
	    /** Encrypt the outline data **/
	    if (strncmp (tf.outlinesHdr.blockId, "O2", 2) == 0)
		numWords = tf.outlinesHdr.nrDataWds +
			   (tf.outlinesHdr.recSize << 16);
	    else
		numWords = tf.outlinesHdr.nrDataWds;

	    _FSEncryptBuff (tf.outlines, numWords);
	}

	/** Initialize rest of typeface header **/
	memcpy (tf.info.outlFmtNr, "C2.32000", 8);

	if (argc > 3)
	    tf.info.layoutNumber = atoi (argv[3]);
	else
	    tf.info.layoutNumber = atoi (GetString ("Layout number? "));

	tf.info.flag2 = 0;
	if (argc > 4)
	    tf.info.flag2 |= (atoi (argv[4]) ? FS_NOPOLYS : 0);
	else
	    tf.info.flag2 |= (atoi (GetString ("No polygons (1 or 0)?  ")) ?
				 FS_NOPOLYS : 0);

	memset (tf.info.custNotice, 0, 100);
	if (argc > 5)
	    strncpy (tf.info.custNotice, argv[5], 99);
	else
	    strncpy (tf.info.custNotice, GetString ("Customer Notice? "), 99);

	tf.info.userId = 0;
	if (argc > 6)
	    tf.info.userId = atoi (argv[6]);
	else
	    tf.info.userId = atoi (GetString ("User id? "));

	tf.info.userData = 0;
	if (argc > 6)
	    tf.info.userData = atoi (argv[6]);
	else
	    tf.info.userData = atoi (GetString ("User data? "));

	memset (tf.info.reserved, 0, 110);
	tf.info.offsLigTable = 0;

	offset = 256 - tf.infoHdr.nrDataWds;
	tf.info.offsKernPrs += offset;
	tf.info.offsKernTrks += offset;
	tf.info.offsCharDir += offset;
	tf.info.offsOutlData += offset;
	tf.infoHdr.nrDataWds = tf.infoHdr.nrRecs = 256;
    }
    else
    {
	printf ("Unknown version number!\n");
	exit (-1);
    }

    if ((file = fopen (argv[2], "w")) == NULL)
    {
	printf ("Cannot open %s for writing.\n", argv[2]);
	exit (-1);
    }

    if (_FSCFTWrite (file, &tf))
    {
	printf ("\nError while writing the new typeface file.\n");
	close (file);
	exit (-1);
    }

    fclose (file);
    exit (0);
}



char *GetString (str)
char *str;
{
    char input[256];

    printf ("%s", str);
    gets (input);
    return (input);
}
