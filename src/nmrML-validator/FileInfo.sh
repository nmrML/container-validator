#!/bin/sh
HOME=/var/www/
export HOME

## Whenever you change a path here,
## also update the appropriate apparmor profile
## under /etc/apparmor.d/local/vol.openms.src.trunk.OpenMS-nmrML.bin.FileInfo

/OpenMS/OpenMS-nmrML/bin/FileInfo -ini /var/www/html/nmrML-validator/FileInfo.ini -v -in "$1"  -in_type nmrML

cp "$1" "$1.xml"
LD_LIBRARY_PATH=/OpenMS/OpenMS/lib/:$LD_LIBRARY_PATH OPENMS_DATA_PATH=/OpenMS/OpenMS-nmrML/share/OpenMS /OpenMS/OpenMS/bin/SemanticValidator -in "$1.xml" -cv /nmrML/nmrCV.obo -mapping_file /nmrML/nmr-mapping.xml
