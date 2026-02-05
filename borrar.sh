#!/bin/bash
echo "Eliminando  archivos anteriores ..."
sleep 2
cd $HOME/Descargas/
echo "Completado. Proceda a descargar los nuevos archivos a procesar. "
rm $HOME/Descargas/*.csv 2>/dev/null
cd $HOME


