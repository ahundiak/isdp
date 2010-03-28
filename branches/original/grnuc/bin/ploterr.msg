%  This file contains a list of all error messages produced by the plot
%  nucleus. It must be kept up to date along with the XXerr.h files
%  which define the constants for use by the programs themselves.
%
%  The following lines define the facilities supported :
%
% fac 02600000 VAXp	VAXpath
% fac 02610000 CRIP	rasterizing routines
% fac 02620000 TEXT	EPSON text metafile interpreter
% fac 02630000 FONT	font manager
% fac 02640000 ODI	ODI routines
% fac 02650000 HEAP	heap manager
% fac 02660000 G4	group 4 routines
% fac 02670000 RDU	raster data utilities
% fac 02680000 IMAGE	image processing functions
% fac 02700000 IGDS	IGDSplot metafile interpreter
% fac 02710000 GKS	GKS metafile interpreter
% fac 02720000 PROP	PROP (TDS) metafile interprter
% fac 02730000 ZEH	Zeh plot mfi
% fac 02740000 ODG	ODI graphics editor
% fac 02750000 OC	optimizer combiner metafile interpreter
% fac 02800000 QMS      QMS emulation
%
%  The format of the rest of this file is as follows :
%
%	Lines beginning with "%" are ignored and may be placed anywhere.
%
%	An error entry consists of a line with a 4 digit hexadecimal message
%	entry, one or more lines of message text to be printed out, and
%	a line consisting of only a ";" in the first character position
%	to terminate the entry. 
%	The first line will be proceded by a facility/severity
%	string - eg CRIP-F-. The rest will be output as they are.
%	Error lines may also contain a subset of the standard C format
%	specifiers. These are %x %d and %s. They will cause successive
%	entries in the errarg structure to be placed in the string -
%	errarg.val for %x and %d, and errarg.str for %s. There are only 4
%	of each of these, so no more than 4 %s's and a total of 4 %x's and
%	%d's may be used in an error entry.
%	Note that since the message numbers do not contain the severity they
%	will always end in 0 or 8.
%
0000
SUCCESS successful completion
;
0010
OPENERR error opening file for read
       - file %s
;
0018
CRERR error creating file for write
       - file %s
;
0020
READERR error reading file
       - file %s
;
0028
WRITERR error during write
       - file %s
;
0030
UNEXEOF unexpected end of file during read
       - file %s
;
0038
SEEK error during seek operation
       - file %s
;
0040
ERROR Closing file
;
0100
MALLOCF insufficient virtual memory
;
0200
NETERR network error
;
0208
NETTMT network request timed out
;
0300
RAWOPENERR error opening raw disk for read
       - partition %s
;
0308
RAWOPENW error opening raw disk for write
       - partition %s
;
0310
RAWREAD error in raw disk read
       - partition %s
;
0318
RAWWRITE error in raw disk write
       - partition %s
;
0320
RAWSMALL disk partition is too small for plot
       - partition %s, plot requires %d blocks
;
0400
TIMEOUT plotter timed out
;
0408
OFFLINE plotter is offline
;
0410
PAPER plotter is out of paper OR cannot select paper tray
;
0418
BADBUFF internal - bad buffer address
;
0420
BADBUFSZ internal - bad buffer size
;
0428
SDLERR kernal device IO error
;
0430
BADPARBF internal - bad parameter buffer address
;
0438
BADPARSZ internal - bad parameter buffer size
;
0440
ILLFUNC illegal function for device
;
0448
DEVFULL device is full
;
0450
NOTOPEN device is not open
;
0458
ALLOC device is allocated to another user or not available
;
0460
OBOVER output buffer overflowed
;
04F0
DEVICE unknown error from plotter
      - error number is %x
;
0500
UNSDTC unsupported raster data type code
      - data type %d, sequence number %d
;
0508
NULLSTRING a null text string was encountered
;
0510
BADRASDATA bad raster data was encountered during decoding/processing
;
0520
RASTERFILE currently cannot support NONSCANNABLE %d Raster Data Type
;
0600
NOALTPRI unable to increase process priority
;
0700
CLERR error parsing command line
;
0708
INSFARGS insufficient command line arguments for function
;
0710
NOSUCHDEV device does not exist
;
%
% font manager messages
%
2000
NOTMAP font is not mapped
;
2008
BITMAP font is bitmapped
;
2010
OUTLIN font is outline
;
2018
NOCHAR font not mapped
;
2020
NOTSUP font type not supported
;
2028
FONT Routine Error - status = %d
;
% 3xxx error are VDI/ODI specific
3000
INTERNAL an internal error occurred
;
3008
CLIPPED plot was clipped in one dimension
      - plot x extent is %d, plot y extent is %d
;
3010
NOVERT vertices in polygon or linestring exceeds limit
      - number of vertices is %d, limit is %d
;
3018
WSNOTOPEN invalid workstation id : %d
;
3020
WSLFULL unable to open another workstation - list full
;
3028
GPIPE error from GPIPE - error number is %d
;
3030
ENVV error from environ V - error number is %d
;
3038
PIXMAP_WORKSTATION: extracting pixmap beyond valid region
	- clipping extraction region to plotarea limits
;
3040
PLOT_LABEL will exceed plotter's dimension:
	- Plot label will be turned off
;
3070
INKFLOW & ACCURACY BLOCK will exceed plotter's dimension:
	- Inkflow & accuracy block will be turned off
;
3080
STASH MUST be configured for this plotter.
;
3090
RASTERFILE specified with %d as rastIndex
	- Maximum raster images in file : %d
;
30a0
ENVRDRV Window Delete event 
;
3100
MAXNUMSTYLES Maximum number of styles exceeded:
style specified %d exceeds %d number of styles in 
styletable %d
;
3108
INVSTYLETBLNO Invalid style table number specified
;
3110
MAXSTYLETABLES Maximum number of style tables created
;
3118
;
INVSTYLEINDX %d is an invalid styleindex in styletableNo %d
;
3120
MAXNUMFONTS unable to create font - font table full
;
3128
INVFONTNO Invalid fontNo specified: %d
;
3130
INVCLRTBLNO invalid colortable number specified
;
3138
MAXCOLORS color number outside specified range for color table
;
313c
MAXCOLORTABLE unable to create color table
      - maximum number of colortables already specified
;
3140
NOCOLORFILE no color file specified
;
3150
INVTYPEFORMAT invalid datatype format specified in colorfile
;
3160
INVCOLORNAME colorname %s not found
;
3200
INVMOSCNAME invalid MOS Classname : %s
;
3208
INVBFILE invalid driver file : %s
;
3210
INVCFGDATA invalid configure data : token id = %d
;
3218
INVCONN invalid connect specified : connect id = %d
;
3220
INVMSG invalid message - call to unitialized method on class %s
;
3228
INVSIZE invalid size (DRIVER ERROR)--change device x limits from %d to %d.
;
3230
INVVERNUM incompatible version numbers between ODI and driver
	- driver file : %s
	- ODI ver. : %d.%d	driver ver. : %d.%d
;
3238
PCCCOMPILE plotcaps compiler (pcc) error on source file : %s
;
3300
VLOCK not enough memory to lock down pages:
	- requires at least %d bytes 
	- and system has only %d free memory bytes
;
3308
VLOCK unable to lock down pages
;
3310
MEMORY_STASH Size specified exceeds system's total memory resources:
        - system total memory available:.......%d bytes
        - Memory_Stash memory size specified:..%d bytes
;
3318
MEMORY_STASH Size specified too small for plot:
        - plot requires:.........%d bytes
        - Memory_Stash size:.....%d bytes
Trying to continue plot using Disk Stash or Asynchronous I/O.
;
3320
ASYNCHRONOUS I/O SETUP: error in allocating event flags
;
3400
INVLIC invalid license for device driver
;
%
% 8000 - 8100 reserved for TDS mf interp
%
8000
BADREQ a bad request was encountered in the metafile
;
8008
BADELE a bad element was encountered in the metafile
;
8010
UNSREQ an unsupported request was encountered in the metafile
;
8018
TOOBIG plot is too big for requested plotter
;
8080
DPSERR error return from DPS : error number %d (dec)
;
8100
NOFONT unable to open font library : %s
;
%
%
