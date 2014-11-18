--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>
Copyright 2008-2011 Jo-Philipp Wich <xm@subsignal.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id: system.lua 9570 2012-12-25 02:45:42Z jow $
]]--

module("luci.controller.admin.system", package.seeall)

function index()
	entry({"admin", "system"}, alias("admin", "system", "info"), _("ids_system"), 90).index = true
	entry({"admin", "system", "info"}, template("admin_system/systeminfo"), _("ids_system_deviceInfo"), 1)
	
	entry({"admin", "system", "system"}, alias("admin", "system", "system","reboot"), _("ids_system_rebootReset"), 2)
	entry({"admin", "system", "system", "reboot"}, call("action_reboot"), _("ids_system_reboot"), 1)
	entry({"admin", "system", "system", "reset"}, call("action_reset"), _("ids_system_factoryReset"), 2)
	
	entry({"admin", "system", "upgrade"}, alias("admin", "system", "upgrade","localupgrade"), _("ids_update_upgrade"), 3)
	entry({"admin", "system", "upgrade","localupgrade"}, call("action_localupgrade"), _("ids_update_localUpgrade"), 1)
	entry({"admin","system", "upgradetool"}, call("action_localupgrade"),_(""),10) --for upgrade tool
	--entry({"admin", "system", "upgrade","onlinegrade"}, call("action_localupgrade"), _("Online Upgrade"), 2)
	--entry({"admin", "system", "upgrade","onlinegrade"}, template("admin_system/online_upgrade"), _("Online Upgrade"), 2)
	entry({"admin", "system", "upgrade","onlineupdate"}, template("admin_system/online_upgrade_fota"), _("ids_update_onlineUpgrade"), 2)
	entry({"admin", "system", "upgrade","tr069"}, template("admin_oem/tr069"), _("TR069"), 3)

	--[[if nixio.fs.access("/bin/opkg") then
		entry({"admin", "system", "packages"}, call("action_packages"), _("Upgrade"), 3)
		entry({"admin", "system", "packages", "ipkg"}, form("admin_system/ipkg"))
	end]]--

	entry({"admin", "system", "mgmt"}, alias("admin", "system", "mgmt","admin"), _("ids_system_deviceMamt"), 4)
	entry({"admin", "system", "mgmt","admin"}, template("admin_oem/admin"), _("ids_system_changePw"), 1)
	entry({"admin", "system", "mgmt","system_settings"}, template("admin_oem/system_settings"), _("ids_system_pageTitle"), 2)
	entry({"admin", "system", "mgmt","flashops"}, call("action_flashops"), _("ids_system_backupRestore"), 3)
	entry({"admin", "system", "mgmt","syslog"}, call("action_syslog"), _("ids_sysLogs_sysLogs"), 4)
	
		--[[entry({"admin", "system", "system"}, cbi("admin_system/system"), _("Device Info"), 1)
	entry({"admin", "system", "clock_status"}, call("action_clock_status"))]]--
	
	--[[entry({"admin", "system", "crontab"}, form("admin_system/crontab"), _("Scheduled Tasks"), 46)

	if nixio.fs.access("/etc/config/fstab") then
		entry({"admin", "system", "fstab"}, cbi("admin_system/fstab"), _("Mount Points"), 50)
		entry({"admin", "system", "fstab", "mount"}, cbi("admin_system/fstab/mount"), nil).leaf = true
		entry({"admin", "system", "fstab", "swap"},  cbi("admin_system/fstab/swap"),  nil).leaf = true
	end

	if nixio.fs.access("/sys/class/leds") then
		entry({"admin", "system", "leds"}, cbi("admin_system/leds"), _("<abbr title=\"Light Emitting Diode\">LED</abbr> Configuration"), 60)
	end

	
	entry({"admin", "system", "flashops", "backupfiles"}, form("admin_system/backupfiles"))

	entry({"admin", "system", "reboot"}, call("action_reboot"), _("Reboot"), 90)]]--
end

function action_syslog()
	local syslog = luci.sys.syslog()
	luci.template.render("admin_status/syslog", {syslog=syslog})
end

function action_clock_status()
	local set = tonumber(luci.http.formvalue("set"))
	if set ~= nil and set > 0 then
		local date = os.date("*t", set)
		if date then
			luci.sys.call("date -s '%04d-%02d-%02d %02d:%02d:%02d'" %{
				date.year, date.month, date.day, date.hour, date.min, date.sec
			})
		end
	end

	luci.http.prepare_content("application/json")
	luci.http.write_json({ timestring = os.date("%c") })
end

function action_packages()
	local ipkg = require("luci.model.ipkg")
	local submit = luci.http.formvalue("submit")
	local changes = false
	local install = { }
	local remove  = { }
	local stdout  = { "" }
	local stderr  = { "" }
	local out, err

	-- Display
	local display = luci.http.formvalue("display") or "installed"

	-- Letter
	local letter = string.byte(luci.http.formvalue("letter") or "A", 1)
	letter = (letter == 35 or (letter >= 65 and letter <= 90)) and letter or 65

	-- Search query
	local query = luci.http.formvalue("query")
	query = (query ~= '') and query or nil


	-- Packets to be installed
	local ninst = submit and luci.http.formvalue("install")
	local uinst = nil

	-- Install from URL
	local url = luci.http.formvalue("url")
	if url and url ~= '' and submit then
		uinst = url
	end

	-- Do install
	if ninst then
		install[ninst], out, err = ipkg.install(ninst)
		stdout[#stdout+1] = out
		stderr[#stderr+1] = err
		changes = true
	end

	if uinst then
		local pkg
		for pkg in luci.util.imatch(uinst) do
			install[uinst], out, err = ipkg.install(pkg)
			stdout[#stdout+1] = out
			stderr[#stderr+1] = err
			changes = true
		end
	end

	-- Remove packets
	local rem = submit and luci.http.formvalue("remove")
	if rem then
		remove[rem], out, err = ipkg.remove(rem)
		stdout[#stdout+1] = out
		stderr[#stderr+1] = err
		changes = true
	end


	-- Update all packets
	local update = luci.http.formvalue("update")
	if update then
		update, out, err = ipkg.update()
		stdout[#stdout+1] = out
		stderr[#stderr+1] = err
	end


	-- Upgrade all packets
	local upgrade = luci.http.formvalue("upgrade")
	if upgrade then
		upgrade, out, err = ipkg.upgrade()
		stdout[#stdout+1] = out
		stderr[#stderr+1] = err
	end


	-- List state
	local no_lists = true
	local old_lists = false
	local tmp = nixio.fs.dir("/var/opkg-lists/")
	if tmp then
		for tmp in tmp do
			no_lists = false
			tmp = nixio.fs.stat("/var/opkg-lists/"..tmp)
			if tmp and tmp.mtime < (os.time() - (24 * 60 * 60)) then
				old_lists = true
				break
			end
		end
	end


	luci.template.render("admin_system/packages", {
		display   = display,
		letter    = letter,
		query     = query,
		install   = install,
		remove    = remove,
		update    = update,
		upgrade   = upgrade,
		no_lists  = no_lists,
		old_lists = old_lists,
		stdout    = table.concat(stdout, ""),
		stderr    = table.concat(stderr, "")
	})

	-- Remove index cache
	if changes then
		nixio.fs.unlink("/tmp/luci-indexcache")
	end
end

--[[function action_flashops()
	local sys = require "luci.sys"
	local fs  = require "luci.fs"

	local upgrade_avail = nixio.fs.access("/lib/upgrade/platform.sh")


	local restore_cmd = "tar -xzC/ >/dev/null 2>&1"
	local backup_cmd  = "sysupgrade --create-backup - 2>/dev/null"
	local image_tmp   = "/tmp/firmware.img"

	local function image_supported()
		-- XXX: yay...
		return ( 0 == os.execute(
			". /lib/functions.sh; " ..
			"include /lib/upgrade; " ..
			"platform_check_image %q >/dev/null"
				% image_tmp
		) )
	end

	local function image_checksum()
		return (luci.sys.exec("md5sum %q" % image_tmp):match("^([^%s]+)"))
	end

	local function storage_size()
		local size = 0
		if nixio.fs.access("/proc/mtd") then
			for l in io.lines("/proc/mtd") do
				local d, s, e, n = l:match('^([^%s]+)%s+([^%s]+)%s+([^%s]+)%s+"([^%s]+)"')
				if n == "linux" or n == "firmware" then
					size = tonumber(s, 16)
					break
				end
			end
		elseif nixio.fs.access("/proc/partitions") then
			for l in io.lines("/proc/partitions") do
				local x, y, b, n = l:match('^%s*(%d+)%s+(%d+)%s+([^%s]+)%s+([^%s]+)')
				if b and n and not n:match('[0-9]') then
					size = tonumber(b) * 1024
					break
				end
			end
		end
		return size
	end


	local fp
	luci.http.setfilehandler(
		function(meta, chunk, eof)
			if not fp then
				if meta and meta.name == "image" then
					fp = io.open(image_tmp, "w")
				else
					fp = io.popen(restore_cmd, "w")
				end
			end
			if chunk then
				fp:write(chunk)
			end
			if eof then
				fp:close()
			end
		end
	)

	if luci.http.formvalue("backup") then
		--
		-- Assemble file list, generate backup
		--
		local reader = ltn12_popen(backup_cmd)
		luci.http.header('Content-Disposition', 'attachment; filename="backup-%s-%s.tar.gz"' % {
			luci.sys.hostname(), os.date("%Y-%m-%d")})
		luci.http.prepare_content("application/x-targz")
		luci.ltn12.pump.all(reader, luci.http.write)
	elseif luci.http.formvalue("restore") then
		--
		-- Unpack received .tar.gz
		--
		local upload = luci.http.formvalue("archive")
		if upload and #upload > 0 then
			luci.template.render("admin_system/applyreboot")
			luci.sys.reboot()
		end
	elseif luci.http.formvalue("image") or luci.http.formvalue("step") then
		--
		-- Initiate firmware flash
		--
		local step = tonumber(luci.http.formvalue("step") or 1)
		if step == 1 then
			if image_supported() then
				local checksum = image_checksum()
				local md5 = luci.http.formvalue("MD5") or ""
				if md5 == checksum or md5 == "" then
					local keep = (luci.http.formvalue("keep") == "on") and "" or "-n"
					luci.template.render("admin_system/applyreboot", {
					title = luci.i18n.translate("Flashing..."),
					msg   = luci.i18n.translate("The system is flashing now.<br /> DO NOT POWER OFF THE DEVICE!<br /> Wait a few minutes until you try to reconnect. It might be necessary to renew the address of your computer to reach the device again, depending on your settings."),
					addr  = (#keep > 0) and "192.168.1.1" or nil
			})
			fork_exec("killall dropbear uhttpd; sleep 1; /sbin/sysupgrade %s %q" %{ keep, image_tmp })
			end
			else
				nixio.fs.unlink(image_tmp)
				luci.template.render("admin_system/flashops", {
					reset_avail   = reset_avail,
					upgrade_avail = upgrade_avail,
					image_invalid = true
				})
			end
		end
	elseif reset_avail and luci.http.formvalue("reset") then
		--
		-- Reset system
		--
		luci.template.render("admin_system/applyreboot", {
			title = luci.i18n.translate("Erasing..."),
			msg   = luci.i18n.translate("The system is erasing the configuration partition now and will reboot itself when finished."),
			addr  = "192.168.1.1"
		})
		fork_exec("killall dropbear uhttpd; sleep 1; mtd -r erase rootfs_data")
	else
		--
		-- Overview
		--
		luci.template.render("admin_system/flashops", {
			reset_avail   = reset_avail,
			upgrade_avail = upgrade_avail
		})
	end
end ]]--

--modify by houailing:2014-04-12,this only for backup and restore
function action_flashops()
	local sys = require "luci.sys"
	local fs  = require "luci.fs"

	local restore_cmd = "tar -xzC/ >/dev/null 2>&1"
	local backup_cmd  = "sysupgrade --create-backup - 2>/dev/null"
	
	local tmp_store = "/tmp/backup_file.tar.gz"

	local fp
	local upfileflage = luci.http.setfilehandler(
	
		--[[function(meta, chunk, eof)
			 if not fp then
					fp = io.popen(restore_cmd, "w")
			end
			if chunk then
				fp:write(chunk)
			end
			if eof then
				fp:close()
			end
		end]]--
	-- modify by houailing 2014-08-27
		
		function(meta, chunk, eof)
			if not fp then
				fp = io.open(tmp_store, "w")
			end
			if chunk then
				fp:write(chunk)
			end
			if eof then
				fp:close()
			end
		end
	)

	if luci.http.formvalue("backup") then
		--
		-- Assemble file list, generate backup
		--
		local reader = ltn12_popen(backup_cmd)
		luci.http.header('Content-Disposition', 'attachment; filename="backup-%s-%s.tar.gz"' % {
			luci.sys.hostname(), os.date("%Y-%m-%d")})
		luci.http.prepare_content("application/x-targz")
		luci.ltn12.pump.all(reader, luci.http.write)
	
	elseif luci.http.formvalue("restore") then
		--
		-- Unpack received .tar.gz
		--
		local upload = luci.http.formvalue("archive")
		
		if upload and #upload > 0 then
								
			--if string.len(upload)>6  and "tar.gz" == string.sub(upload,string.len(upload)-5,-1) then
		   os.execute(
			". /lib/functions.sh; " ..
			"include /lib/upgrade; " ..
			"restore_config_check backup_file.tar.gz >/dev/null"
		    )
			
			if fs.isfile("/tmp/restore_check") then
			    
				luci.template.render("admin_system/applyreboot")
			    luci.sys.reboot()	
			
			else
			luci.template.render("admin_system/oem_flashops", { error_upload = true
		      })
			end	
		else
		   luci.template.render("admin_system/oem_flashops", { error_upload = true		
		})
		end
	else
		--
		-- Overview
		--
		luci.template.render("admin_system/oem_flashops", {
		
		})
	end
end

function action_passwd()
	local p1 = luci.http.formvalue("pwd1")
	local p2 = luci.http.formvalue("pwd2")
	local stat = nil

	if p1 or p2 then
		if p1 == p2 then
			stat = luci.sys.user.setpasswd("root", p1)
		else
			stat = 10
		end
	end

	luci.template.render("admin_system/passwd", {stat=stat})
end

function action_reboot()
	local reboot = luci.http.formvalue("reboot")
	
	if reboot then
		luci.template.render("admin_system/applyreboot", {
			title = luci.i18n.translate("Reboot..."),
			addr  = "192.168.1.1"
		}) 
		
			luci.util.exec("echo 1 > /proc/gpio36/4g_pwr")
			luci.util.exec("echo 0 > /proc/gpio36/4g_pwr")

			luci.sys.reboot()

	else
	    luci.template.render("admin_system/reboot", {reboot=reboot})
	end
end
--add by houailing:2014-04-12
function action_reset()	
	local sys = require "luci.sys"
	local fs  = require "luci.fs"
	
	local reset_avail   = os.execute([[grep '"rootfs_data"' /proc/mtd >/dev/null 2>&1]]) == 0
	local reset = luci.http.formvalue("reset")
	
	if reset_avail and reset then
		--
		-- Reset system
		--
		luci.template.render("admin_system/applyreset", {
			title = luci.i18n.translate("Erasing..."),
			msg   = luci.i18n.translate("The system is erasing the configuration partition now and will reboot itself when finished."),
			addr  = "192.168.1.1"
		})
		fork_exec("killall dropbear uhttpd; sleep 1; mtd -r erase rootfs_data")
	else
		--
		-- Overview
		--
		luci.template.render("admin_system/reset", {
			reset_avail   = reset_avail,
		})
	end

end

--add by houailing:2014-04-14
function action_localupgrade()
	local sys = require "luci.sys"
	local fs  = require "luci.fs"

	local upgrade_avail = nixio.fs.access("/lib/upgrade/platform.sh")
	local image_tmp   = "/tmp/firmware.img"

	local function image_supported()
		-- XXX: yay...
		return ( 0 == os.execute(
			". /lib/functions.sh; " ..
			"include /lib/upgrade; " ..
			"platform_check_image %q >/dev/null"
				% image_tmp
		) )
	end

	local function image_checksum()
		return (luci.sys.exec("md5sum %q" % image_tmp):match("^([^%s]+)"))
	end

	local function storage_size()
		local size = 0
		if nixio.fs.access("/proc/mtd") then
			for l in io.lines("/proc/mtd") do
				local d, s, e, n = l:match('^([^%s]+)%s+([^%s]+)%s+([^%s]+)%s+"([^%s]+)"')
				if n == "linux" or n == "firmware" then
					size = tonumber(s, 16)
					break
				end
			end
		elseif nixio.fs.access("/proc/partitions") then
			for l in io.lines("/proc/partitions") do
				local x, y, b, n = l:match('^%s*(%d+)%s+(%d+)%s+([^%s]+)%s+([^%s]+)')
				if b and n and not n:match('[0-9]') then
					size = tonumber(b) * 1024
					break
				end
			end
		end
		return size
	end


	local fp
	luci.http.setfilehandler(
		function(meta, chunk, eof)
			if not fp then
				fp = io.open(image_tmp, "w")
			end
			if chunk then
				fp:write(chunk)
			end
			if eof then
				fp:close()
			end
		end
	)


	if luci.http.formvalue("image") or luci.http.formvalue("step") then
		--
		-- Initiate firmware flash
		--
		local step = tonumber(luci.http.formvalue("step") or 1)
		if step == 1 then
			if image_supported() then
				local checksum = image_checksum()
				local md5 = luci.http.formvalue("MD5") or ""
				if md5 == checksum or md5 == "" then
					local keep = (luci.http.formvalue("keep") == "on") and "" or "-n"
					luci.template.render("admin_system/applyreboot", {
					title = luci.i18n.translate("Flashing..."),
					msg   = luci.i18n.translate("The system is flashing now.<br /> DO NOT POWER OFF THE DEVICE!<br /> Wait a few minutes until you try to reconnect. It might be necessary to renew the address of your computer to reach the device again, depending on your settings."),
					addr  = (#keep > 0) and "192.168.1.1" or nil
			})
			fork_exec("killall dropbear uhttpd; sleep 1; /sbin/sysupgrade %s %q" %{ keep, image_tmp })
			end
			else
				nixio.fs.unlink(image_tmp)
				luci.template.render("admin_system/flashimage", {
					upgrade_avail = upgrade_avail,
					image_invalid = true
				})
			end
		end
	else
		--
		-- Overview
		--
		luci.template.render("admin_system/flashimage", {
			upgrade_avail = upgrade_avail
		})
	end
end

function fork_exec(command)
	local pid = nixio.fork()
	if pid > 0 then
		return
	elseif pid == 0 then
		-- change to root dir
		nixio.chdir("/")

		-- patch stdin, out, err to /dev/null
		local null = nixio.open("/dev/null", "w+")
		if null then
			nixio.dup(null, nixio.stderr)
			nixio.dup(null, nixio.stdout)
			nixio.dup(null, nixio.stdin)
			if null:fileno() > 2 then
				null:close()
			end
		end

		-- replace with target command
		nixio.exec("/bin/sh", "-c", command)
	end
end

function ltn12_popen(command)

	local fdi, fdo = nixio.pipe()
	local pid = nixio.fork()

	if pid > 0 then
		fdo:close()
		local close
		return function()
			local buffer = fdi:read(2048)
			local wpid, stat = nixio.waitpid(pid, "nohang")
			if not close and wpid and stat == "exited" then
				close = true
			end

			if buffer and #buffer > 0 then
				return buffer
			elseif close then
				fdi:close()
				return nil
			end
		end
	elseif pid == 0 then
		nixio.dup(fdo, nixio.stdout)
		fdi:close()
		fdo:close()
		nixio.exec("/bin/sh", "-c", command)
	end
end
