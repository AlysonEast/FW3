#!/bin/bash

export GISRC=/home/1te/.grassrc6.data

CORR_TEST=0
REGRESION_FULL=0
REGRESION_PHENO=1
MAP_PHENO=0
DATA_OUT_FOR_R=0
RUN_GLM=0
RUN_GLM_PHENO=0

#############################################################
if [ $CORR_TEST -eq 1 ]
then

 g.region rast=terraAquaCombined_1yr_auc_2014
 r.mask -r

d.mon x4
d.correlate layer1=terraAquaCombined_1yr_auc_2014 layer2=fakeS3laea.maxMODIS.2014.std.rseriessum.45
d.out.file output=./figures/GPP_FW3_2014 format=png --o

d.correlate layer1=terraAquaCombined_1yr_auc_2016 layer2=fakeS3laea.maxMODIS.2016.std.rseriessum.45
d.out.file output=./figures/GPP_FW3_2016 format=png --o

d.correlate layer1=terraAquaCombined_1yr_auc_2017 layer2=fakeS3laea.maxMODIS.2017.std.rseriessum.45
d.out.file output=./figures/GPP_FW3_2017 format=png --o

d.correlate layer1=terraAquaCombined_1yr_auc_2018 layer2=fakeS3laea.maxMODIS.2018.std.rseriessum.45
d.out.file output=./figures/GPP_FW3_2018 format=png --o

d.correlate layer1=terraAquaCombined_1yr_auc_2019 layer2=fakeS3laea.maxMODIS.2019.std.rseriessum.45
d.out.file output=./figures/GPP_FW3_2019 format=png --o

d.correlate layer1=terraAquaCombined_1yr_auc_2020 layer2=2020.trueS3.S3?-NT.napolygon.maxndvi.LAEA.rseriessum.45
d.out.file output=./figures/GPP_FW3_2020 format=png --o

d.correlate layer1=terraAquaCombined_1yr_auc_2021 layer2=2021.trueS3.S3?-NT.napolygon.maxndvi.LAEA.rseriessum.45
d.out.file output=./figures/GPP_FW3_2021 format=png --o

d.correlate layer1=terraAquaCombined_1yr_auc_2022 layer2=2022.trueS3.S3?-NT.napolygon.maxndvi.LAEA.rseriessum.45
d.out.file output=./figures/GPP_FW3_2022 format=png --o

d.correlate layer1=terraAquaCombined_1yr_auc_2023 layer2=2023.trueS3.S3?-NT.napolygon.maxndvi.LAEA.rseriessum.45
d.out.file output=./figures/GPP_FW3_2023 format=png --o

fi
#############################################################
if [ $REGRESION_FULL -eq 1 ]
then

r.regression.line map1=terraAquaCombined_1yr_auc_2014 map2=fakeS3laea.maxMODIS.2014.std.rseriessum.45 -g >tmp

awk 'BEGIN{FS="="} {print $1}' tmp | tr '\n' '|' >Full_Regression
echo "year" >>Full_Regression
awk 'BEGIN{FS="="} {print $2}' tmp | tr '\n' '|' >>Full_Regression
echo "2014" >>Full_Regression

for((v=1; v<5; v++)) do
 echo "Running $((v+2015))"

r.regression.line map1=terraAquaCombined_1yr_auc_$((v+2015)) map2=fakeS3laea.maxMODIS.$((v+2015)).std.rseriessum.45 -g >tmp

awk 'BEGIN{FS="="} {print $2}' tmp | tr '\n' '|' >>Full_Regression
echo "$((v+2015))" >>Full_Regression

done

for((v=1; v<5; v++)) do
 echo "Running $((v+2019))"

r.regression.line map1=terraAquaCombined_1yr_auc_$((v+2019)) map2=$((v+2019)).trueS3.S3?-NT.napolygon.maxndvi.LAEA.rseriessum.45 -g >tmp

awk 'BEGIN{FS="="} {print $2}' tmp | tr '\n' '|' >>Full_Regression
echo "$((v+2019))" >>Full_Regression

done

fi
#############################################################
if [ $REGRESION_PHENO -eq 1 ]
then

r.mask phenology_2000-2016.100.maxmode maskcats=1 --o
r.regression.line map1=MODIS_CalYear_AUC_2020 map2=2020.trueS3.S3?-NT.napolygon.maxndvi.LAEA.rseriessum.45 -g >tmp
i
d.mon x4
d.correlate layer1=MODIS_CalYear_AUC_2020 layer2=2020.trueS3.S3?-NT.napolygon.maxndvi.LAEA.rseriessum.45

awk 'BEGIN{FS="="} {print $1}' tmp | tr '\n' '|' >Pheno_Regression
echo "pheno" >>Pheno_Regression
awk 'BEGIN{FS="="} {print $2}' tmp | tr '\n' '|' >>Pheno_Regression
echo "1" >>Pheno_Regression

for((v=2; v<101; v++)) do
 echo "Running Phenoregion $((v))"
r.mask phenology_2000-2016.500.maxmode maskcats=$((v)) --o

r.regression.line map1=MODIS_CalYear_AUC_2020 map2=2020.trueS3.S3?-NT.napolygon.maxndvi.LAEA.rseriessum.45 -g >tmp
d.correlate layer1=MODIS_CalYear_AUC_2020 layer2=2020.trueS3.S3?-NT.napolygon.maxndvi.LAEA.rseriessum.45


awk 'BEGIN{FS="="} {print $2}' tmp | tr '\n' '|' >>Pheno_Regression
echo "$((v))" >>Pheno_Regression

done
fi
#############################################################
if [ $MAP_PHENO -eq 1 ]
then

awk 'BEGIN{FS="|"} {print $10":"$10":"$2":"$2}' Pheno_Regression | sed '1d' >Reclass_Pheno_slope.txt
awk 'BEGIN{FS="|"} {print $10":"$10":"$3":"$3}' Pheno_Regression | sed '1d' >Reclass_Pheno_R.txt

g.region rast=phenology_2000-2016.500.maxmode
r.mask -r

r.recode input=phenology_2000-2016.500.maxmode output=phenology_500_slope rules=Reclass_Pheno_slope.txt --o
r.recode input=phenology_2000-2016.500.maxmode output=phenology_500_R rules=Reclass_Pheno_R.txt --o

r.mapcalc "phenology_500_slope = phenology_500_slope"
r.mapcalc "phenology_500_R = phenology_500_R"

fi


#############################################################
if [ $DATA_OUT_FOR_R -eq 1 ]
then
 g.region rast=MODIS_CalYear_AUC_2020
 r.mask -r

for((v=1; v<4; v++)) do

r.stats -1gn input=MODIS_CalYear_AUC_$((2019+v)),$((2019+v)).trueS3.S3?-NT.napolygon.maxndvi.LAEA.rseriessum.45,NLCD_2019_500m,phenology_2000-2016.100.maxmode >Compare_$((2019+v))
done
fi
####d##############################################################################
if [ $RUN_GLM -eq 1 ]
then
 g.region rast=MODIS_CalYear_AUC_2020
 r.mask -r

#./Regression.R

for((v=1; v<4; v++)) do
awk 'BEGIN {FS=","} {print $2" "$3" "$9}' diff_$((2019+v)).csv | sed '1d' >temp                                                                         
r.in.xyz in=temp x=1 y=2 z=3 fs=space out=GPP_FW3_diff_$((2019+v)) --o
r.out.gdal in=GPP_FW3_diff_$((2019+v)) out=./export/GPP_FW3_diff_$((2019+v)).tif type=Float64 format=GTiff --o
done
fi
##################################################################################
if [ $RUN_GLM_PHENO -eq 1 ]
then
 g.region rast=MODIS_CalYear_AUC_2020
 r.mask -r

./Regression.R

for((v=1; v<4; v++)) do

awk 'BEGIN {FS=","} {print $2" "$3" "$9}' diff_RF_$((2019+v)).csv | sed '1d' >temp                                                                         
r.in.xyz in=temp x=1 y=2 z=3 fs=space out=GPP_FW3_diff_$((2019+v))_Pheno --o
r.out.gdal in=GPP_FW3_diff_$((2019+v))_Pheno out=./export/GPP_FW3_diff_$((2019+v))_Pheno.tif type=Float64 format=GTiff --o
done
fi

