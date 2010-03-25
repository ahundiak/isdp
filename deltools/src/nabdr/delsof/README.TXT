This is the serial number support libarry for DELTOOLS.  This library
contains the following sources

API Files:

    esapi.[ch]    - Evaluation Serial Number API.
    msapi.[ch]    - Maintenancen Serial Number API.
    wsapi.[ch]    - Warranty Serial Number API.

Support Files:

    esne.[ch]     - Evaluation Serial Number Encryption module.
    msne.[ch]     - Maintenance Serial Number Encryption module.
    a2b32.[ch]    - Code for mapping binary data <-> ASCII strings using a
	            32 character alphabet.
    a2b64.[ch]    - Code for mapping binary data <-> ASCII strings using a
	            64 character alphabet.
    crc32.[ch]    - Code for computing 32 bit CRCs.
    snerr.[ch]    - Global error definition module.
    myctype.[ch]  - Miscellaneous data conversion functions.

The following compilation directives should be used when compiling all of
the source files included in this library:

    _A2B32_DECONLY_ - Used when compiling the evaluation API.  This compilation
                      directive excludes unnecessary binary -> ascii
                      conversion code and data.

    _ESNE_DECONLY_  - Used when compiling the evaluation API.  This compilation
                      directive excludes unnecessary encryption code and data
	              structures.

    _A2B64_DECONLY_ - Used when compiling the maintenance API.  This
	              compilation directive excludes unnecessary
                      binary -> ascii conversion code and data.

    _MSNE_DECONLY_  - Used when compiling the maintenance API.  This
                      compilation directive excludes unnecessary encryption
                      code and data structures.

    _SYSV_          - Used for all APIs when compiling for a SYSV compatible
                      system.

    _SunOS_         - Used for all APIs when compiling for a SunOS compatible
                      system.

You will probably need to add additional platform dependent compilation
directives.  If you do modify the code, however, please send me the
modified code so that I can check it back into my source code control
system.

I have included a complete compilation environment in this zipfile.  You can
reference the makefiles for the respective APIs to see what you will need
when using the API.

Each API file has a main() in its testing section which illustrates how to
use the API calls.

If you have additional questions, please call me.

P.S.

This code is sensitive and confidential.  The encryption algorithms for the
maintenance and evaluation serial numbers must be protected.  This protection
not only includes protecting the sources, but also using the compilation
directives listed above to exclude unnecessary partions of the algorithm from
DELTOOLS executables.

Dave
