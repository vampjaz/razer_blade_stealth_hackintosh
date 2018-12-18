Razer Blade Stealth (2018) hackintosh
===

![about this mac image](https://github.com/red-green/razer_blade_stealth_hackintosh/raw/master/images/about.png)

Intro
----

Hey there, I got several requests to release my ESP and show how I made my Razer Bade Stealth Mojave hackintosh, so here it is. This is not a full step-by-step guide, rather a few specific notes (and a full EFI folder) to compliment a full guide like [Corp's](https://hackintosh.gitbook.io/-r-hackintosh-vanilla-desktop-guide/) or [RehabMan's](https://www.tonymacx86.com/threads/guide-booting-the-os-x-installer-on-laptops-with-clover.148093/). This install aims to be as vanilla as possible, so no modifications should be needed to the actual macOS operating system files.

**Disclaimer:** I am not responsible if you mess up your computer with this guide.

Here is the hardware specification of my Blade as I bought it:

__**Razer Blade Stealth 2018**__
- **CPU** : Intel Core i7-8550U 4C8T 1.8GHz (4.0GHz turbo)
- **RAM** : 16GB dual-channel LPDDR3-2133
- **GPU** : Intel UHD 620
- **Storage** : Samsung PM981 512GB NVMe M.2
- **Screen** : 13.3" 3200x1800 with touch
- **WiFi** : Killer AC1535
- **Soundcard** : Realtek ALC298
- **Battery** : 53.6 Wh

Hardware compatibility
----

If you're familiar with hackintosh hardware compatibility, you will notice there are a few issues there. Lets look at the hardware compatibility that I've so far gotten to work:

CPU
-----

The [8550U](https://ark.intel.com/products/122589/Intel-Core-i7-8550U-Processor-8M-Cache-up-to-4-00-GHz-) worked pretty well out of the box. I needed to add CPUFriend and a data SSDT (see SSDT-CPUF) to get it to idle below 1.20GHz (it goes down to about 0.80 now), but other than that, power management seems fine and it has plenty of power. I haven't seen it turbo up all the way, but I think thats a power limit issue. The SMCProcessor sensors kext worked out of the box for seeing CPU temperature.

GPU
----

After realizing I needed a specific old version of Lilu (1.2.7), all I needed to do is inject a `device-id` in the GPU properties section to get full acceleration, including video decode. It does have a few framebuffer issues however, which caused problems elsewhere. I can run it at the full 3200x1800 resolution (or 1600x900 HiDPI mode) and get acceleration, but it seems to flicker at that resolution. I don't use that however, I simply run at 2048x1152 which is about 150% scaling, giving me the amount of screen space I want. There is no flickering at this resolution. I even get full resolution in Clover, so the Clovy theme looks very sharp.

SSD
----

**Here is where you may run into issues.** My model (bought in November 2018) came with a Samsung PM981 SSD. ***This drive will not work in macOS.*** Older models of the computer may come with a Samsung PM961, which seems to work fine. You will need to replace the SSD with a compatible one in order to install. This is a known issue and I have not seen any solution.

Be careful about what you replace it with though. If there are components on the back of the PCB, there may not be enough clearance. I replaced mine with a Samsung 970 EVO, which has all the components on the front of the board, and a compatible controller. 960 series should also work.

Wifi
----

The included Killer AC1535 wifi/BT card will also not work in macOS as it lacks drivers. **You will need to replace it if you want wifi**, or else get a USB dongle. There are a number of compatible cards that can fit into the M.2 E-key slot. A Dell DW1560 or a Lenovo 04X6020 card will fit there fine. Be careful of wider cards like the Dell DW1860, they will not fit. 

Both of the cards I mentioned (I got the 04X6020) use a Broadcom BCM94352Z, which works for me using AirportBrcmFixup and BrcmBluetoothInjector for Wifi and Bluetooth respectively. I have used Airdrop fine with this card, and continuity seems to work too.

Sleep
----

I still don't have sleep working fully on this machine. So far, I have lid sleep and wake working fine, and USB PRW has been patched (see SSDT-GPRW) so that it won't wake instantly after sleep. However, although it can sleep and wake fine, the screen stays black after wake. I'm fairly sure this is an issue caused by the framebuffer crashing, but I have not had any success patching it (because I don't know how).

Trackpad
----

Its a multitouch I2C trackpad, so I simply used VoodooI2C plus VoodooI2CHID with an SSDT-XOSI to enable the I2C controller. All the native multitouch gestures work great, even three finger click-and-drag. Its not quite as sensitive as my MBP trackpad, but its better than I expected on a hackintosh. Right click is a little finnicky if you don't tap with two fingers.

Touchscreen
----

The touchscreen worked fine out of the box for basic pointing. Additionally, when I installed the VoodooI2C drivers, I also started to get multitouch support on the touchscreen. It acts similar to the trackpad gestures, being able to switch desktops (4 finger drag) and scroll (2 finger drag).

Sound
----

The soundcard, according to the PCI ID, seems to be a Realtek ALC298. This is supported by AppleALC with layout ID 29, which I patched in through device properties. Both the internal speakers and headphone jack work, and switching between them is automatic.

USB
----

Using just USBInjectAll and XHCI-unsupported, I had full USB capabilities out of the box on the USB 3 ports. I did decide to map the ports anyway with an SSDT-UIAC to hide the webcam and some unused ports. Delete this file if you have issues with USB. I do not own any USB-C devices to test the USB 3.1 port with.

I used the [USBMap](https://github.com/corpnewt/USBMap) script to create the UIAC and USBX SSDTs. You may need to run it yourself to properly map USB ports if they end up being different on your system.

Display Outs
----

The laptop has an HDMI port and a DisplayPort-over-Thunderbolt 3 as display outputs. I don't have any TB3-DP converters to test that output, but the HDMI out doesn't really work. Plugging anything into it seems to crash the framebuffer, as I lose all display output. I'm sure this could be solved if I knew how to patch framebuffers properly.

Battery
----

Using a DSDT patch in the MaciASL patch repo named "bat - Razer Blade (2014)", and SMCBatteryManager, I was able to get battery status and precentage working. I incorporated the patched methods into an SSDT hotpatch (see SSDT-BATT). It also seems to last a really long time with proper power management.

Keyboard Illumination
----

The RGB keyboard (and logo illumination) cannot be easily controlled from macOS that I know of. The Razer Synapse software for Mac doesn't support this device, and various attempts to hotpatch the Razer kexts failed for me. However, I found a [project](https://github.com/kprinssu/osx-razer-blade) that I patched and was able to use to set a few patterns. The `rz_*` apps in the extra folder are some hardcoded examples that can set the keyboard lights to different colors, and enable the Razer logo illumination. Some day I might improve on that app to make it more user friendly.

Stuff in this repo
---

The `EFI` folder should be a minimal but complete EFI partition with Clover and all my kexts, config, and ACPI patches. On another Blade Stealth, you may be able to drop this in and get a working system, though that is not guaranteed. You should be able to take ideas from the configuration for your own build. If you use the config.plist, you will want to change your serial number, board serial, and SmUUID (can be done with [this](https://github.com/corpnewt/GenSMBIOS)).

The `SSDTs` folder has the uncompiled versions of the SSDTs that I had to create for various hotpatches.

The `extra` folder contains the command-line apps I compiled to be able to change the keyboard color. See "keyboard illumination" above.

The `images` folder has, among other things, the desktop I edited based on the [default Razer desktop](http://assets.razerzone.com/eedownloads/desktop-wallpapers/Wave-3200x1800.png) with an Apple logo. I also added the image I used to replace the system logo in About This Mac (using [this guide](https://github.com/Haru-tan/Hackintosh-Things/blob/master/AboutThisMacMojave.md)).

Conclusion?
---

Its a pretty good laptop, one might almost mistake it for a dark Macbook. I'm quite satasfied with it, though I would really like to get sleep working. If you want help you can probably find me on the Hackintosh discord: https://discord.gg/uvWNGKV - `@LGA#1151`. Also, if you figure out sleep or FB patching, please let me know!