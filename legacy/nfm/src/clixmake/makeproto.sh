echo
echo "alpha ..."
cd ../alpha
mkptypes.sh NFA ../include

echo
echo "bulkload ..."
cd ../bulkload
mkptypes.sh BULK ../include

echo
echo "dbtools ..."
cd ../dbtools
mkptypes.sh DBTL ../include

echo
echo "cmdtools ..."
cd ../cmdtools
mkptypes.sh CMDT ../include

echo
echo "ris_initial ..."
cd ../ris_initial
mkptypes.sh INIT ../include

echo
echo "filetransfer ..."
cd ../filetransfer
mkptypes.sh TFER  ../include

echo
echo "nfmfi ..."
cd ../nfmfi
mkptypes.sh NFI ../include

echo 
echo "nfmr ..."
cd ../nfmr
mkptypes.sh NFMR ../include

echo
echo "nfms ..."
cd ../nfms
mkptypes.sh NFMS ../include

echo
echo "nfma ..."
cd ../nfma
mkptypes.sh NFMA ../include

echo
echo "nfmu ..."
cd ../nfmu
mkptypes.sh NFMU ../include

echo
echo "nfmlist ..."
cd ../nfmlist
mkptypes.sh DIS ../include

echo
echo "nfmd ..."
cd ../nfmd
mkptypes.sh NFMD ../include

echo
echo "utilities ..."
cd ../utilities
mkptypes.sh UTI ../include

echo
echo "workflow ..."
cd ../workflow
mkptypes.sh WF ../include

echo
echo "admin ..."
cd ../admin
mkptypes.sh ADM ../include
