/*
Asset cache quick users guide:

Make a datum at the bottom of this file with your assets for your thing.
The simple subsystem will most like be of use for most cases.
Then call get_asset_datum() with the type of the datum you created and store the return
Then call .send(client) on that stored return value.

You can set verify to TRUE if you want send() to sleep until the client has the assets.
*/

/client
	var/list/cache = list() // List of all assets sent to this client by the asset cache.
	var/list/completed_asset_jobs = list() // List of all completed jobs, awaiting acknowledgement.
	var/list/sending = list()
	var/last_asset_job = 0 // Last job done.

// Global wrapper procs delegating to SSassets subsystem
/proc/send_asset(var/client/client, var/asset_name, var/verify = TRUE, var/check_cache = TRUE)
	return SSassets.send_asset(client, asset_name, verify, check_cache)

/proc/send_asset_list(var/client/client, var/list/asset_list, var/verify = TRUE)
	return SSassets.send_asset_list(client, asset_list, verify)

/proc/getFilesSlow(var/client/client, var/list/files, var/register_asset = TRUE)
	return SSassets.getFilesSlow(client, files, register_asset)

/proc/register_asset(var/asset_name, var/asset)
	return SSassets.register_asset(asset_name, asset)

// will return filename for cached atom icon or null if not cached
// can accept atom objects or types
/proc/getAtomCacheFilename(var/atom/A)
	if(!A || (!istype(A) && !ispath(A)))
		return
	var/filename = "[ispath(A) ? A : A.type].png"
	filename = sanitizeFileName(filename)

//Generated names do not include file extention.
//Used mainly for code that deals with assets in a generic way
//The same asset will always lead to the same asset name
/proc/generate_asset_name(file)
	return "asset.[md5(fcopy_rsc(file))]"


//These datums are used to populate the asset cache, the proc "register()" does this.

//all of our asset datums, used for referring to these later
/var/global/list/asset_datums = list()

//get a assetdatum or make a new one
/proc/get_asset_datum(var/type)
	if (!(type in asset_datums))
		return new type()
	return asset_datums[type]

/datum/asset
	var/list/common = list()

/datum/asset/New()
	asset_datums[type] = src
	register()

/datum/asset/proc/register()
	return

/datum/asset/proc/send(client)
	return

/datum/asset/proc/register_directory(dir_path, is_common = TRUE)
	var/list/filenames = flist(dir_path)
	for(var/filename in filenames)
		if(copytext(filename, length(filename)) != "/") // Ignore directories.
			var/file_path = dir_path + filename
			if(fexists(file_path))
				var/rsc = fcopy_rsc(file_path)
				register_asset(filename, rsc)
				if(is_common)
					common[filename] = rsc

//If you don't need anything complicated.
/datum/asset/simple
	var/assets = list()
	var/verify = FALSE

/datum/asset/simple/register()
	for(var/asset_name in assets)
		register_asset(asset_name, assets[asset_name])

/datum/asset/simple/send(client)
	send_asset_list(client,assets,verify)

// For registering or sending multiple others at once
/datum/asset/group
	var/list/children

/datum/asset/group/register()
	for(var/type in children)
		get_asset_datum(type)

/datum/asset/group/send(client/C)
	for(var/type in children)
		var/datum/asset/A = get_asset_datum(type)
		A.send(C)

//DEFINITIONS FOR ASSET DATUMS START HERE.

/datum/asset/simple/pda
	assets = list(
		"pda_atmos.png"			= 'icons/pda_icons/pda_atmos.png',
		"pda_back.png"			= 'icons/pda_icons/pda_back.png',
		"pda_bell.png"			= 'icons/pda_icons/pda_bell.png',
		"pda_blank.png"			= 'icons/pda_icons/pda_blank.png',
		"pda_boom.png"			= 'icons/pda_icons/pda_boom.png',
		"pda_bucket.png"		= 'icons/pda_icons/pda_bucket.png',
		"pda_chatroom.png"      = 'icons/pda_icons/pda_chatroom.png',
		"pda_crate.png"         = 'icons/pda_icons/pda_crate.png',
		"pda_cuffs.png"         = 'icons/pda_icons/pda_cuffs.png',
		"pda_eject.png"			= 'icons/pda_icons/pda_eject.png',
		"pda_exit.png"			= 'icons/pda_icons/pda_exit.png',
		"pda_honk.png"			= 'icons/pda_icons/pda_honk.png',
		"pda_locked.png"        = 'icons/pda_icons/pda_locked.png',
		"pda_mail.png"			= 'icons/pda_icons/pda_mail.png',
		"pda_medical.png"		= 'icons/pda_icons/pda_medical.png',
		"pda_menu.png"			= 'icons/pda_icons/pda_menu.png',
		"pda_mule.png"			= 'icons/pda_icons/pda_mule.png',
		"pda_notes.png"			= 'icons/pda_icons/pda_notes.png',
		"pda_power.png"			= 'icons/pda_icons/pda_power.png',
		"pda_rdoor.png"			= 'icons/pda_icons/pda_rdoor.png',
		"pda_reagent.png"		= 'icons/pda_icons/pda_reagent.png',
		"pda_refresh.png"		= 'icons/pda_icons/pda_refresh.png',
		"pda_scanner.png"		= 'icons/pda_icons/pda_scanner.png',
		"pda_signaler.png"		= 'icons/pda_icons/pda_signaler.png',
		"pda_status.png"		= 'icons/pda_icons/pda_status.png'
	)

/datum/asset/simple/tgui
	assets = list(
		"tgui.css"	= 'tgui/assets/tgui.css',
		"tgui.js"	= 'tgui/assets/tgui.js'
	)

/datum/asset/simple/craft/register()
	for(var/name in SScraft.categories)
		for(var/datum/crafting_recipe/CR in SScraft.categories[name])
			if(CR.result && CR.result.len)
				var/filename = sanitizeFileName("[CR.result[1]].png")
				var/icon/I = getFlatTypeIcon(CR.result[1])
				register_asset(filename, I)
				assets[filename] = I

/datum/asset/nanoui
	var/list/common_dirs = list(
		"nano/css/",
		"nano/images/",
		"nano/images/status_icons/",
		"nano/images/modular_computers/",
		"nano/js/"
	)
	var/list/uncommon_dirs = list(
		"nano/templates/",
		"news_articles/images/"
	)

/datum/asset/nanoui/register()
	for (var/path in common_dirs)
		register_directory(path, is_common = TRUE)

	for (var/path in uncommon_dirs)
		var/list/filenames = flist(path)
		for(var/filename in filenames)
			if(copytext(filename, length(filename)) != "/") // Ignore directories.
				var/file_path = path + filename
				if(fexists(file_path))
					var/rsc = fcopy_rsc(file_path)
					register_asset(filename, rsc)
					if(findtext(filename, "layout_") == 1)
						common[filename] = rsc

	var/list/mapnames = list()
	for(var/z in GLOB.using_map.map_levels)
		mapnames += map_image_file_name(z)

	var/list/filenames = flist(MAP_IMAGE_PATH)
	for(var/filename in filenames)
		if(copytext(filename, length(filename)) != "/") // Ignore directories.
			var/file_path = MAP_IMAGE_PATH + filename
			if((filename in mapnames) && fexists(file_path))
				common[filename] = fcopy_rsc(file_path)
				register_asset(filename, common[filename])

/datum/asset/nanoui/send(client, uncommon)
	if(!islist(uncommon))
		uncommon = list(uncommon)

	send_asset_list(client, uncommon, FALSE)
	send_asset_list(client, common, TRUE)

/datum/asset/goonchat
	var/list/common_dirs = list(
		"code/modules/html_interface/js/",
		"code/modules/goonchat/browserassets/js/scrollbar/",
		"code/modules/goonchat/browserassets/js/",
		"code/modules/goonchat/browserassets/css/"
	)

/datum/asset/goonchat/register()
	for (var/path in common_dirs)
		register_directory(path, is_common = TRUE)

/datum/asset/goonchat/send(client)
	send_asset_list(client, common, TRUE)

/datum/asset/pig
	var/list/common_dirs = list(
		"code/porco/html/"
	)

/datum/asset/pig/register()
	for (var/path in common_dirs)
		register_directory(path, is_common = TRUE)

/datum/asset/pig/send(client)
	send_asset_list(client, common, TRUE)

/datum/asset/group/goonchat
	children = list(
		/datum/asset/simple/jquery,
		/datum/asset/simple/goonchat,
		/datum/asset/simple/fontawesome
	)

/datum/asset/simple/jquery
	verify = FALSE
	assets = list(
		"jquery.min.js"            = 'code/modules/goonchat/browserassets/js/jquery.min.js',
		"jquery.jscrollpane.min.js"= 'code/modules/goonchat/browserassets/js/scrollbar/jquery.jscrollpane.min.js',
		"jquery.jscrollpane.css"   = 'code/modules/goonchat/browserassets/js/scrollbar/jquery.jscrollpane.css',
	)

/datum/asset/simple/goonchat
	verify = TRUE
	assets = list(
		"json2.min.js"             = 'code/modules/goonchat/browserassets/js/json2.min.js',
		"browserOutput.js"         = 'code/modules/goonchat/browserassets/js/browserOutput.js',
		"browserOutput.css"	       = 'code/modules/goonchat/browserassets/css/browserOutput.css',
		"chatbg.png"			   = 'icons/misc/chatbg.png',
		"tchatshadow.png"		   = 'icons/misc/tchatshadow.png',
		"chatscrollbar-bg.png"			   = 'icons/misc/chatscrollbar-bg.png',
		"chatscrollbar-scrolldown.png"		   = 'icons/misc/chatscrollbar-scrolldown.png',
		"chatscrollbar-scrollup.png"			   = 'icons/misc/chatscrollbar-scrollup.png',
		"chatscroller-b.png"		   = 'icons/misc/chatscroller-b.png',
		"chatscroller-m.png"		   = 'icons/misc/chatscroller-m.png',
		"chatscroller-t.png"		   = 'icons/misc/chatscroller-t.png',
		"PTsans.ttf"			   = 'fonts/PTsans.ttf',
	)

/datum/asset/simple/fontawesome
	verify = FALSE
	assets = list(
		"fa-regular-400.eot"  = 'html/font-awesome/webfonts/fa-regular-400.eot',
		"fa-regular-400.woff" = 'html/font-awesome/webfonts/fa-regular-400.woff',
		"fa-solid-900.eot"    = 'html/font-awesome/webfonts/fa-solid-900.eot',
		"fa-solid-900.woff"   = 'html/font-awesome/webfonts/fa-solid-900.woff',
		"font-awesome.css"    = 'html/font-awesome/css/all.min.css',
		"v4shim.css"          = 'html/font-awesome/css/v4-shims.min.css'
	)

/*
	Asset cache
*/

/decl/asset_cache
	var/list/cache = list()

/decl/asset_cache/proc/load()
	for(var/type in typesof(/datum/asset) - list(/datum/asset, /datum/asset/simple))
		var/datum/asset/A = new type()
		A.register()

	for(var/client/C in GLOB.clients) // This is also called in client/New, but as we haven't initialized the cache until now, and it's possible the client is already connected, we risk doing it twice.
		// Doing this to a client too soon after they've connected can cause issues, also the proc we call sleeps.
		spawn(10)
			getFilesSlow(C, cache, FALSE)
