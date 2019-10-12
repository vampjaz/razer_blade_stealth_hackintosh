Razer Blade Stealth (2018) hackintosh
===

![about this mac image](https://github.com/red-green/razer_blade_stealth_hackintosh/raw/master/images/about.png)

Intro
---

Hey there, I got several requests to release my EFI and show how I made my Razer Bade Stealth Mojave hackintosh, so here it is. This is not a full step-by-step guide, rather a few specific notes (and a full EFI folder) to compliment a full guide like [Corp's](https://hackintosh.gitbook.io/-r-hackintosh-vanilla-desktop-guide/) or [RehabMan's](https://www.tonymacx86.com/threads/guide-booting-the-os-x-installer-on-laptops-with-clover.148093/). This install aims to be as vanilla as possible, so no modifications should be needed to the actual mac operating system files. The only system files I modified were the asset files needed to change the About This Mac display, and the screen resoltion overrides to allow me to run the internal display at 5K HiDPI.

Also, I have tried out the macOS Catalina release and most things work, sleep is buggy though. At least sidecar seems to work fine now on the release.

**Disclaimer:** I am not responsible if you mess up your computer with this setup. I recommend reading everything so you know what you're getting yourself into.

**I do not recommend using the OpenCore EFI!** It's not maintained as often (I made it as an experiement), and causes instability with the trackpad drivers. It's meant for learning.

Here is the hardware specification of my Blade as I bought it:

__**Razer Blade Stealth 2018**__
- **CPU** : Intel Core i7-8550U 4C8T 1.8GHz (4.0GHz turbo)
- **RAM** : 16GB dual-channel LPDDR3-2133
- **GPU** : Intel UHD 620
- **Storage** : Samsung PM981 512GB NVMe M.2
- **Screen** : 13.3" 3200x1800 with touch
- **WiFi** : Killer AC1535
- **Thunderbolt** : Intel Alpine Ridge JHL6340
- **Soundcard** : Realtek ALC298
- **Battery** : 53.6 Wh

However I replaced the SSD with an Samsung 970 EVO and the wifi card with a Lenovo 04X6020.

Hardware compatibility
---

TL;DR - 

**What works:**

- CPU power management
- Readng CPU temperature
- GPU acceleration and video codecs
- SSD with full speed **[after being replaced]**
- Wireless (wifi, bt, Continuity, Airdrop) **[after being replaced]**
- Sleep, lid sleep and lid wake
- Trackpad including gestures
- Touchscreen, also with gestures
- Sound through headphone jack and speakers (including persistence through sleep)
- Internal microphone
- All USB ports except the USB-C
- Screen full resolution, brightness
- HDMI (some graphical glitches at certain resolutions, but they come and go)
- Battery precentage, charging
- Changing the keyboard color through some custom apps, also enabling the logo light
- Internal webcam with Facetime
- Virtualization (VT-x)
- SideCar over USB and wireless (in Catalina)
- iMessage and iCloud (YMMV)

**What does not work:**

- Thunderbolt 3 
- USB-C functionality on the TB3 port (it can be enabled but it breaks other things)
- Apple Watch Unlock - something with the third party wifi card causes failure
- Booting with OpenCore - there are stability issues

**Not tested:**

- Displayport output on the TB3 port
- Shaving with it

Much more detailed notes to follow...

CPU
-----

The [i7-8550U](https://ark.intel.com/products/122589/Intel-Core-i7-8550U-Processor-8M-Cache-up-to-4-00-GHz-) worked pretty well out of the box. I needed to add CPUFriend and a data SSDT (see SSDT-CPUF) to get it to idle below 1.20GHz (it goes down to about 0.80 now), but other than that, power management seems fine and it has plenty of power. I haven't seen it turbo up all the way (usually tops out at about 3.7GHz, although that might be a misconfigured CPUFriend vector or a power limit issue). The SMCProcessor sensors kext worked out of the box for seeing CPU temperature.

![screenshot of CPU temp and wattage in HWMonitor](https://github.com/red-green/razer_blade_stealth_hackintosh/raw/master/images/hwmon_info.png)

GPU
-----

All I needed to do is inject a `device-id` in the GPU properties section and use `lilucpu=9` as a boot arg to get full acceleration, including video decode. I can run it at the full 3200x1800 resolution (or 1600x900 HiDPI mode) and get acceleration, but it will occasionally flicker at that resolution. I don't use that however, I simply run at 2560x1440 using [RDM](https://github.com/usr-sse2/RDM) which is about 125% scaling, giving me the amount of screen space I want. There is no flickering at this resolution. I even get full resolution in Clover, so the theme looks very sharp. I changed the unifiedmem on the gpu to allocate 2GB to it.

A note about the flickering issue: lately I have noticed that on boot it will flicker at a high resolution but if I sleep and wake, it goes away. If you experience flickering on this laptop and have working sleep, try sleeping for a minute and waking back up. Have been running 5120x2880 HiDPI just fine.

![system profiler gpu screenshot](https://github.com/red-green/razer_blade_stealth_hackintosh/raw/master/images/gpu_info.png)

SSD
-----

**Here is where you may run into issues.** My model (bought in November 2018) came with a Samsung PM981 SSD. ***This drive will not work in macOS.*** Older models of the computer may come with a Samsung PM961, which seems to work fine. You will need to replace the SSD with a compatible one in order to install. This is a known issue and I have not seen any solution.

Be careful about what you replace it with though. If there are components on the back of the PCB, there may not be enough clearance. I replaced mine with a Samsung 970 EVO, which has all the components on the front of the board, and a compatible controller. 960 series should also work.

![970 EVO benchmark](https://github.com/red-green/razer_blade_stealth_hackintosh/raw/master/images/nvme_bench.png)

Wifi and Bluetooth
-----

The included Killer AC1535 wifi/BT card will also not work in macOS as it lacks drivers. **You will need to replace it if you want wifi**, or else get a USB dongle (not recommended). There are a number of compatible cards that can fit into the M.2 E-key slot. A Dell DW1560 or a Lenovo 04X6020 card will fit there fine. Be careful of wider cards like the Dell DW1860, they will not fit. 

Both of the cards I mentioned (I got the 04X6020) use a Broadcom BCM94352Z, which works for me using AirportBrcmFixup and BrcmBluetoothInjector+BrcmPatchRam2 for Wifi and Bluetooth respectively. I have used Airdrop fine with this card, and continuity seems to work too. Note: the included BrcmPatchRam2 is from headkaze's fork for Catalina compatibility. I've heard reports that the DW1820a does not work well, despite being a chipset that is supposedly compatible.

![bluetooth and wifi status from sys profiler](https://github.com/red-green/razer_blade_stealth_hackintosh/raw/master/images/bt_wifi_info.png)

Sleep
-----

Without any patching, sleep works for the most part. You can trigger sleep by shutting the lid and wake it by opening the lid, much like a real mac. However, due to some EC issue, the lid is reported as closed after the computer wakes up. This causes it to go back to sleep about 10 seconds after it wakes up, making the computer almost unusable. Additionally, since the computer thinks the lid is closed, it'll keep the backlight off. This can be partially remedied by removing the PNLF SSDT. 

I had some issues with USB devices causing instant wake, I patched GPRW calls (see the two patches in the DSDT Patches section of the plist) to prevent this from happening, although that prevents some USB devices from waking the computer for example when you tap the keyboard to wake. Additionally, I had to disable network wake in Energy Saver and bluetooth wake in the advanced section of bluetooth preferences. I'm still tracking down a few rare random wakes. The SSDT-DLAN adds a status method to the GLAN device to disable it as that was referenced a couple times in the wake reason.

With the last DSDT patch in the config.plist, I force the lid status to "open" right as the computer wakes up. This means it won't go back to sleep and also the screen is not black after waking. I can keep brightness control and also have proper sleep/wake. I'm quite happy to have finally fixed this issue.

If you're interested in how this is done, I tried many different manual DSDT edits until I got the behavior I wanted. This only requires one small change near the end of the `RWAK` function, which is called whever the computer wakes up. The offending code is this:

```
Store (\_SB.PCI0.LPCB.EC0.PSTA, Local0)
And (Local0, 0x04, Local0)
ShiftRight (Local0, 0x02, Local0)
Store (Local0, LIDS)
Notify (\_SB.PCI0.LPCB.EC0.LID0, 0x80)
```

`PSTA` is a register within the `EC`'s OperatingRegion that has one bit that exposes the physical status of the `LID0` device to the ACPI. This code copies that register and extracts bit 3 and stores it in the global variable `LIDS` (lid status), with a 0 for closed an a 1 for open. It then Notifies the `LID0` device causing the OS to check for the new value. The problem with this is that somehow it was returning 0 after every wake, causing the computer to want to go back to sleep.

In order to have a clean patch and not have a modified DSDT injected via clover (a messy solution at best), I needed to rewrite this code to set `LIDS` to 1 *before* the Notify is called. Additionally, for OpenCore to be able to patch this, the find and replace patches need to be the same length. This means I need to have the same length of ACPI machine instructions. As it turns out, this is not hard. I simply leave the first three lines as they are, and then instead of Storing the Local0 value they calculated, I just store the ACPI constant One. The fourth line now looks like this:

```
Store (One, LIDS)
```

This patch works great in DSDT form and it also retains the exact same length so both Clover and OpenCore can patch it on the fly. I do need to be careful however, as simply patching the Store instruction messes up other things. In the EC0 device, there are two EC query methods that execute some similar code to the original block. The difference is that because the queries are within the scope of the EC, they have a different Notify instruction. My patch had to include the first part of the Notify instruction to differentiate it fron the other two. It turns out that patching the other two breaks lid wake and sleep, which I did not want to do.

Be aware that if you use TbtForcePower (not included, discussed in the Thunderbolt section) with your thunderbolt port enabled in the UEFI, it will likely break sleep due to USB errors. Also I have heard from some Stealth owners that their DSDT does not reference `LIDS` anywhere in `RWAK`. This means the sleep fix may not work for everyone.

Per another person with a Stealth, their DSDT did not contain the relevant lid code in RWAK so my patch did not work. However, they manually edited their DSDT to add the line setting `LIDS` to One at the end of the `RWAK` method and it fixed their sleep issue, so look in your DSDT to see if this is the case.

![diffmerge of the dsdt sleep patch](https://github.com/red-green/razer_blade_stealth_hackintosh/raw/master/images/dsdt_edit_sleep.png)

Trackpad
-----

It's a Synaptics 1A586757 multitouch I2C trackpad, so I simply used VoodooI2C plus VoodooI2CHID with an SSDT-XOSI to enable the I2C controller. All the native multitouch gestures work great, even three finger click-and-drag. Its not quite as sensitive as my MBP trackpad, but its better than I expected on a hackintosh. Right click is a little finnicky if you don't tap with two fingers. I'm also using an old version of Voodoo as the newest one has some bugs with click and drag on this trackpad. However, I have heard that others with this laptop have been able to use the latest VoodooI2C just fine with properly working right click.

Note about VoodooI2C: a common issue I've heard from other users is the kext simply not loading even with the proper DSDT patches. While unconventional, it seems that rebuilding the kext cache (even if you do not install any third part kexts in there) actually fixes this and allows voodoo to load. 

Touchscreen
-----

The USB touchscreen worked fine out of the box for basic pointing. Additionally, when I installed the VoodooI2C drivers, I also started to get multitouch support on the touchscreen. It acts similar to the trackpad gestures, being able to switch desktops (4 finger drag) and scroll (2 finger drag). It's surprisingly useful in macOS, despite the OS not being designed for touch.

Sound
-----

The soundcard, according to the PCI ID, seems to be a Realtek ALC298. This is supported by [AppleALC](https://github.com/acidanthera/AppleALC/wiki/Supported-codecs) with layout ID 29, which I patched in through device properties. Both the internal speakers and headphone jack work, and switching between them is automatic. Microphone also seems to work, unlike some other laptops I've heard about.

CodecCommander is included, and the SSDT-CDEC contains a config for my ALC298 to fix distorted audio after sleep. I found this [config](https://bitbucket.org/RehabMan/os-x-eapd-codec-commander/src/master/SSDT-ALC298.dsl) in Rehabman's repo, which is equivalent to running the following on wake:

```
hda-verb 0x18 SET_PIN_WIDGET_CONTROL 0x22
hda-verb 0x1a SET_PIN_WIDGET_CONTROL 0x23
hda-verb 0x21 SET_UNSOLICITED_ENABLE 0x83
```

USB
-----

Using just USBInjectAll, I had full USB capabilities out of the box on the USB 3 ports. I did decide to map the ports anyway with an SSDT-UIAC to hide the webcam and some unused ports. Delete this file if you have issues with USB or want to be able to use your webcam. As for the USB C port, it's on a different controller which is only active when Thunderbolt is enabled and force-powered on (see the Thunderbolt section). This causes sleep issues an USB driver crashes, so I would not recommend it. Additionally, USB-C stops working after I sleep.

I used the [USBMap](https://github.com/corpnewt/USBMap) script to create the UIAC and USBX SSDTs. You may need to run it yourself to properly map USB ports if they end up being different on your system.

![the USB ports i mapped](https://github.com/red-green/razer_blade_stealth_hackintosh/raw/master/images/usbmap_info.png)

Display Outs
-----

The laptop has an HDMI port and a DisplayPort-over-Thunderbolt 3 as display outputs. I don't have any TB3-DP converters to test that output, but I have gotten HDMI working. Like the internal display, it sometimes flickers at high resolutions and doesn't seem to support 4K60 but it works alright for now.

![displays in system profiler and ioreg](https://github.com/red-green/razer_blade_stealth_hackintosh/raw/master/images/display_info.png)

Thunderbolt
-----

I have been beta testing al3x's [TbtForcePower.efi](https://github.com/al3xtjames/ThunderboltPkg) to enable the thunderbolt controller in macOS. Having the TB controller enabled is required to use USB-C devices in that port as well, since the TB port has its own USB controller. I do not have any TB3 devices that I can test with, but I do have some USB-C devices and it's somewhat usable. See the USB section for USB-C results. This file is not included because it interferes with sleep.

**Note:** in my experience, with Thunderbolt enabled in the UEFI, some Clover vector themes, like Clovy, seem to run out of memory and hang Clover. If you get stuck on `scan entries`, either use a legacy theme (like the Mojave4k one included in this repo) or disable Thunderbolt in the firmware.

Battery
-----

Using a DSDT patch in the MaciASL patch repo named "bat - Razer Blade (2014)", and SMCBatteryManager, I was able to get battery status and precentage working. I incorporated the patched methods into an SSDT hotpatch (see SSDT-BATT). The power management works well and the battery lasts a while. I'm not sure if this is normal for hackintoshes but my battery cycle count has always showed 0.

![battery info](https://github.com/red-green/razer_blade_stealth_hackintosh/raw/master/images/battery_info.png)

Keyboard Illumination
-----

The RGB keyboard (and logo illumination) cannot be easily controlled from macOS that I know of. The Razer Synapse software for Mac doesn't support this device, and various attempts to hotpatch the Razer kexts failed for me. However, I found a [project](https://github.com/kprinssu/osx-razer-blade) that I patched and was able to use to set a few patterns. The `rz_*` apps in the extra folder are some hardcoded examples that can set the keyboard lights to different colors, and enable the Razer logo illumination. Some day I might improve on that app to make it more user friendly.

If you want to patch this yourself, you need to change the vendor and device IDs in one of the source files since the USB ID of my keyboard differed from the one in the source:

![changing the usb ids in xcode](https://github.com/red-green/razer_blade_stealth_hackintosh/raw/master/images/rbs_led_code.png)

UEFI Firmware
-----

In the UEFI firmware, I needed to disable these options to get a usable system:

- Thunderbolt support (fully disabled)
- Security device support
- Network stack
- Secure boot
- Fast boot
- Launch CSM

Thuderbolt can be turned on but it causes a number of issues and doesn't seem to work in macOS anyway (as reported by someone who tried a TB device on this computer).

Stuff in this repo
---

The `EFI` folder should be a minimal but complete EFI partition with Clover and all my kexts, config, and ACPI patches. On another Blade Stealth, you *may* be able to drop this in and get a working system, though that is not guaranteed and I don't provide support for it. You should be able to take ideas from the configuration for your own build. If you use the config.plist, you will want to change your serial number, board serial, and UUIDs (can be done with [this tool](https://github.com/corpnewt/GenSMBIOS)). (Also for those paying attention, the serials in the config are randomly generated and not the ones I use on my actual laptop.)

The `EFI_OpenCore` folder is an experimental OpenCore configuration for the Stealth, based mostly on the Clover setup. Beware that OpenCore is much less user friendly and can cause issues with dual boots and Apple accounts. Use at your own risk. It may also be out of date with the config of the Clover version, as I am not ready to switch over to it on my laptop. (OpenCore causes VoodooI2C to crash randomly)

The `SSDTs` folder has the uncompiled versions of the SSDTs that I had to create for various hotpatches.

The `extra` folder contains the command-line apps I compiled to be able to change the keyboard color. See "keyboard illumination" above.

The `images` folder has, among other things, the desktop I edited based on the [default Razer desktop](http://assets.razerzone.com/eedownloads/desktop-wallpapers/Wave-3200x1800.png) with an Apple logo. I also added the image I used to replace the system logo in About This Mac (using [this guide](https://github.com/Haru-tan/Hackintosh-Things/blob/master/AboutThisMacMojave.md)). Also, a number of screenshots found in this readme.

Conclusion?
---

Its a pretty good laptop, one might almost mistake it for a dark Macbook. I'm quite satisfied with it. If you want help you can probably find me on the Hackintosh discord: https://discord.gg/uvWNGKV - `@Jazzy#5637`. 