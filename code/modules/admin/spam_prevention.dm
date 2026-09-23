/**
 * Prevents spamming KeyDown & other actions.
 *
 * Arguments:
 * * C - client
 * * admin_message - message sent to admins
 * * client_message - message sent to the client
 */
/proc/user_acted(client/C, admin_message = TRUE, client_message = TRUE)
	if(!C)
		return FALSE

	var/current_time = world.time
	if(C.acted_time != current_time)
		C.acted_time = current_time
		C.acted_counter = 0

	var/max_acted = 10
	if(C.fps)
		max_acted = C.fps / 2

	if(++C.acted_counter > max_acted)
		if(C.acted_counter == max_acted + 1)
			if(admin_message)
				message_admins("Client [key_name_admin(C)] is spamming actions and was throttled! (Limit: [max_acted]/tick)")
			if(client_message)
				to_chat(C, "<span class='warning'>You are sending too many actions per tick! Please slow down.</span>")
		return FALSE

	return TRUE
