Copyright 1993 Intergraph Corporation
All Rights Reserved

Including software, file formats, and audio-visual displays;
may only be used pursuant to applicable software license agreement;
contains confidential and proprietary information of Intergraph
and/or third parties which is protected by copyright and trade
secret law and may not be provided or otherwise made available
without proper authorization.

RESTRICTED RIGHTS LEGENDS

Use, duplication, or disclosure by the U.S. Government is subject to
restrictions as set forth in subparagraph (c) (1) (ii) of The Rights
in Technical Data and Computer Software clause at DFARS 252.227-7013
or subparagraphs (c) (1) and (2) of Commercial Computer Software --
Restricted Rights at 48 CFR 52.227-19, as applicable.

Unpublished -- rights reserved under the Copyright Laws of the
United States.

Intergraph Corporation
Huntsville, Alabama   35894-0001

-------------------
Version Information
---------------------------------------------------------------------
Product:    NFMPC      Network File Manager PC Command Line Interface
Version:    03.05.00.20
Date:       11-AUG-1994
---------------------------------------------------------------------
End of Version Information
--------------------------


-----------------
Installation Help
-----------------

    Newprod the NFMPC product to any Intergraph UNIX machine,
    and then 'ftp' from the PC to that UNIX machine and execute the
    following commands:

        ftp:> get /usr/ip32/nfm/bin/nfmpc.tak \nfmpc.tak
        ftp:> take \nfmpc.tak

        C:\> ninstall -p <absolute path> -h <pc nodename> 
                      [-d -o <debug_file>]

	options :

        -p   Enter drive and directory where NFMPC is to be installed

        -h   Select the name of this PC

	-d -o Optional - for debug purposes


If you are installing on a PC/TCP 2.2 or greater 

The installation procedure uses ipcust.sys file to verify host information.
PC/TCP may not have updated this information in 2.2 as it started using pctcp.ini
file.

Change directory to your  pctcp directory and run

ipconfig ipcust.sys hostname <your pcs official name>
ipconfig ipcust.sys hosttable <absolute path to the hosts file>


Re-do the installation process.
------------------------
End of Installation Help
------------------------


---------------
Getting Started
---------------
   
    o   If you move the PC hosts file, you must edit the DEFAULTS
        file in the \cfg directory for the new location.

    o   The FTP directory must be in the path.

    o   If you have more than 1 hard disk, the TCP/IP paths in the
        autoexec.bat file and any programs and/or drivers in the
        config.sys file MUST be prefixed with the disk drive.

    o   Start NFMPC by entering "nfmpc" at the DOS prompt, ie.

            C:\> nfmpc [-d [-o output] [-s server] [-e environment] [-u username] [-p password] [-c catalog] [-i item] [-r revision] [-a storage area] [-f command file] [-b defaults file]

    o   To remove NFMPC enter "remove" at the DOS prompt, ie.

            C:\> nremove -p <absolute path where a bin/nfmpc.exe exists>


----------------------
End of Getting Started
----------------------

-------------
Documentation
-------------
For current information on product documentation, please see the Intergraph
Document List (IDL).  This online information source lists and describes the
available documents that support Intergraph application and system software
products.  The IDL is delivered free with the Intergraph System Software (ISS)
Supplemental Baseline product set.

To get a copy of the current IDL, use the newprod software delivery utility to
deliver ST**008 IDL from the ISS Supplemental Baseline to your workstation or
server.  The IDL files are delivered to /usr/ip32/idl.

Instructions on using the IDL are available in the README and idl.doc files
located in /usr/ip32/idl.
--------------------
End of Documentation
--------------------


--------
Training
--------

TDR0001  --  NFM Administrator

---------------
End of Training
---------------


----------------
Product Sections
----------------

Memory Requirements

-----------------------
End of Product Sections
-----------------------

-------------------
Memory Requirements      
-------------------

    The minimum amount of memory required by the NFMPC executable 
    is 256k bytes.   

    If you run NFMPC in batch mode, the configuration is copied
    reducing the amount of memory available to NFMPC.

    NOTE: NFMPC is a "real mode", not "protected mode",  
    application.

--------------------------
End of Memory Requirements
--------------------------


------------
New Features
------------
None.
-------------------
End of New Features
-------------------


---------
New Fixes
---------
None.
----------------
End of New Fixes
----------------


-------------
Open Problems
-------------
None.
--------------------
End of Open Problems
--------------------
