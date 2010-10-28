%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This file contains a list of all error messages produced by the igds
%  metafile interpreter. It must be kept up to date along with the XXerr.h
% files which define the constants for use by the programs themselves.
%
%  The following lines define the facilities supported :
%
% fac 02700000 IGDS	IGDSplot metafile interpreter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SUCCESS
0001
IGDS_SUCCESS successful completion
;
%PLOT TOO big
0010
IGDS-F-TOOBIG plot is too big for requested plotter - Max size is %d
;
%IGDS-F-MALLOCF 
0020
IGDS-F-MALLOCF malloc failure.
;
%INSUFFIENT ARGS
0030
IGDS-F-INSFARGS insufficient command line arguments for function
;
%INCORRECT ARGS
0040
IGDS-F-INVFARGS invalid command line arguments for metafile interpreter.
;
%FATAL INTERNAL ERROR
0050
IGDS-F-INTERNAL an internal error occurred
;
%INTERNAL ERROR
0060
IGDS-W-INTERNAL an internal error occurred
;
%NO font found
0070
IGDS-F-NOFONT unable to open font library: %s
;
%NO font found
0080
IGDS-F-FONTERR error loading fonts from font library: %s
;
0090
IGDS-F-BADELE Element number %d in metafile segment %d is corrupt.
;
%error opening file 
00A0
IGDS-F-OPENERR error opening file for read 
       - file %s
;
%error reading file
00B0
IGDS-F-READERR error reading file %s
;
%MR tools no matchin netry
00C0
IGDS-F-NOMATCH No matching entry found in file - %s
;
%MR tools invalid type
00D0
IGDS-F-INVTYPE Invalid Resource type
;
%Invalid metafile
00E0
IGDS-F-INVMFILE invalid metafile
;
%Metafile without a type 5 level 4 or type 5 level 16.
00F0
IGDS-F-NOTYPE5 Invalid metafile.
This file does not contain a necessary type 5 element.
;
%Unexpected end of file
0100
IGDS-F-BADEOF Corrupt metafile: unexpected end of file marker found. 
;
%Invalid attribute bundle index
0110
IGDS-W-BADIDX Invalid index to attribute bundle %d in element %d.
Elements from an IGDS metafile were used in a design file.
;
%Invalid words to follow
0130
IGDS-W-INVWTF Invalid words to follow in element %d
%s
;
%Error occurred while steeing up GPIPE
0140
IGDS-F-GPIPE An error occurred while setting up GPIPE.
