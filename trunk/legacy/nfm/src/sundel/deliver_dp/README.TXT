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
---------------------------------------------------------------------------
Product:      I/NFMDP            I/NFM Development Platform
Version:      03.04.00.14
Date:         09-OCT-1993
Description:  I/NFM is  a  complete system for managing files, both current
              and  archived, in  a  heterogeneous  or  homogeneous  network
              environment.  The I/NFMDP is a developmental toolkit to inter-
              face with I/NFM.

---------------------------------------------------------------------------
End of Version Information
--------------------------

-----------------
Installation Help
-----------------

     ALL NUCLEUS SOFTWARE MUST BE INSTALLED BEFORE I/NFM IS INSTALLED,
     OTHERWISE, I/NFM WILL BEHAVE IN AN UNPREDICTABLE MANNER.

     The I/NFMDP installation procedure will prompt the user as to what 
     pieces of the development platform he wishes to download:

          Install the C100 libraries (y/n) ?
          Install the C400 libraries (y/n) ?
          Install the I/NFM Include Files (y/n/h) ?
          Install the MEM, NET, and SQL Libraries (y/n/h) ?
              The I/NFM Development Platform provides a set of memory, 
              network, and structured query language tools.  These are 
              essential when developing I/NFM server or requester 
              executables.
          Install the I/NFM Requester Libraries (y/n/h) ?
              The I/NFM Requester Libraries are a set of functions that 
              can communicate with the I/NFM Server on a client/server basis.
          Install the I/NFM Server Libraries (y/n/h) ?
              The I/NFM Server Libraries are a set of functions that can
              communicate directly with the I/NFM database.

     If RIS does not exist on the machine where the I/NFM server software is
     being downloaded, a warning will be printed during the newprod session. 
     The product will continue to download, but cannot be used until RIS has
     been loaded.
     
     USER PARTITIONS
     To download the I/NFM software to a partition other than /usr, the
     -b option may be specified on the newprod command line.  For example, 

             newprod -n deliver.ip32 -b /usr2

     You may also change the destination file system while in newprod.
     If you download software to a partition other than /usr, it is
     important that the /usr/ip32/nfmdp directory does not exist prior to
     installation.

------------------------
End of Installation Help
------------------------

---------
New Fixes
---------

----------------
End of New Fixes
----------------

------------
New Features
------------

     RIS VERSION
     This version of I/NFM is build on and is dependent on RIS 4.3
     NO other version of RIS (earlier or later) is compatible with this
     version of I/NFM.

     RIS WITH INFORMIX
     Anyone using the Informix RDBMS must upgrade there Informix to
     05.00 or later.  RIS is dependent upon bug fixes in this version.

     This version of I/NFM is built on ISS 7.1.

-------------------
End of New Features
-------------------

--------
Comments
--------

---------------
End of Comments     
---------------

-------------
Documentation
-------------

For current information on product documentation, please see the Intergraph
Document List (IDL). This online information source lists and describes the
available documents that support Intergraph application and system software
products. The IDL is delivered free with the Intergraph Systems Software (ISS)
Supplemental Baseline product set.

To get a copy of the current IDL, use the newprod software delivery utility to
deliver ST**008 IDL from the ISS Supplemental Baseline to your workstation or
server. The IDL files are delivered to /usr/ip32/idl.

Instructions on using the menu-driven IDL interface are available in the 
README and idl.doc files located in /usr/ip32/idl.

For information on Intergraph documentation and Intergraph document delivery
policies, use a World Wide Web browser to connect to Intergraph online at
http://www.intergraph.com, and follow the links to Customer Services.

--------------------
End of Documentation
--------------------

--------
Training
--------

The I/NFM User training course number is TIME1300.
The I/NFM Administrator training course number is TIME2301.
The training classes are taught monthly, the second full week of each month.

---------------
End of Training
---------------

