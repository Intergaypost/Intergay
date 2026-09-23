//Please use mob or src (not usr) in these procs. This way they can be called in the same fashion as procs.
/client/verb/wiki()
	set name = "wiki"
	set desc = "Visit the wiki."
	set hidden = 1
	if( config.wikiurl )
		if(alert("This will open the wiki in your browser. Are you sure?",,"Yes","No")=="No")
			return
		src << link(config.wikiurl)
	else
		to_chat(src, "<span class='warning'>The wiki URL is not set in the server configuration.</span>")
	return

/client/verb/forum()
	set name = "forum"
	set desc = "Visit the forum."
	set hidden = 1
	if( config.forumurl )
		if(alert("This will open the forum in your browser. Are you sure?",,"Yes","No")=="No")
			return
		src << link(config.forumurl)
	else
		to_chat(src, "<span class='warning'>The forum URL is not set in the server configuration.</span>")
	return

/client/verb/discord()
	set name = "discord"
	set desc = "Join the discord."
	set hidden = 1
	if( config.discordurl )
		if(alert("This will invite you to the discord and will open in your browser. Are you sure?",,"Yes","No")=="No")
			return
		src << link( config.discordurl )
	else
		to_chat(src, "<span class='warning'>The Discord link is not set in the server configuration.</span>")
	return

#define RULES_FILE "config/rules.html"
/client/verb/rules()
	set name = "Rules"
	set desc = "Show Server Rules."
	set hidden = 1
	src << browse(file(RULES_FILE), "window=rules;size=480x320")
#undef RULES_FILE

#define LORE_FILE "config/lore.html"
/client/verb/lore_splash()
	set name = "Lore"
	set desc = "Links to the beginner Lore wiki."
	set hidden = 1
	show_browser(src, file(LORE_FILE), "window=lore;size=480x320")
#undef LORE_FILE

