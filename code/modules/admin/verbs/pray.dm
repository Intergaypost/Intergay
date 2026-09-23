/mob/verb/pray(msg as text)
	set category = "IC"
	set name = "Pray"

	sanitize_and_communicate(/decl/communication_channel/pray, src, msg)
	SSstatistics.add_field_details("admin_verb","PR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/proc/Centcomm_announce(var/msg, var/mob/Sender, var/iamessage)
	var/mob/intercepted = check_for_interception()
	msg = "<span class='notice'><b><font color=orange>[uppertext(GLOB.using_map.boss_short)]M[iamessage ? " IA" : ""][intercepted ? "(Intercepted by [intercepted])" : null]:</font>[key_name(Sender, 1)] (<a href='byond://?_src_=holder;adminplayeropts=\ref[Sender]'>PP</A>) (<a href='byond://?_src_=vars;Vars=\ref[Sender]'>VV</A>) (<a href='byond://?_src_=holder;subtlemessage=\ref[Sender]'>SM</A>) ([admin_jump_link(Sender)]) (<a href='byond://?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<a href='byond://?_src_=holder;BlueSpaceArtillery=\ref[Sender]'>BSA</A>) (<a href='byond://?_src_=holder;CentcommReply=\ref[Sender]'>RPLY</A>):</b> [msg]</span>"
	for(var/client/C in GLOB.admins)
		if(R_ADMIN & C.holder.rights)
			to_chat(C, msg)
			sound_to(C, 'sound/machines/signal.ogg')

/proc/Syndicate_announce(var/msg, var/mob/Sender)
	var/mob/intercepted = check_for_interception()
	msg = "<span class='notice'><b><font color=crimson>ILLEGAL[intercepted ? "(Intercepted by [intercepted])" : null]:</font>[key_name(Sender, 1)] (<a href='byond://?_src_=holder;adminplayeropts=\ref[Sender]'>PP</A>) (<a href='byond://?_src_=vars;Vars=\ref[Sender]'>VV</A>) (<a href='byond://?_src_=holder;subtlemessage=\ref[Sender]'>SM</A>) ([admin_jump_link(Sender)]) (<a href='byond://?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<a href='byond://?_src_=holder;BlueSpaceArtillery=\ref[Sender]'>BSA</A>) (<a href='byond://?_src_=holder;take_ic=\ref[Sender]'>TAKE</a>) (<a href='byond://?_src_=holder;SyndicateReply=\ref[Sender]'>RPLY</A>):</b> [msg]</span>"
	for(var/client/C in GLOB.admins)
		if(R_ADMIN & C.holder.rights)
			to_chat(C, msg)
			sound_to(C, 'sound/machines/signal.ogg')