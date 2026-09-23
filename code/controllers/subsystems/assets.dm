SUBSYSTEM_DEF(assets)
	name = "Assets"
	init_order = INIT_ORDER_ASSETS
	flags = SS_NO_FIRE
	var/list/cache = list()
	var/list/preload = list()

/datum/controller/subsystem/assets/Initialize(timeofday)
	for(var/type in typesof(/datum/asset) - list(/datum/asset, /datum/asset/simple))
		var/datum/asset/A = new type()
		A.register()

	preload = cache.Copy() //don't preload assets generated during the round

	for(var/client/C in GLOB.clients)
		addtimer(CALLBACK(src, PROC_REF(getFilesSlow), C, preload, FALSE), 10)
	..()

/datum/controller/subsystem/assets/Recover()
	cache = SSassets.cache
	preload = SSassets.preload

/datum/controller/subsystem/assets/proc/register_asset(asset_name, asset)
	cache[asset_name] = asset

/datum/controller/subsystem/assets/proc/send_asset(client/client, asset_name, verify = TRUE, check_cache = TRUE)
	if(!istype(client))
		if(ismob(client))
			var/mob/M = client
			if(M.client)
				client = M.client
			else
				return 0
		else
			return 0

	if(check_cache && (client.cache.Find(asset_name) || client.sending.Find(asset_name)))
		return 0

	client << browse_rsc(cache[asset_name], asset_name)
	if(!verify) // Can't access the asset cache browser, rip.
		client.cache += asset_name
		return 1

	client.sending |= asset_name
	var/job = ++client.last_asset_job

	client << browse({"
	<script>
		window.location.href="?asset_cache_confirm_arrival=[job]"
	</script>
	"}, "window=asset_cache_browser")

	var/t = 0
	var/timeout_time = (ASSET_CACHE_SEND_TIMEOUT * client.sending.len) + ASSET_CACHE_SEND_TIMEOUT
	while(client && !client.completed_asset_jobs.Find(job) && t < timeout_time) // Reception is handled in Topic()
		sleep(1) // Lock up the caller until this is received.
		t++

	if(client)
		client.sending -= asset_name
		client.cache |= asset_name
		client.completed_asset_jobs -= job

	return 1

/datum/controller/subsystem/assets/proc/send_asset_list(client/client, list/asset_list, verify = TRUE)
	if(!istype(client))
		if(ismob(client))
			var/mob/M = client
			if(M.client)
				client = M.client
			else
				return 0
		else
			return 0

	var/list/unreceived = asset_list - (client.cache + client.sending)
	if(!unreceived || !unreceived.len)
		return 0
	for(var/asset in unreceived)
		if(asset in cache)
			client << browse_rsc(cache[asset], asset)

	if(!verify) // Can't access the asset cache browser, rip.
		client.cache += unreceived
		return 1

	client.sending |= unreceived
	var/job = ++client.last_asset_job

	client << browse({"
	<script>
		window.location.href="?asset_cache_confirm_arrival=[job]"
	</script>
	"}, "window=asset_cache_browser")

	var/t = 0
	var/timeout_time = ASSET_CACHE_SEND_TIMEOUT * client.sending.len
	while(client && !client.completed_asset_jobs.Find(job) && t < timeout_time) // Reception is handled in Topic()
		sleep(1) // Lock up the caller until this is received.
		t++

	if(client)
		client.sending -= unreceived
		client.cache |= unreceived
		client.completed_asset_jobs -= job

	return 1

/datum/controller/subsystem/assets/proc/getFilesSlow(client/client, list/files, register_asset = TRUE)
	var/concurrent_tracker = 1
	for(var/file in files)
		if(!client)
			break
		if(register_asset)
			register_asset(file, files[file])
		if(concurrent_tracker >= ASSET_CACHE_PRELOAD_CONCURRENT)
			concurrent_tracker = 1
			send_asset(client, file)
		else
			concurrent_tracker++
			send_asset(client, file, verify = FALSE)
		sleep(0) //queuing calls like this too quickly can cause issues in some client versions
