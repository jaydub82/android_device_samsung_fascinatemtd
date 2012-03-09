#!/bin/sh

# Copyright (C) 2010 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

DEVICE=fascinatemtd
COMMON=aries-common
MANUFACTURER=samsung
EXT_F=EXTRACT_ROM_FILES

prop_list="system/lib/libril.so \
system/lib/libsecril-client.so \
system/lib/libsec-ril40.so \
system/bin/rild \
system/lib/hw/gps.aries.so \
system/vendor/bin/gpsd \
system/vendor/etc/gps.xml \
system/etc/gps.conf \
system/lib/libsamsungcamera.so \
system/vendor/lib/libsensorservice.so \
system/vendor/lib/libsensor_yamaha_test.so \
system/vendor/bin/geomagneticd \
system/vendor/bin/orientationd \
system/lib/hw/sensors.default.so \
system/bin/pppd_runner"

prop_com_list="system/vendor/bin/pvrsrvinit \
system/vendor/firmware/bcm4329.hcd \
system/vendor/firmware/nvram_net.txt \
system/vendor/firmware/cypress-touchkey.bin \
system/vendor/firmware/samsung_mfc_fw.bin \
system/lib/egl/libGLES_android.so \
system/vendor/lib/egl/libEGL_POWERVR_SGX540_120.so \
system/vendor/lib/egl/libGLESv1_CM_POWERVR_SGX540_120.so \
system/vendor/lib/egl/libGLESv2_POWERVR_SGX540_120.so \
system/vendor/lib/hw/gralloc.aries.so \
system/vendor/lib/libakm.so \
system/vendor/lib/libglslcompiler.so \
system/vendor/lib/libIMGegl.so \
system/vendor/lib/libpvr2d.so \
system/vendor/lib/libpvrANDROID_WSEGL.so \
system/vendor/lib/libPVRScopeServices.so \
system/vendor/lib/libsrv_init.so \
system/vendor/lib/libsrv_um.so \
system/vendor/firmware/CE147F02.bin \
system/vendor/lib/libusc.so \
system/lib/libActionShot.so \
system/lib/libarccamera.so \
system/lib/libcamera_client.so \
system/lib/libcamerafirmwarejni.so \
system/lib/libCaMotion.so \
system/lib/libcaps.so \
system/lib/libPanoraMax1.so \
system/lib/libPlusMe.so \
system/lib/libs3cjpeg.so \
system/lib/libseccamera.so \
system/lib/libseccameraadaptor.so \
system/lib/libsecjpegencoder.so \
system/lib/libtvout.so \
system/lib/lib_tvoutengine.so \
system/lib/libtvoutfimc.so \
system/lib/libtvouthdmi.so \
system/lib/libtvoutservice.so \
system/bin/tvoutserver \
system/cameradata/datapattern_420sp.yuv \
system/cameradata/datapattern_front_420sp.yuv \
system/firmware/CE147F00.bin \
system/firmware/CE147F01.bin \
system/firmware/CE147F02.bin \
system/firmware/CE147F03.bin \
system/bin/charging_mode \
system/bin/playlpm \
system/lib/libQmageDecoder.so \
system/media/battery_charging_10.qmg \
system/media/battery_charging_100.qmg \
system/media/battery_charging_15.qmg \
system/media/battery_charging_20.qmg \
system/media/battery_charging_25.qmg \
system/media/battery_charging_30.qmg \
system/media/battery_charging_35.qmg \
system/media/battery_charging_40.qmg \
system/media/battery_charging_45.qmg \
system/media/battery_charging_5.qmg \
system/media/battery_charging_50.qmg \
system/media/battery_charging_55.qmg \
system/media/battery_charging_60.qmg \
system/media/battery_charging_65.qmg \
system/media/battery_charging_70.qmg \
system/media/battery_charging_75.qmg \
system/media/battery_charging_80.qmg \
system/media/battery_charging_85.qmg \
system/media/battery_charging_90.qmg \
system/media/battery_charging_95.qmg \
system/media/chargingwarning.qmg \
system/media/Disconnected.qmg"

prop_apk_list="system/app/PhoneConfig.apk \
system/app/ProgramMenu.apk \
system/app/ProgramMenuSystem.apk"

chmod_list=""

pull_adb_files() {
for x in ${prop_list} ${prop_apk_list}; do
        echo "Pulling ${x} from adb connection now..."
        adb pull /${x} ../../../vendor/$MANUFACTURER/$DEVICE/proprietary/
done

cchm=$(echo ${chmod_list} |wc -w)
if [ ${cchm} -gt 0 ]; then
for x in ${chmod_list}; do
        s=$(echo "$x" |awk -F/ '{print $NF}')
        echo "Fixing permissions for ${x} from now..."
        chmod 755 ../../../vendor/$MANUFACTURER/$DEVICE/proprietary/${s}
done
fi
}

pull_zip_files() {
if [ -d ${EXT_F} ]; then
        rm -rf ${EXT_F}
fi
unzip ${ZIP} -d ${EXT_F}

for x in ${prop_list} ${prop_apk_list}; do
        echo "Copying ${x} from ${ZIP} now..."
        cp ${EXT_F}/${x} ../../../vendor/$MANUFACTURER/$DEVICE/proprietary/
done

for x in $${prop_com_list}; do
        echo "Copying ${x} from ${ZIP} now..."
        cp ${EXT_F}/${x} ../../../vendor/$MANUFACTURER/$COMMON/proprietary/
done

cchm=$(echo ${chmod_list} |wc -w)
if [ ${cchm} -gt 0 ]; then
for x in ${chmod_list}; do
        s=$(echo "$x" |awk -F/ '{print $NF}')
        echo "Fixing permissions for ${s} from now..."
        chmod 755 ../../../vendor/$MANUFACTURER/$DEVICE/proprietary/${s}
done
fi
}

mkdir -p ../../../vendor/$MANUFACTURER/$DEVICE/proprietary
touch ../../../vendor/$MANUFACTURER/$DEVICE/proprietary/modem.bin
mkdir -p ../../../vendor/$MANUFACTURER/$COMMON/proprietary

if [ $# -eq  0 ]; then
        pull_adb_files
elif [ $# -eq 1 ]; then
        ZIP="${1}"
        pull_zip_files
else
        echo "Error: Too many arguments. Wanted 1 got $#"
        exit 1
fi

(cat << EOF) | sed s/__DEVICE__/$DEVICE/g | sed s/__MANUFACTURER__/$MANUFACTURER/g > ../../../vendor/$MANUFACTURER/$DEVICE/$DEVICE-vendor-blobs.mk
# Copyright (C) 2010 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Prebuilt libraries that are needed to build open-source libraries
PRODUCT_COPY_FILES := \\
EOF
chk_count=$(echo ${prop_list} |wc -w)
COUNT=0
for x in ${prop_list}; do
        COUNT=`expr ${COUNT} + 1`
        s=$(echo "$x" |awk -F/ '{print $NF}')
        if [ ${COUNT} -eq ${chk_count} ]; then
                echo "    vendor/$MANUFACTURER/$DEVICE/proprietary/${s}:${x}" >> ../../../vendor/$MANUFACTURER/$DEVICE/$DEVICE-vendor-blobs.mk
        else
                echo "    vendor/$MANUFACTURER/$DEVICE/proprietary/${s}:${x} \\" >> ../../../vendor/$MANUFACTURER/$DEVICE/$DEVICE-vendor-blobs.mk
        fi
done

(cat << EOF) | sed s/__COMMON__/$COMMON/g | sed s/__MANUFACTURER__/$MANUFACTURER/g > ../../../vendor/$MANUFACTURER/$COMMON/aries-vendor-blobs.mk
# Copyright (C) 2010 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# All the blobs necessary for galaxys devices
PRODUCT_COPY_FILES += \\
EOF
chk_count=$(echo ${prop_com_list} |wc -w)
COUNT=0
for x in ${prop_com_list}; do
        COUNT=`expr ${COUNT} + 1`
        s=$(echo "$x" |awk -F/ '{print $NF}')
        if [ ${COUNT} -eq ${chk_count} ]; then
                echo "    vendor/$MANUFACTURER/$DEVICE/proprietary/${s}:${x}" >> ../../../vendor/$MANUFACTURER/$COMMON/aries-vendor-blobs.mk
        else
                echo "    vendor/$MANUFACTURER/$DEVICE/proprietary/${s}:${x} \\" >> ../../../vendor/$MANUFACTURER/$COMMON/aries-vendor-blobs.mk
        fi
done

./setup-makefiles.sh
