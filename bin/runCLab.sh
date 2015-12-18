 #!/bin/bash
 
 cLabPath="python bin/cLab.py "
 source "venv/bin/activate";
 command=$cLabPath$*
 echo "Running: "$command
$command