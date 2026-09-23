/proc/rhtml_encode(var/msg)
	return html_encode(msg)

/proc/rhtml_decode(var/msg)
	return html_decode(msg)


//UPPER/LOWER TEXT
/proc/ruppertext(text as text)
	return uppertext(text)

/proc/rlowertext(text as text)
	return lowertext(text)


//RUS CONVERTERS
/proc/russian_to_cp1251(var/msg)
	return msg

/proc/russian_to_utf8(var/msg)
	return msg

/proc/utf8_to_cp1251(msg)
	return msg

/proc/cp1251_to_utf8(msg)
	return msg

/proc/edit_cp1251(msg)
	return msg

/proc/edit_utf8(msg)
	return msg

/proc/post_edit_cp1251(msg)
	return msg

/proc/post_edit_utf8(msg)
	return msg

//input

/proc/input_cp1251(var/mob/user = usr, var/message, var/title, var/default, var/type = "message")
	if(type == "text")
		return input(user, message, title, default) as text
	return input(user, message, title, default) as message

/proc/input_utf8(var/mob/user = usr, var/message, var/title, var/default, var/type = "message")
	if(type == "text")
		return input(user, message, title, default) as text
	return input(user, message, title, default) as message


var/global/list/rkeys = list(
	"й" = "q", "ц" = "w", "у" = "e", "к" = "r", "е" = "t", "н" = "y", "г" = "u", "ш" = "i", "щ" = "o", "з" = "p", "х" = "\[", "ъ" = "\]",
	"ф" = "a", "ы" = "s", "в" = "d", "а" = "f", "п" = "g", "р" = "h", "о" = "j", "л" = "k", "д" = "l", "ж" = ";", "э" = "'",
	"я" = "z", "ч" = "x", "с" = "c", "м" = "v", "и" = "b", "т" = "n", "ь" = "m", "б" = ",", "ю" = "."
)

//Transform keys from russian keyboard layout to eng analogues and lowertext it.
/proc/sanitize_key(t)
	t = lowertext(t)
	if(t in rkeys) return rkeys[t]
	return (t)

//TEXT MODS RUS
/proc/capitalize_cp1251(var/t as text)
	return capitalize(t)

/proc/intonation(text)
	if (copytext(text,-1) == "!")
		text = "<b>[text]</b>"
	return text

/proc/rustoutf(text)
	return text
