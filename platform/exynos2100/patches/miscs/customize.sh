LOG_STEP_IN "- Disabling Vulkan"
SET_PROP "vendor" "ro.security.fips.ux" "Disabled"
SET_PROP "vendor" "ro.hwui.use_vulkan" "false"
SET_PROP "vendor" "debug.hwui.renderer" "skiagl"
SET_PROP "vendor" "debug.renderengine.backend" "skiagl"
SET_PROP "vendor" "renderthread.skia.reduceopstasksplitting" "true"
SET_PROP "vendor" "debug.hwui.skia_atrace_enabled" "false"
LOG_STEP_OUT

LOG_STEP_IN "- Normalize security/unlock
SET_PROP "system" "ro.security.fips.ux" "Disabled"
LOG_STEP_OUT

LOG_STEP_IN "- Applying 32bit
SET_PROP "vendor" "dalvik.vm.dex2oat64.enabled" "true"
LOG_STEP_OUT

LOG_STEP_IN "- Setting FUSE passthough"
SET_PROP "vendor" "persist.sys.fuse.passthrough.enable" "true"
LOG_STEP_OUT

LOG_STEP_IN "- fixing DPI"
SET_PROP "vendor" "ro.sf.init.lcd_density" "450"
LOG_STEP_OUT

LOG "- Disabling encryption"
# Encryption
LINE=$(sed -n "/^\/dev\/block\/by-name\/userdata/=" "$WORK_DIR/vendor/etc/fstab.exynos2100")
sed -i "${LINE}s/,fileencryption=aes-256-xts:aes-256-cts:v2//g" "$WORK_DIR/vendor/etc/fstab.exynos2100"

# ODE
sed -i -e "/ODE/d" -e "/keydata/d" -e "/keyrefuge/d" "$WORK_DIR/vendor/etc/fstab.exynos2100"

LOG_STEP_IN "- Setting stock Bluetooth profiles"
SET_PROP "product" "bluetooth.profile.asha.central.enabled" "true"
SET_PROP "product" "bluetooth.profile.a2dp.source.enabled" "true"
SET_PROP "product" "bluetooth.profile.avrcp.target.enabled" "true"
SET_PROP "product" "bluetooth.profile.bap.broadcast.assist.enabled" "false"
SET_PROP "product" "bluetooth.profile.bap.broadcast.source.enabled" "false"
SET_PROP "product" "bluetooth.profile.bap.unicast.client.enabled" "false"
SET_PROP "product" "bluetooth.profile.bas.client.enabled" "false"
SET_PROP "product" "bluetooth.profile.csip.set_coordinator.enabled" "false"
SET_PROP "product" "bluetooth.profile.gatt.enabled" "true"
SET_PROP "product" "bluetooth.profile.hap.client.enabled" "false"
SET_PROP "product" "bluetooth.profile.hfp.ag.enabled" "true"
SET_PROP "product" "bluetooth.profile.hid.device.enabled" "true"
SET_PROP "product" "bluetooth.profile.hid.host.enabled" "true"
SET_PROP "product" "bluetooth.profile.map.server.enabled" "true"
SET_PROP "product" "bluetooth.profile.mcp.server.enabled" "false"
SET_PROP "product" "bluetooth.profile.opp.enabled" "false"
SET_PROP "product" "bluetooth.profile.pan.nap.enabled" "true"
SET_PROP "product" "bluetooth.profile.pan.panu.enabled" "true"
SET_PROP "product" "bluetooth.profile.pbap.server.enabled" "true"
SET_PROP "product" "bluetooth.profile.sap.server.enabled" "true"
SET_PROP "product" "bluetooth.profile.ccp.server.enabled" "false"
SET_PROP "product" "bluetooth.profile.vcp.controller.enabled" "false"
LOG_STEP_OUT

LOG_STEP_IN "- Patching build.prop"

# Read current codename and model from build.prop
CURRENT_FLAVOR="$(GET_PROP "$WORK_DIR/system/system/build.prop" "ro.build.flavor")"
CURRENT_MODEL="$(GET_PROP "$WORK_DIR/system/system/build.prop" "ro.product.system.model")"

LOG "- Current flavor: $CURRENT_FLAVOR"
LOG "- Current model: $CURRENT_MODEL"

# Local variables for this patch only
PATCH_CODENAME=""
PATCH_MODELNAME=""

case "$CURRENT_FLAVOR" in
  r9sxxx*)
    PATCH_MODELNAME="SM-G990E"
    PATCH_CODENAME="r9sxxx"
    ;;
  t2sxxx*)
    PATCH_MODELNAME="SM-G996B"
    PATCH_CODENAME="t2sxxx"
    ;;
  p3sxxx*)
    PATCH_MODELNAME="SM-G998B"
    PATCH_CODENAME="p3sxxx"
    ;;
  o1sxxx*)
    PATCH_MODELNAME="SM-G991B"
    PATCH_CODENAME="o1sxxx"
    ;;
  *)
    LOG "Unknown flavor: $CURRENT_FLAVOR"
    ;;
esac

if [[ -n "$PATCH_MODELNAME" ]]; then
    SET_PROP "system" "ro.build.flavor" "$PATCH_CODENAME-user"
    SET_PROP "system" "ro.factory.model" "$PATCH_MODELNAME"
    SET_PROP "system" "ro.unica.camera" "$PATCH_CODENAME"

    # Normalize security/unlock
    SET_PROP "system" "ro.oem_unlock_supported" "0"
    SET_PROP "system" "ro.security.fips.ux" "Disabled"

    # Common additions
    SET_PROP "system" "ro.build.product" "qssi"
    SET_PROP "system" "persist.demo.hdmirotationlock" "false"
    SET_PROP "system" "dev.usbsetting.embedded" "on"
    SET_PROP "system" "log.tag.EDEN" "INFO"
    SET_PROP "system" "ro.debug_level" "0x494d"
    SET_PROP "system" "ro.vendor.cscsupported" "1"
    SET_PROP "system" "audio.offload.min.duration.secs" "30"
    SET_PROP "system" "bluetooth.device.class_of_device" "90,2,12"
    SET_PROP "system" "media.extractor.sec.dolby-lib-version" "3.13"
    SET_PROP "system" "ro.netflix.bsp_rev" "EXYNOS2400-37698-1"
    SET_PROP "system" "wlan.wfd.hdcp" "disable"
    SET_PROP "system" "fw.max_users" "8"
    SET_PROP "system" "fw.show_multiuserui" "1"
    SET_PROP "system" "persist.device_config.activity_manager_native_boot.use_freezer" "true"
fi

LOG "- Removing unwanted properties from build.prop"

sed -i -e '/^rild\.libpath=/d' \
       -e '/^#rild\.libargs=/d' \
       -e '/^persist\.rild\.nitz_plmn=/d' \
       -e '/^persist\.rild\.nitz_long_ons_[0-3]=/d' \
       -e '/^persist\.rild\.nitz_short_ons_[0-3]=/d' \
       -e '/^ril\.subscription\.types=/d' \
       -e '/^#ro\.telephony\.default_network=/d' \
       -e '/^dalvik\.vm\.heapsize=/d' \
       -e '/^dalvik\.vm\.dex2oat64\.enabled=/d' \
       -e '/^dev\.pm\.dyn_samplingrate=/d' \
       -e '/^#ro\.hdmi\.enable=/d' \
       -e '/^#persist\.speaker\.prot\.enable=/d' \
       -e '/^qcom\.hw\.aac\.encoder=/d' \
       -e '/^persist\.vendor\.cne\.feature=/d' \
       -e '/^media\.stagefright\./d' \
       -e '/^mmp\.enable\.3g2=/d' \
       -e '/^media\.aac_51_output_enabled=/d' \
       -e '/^#media\.settings\.xml=/d' \
       -e '/^vendor\.mm\.enable\.qcom_parser=/d' \
       -e '/^persist\.mm\.enable\.prefetch=/d' \
       -e '/^ro\.vendor\.use_data_netmgrd=/d' \
       -e '/^persist\.vendor\.data\.mode=/d' \
       -e '/^persist\.timed\.enable=/d' \
       -e '/^ro\.opengles\.version=/d' \
       -e '/^telephony\.lteOnCdmaDevice=/d' \
       -e '/^persist\.fuse_sdcard=/d' \
       -e '/^ro\.bluetooth\.library_name=/d' \
       -e '/^persist\.vendor\.btstack\.aac_frm_ctl\.enabled=/d' \
       -e '/^persist\.rmnet\.data\.enable=/d' \
       -e '/^persist\.data\./d' \
       -e '/^persist\.debug\.wfd\.enable=/d' \
       -e '/^persist\.sys\.wfd\.virtual=/d' \
       -e '/^debug\.sf\./d' \
       -e '/^tunnel\.audio\.encode=/d' \
       -e '/^use\.voice\.path\.for\.pcm\.voip=/d' \
       -e '/^ro\.nfc\.port=/d' \
       -e '/^sys\.qca1530=/d' \
       -e '/^persist\.debug\.coresight\.config=/d' \
       -e '/^ro\.hwui\./d' \
       -e '/^debug\.hwui\.skia_atrace_enabled=/d' \
       -e '/^config\.disable_rtt=/d' \
       -e '/^persist\.sys\.force_sw_gles=/d' \
       -e '/^persist\.vendor\.radio\.atfwd\.start=/d' \
       -e '/^ro\.kernel\.qemu\.gles=/d' \
       -e '/^qemu\.hw\.mainkeys=/d' \
       -e '/^vendor\.camera\.aux\.packagelist=/d' \
       -e '/^persist\.vendor\.camera\.privapp\.list=/d' \
       -e '/^persist\.vendor\.overlay\.izat\.optin=/d' \
       -e '/^persist\.backup\.ntpServer=/d' \
       -e '/^ro\.product\.property_source_order=/d' \
       -e '/^debug\.stagefright\.ccodec=/d' \
       -e '/^ro\.media\.recorder-max-base-layer-fps=/d' \
       -e '/^ro\.charger\.enable_suspend=/d' \
       -e '/^arm64\.memtag\.process\.system_server=/d' \
       -e '/^ro\.launcher\.blur\.appLaunch=/d' \
       -e '/^ro\.bluetooth\.finder\.supported=/d' \
       -e '/^ro\.vendor\.qti\.va_aosp\.support=/d' \
       "$WORK_DIR/system/system/build.prop"
LOG_STEP_OUT

LOG_STEP_IN "- Applying omx,bpf,ril and wkprovhal-patches"

# Ensure OMX seccomp policy gets the fix
OMX_POLICY="$WORK_DIR/vendor/etc/seccomp_policy/samsung.software.media.c2-base-policy"
if [ -f "$OMX_POLICY" ]; then
    LOG "- Updating mremap rule in $OMX_POLICY"
    # Replace the existing line if present
    sed -i 's/^mremap: arg3 == 3$/mremap: arg3 == 3 || arg3 == MREMAP_MAYMOVE/' "$OMX_POLICY"

    # If the line wasn't found, append it
    if ! grep -q "mremap: arg3 == 3 || arg3 == MREMAP_MAYMOVE" "$OMX_POLICY"; then
        echo "mremap: arg3 == 3 || arg3 == MREMAP_MAYMOVE" >> "$OMX_POLICY"
    fi
fi

# Apply genconfsrulesfix to platsepolicy.cil
PLAT_SEPOLICY="$WORK_DIR/system/etc/selinux/platsepolicy.cil"
if [ -f "$PLAT_SEPOLICY" ]; then
    echo "Appending genconfsrulesfix to $PLAT_SEPOLICY"
    cat <<'EOF' >> "$PLAT_SEPOLICY"
(genfscon bpf "/cputimeinstate" (u object_r fs_bpf_cputimeinstate ((s0) (s0))))
(genfscon proc "/sys/vm/dirty_writeback_centisecs" (u object_r proc_dirty ((s0) (s0))))
(genfscon proc "/sys/kernel/firmware_config" (u object_r proc_firmware_config ((s0) (s0))))
(genfscon sysfs "/devices/virtual/misc/ublk-control/" (u object_r sysfs_ublk ((s0) (s0))))
(genfscon sysfs "/devices/virtual/block/ublk" (u object_r sysfs_ublk ((s0) (s0))))
(genfscon sysfs "/class/ublk-char/" (u object_r sysfs_ublk ((s0) (s0))))
(genfscon sysfs "/kernel/btf" (u object_r sysfs_btf ((s0) (s0))))
(genfscon tracefs "/events/f2fs/f2fs_set_page_dirty/" (u object_r debugfs_tracing ((s0) (s0))))
(genfscon tracefs "/hypervisor" (u object_r debugfs_tracing ((s0) (s0))))
EOF
fi

# Remove unwanted property context
VENDOR_PROP_CTX="$WORK_DIR/vendor/etc/selinux/vendor_property_contexts"
if [ -f "$VENDOR_PROP_CTX" ]; then
    echo "Removing init.svc.vendor.wvkprov_server_hal from $VENDOR_PROP_CTX"
    sed -i '/init\.svc\.vendor\.wvkprov_server_hal/d' "$VENDOR_PROP_CTX"
fi

ADD_TO_WORK_DIR "r11sxxx" "system" "system/apex/com.google.android.tethering_compressed.apex" 0 0 644 "u:object_r:system_file:s0"
LOG_STEP_OUT



