#!/bin/sh
HOME=/var/www/
export HOME

## Whenever you change a path here, 
## also update the appropriate apparmor profile 
## under /etc/apparmor.d/local/vol.openms.src.trunk.OpenMS-nmrML.bin.FileInfo 

/vol/openms/src/trunk/OpenMS-nmrML/bin/FileInfo -ini FileInfo.ini -v -in "$1"  -in_type nmrML

/vol/openms/src/trunk/OpenMS/bin/SemanticValidator -in "$1"  -cv /vol/nmrML/code/ontologies/nmrCV.obo -mapping_file /vol/nmrML/code/ontologies/nmr-mapping.xml



