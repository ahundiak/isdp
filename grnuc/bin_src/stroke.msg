
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This file contains a list of all error messages produced by stroker
%  portion of the IGDS metafile interpreter. It must be kept up to
%  date along with the ASerr.h files which define the constants for
%  use by the programs themselves.
%
%  The following lines define the facilities supported :
%
% fac 02600000 STROKER  stroker code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SUCCESS
0001
ST_SUCCESS successful completion
;
%INVWTF
0010
STR-W-INVWTF invalid words-to-follow in element %d
;
%INSFMEM
0020
STR-W-INSFMEM not enough memory
;
%MALLOCF
0030
STR-F-MALLOCF malloc failure
;
%MAPOLE
0040
STR-F-MAPOLE mis-aligned pole
;
%ECSTOVFL
0050
STR-F-ECSTOVFL end condition stack overflowed
;
%ECSEMPTY
0060
STR-F-ECSEMPTY end condition stack is already empty
;
%ECMOVFL
0070
STR-F-ECMOVFL end condition matrix overflow
;
%ECMEMPTY
0080
STR-F-ECMEMPTY end condition matrix already empty
;
%INVCMP
0090
STR-F-INVCMP invalid component type (%d) raster 
element encounterd at block = %d, byte = %d
;
%OPENERR
00A0
STR-F-OPENERR Error opening file %s
;
%seek error
00B0
STR-F-FSEEKE Could not fseek to image number %d.
;
%RASTHEAD
00C0
STR-F-RASTHEAD Could not read raster header for raster image # %d
;
%READERR
00D0
STR-F-READERR error reading file %s
;
%INTERNAL
00E0
STR-F-INTERNAL error fatal internal stroker error
;
%GPIPE
00F0
STR-W-GPIPE A Gpipe error occurred.  The Gpipe status is %d.
;
%POLE error
0100
STR-W-POLE Error processing bspline pole elements.
;
%BSURF error
0110
STR-W-BSURF Error processing bspline-surface.
;
%BBOUND error
0120
STR-W-BBOUND Error processing bspline boundary.
;
%BKNOTS error
0130
STR-W-BKNOTS Error processing bspline knots.
;
%BCRVE error
0140
STR-W-BCRVE Error processing bspline curve header.
;
%BWT error
0150
STR-W-BWT Error processing bspline weight element.
;
%INVH90 error
0160
STR-F-INVH90 Invlid version on Raster Element type 90.
;
%NTSPT error
0170
STR-W-NTSPT This feature is not supported.
;
%INVLNKG
0180
STR-W-INVLNKG invalid attribute index/linkage in element %d
;

